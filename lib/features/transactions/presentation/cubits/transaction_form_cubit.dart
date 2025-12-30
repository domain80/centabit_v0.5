import 'dart:async';

import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/repositories/budget_repository.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Cubit for managing transaction form state and validation
///
/// Subscribes to budget and category repository streams to keep
/// dropdowns reactive. When a new category is created (Phase 2),
/// the dropdown automatically updates.
///
/// Supports three modes via initialValue parameter:
/// - Create (initialValue = null): Creates new transaction
/// - Edit (initialValue = existing): Updates existing transaction
/// - Copy (initialValue = existing with new ID): Duplicates transaction
class TransactionFormCubit extends Cubit<TransactionFormState> {
  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;
  final GlobalKey<FormBuilderState> formKey;

  // Stream subscriptions for reactive dropdown updates
  StreamSubscription? _budgetSubscription;
  StreamSubscription? _categorySubscription;

  // Cached data for dropdowns (synchronous access)
  List<BudgetModel> _activeBudgets = [];
  List<CategoryModel> _categories = [];

  TransactionFormCubit(
    this._transactionRepository,
    this._budgetRepository,
    this._categoryRepository,
  )   : formKey = GlobalKey<FormBuilderState>(),
        super(const TransactionFormState.initial()) {
    _subscribeToStreams();
  }

  /// Subscribe to repository streams for reactive dropdown updates
  void _subscribeToStreams() {
    // Subscribe to budget changes to update dropdown in real-time
    _budgetSubscription = _budgetRepository.budgetsStream.listen((budgets) {
      _activeBudgets = budgets.where((b) => b.isActive()).toList();
    });

    // Subscribe to category changes (important for inline category creation in Phase 2)
    _categorySubscription = _categoryRepository.categoriesStream.listen((categories) {
      _categories = categories;
    });

    // Initial load
    _activeBudgets = _budgetRepository.getActiveBudgets();
    _categories = _categoryRepository.categories;
  }

  /// Getters for reactive dropdowns
  List<BudgetModel> get activeBudgets => _activeBudgets;
  List<CategoryModel> get categories => _categories;

  /// Default budget ID for new transactions (first active budget)
  String? get defaultBudgetId =>
      _activeBudgets.isNotEmpty ? _activeBudgets.first.id : null;

  /// Create new transaction from form data
  ///
  /// Validates form, combines date + time, and calls repository.
  /// Emits loading → success/error states.
  Future<void> createTransaction() async {
    if (!_validateForm()) {
      return;
    }

    // Get form data AFTER validation
    final formData = formKey.currentState?.value ?? {};

    emit(const TransactionFormState.loading());

    try {
      final transaction = _buildTransactionFromForm(formData);
      await _transactionRepository.createTransaction(transaction);
      emit(const TransactionFormState.success());
    } catch (e, stackTrace) {
      emit(TransactionFormState.error('Failed to create transaction: ${e.toString()}'));
      // TODO: Log error with AppLogger
      debugPrint('createTransaction error: $e\n$stackTrace');
    }
  }

  /// Update existing transaction from form data
  ///
  /// Validates form, combines date + time, and calls repository.
  /// Emits loading → success/error states.
  Future<void> updateTransaction(String id) async {
    if (!_validateForm()) return;

    // Get form data AFTER validation
    final formData = formKey.currentState?.value ?? {};

    emit(const TransactionFormState.loading());

    try {
      final transaction = _buildTransactionFromForm(formData, id: id);
      await _transactionRepository.updateTransaction(transaction);
      emit(const TransactionFormState.success());
    } catch (e, stackTrace) {
      emit(TransactionFormState.error('Failed to update transaction: ${e.toString()}'));
      debugPrint('updateTransaction error: $e\n$stackTrace');
    }
  }

  /// Delete transaction by ID
  ///
  /// Soft deletes transaction via repository.
  /// Emits loading → success/error states.
  Future<void> deleteTransaction(String id) async {
    emit(const TransactionFormState.loading());

    try {
      await _transactionRepository.deleteTransaction(id);
      emit(const TransactionFormState.success());
    } catch (e, stackTrace) {
      emit(TransactionFormState.error('Failed to delete transaction: ${e.toString()}'));
      debugPrint('deleteTransaction error: $e\n$stackTrace');
    }
  }

  /// Validate form using FormBuilder's built-in validation
  bool _validateForm() {
    return formKey.currentState?.saveAndValidate() ?? false;
  }

  /// Build TransactionModel from form data
  ///
  /// Combines date + time fields into single DateTime.
  /// If [id] provided, creates model with that ID (update mode).
  /// Otherwise uses factory constructor (create mode).
  TransactionModel _buildTransactionFromForm(
    Map<String, dynamic> formData, {
    String? id,
  }) {
    final date = formData['date'] as DateTime;
    final time = formData['time'] as TimeOfDay;

    // Combine date + time into single DateTime
    final transactionDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Parse form fields
    final name = formData['transactionName'] as String;
    final amount = double.parse(formData['amount'] as String);
    final isDebit = formData['isDebit'] as bool? ?? true;
    final type = isDebit ? TransactionType.debit : TransactionType.credit;
    final categoryId = formData['categoryId'] as String?;
    final budgetId = formData['budgetId'] as String?;
    final notes = formData['notes'] as String?;

    if (id != null) {
      // Update mode - fetch existing to preserve createdAt
      final existing = _transactionRepository.transactions
          .firstWhere((t) => t.id == id);

      return TransactionModel(
        id: id,
        name: name,
        amount: amount,
        type: type,
        transactionDate: transactionDate,
        categoryId: categoryId,
        budgetId: budgetId,
        notes: notes,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
    } else {
      // Create mode - use factory constructor
      return TransactionModel.create(
        name: name,
        amount: amount,
        type: type,
        transactionDate: transactionDate,
        categoryId: categoryId,
        budgetId: budgetId,
        notes: notes,
      );
    }
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    _categorySubscription?.cancel();
    return super.close();
  }
}
