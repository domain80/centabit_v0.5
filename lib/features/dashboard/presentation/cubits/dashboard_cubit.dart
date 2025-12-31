import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:centabit/data/models/allocation_model.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/models/transactions_chart_data.dart';
import 'package:centabit/data/repositories/allocation_repository.dart';
import 'package:centabit/data/repositories/budget_repository.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_state.dart';

/// Cubit for managing dashboard state and budget report data.
///
/// Orchestrates data from 4 services (budgets, allocations, transactions,
/// categories) to build comprehensive budget reports with BAR calculations
/// and chart data.
///
/// **Architecture Pattern**: MVVM with Cubit
/// - Replaces v0.4's `DashboardViewModel` (Command pattern)
/// - Uses stream subscriptions instead of `Command.combineLatest`
/// - Direct service access (no repository layer needed)
///
/// **Responsibilities**:
/// 1. Subscribe to 4 service streams for reactive updates
/// 2. Fetch and aggregate data from multiple sources
/// 3. Calculate BAR (Budget Available Ratio) metrics
/// 4. Build chart data (allocations vs transactions per category)
/// 5. Emit state changes for UI updates
///
/// **Data Flow**:
/// ```
/// Services emit changes
///   ↓
/// Stream subscriptions trigger _loadDashboardData()
///   ↓
/// For each active budget:
///   - Get allocations
///   - Get transactions
///   - Get categories
///   - Build chart data
///   - Calculate BAR
///   - Create BudgetPageModel
///   ↓
/// Emit DashboardState.success([BudgetPageModel, ...])
///   ↓
/// UI rebuilds with BlocBuilder
/// ```
///
/// **Usage**:
/// ```dart
/// BlocProvider(
///   create: (_) => getIt<DashboardCubit>(),
///   child: DashboardPage(),
/// )
/// ```
class DashboardCubit extends Cubit<DashboardState> {
  final BudgetRepository _budgetRepository;
  final AllocationRepository _allocationRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  // Stream subscriptions for reactive updates
  StreamSubscription? _budgetSubscription;
  StreamSubscription? _allocationSubscription;
  StreamSubscription? _transactionSubscription;
  StreamSubscription? _categorySubscription;

  /// Creates dashboard cubit with service dependencies.
  ///
  /// Automatically starts listening to service streams and loads initial data.
  ///
  /// **Example** (via GetIt):
  /// ```dart
  /// final cubit = getIt<DashboardCubit>();
  /// ```
  DashboardCubit(
    this._budgetRepository,
    this._allocationRepository,
    this._transactionRepository,
    this._categoryRepository,
  ) : super(const DashboardState.initial()) {
    _subscribeToStreams();
  }

  /// Subscribes to all service streams for reactive updates.
  ///
  /// Any change in budgets, allocations, transactions, or categories
  /// triggers a full dashboard reload. This ensures the UI always shows
  /// current data.
  ///
  /// **Performance Note**:
  /// This recalculates everything on any change. For in-memory data with
  /// <100 items, this is acceptable. If performance becomes an issue:
  /// - Add debouncing to prevent rapid successive updates
  /// - Implement incremental updates (only recalculate changed budgets)
  /// - Cache last computation
  void _subscribeToStreams() {
    _budgetSubscription = _budgetRepository.budgetsStream.listen((_) {
      _loadDashboardData();
    });

    _allocationSubscription = _allocationRepository.allocationsStream.listen((_) {
      _loadDashboardData();
    });

    _transactionSubscription = _transactionRepository.transactionsStream.listen((_) {
      _loadDashboardData();
    });

    _categorySubscription = _categoryRepository.categoriesStream.listen((_) {
      _loadDashboardData();
    });

    // Initial load
    _loadDashboardData();
  }

