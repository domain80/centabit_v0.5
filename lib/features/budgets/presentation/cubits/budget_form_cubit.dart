import 'dart:async';

import 'package:centabit/data/models/allocation_model.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/data/repositories/allocation_repository.dart';
import 'package:centabit/data/repositories/budget_repository.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_form_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uuid/uuid.dart';

/// Cubit for budget form (create/edit/delete) with allocation management.
///
/// Manages:
/// - Budget form fields (name, amount, startDate, endDate)
/// - Allocation list (add/edit/delete inline)
/// - Form validation (name required, dates valid, allocations valid)
/// - Atomic create/update operations (budget + allocations)
/// - Category data for allocation dropdowns
///
/// **Architecture Pattern**:
/// - FormBuilder for budget fields
/// - Separate allocation state (List<AllocationEditModel>)
/// - Atomic operations with rollback on failure
/// - Reactive category updates from repository
///
/// **Data Flow - Create**:
/// ```
/// User fills form → validates → createBudget()
///   ↓
/// Create budget model → repository.createBudget()
///   ↓ (success)
/// For each allocation → repository.createAllocation()
///   ↓ (all success)
/// Emit success → close modal
///   ↓ (if any fail)
/// Rollback: delete budget → emit error → keep form open
/// ```
///
/// **Usage**:
/// ```dart
/// BlocProvider(
///   create: (_) => getIt<BudgetFormCubit>(),
///   child: BudgetFormModal(initialBudget: null), // null = create
/// )
/// ```
class BudgetFormCubit extends Cubit<BudgetFormState> {
  final BudgetRepository _budgetRepository;
  final AllocationRepository _allocationRepository;
  final CategoryRepository _categoryRepository;

  final GlobalKey<FormBuilderState> formKey;

  StreamSubscription? _categorySubscription;
  List<CategoryModel> _categories = [];

  // Allocation state (not in FormBuilder)
  List<AllocationEditModel> _allocations = [];

  // Counter to force unique states (needed for UI reactivity)
  int _rebuildCounter = 0;

  BudgetFormCubit(
    this._budgetRepository,
    this._allocationRepository,
    this._categoryRepository,
  )   : formKey = GlobalKey<FormBuilderState>(),
        super(const BudgetFormState.initial()) {
    _subscribeToCategories();
  }

  // Public getters for UI
  List<CategoryModel> get categories => _categories;
  List<AllocationEditModel> get allocations => _allocations;

  /// Subscribe to category repository stream for dropdown data.
  ///
  /// Immediately initializes with current categories, then listens for updates.
  void _subscribeToCategories() {
    _categories = _categoryRepository.categories;

    _categorySubscription =
        _categoryRepository.categoriesStream.listen((categories) {
      _categories = categories;
      // Re-emit state to trigger dropdown rebuild
      _rebuildCounter++;
      emit(BudgetFormState.initial(rebuildCounter: _rebuildCounter));
    });
  }

  /// Initializes allocation state when editing an existing budget.
  ///
  /// Called by form modal when initialBudget is provided.
  ///
  /// **Parameters**:
  /// - `budgetId`: ID of budget being edited
  ///
  /// **Usage**:
  /// ```dart
  /// if (initialBudget != null) {
  ///   cubit.loadExistingAllocations(initialBudget.id);
  /// }
  /// ```
  Future<void> loadExistingAllocations(String budgetId) async {
    final existingAllocations =
        _allocationRepository.getAllocationsForBudget(budgetId);

    _allocations = existingAllocations
        .map((alloc) => AllocationEditModel(
              id: alloc.id,
              categoryId: alloc.categoryId,
              amount: alloc.amount,
              isNew: false,
            ))
        .toList();

    // Re-emit state to trigger UI rebuild
    _rebuildCounter++;
    emit(BudgetFormState.initial(rebuildCounter: _rebuildCounter));
  }

  /// Adds a new allocation to the list.
  ///
  /// **Parameters**:
  /// - `categoryId`: Category to allocate funds to
  /// - `amount`: Amount to allocate
  ///
  /// **Validation**: Caller should ensure categoryId is not already allocated.
  void addAllocation(String categoryId, double amount) {
    print('✨ BudgetFormCubit.addAllocation called');
    print('   Before: ${_allocations.length} allocations');
    print('   Adding: category=$categoryId, amount=$amount');

    final newAllocation = AllocationEditModel(
      id: const Uuid().v4(), // Temp ID for new allocation
      categoryId: categoryId,
      amount: amount,
      isNew: true,
    );

    _allocations = [..._allocations, newAllocation];

    print('   After: ${_allocations.length} allocations');
    print('   Allocations: ${_allocations.map((a) => a.categoryId).toList()}');

    // Re-emit state to trigger UI rebuild
    _rebuildCounter++;
    emit(BudgetFormState.initial(rebuildCounter: _rebuildCounter));
    print('   State emitted with counter: $_rebuildCounter');
  }

