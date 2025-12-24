import 'dart:async';
import 'package:centabit/data/models/allocation_model.dart';
import 'package:centabit/data/services/budget_service.dart';
import 'package:centabit/data/services/category_service.dart';

/// Service for managing budget allocations with in-memory storage and reactive streams.
///
/// Allocations distribute a budget's total amount across different spending
/// categories. This service manages the allocation lifecycle and provides
/// reactive updates for chart data building.
///
/// **Dependencies**:
/// - [CategoryService]: To validate category IDs and get default categories
/// - [BudgetService]: To validate budget IDs and get default budget
///
/// **Architecture**: Simple in-memory service (no Repository layer needed)
/// - Stores allocations in a list
/// - Emits stream events on changes
/// - Cubits subscribe to stream for reactive UI updates
///
/// **Default Data**:
/// Initializes with allocations for the default budget, distributed across
/// common spending categories. Total: $1,550 out of $2,000 default budget.
///
/// **Example Usage**:
/// ```dart
/// final allocationService = AllocationService(
///   categoryService,
///   budgetService,
/// );
///
/// // Listen to changes
/// allocationService.allocationsStream.listen((allocations) {
///   print('Allocations updated: ${allocations.length}');
/// });
///
/// // Get allocations for a budget
/// final allocations = allocationService.getAllocationsForBudget(budgetId);
/// final total = allocations.totalAmount(); // Using extension method
/// ```
///
/// **Stream Subscriptions**:
/// - DashboardCubit subscribes to `allocationsStream`
/// - Any change triggers chart data rebuild
class AllocationService {
  /// Internal list of all allocations
  final List<AllocationModel> _allocations = [];

  /// Broadcast stream controller for allocation changes
  final _allocationsController =
      StreamController<List<AllocationModel>>.broadcast();

  /// Reference to category service for validation and default data
  final CategoryService _categoryService;

  /// Reference to budget service for validation and default data
  final BudgetService _budgetService;

  /// Stream of allocation changes
  ///
  /// Emits an immutable list of allocations whenever the collection changes.
  /// Subscribe to this stream for reactive UI updates.
  ///
  /// **Example**:
  /// ```dart
  /// _allocationSubscription = allocationService.allocationsStream.listen((_) {
  ///   _loadDashboardData();
  /// });
  /// ```
  Stream<List<AllocationModel>> get allocationsStream =>
      _allocationsController.stream;

  /// Immutable snapshot of all allocations
  ///
  /// Returns a read-only copy of the allocation list.
  /// Use this for synchronous access.
  List<AllocationModel> get allocations => List.unmodifiable(_allocations);

  /// Creates the allocation service with dependencies.
  ///
  /// **Example**:
  /// ```dart
  /// final allocationService = AllocationService(
  ///   categoryService,
  ///   budgetService,
  /// );
  /// ```
  AllocationService(this._categoryService, this._budgetService) {
    _initializeDefaultAllocations();
  }

  /// Initializes the service with default allocations for the default budget.
  ///
  /// Creates allocations distributed across common spending categories:
  /// - Groceries: $400 (highest, frequent expense)
  /// - Dining: $300 (social, restaurants)
  /// - Healthcare: $250 (medical, pharmacy)
  /// - Entertainment: $200 (streaming, movies, hobbies)
  /// - Gas & Fuel: $150 (transportation)
  /// - Transport: $150 (public transit, rideshare)
  /// - Coffee: $100 (daily expenses)
  ///
  /// **Total**: $1,550 out of $2,000 budget (leaves $450 unallocated)
  ///
  /// **Why Unallocated**:
  /// - Provides buffer for unexpected expenses
  /// - Allows flexibility in spending
  /// - Realistic budget scenario
  void _initializeDefaultAllocations() {
    final budgets = _budgetService.budgets;
    if (budgets.isEmpty) {
      // No default budget yet, skip initialization
      // This shouldn't happen since BudgetService initializes first
      return;
    }

    final defaultBudget = budgets.first;
    final categories = _categoryService.categories;

    // Helper to find category ID by name
    String? getCategoryId(String name) {
      try {
        return categories.firstWhere((c) => c.name == name).id;
      } catch (_) {
        return null;
      }
    }

    // Create allocations for common categories
    final allocationData = [
      ('Groceries', 400.0),
      ('Dining', 300.0),
      ('Healthcare', 250.0),
      ('Entertainment', 200.0),
      ('Gas & Fuel', 150.0),
      ('Transport', 150.0),
      ('Coffee', 100.0),
    ];

    for (final (categoryName, amount) in allocationData) {
      final categoryId = getCategoryId(categoryName);
      if (categoryId != null) {
        final allocation = AllocationModel.create(
          amount: amount,
          categoryId: categoryId,
          budgetId: defaultBudget.id,
        );
        _allocations.add(allocation);
      }
    }

    _emitAllocations();
  }

  /// Creates a new allocation.
  ///
  /// Adds the allocation to the collection and notifies all stream listeners.
  ///
  /// **Example**:
  /// ```dart
  /// final allocation = AllocationModel.create(
  ///   amount: 500.0,
  ///   categoryId: groceriesCategoryId,
  ///   budgetId: januaryBudgetId,
  /// );
  /// await allocationService.createAllocation(allocation);
  /// ```
  ///
  /// **Validation Considerations**:
  /// - Verify categoryId exists in CategoryService
  /// - Verify budgetId exists in BudgetService
  /// - Check total allocations don't exceed budget.amount (soft limit)
  Future<void> createAllocation(AllocationModel allocation) async {
    _allocations.add(allocation);
    _emitAllocations();
  }

