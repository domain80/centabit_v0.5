import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:centabit/core/utils/date_formatter.dart';
import 'package:centabit/data/repositories/allocation_repository.dart';
import 'package:centabit/data/repositories/budget_repository.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_details_state.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_details_vmodel.dart';
import 'package:centabit/features/budgets/presentation/cubits/chart_type.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';

class BudgetDetailsCubit extends Cubit<BudgetDetailsState> {
  final String budgetId;
  final BudgetRepository _budgetRepository;
  final AllocationRepository _allocationRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  StreamSubscription? _budgetSubscription;
  StreamSubscription? _allocationSubscription;
  StreamSubscription? _transactionSubscription;
  StreamSubscription? _categorySubscription;

  ChartType _selectedChartType = ChartType.bar;

  ChartType get selectedChartType => _selectedChartType;

  void setChartType(ChartType type) {
    if (_selectedChartType == type) return; // Skip if already selected

    _selectedChartType = type;

    // Force emit to trigger BlocBuilder rebuilds
    state.maybeWhen(
      success: (details) {
        emit(BudgetDetailsState.loading()); // Emit intermediate state
        emit(BudgetDetailsState.success(details: details)); // Then success
      },
      orElse: () {}, // Do nothing if not in success state
    );
  }

  BudgetDetailsCubit({
    required this.budgetId,
    required BudgetRepository budgetRepository,
    required AllocationRepository allocationRepository,
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
  })  : _budgetRepository = budgetRepository,
        _allocationRepository = allocationRepository,
        _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        super(const BudgetDetailsState.initial()) {
    _subscribeToStreams();
    _loadBudgetDetails();
  }

  void _subscribeToStreams() {
    _budgetSubscription =
        _budgetRepository.budgetsStream.listen((_) => _loadBudgetDetails());
    _allocationSubscription = _allocationRepository.allocationsStream
        .listen((_) => _loadBudgetDetails());
    _transactionSubscription = _transactionRepository.transactionsStream
        .listen((_) => _loadBudgetDetails());
    _categorySubscription = _categoryRepository.categoriesStream
        .listen((_) => _loadBudgetDetails());
  }

  Future<void> _loadBudgetDetails() async {
    emit(const BudgetDetailsState.loading());

    try {
      // Load data from cached repositories
      final budget = _budgetRepository.budgets.firstWhere(
        (b) => b.id == budgetId,
        orElse: () => throw Exception('Budget not found'),
      );

      final allocations = _allocationRepository.allocations
          .where((a) => a.budgetId == budgetId)
          .toList();

      final categories = _categoryRepository.categories;

      // Filter transactions by budgetId AND date range
      final transactions = _transactionRepository.transactions.where((t) {
        // Transaction must be in budget's date range
        final isInDateRange = !t.transactionDate.isBefore(budget.startDate) &&
            !t.transactionDate.isAfter(budget.endDate);

        // Transaction must link to this budget OR have category in allocations
        final isLinkedToBudget = t.budgetId == budgetId;
        final categoryInAllocations =
            allocations.any((a) => a.categoryId == t.categoryId);

        return isInDateRange && (isLinkedToBudget || categoryInAllocations);
      }).toList();

      // Build allocation detail view models
      final allocationDetails = allocations.map((allocation) {
        final category = categories.firstWhere(
          (c) => c.id == allocation.categoryId,
          orElse: () => throw Exception('Category not found'),
        );

        // Transactions for this allocation
        final allocationTransactions = transactions
            .where((t) => t.categoryId == allocation.categoryId)
            .map(
              (t) => TransactionVModel(
                id: t.id,
                name: t.name,
                amount: t.amount,
                type: t.type,
                transactionDate: t.transactionDate,
                formattedDate:
                    DateFormatter.formatTransactionDateTime(t.transactionDate),
                formattedTime: DateFormatter.formatTime(t.transactionDate),
                categoryId: t.categoryId,
                categoryName: category.name,
                categoryIconName: category.iconName,
                notes: t.notes,
              ),
            )
            .toList();

        return AllocationDetailVModel(
          allocation: allocation,
          category: category,
          transactions: allocationTransactions,
        );
      }).toList();

      // Build full transaction list (denormalized)
      final transactionViewModels = transactions.map((t) {
        final category = categories.firstWhere(
          (c) => c.id == t.categoryId,
          orElse: () => throw Exception('Category not found'),
        );
        return TransactionVModel(
          id: t.id,
          name: t.name,
          amount: t.amount,
          type: t.type,
          transactionDate: t.transactionDate,
          formattedDate:
              DateFormatter.formatTransactionDateTime(t.transactionDate),
          formattedTime: DateFormatter.formatTime(t.transactionDate),
          categoryId: t.categoryId,
          categoryName: category.name,
          categoryIconName: category.iconName,
          notes: t.notes,
        );
      }).toList();

      // Sort transactions by date (newest first)
      transactionViewModels.sort((a, b) =>
          b.transactionDate.compareTo(a.transactionDate));

      final viewModel = BudgetDetailsVModel(
        budget: budget,
        allocations: allocationDetails,
        transactions: transactionViewModels,
      );

      emit(BudgetDetailsState.success(details: viewModel));
    } catch (e) {
      emit(BudgetDetailsState.error(e.toString()));
    }
  }

  Future<void> deleteBudget() async {
    try {
      await _budgetRepository.deleteBudget(budgetId);
      // Navigation handled in listener
    } catch (e) {
      emit(BudgetDetailsState.error('Failed to delete budget: $e'));
    }
  }

  Future<void> refresh() => _loadBudgetDetails();

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    _allocationSubscription?.cancel();
    _transactionSubscription?.cancel();
    _categorySubscription?.cancel();
    return super.close();
  }
}