  /// Updates an existing allocation in the list.
  ///
  /// **Parameters**:
  /// - `id`: Allocation ID to update
  /// - `categoryId`: New category ID
  /// - `amount`: New amount
  void updateAllocation(String id, String categoryId, double amount) {
    _allocations = _allocations.map((alloc) {
      if (alloc.id == id) {
        return AllocationEditModel(
          id: alloc.id,
          categoryId: categoryId,
          amount: amount,
          isNew: alloc.isNew,
        );
      }
      return alloc;
    }).toList();

    // Re-emit state to trigger UI rebuild
    _rebuildCounter++;
    emit(BudgetFormState.initial(rebuildCounter: _rebuildCounter));
  }

  /// Removes an allocation from the list.
  ///
  /// **Parameters**:
  /// - `id`: Allocation ID to remove
  void removeAllocation(String id) {
    _allocations = _allocations.where((alloc) => alloc.id != id).toList();

    // Re-emit state to trigger UI rebuild
    _rebuildCounter++;
    emit(BudgetFormState.initial(rebuildCounter: _rebuildCounter));
  }

  /// Validates budget name (required, unique for same period).
  ///
  /// **Parameters**:
  /// - `value`: Name to validate
  /// - `excludeId`: Budget ID to exclude from uniqueness check (for editing)
  ///
  /// **Returns**: Error message or null if valid
  String? validateName(String? value, {String? excludeId}) {
    if (value == null || value.isEmpty) {
      return 'Budget name is required';
    }

    // Note: Name uniqueness is not strictly required (could have "December 2025"
    // for different years), but checking same name in overlapping periods
    // could be added here if needed.

    return null; // Valid
  }