  /// Loads and aggregates dashboard data from all services.
  ///
  /// **Process**:
  /// 1. Emit loading state
  /// 2. Get all active budgets
  /// 3. For each budget, build a BudgetPageModel
  /// 4. Build monthly overview for current month
  /// 5. Emit success state with all pages and monthly overview
  ///
  /// **Error Handling**:
  /// Catches any exceptions and emits error state with message.
  void _loadDashboardData() {
    emit(const DashboardState.loading());

    try {
      // Get all budgets that are currently active
      final activeBudgets = _budgetRepository.getActiveBudgets();

      // Build a page model for each active budget
      final budgetPages = activeBudgets.map((budget) {
        return _buildBudgetPageModel(budget);
      }).toList();

      // Build monthly overview for current calendar month
      final monthlyOverview = _buildMonthlyOverviewModel(DateTime.now());

      emit(DashboardState.success(
        budgetPages: budgetPages,
        monthlyOverview: monthlyOverview,
      ));
    } catch (e) {
      emit(DashboardState.error(e.toString()));
    }
  }

  /// Builds complete data for one budget page.
  ///
  /// **Ported from v0.4**: `dashboard_view_model.dart` line 119-144
  /// (buildBudgetDetails method)
  ///
  /// **Aggregates**:
  /// - Budget metadata
  /// - Allocations for this budget
  /// - Transactions for this budget
  /// - All categories (for chart display)
  ///
  /// **Computes**:
  /// - Chart data (allocations vs transactions per category)
  /// - Total budgeted amount
  /// - Total spent amount
  /// - BAR value
  ///
  /// **Parameters**:
  /// - `budget`: The budget to build data for
  ///
  /// **Returns**: Complete [BudgetPageModel] ready for UI rendering
  BudgetPageModel _buildBudgetPageModel(BudgetModel budget) {
    // Get allocations for this budget
    final allocations = _allocationRepository.getAllocationsForBudget(budget.id);

    // Get transactions - ONLY include explicitly assigned to this budget
    final transactions = _transactionRepository.transactions.where((t) {
      // Transaction must be in budget's date range
      final isInDateRange = !t.transactionDate.isBefore(budget.startDate) &&
          !t.transactionDate.isAfter(budget.endDate);

      // Transaction must be explicitly linked to this budget
      final isLinkedToBudget = t.budgetId == budget.id;

      return isInDateRange && isLinkedToBudget;
    }).toList();

    // Get all categories for chart display
    final categories = _categoryRepository.categories;

    // Build chart data combining allocations and transactions
    final chartData = _buildChartData(
      allocations: allocations,
      transactions: transactions,
      categories: categories,
    );

    // Calculate total budgeted amount (sum of allocations)
    final totalBudget = allocations.fold<double>(
      0,
      (sum, allocation) => sum + allocation.amount,
    );

    // Calculate total spent amount (sum of transactions)
    // Credit transactions reduce spending (income)
    final totalSpent = transactions.fold<double>(
      0,
      (sum, transaction) {
        if (transaction.type == TransactionType.credit) {
          return sum - transaction.amount;
        } else {
          return sum + transaction.amount;
        }
      },
    );

    // Calculate BAR (Budget Available Ratio)
    final barValue = _calculateBAR(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      startDate: budget.startDate,
      endDate: budget.endDate,
      now: DateTime.now(),
    );

    return BudgetPageModel(
      budget: budget,
      barIndexValue: barValue,
      chartData: chartData,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
    );
  }

  /// Builds chart data combining allocations and transactions by category.
  ///
  /// **Ported from v0.4**: `dashboard_view_model.dart` line 12-34
  /// (buildData function)
  ///
  /// **Algorithm**:
  /// 1. Create map of allocations by category ID
  /// 2. Create map of transaction totals by category ID
  /// 3. For each category, create TransactionsChartData with both amounts
  ///
  /// **Parameters**:
  /// - `allocations`: List of allocations for the budget
  /// - `transactions`: List of transactions for the budget
  /// - `categories`: All categories (for complete chart)
  ///
  /// **Returns**: List of chart data, one per category
  ///
  /// **Example**:
  /// ```
  /// Groceries: allocated=$400, spent=$325.50
  /// Dining: allocated=$300, spent=$187.20
  /// Transport: allocated=$150, spent=$0
  /// ```
  List<TransactionsChartData> _buildChartData({
    required List<AllocationModel> allocations,
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
  }) {
    // Map allocation amounts by category ID
    final Map<String, double> allocationMap = {
      for (var allocation in allocations)
        allocation.categoryId: allocation.amount,
    };

    // Map transaction totals by category ID
    final Map<String, double> transactionMap = {};
    for (var transaction in transactions) {
      if (transaction.categoryId == null) continue;

      final categoryId = transaction.categoryId!;
      final currentTotal = transactionMap[categoryId] ?? 0;

      // Add transaction amount (all are debit in our current sample data)
      transactionMap[categoryId] = currentTotal + transaction.amount;
    }

    // Build chart data for each category
    return categories.map((category) {
      return TransactionsChartData(
        categoryId: category.id,
        categoryName: category.name,
        categoryIconName: category.iconName,
        allocationAmount: allocationMap[category.id] ?? 0,
        transactionAmount: transactionMap[category.id] ?? 0,
      );
    }).toList();
  }