  /// Updates an existing allocation.
  ///
  /// Replaces the allocation with matching ID and updates its timestamp.
  /// If the allocation doesn't exist, no action is taken.
  ///
  /// **Example**:
  /// ```dart
  /// final updated = allocation.copyWith(amount: 450.0);
  /// await allocationService.updateAllocation(updated);
  /// ```
  Future<void> updateAllocation(AllocationModel allocation) async {
    final index = _allocations.indexWhere((a) => a.id == allocation.id);
    if (index != -1) {
      _allocations[index] = allocation.withUpdatedTimestamp();
      _emitAllocations();
    }
  }

  /// Deletes an allocation by ID.
  ///
  /// Removes the allocation from the collection and notifies listeners.
  ///
  /// **Example**:
  /// ```dart
  /// await allocationService.deleteAllocation(allocationId);
  /// ```
  Future<void> deleteAllocation(String id) async {
    _allocations.removeWhere((a) => a.id == id);
    _emitAllocations();
  }

  /// Finds an allocation by ID.
  ///
  /// Returns the allocation if found, null otherwise.
  ///
  /// **Example**:
  /// ```dart
  /// final allocation = allocationService.getAllocationById(allocationId);
  /// ```
  AllocationModel? getAllocationById(String id) {
    try {
      return _allocations.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns all allocations for a specific budget.
  ///
  /// This is the most commonly used query method, used by DashboardCubit
  /// to build chart data for each budget.
  ///
  /// **Example**:
  /// ```dart
  /// final allocations = allocationService.getAllocationsForBudget(budgetId);
  /// final total = allocations.totalAmount(); // $1,550
  ///
  /// // Build chart data
  /// for (final allocation in allocations) {
  ///   final category = categoryService.getCategoryById(allocation.categoryId);
  ///   print('${category.name}: \$${allocation.amount}');
  /// }
  /// ```
  List<AllocationModel> getAllocationsForBudget(String budgetId) {
    return _allocations.where((a) => a.budgetId == budgetId).toList();
  }

  /// Returns all allocations for a specific category.
  ///
  /// Useful for analyzing spending across different budget periods.
  ///
  /// **Example**:
  /// ```dart
  /// final groceryAllocations = allocationService
  ///     .getAllocationsForCategory(groceriesCategoryId);
  ///
  /// // See how grocery budget changed over time
  /// for (final allocation in groceryAllocations) {
  ///   final budget = budgetService.getBudgetById(allocation.budgetId);
  ///   print('${budget.name}: \$${allocation.amount}');
  /// }
  /// ```
  List<AllocationModel> getAllocationsForCategory(String categoryId) {
    return _allocations.where((a) => a.categoryId == categoryId).toList();
  }

  /// Calculates the total allocated amount for a budget.
  ///
  /// Returns the sum of all allocation amounts for the given budget.
  /// This is compared against the budget's total amount to find unallocated funds.
  ///
  /// **Example**:
  /// ```dart
  /// final totalAllocated = allocationService.getTotalForBudget(budgetId);
  /// final budget = budgetService.getBudgetById(budgetId);
  /// final unallocated = budget.amount - totalAllocated;
  /// print('Unallocated: \$$unallocated');
  /// ```
  double getTotalForBudget(String budgetId) {
    return getAllocationsForBudget(budgetId).totalAmount();
  }

  /// Validates that allocations don't exceed budget amount.
  ///
  /// Returns true if total allocations <= budget.amount.
  /// This is a soft validation - the service doesn't enforce it.
  ///
  /// **Example**:
  /// ```dart
  /// if (!allocationService.isValidTotal(budgetId)) {
  ///   print('Warning: Allocations exceed budget!');
  /// }
  /// ```
  bool isValidTotal(String budgetId) {
    final budget = _budgetService.getBudgetById(budgetId);
    if (budget == null) return false;

    final totalAllocated = getTotalForBudget(budgetId);
    return totalAllocated <= budget.amount;
  }

  /// Deletes all allocations for a budget.
  ///
  /// Useful for cascade delete when removing a budget.
  ///
  /// **Example**:
  /// ```dart
  /// await allocationService.deleteAllocationsForBudget(budgetId);
  /// await budgetService.deleteBudget(budgetId);
  /// ```
  Future<void> deleteAllocationsForBudget(String budgetId) async {
    _allocations.removeWhere((a) => a.budgetId == budgetId);
    _emitAllocations();
  }

  /// Deletes all allocations for a category.
  ///
  /// Useful for cascade delete when removing a category.
  ///
  /// **Example**:
  /// ```dart
  /// await allocationService.deleteAllocationsForCategory(categoryId);
  /// await categoryService.deleteCategory(categoryId);
  /// ```
  Future<void> deleteAllocationsForCategory(String categoryId) async {
    _allocations.removeWhere((a) => a.categoryId == categoryId);
    _emitAllocations();
  }

  /// Returns a summary of allocations grouped by budget.
  ///
  /// Useful for dashboard overview or budget comparison.
  ///
  /// **Example**:
  /// ```dart
  /// final summary = allocationService.getAllocationSummary();
  /// for (final entry in summary.entries) {
  ///   print('Budget ${entry.key}: ${entry.value.length} allocations');
  /// }
  /// ```
  Map<String, List<AllocationModel>> getAllocationSummary() {
    return _allocations.groupByBudget();
  }

  /// Emits the current allocation list to all stream listeners.
  ///
  /// Called after any mutation (create, update, delete).
  /// Sends an immutable copy to prevent external modification.
  void _emitAllocations() {
    _allocationsController.add(List.unmodifiable(_allocations));
  }

  /// Disposes of the stream controller.
  ///
  /// Call this when the service is no longer needed (app shutdown).
  ///
  /// **Example**:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   allocationService.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    _allocationsController.close();
  }
}