  /// Validates budget amount (must be positive).
  ///
  /// **Returns**: Error message or null if valid
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null; // Valid
  }

  /// Validates allocations list.
  ///
  /// **Checks**:
  /// 1. At least one allocation exists
  /// 2. Total allocated ≤ budget amount
  /// 3. No duplicate categories
  /// 4. All amounts are positive
  ///
  /// **Returns**: Error message or null if valid
  String? validateAllocations() {
    // Check if at least one allocation exists
    if (_allocations.isEmpty) {
      return 'Add at least one allocation';
    }

    // Get budget amount from form
    final amountStr = formKey.currentState?.fields['amount']?.value ?? '0';
    final budgetAmount = double.tryParse(amountStr) ?? 0;

    // Calculate total allocated
    final totalAllocated = _allocations.fold<double>(
      0.0,
      (sum, alloc) => sum + alloc.amount,
    );

    // Check if total allocated exceeds budget
    if (totalAllocated > budgetAmount) {
      return 'Total allocations (\$${totalAllocated.toStringAsFixed(2)}) exceed budget (\$${budgetAmount.toStringAsFixed(2)})';
    }

    // Check for duplicate categories
    final categoryIds = _allocations.map((a) => a.categoryId).toSet();
    if (categoryIds.length != _allocations.length) {
      return 'Duplicate categories found. Each category can only be allocated once';
    }

    // Check all amounts are positive
    final hasNegativeAmount = _allocations.any((a) => a.amount <= 0);
    if (hasNegativeAmount) {
      return 'All allocation amounts must be greater than 0';
    }

    return null; // Valid
  }

  /// Creates new budget with allocations (atomic operation).
  ///
  /// **Process**:
  /// 1. Validate form fields
  /// 2. Validate allocations
  /// 3. Create budget → repository
  /// 4. Create all allocations → repository
  /// 5. Emit success (triggers modal close)
  ///
  /// **Rollback**: If allocations fail, delete the created budget
  ///
  /// **Error Handling**: Emit error state (keeps form open for retry)
  Future<void> createBudget() async {
    // Validate form fields
    if (!formKey.currentState!.saveAndValidate()) {
      return; // Validation failed (errors shown by FormBuilder)
    }

    // Validate allocations
    final allocError = validateAllocations();
    if (allocError != null) {
      emit(BudgetFormState.error(allocError));
      return;
    }

    emit(const BudgetFormState.loading());

    try {
      // Extract form data
      final formData = formKey.currentState!.value;
      final name = formData['name'] as String;
      final amount = double.parse(formData['amount'] as String);
      final startDate = formData['startDate'] as DateTime;
      final endDate = formData['endDate'] as DateTime;

      // Create budget model
      final budget = BudgetModel.create(
        name: name,
        amount: amount,
        startDate: startDate,
        endDate: endDate,
      );

      // Step 1: Create budget
      await _budgetRepository.createBudget(budget);

      // Step 2: Create all allocations
      try {
        for (final allocEdit in _allocations) {
          final allocation = AllocationModel.create(
            amount: allocEdit.amount,
            categoryId: allocEdit.categoryId,
            budgetId: budget.id,
          );
          await _allocationRepository.createAllocation(allocation);
        }
      } catch (e) {
        // Rollback: delete budget if allocations failed
        await _budgetRepository.deleteBudget(budget.id);
        throw Exception('Failed to create allocations: $e');
      }

      emit(const BudgetFormState.success());
    } catch (e) {
      emit(BudgetFormState.error('Failed to create budget: $e'));
    }
  }

  /// Updates existing budget with allocations.
  ///
  /// **Process**:
  /// 1. Validate form fields
  /// 2. Validate allocations
  /// 3. Update budget → repository
  /// 4. Diff allocations (identify adds/updates/deletes)
  /// 5. Apply allocation changes → repository
  /// 6. Emit success (triggers modal close)
  ///
  /// **Note**: Uses diff approach instead of delete-all-recreate for efficiency
  ///
  /// **Parameters**:
  /// - `budgetId`: ID of budget being edited
  Future<void> updateBudget(String budgetId) async {
    // Validate form fields
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }

    // Validate allocations
    final allocError = validateAllocations();
    if (allocError != null) {
      emit(BudgetFormState.error(allocError));
      return;
    }

    emit(const BudgetFormState.loading());

    try {
      // Extract form data
      final formData = formKey.currentState!.value;
      final name = formData['name'] as String;
      final amount = double.parse(formData['amount'] as String);
      final startDate = formData['startDate'] as DateTime;
      final endDate = formData['endDate'] as DateTime;

      // Get existing budget
      final existingBudget = _budgetRepository.budgets
          .firstWhere((b) => b.id == budgetId);

      // Update budget
      final updatedBudget = existingBudget.copyWith(
        name: name,
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        updatedAt: DateTime.now(),
      );
      await _budgetRepository.updateBudget(updatedBudget);

      // Get existing allocations for diff
      final existingAllocations =
          _allocationRepository.getAllocationsForBudget(budgetId);

      // Diff allocations: determine adds, updates, deletes
      final currentIds = _allocations.where((a) => !a.isNew).map((a) => a.id).toSet();

      // Delete removed allocations
      for (final existing in existingAllocations) {
        if (!currentIds.contains(existing.id)) {
          await _allocationRepository.deleteAllocation(existing.id);
        }
      }

      // Update existing allocations
      for (final allocEdit in _allocations.where((a) => !a.isNew)) {
        final existing = existingAllocations
            .where((a) => a.id == allocEdit.id)
            .firstOrNull;

        if (existing != null) {
          // Check if changed
          if (existing.amount != allocEdit.amount ||
              existing.categoryId != allocEdit.categoryId) {
            final updated = existing.copyWith(
              amount: allocEdit.amount,
              categoryId: allocEdit.categoryId,
              updatedAt: DateTime.now(),
            );
            await _allocationRepository.updateAllocation(updated);
          }
        }
      }

      // Create new allocations
      for (final allocEdit in _allocations.where((a) => a.isNew)) {
        final allocation = AllocationModel.create(
          amount: allocEdit.amount,
          categoryId: allocEdit.categoryId,
          budgetId: budgetId,
        );
        await _allocationRepository.createAllocation(allocation);
      }

      emit(const BudgetFormState.success());
    } catch (e) {
      emit(BudgetFormState.error('Failed to update budget: $e'));
    }
  }

  /// Deletes budget (cascades to allocations via repository).
  ///
  /// **Parameters**:
  /// - `budgetId`: ID of budget to delete
  Future<void> deleteBudget(String budgetId) async {
    emit(const BudgetFormState.loading());

    try {
      // Repository handles cascade delete of allocations
      await _budgetRepository.deleteBudget(budgetId);
      emit(const BudgetFormState.success());
    } catch (e) {
      emit(BudgetFormState.error('Failed to delete budget: $e'));
    }
  }

  @override
  Future<void> close() {
    _categorySubscription?.cancel();
    return super.close();
  }
}

/// Edit model for allocations (not freezed).
///
/// Used to track allocation state during form editing.
/// Simpler than AllocationModel since it doesn't need timestamps or sync metadata.
///
/// **Fields**:
/// - `id`: Allocation ID (temp UUID for new, real ID for existing)
/// - `categoryId`: Category being allocated to
/// - `amount`: Amount allocated
/// - `isNew`: True if not yet saved to repository
class AllocationEditModel {
  final String id;
  final String categoryId;
  final double amount;
  final bool isNew;

  const AllocationEditModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.isNew,
  });

  @override
  String toString() {
    return 'AllocationEditModel(id: $id, categoryId: $categoryId, amount: \$${amount.toStringAsFixed(2)}, isNew: $isNew)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AllocationEditModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