  /// Calculates Budget Available Ratio (BAR).
  ///
  /// **Ported from v0.4**: `dashboard_view_model.dart` line 36-63
  /// (calculateBAR function)
  ///
  /// **Formula**:
  /// ```
  /// BAR = (totalSpent / totalBudget) / (elapsedDays / totalDays)
  /// ```
  ///
  /// **Interpretation**:
  /// - BAR < 1.0: Spending slower than time passing (good!)
  /// - BAR = 1.0: Spending at exactly expected pace
  /// - BAR > 1.0: Spending faster than time passing (warning!)
  /// - BAR > 1.2: Significantly over pace (error color in UI)
  ///
  /// **Edge Cases**:
  /// - `totalBudget <= 0`: Returns 0.0 (avoid division by zero)
  /// - Before `startDate`: `elapsedDays = 0`, BAR = 0.0
  /// - After `endDate`: `elapsedDays = totalDays`, normal calculation
  /// - `timeRatio == 0`: Returns 0.0 (avoid division by zero)
  ///
  /// **Special Adjustment**:
  /// Adds 0.3 days to elapsed time to prevent extreme BAR values at
  /// the very start of a budget period.
  ///
  /// **Example**:
  /// ```
  /// Budget: $1000, Period: 30 days
  /// Spent: $400 in 10 days
  ///
  /// totalDays = 30
  /// elapsedDays = 10
  /// spendRatio = 400/1000 = 0.40 (40% of budget)
  /// timeRatio = (10 + 0.3)/30 = 0.343 (34.3% of time)
  /// BAR = 0.40 / 0.343 = 1.17 ⚠️
  ///
  /// Interpretation: Spending 17% faster than time passing!
  /// ```
  ///
  /// **Parameters**:
  /// - `totalBudget`: Total allocated amount
  /// - `totalSpent`: Total spent so far
  /// - `startDate`: Budget period start
  /// - `endDate`: Budget period end
  /// - `now`: Current date/time
  ///
  /// **Returns**: BAR value (typically 0.0 to 2.0, but can be higher)
  double _calculateBAR({
    required double totalBudget,
    required double totalSpent,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime now,
  }) {
    // Edge case: No budget allocated
    if (totalBudget <= 0) return 0.0;

    // Calculate total days in budget period (inclusive)
    final totalDays = endDate.difference(startDate).inDays + 1;

    // Calculate elapsed days based on current date
    final int elapsedDays;
    if (now.isBefore(startDate)) {
      // Before budget starts
      elapsedDays = 0;
    } else if (now.isAfter(endDate)) {
      // After budget ends
      elapsedDays = totalDays;
    } else {
      // During budget period
      elapsedDays = now.difference(startDate).inDays + 1;
    }

    // Calculate spending ratio (how much of budget is spent)
    final spendRatio = totalSpent / totalBudget;

    // Calculate time ratio (how much of period has elapsed)
    // Add 0.3 to prevent extreme values at start of period
    final timeRatio = totalDays > 0 ? (elapsedDays + 0.3) / totalDays : 1.0;

    // Edge case: Avoid division by zero
    if (timeRatio == 0) return 0.0;

    // Calculate and return BAR
    // Higher value = spending faster than time passing
    return spendRatio / timeRatio;
  }

  /// Builds monthly spending overview for current calendar month.
  ///
  /// **Purpose**:
  /// Provides visibility into all spending for the month, breaking down
  /// transactions by budget assignment status (budgeted vs unassigned).
  ///
  /// **Algorithm**:
  /// 1. Calculate month's date range (1st day 00:00 to last day 23:59:59)
  /// 2. Filter transactions for current month (debit only)
  /// 3. Separate budgeted (budgetId != null) vs unassigned (budgetId == null)
  /// 4. Calculate spending totals for each category
  /// 5. Calculate percentage vs total budgeted amount
  ///
  /// **Parameters**:
  /// - `month`: The month to build overview for (typically DateTime.now())
  ///
  /// **Returns**: Complete [MonthlyOverviewModel] with all metrics
  ///
  /// **Example**:
  /// ```dart
  /// final overview = _buildMonthlyOverviewModel(DateTime(2024, 12, 15));
  /// // Returns data for entire December 2024 (Dec 1 - Dec 31)
  /// ```
  MonthlyOverviewModel _buildMonthlyOverviewModel(DateTime month) {
    // Get current month's date range (normalized to full month)
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    // Filter transactions for current month (debit only)
    // Credit transactions are excluded from monthly overview
    final monthTransactions = _transactionRepository.transactions.where((t) {
      return !t.transactionDate.isBefore(monthStart) &&
          !t.transactionDate.isAfter(monthEnd) &&
          t.type == TransactionType.debit;
    }).toList();

    // Separate budgeted vs unassigned transactions
    final budgetedTransactions =
        monthTransactions.where((t) => t.budgetId != null).toList();
    final unassignedTransactions =
        monthTransactions.where((t) => t.budgetId == null).toList();

    // Calculate spending totals
    final budgetedSpent =
        budgetedTransactions.fold<double>(0, (sum, t) => sum + t.amount);
    final unassignedSpent =
        unassignedTransactions.fold<double>(0, (sum, t) => sum + t.amount);
    final totalSpent = budgetedSpent + unassignedSpent;

    // Calculate total budgeted amount for active budgets overlapping this month
    final activeBudgets = _budgetRepository.getActiveBudgets().where((b) {
      // Budget overlaps with month if it doesn't end before month starts
      // AND doesn't start after month ends
      return !(b.endDate.isBefore(monthStart) || b.startDate.isAfter(monthEnd));
    }).toList();

    final totalBudgetedAmount = activeBudgets.fold<double>(0, (sum, budget) {
      final allocations = _allocationRepository.getAllocationsForBudget(budget.id);
      return sum + allocations.fold<double>(0, (s, a) => s + a.amount);
    });

    // Calculate percentage of budgeted spending vs total budget
    final percentageSpent = totalBudgetedAmount > 0
        ? (budgetedSpent / totalBudgetedAmount * 100)
        : 0.0;

    return MonthlyOverviewModel(
      month: monthStart,
      totalSpent: totalSpent,
      budgetedSpent: budgetedSpent,
      unassignedSpent: unassignedSpent,
      budgetedCount: budgetedTransactions.length,
      unassignedCount: unassignedTransactions.length,
      percentageSpent: percentageSpent,
      hasUnassignedSpending: unassignedSpent > 0,
    );
  }

  /// Public method to manually refresh dashboard data.
  ///
  /// Called by pull-to-refresh in UI.
  ///
  /// **Example**:
  /// ```dart
  /// RefreshIndicator(
  ///   onRefresh: () async {
  ///     context.read<DashboardCubit>().refresh();
  ///   },
  ///   child: DashboardView(),
  /// )
  /// ```
  Future<void> refresh() {
    _loadDashboardData();
    return Future.value();
  }

  /// Cancels all stream subscriptions when cubit is closed.
  ///
  /// **Critical**: Prevents memory leaks by cleaning up subscriptions.
  /// Called automatically by BLoC when the cubit is disposed.
  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    _allocationSubscription?.cancel();
    _transactionSubscription?.cancel();
    _categorySubscription?.cancel();
    return super.close();
  }
}
