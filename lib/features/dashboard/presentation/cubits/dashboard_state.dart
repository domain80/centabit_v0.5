import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/models/transactions_chart_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_state.freezed.dart';

/// States for the dashboard screen.
///
/// Represents the different states the dashboard can be in while loading
/// and displaying budget report data.
///
/// **State Flow**:
/// ```
/// initial → loading → success (with budget pages)
///                  ↓
///                error (if something fails)
/// ```
///
/// **Usage in Widgets**:
/// ```dart
/// BlocBuilder<DashboardCubit, DashboardState>(
///   builder: (context, state) {
///     return state.when(
///       initial: () => const SizedBox(),
///       loading: () => const CircularProgressIndicator(),
///       success: (budgetPages) => BudgetReportSection(pages: budgetPages),
///       error: (message) => Text('Error: $message'),
///     );
///   },
/// )
/// ```
@freezed
abstract class DashboardState with _$DashboardState {
  /// Initial state before any data is loaded.
  ///
  /// Shown briefly when the dashboard first opens.
  const factory DashboardState.initial() = _Initial;

  /// Loading state while fetching and aggregating data.
  ///
  /// Shown when:
  /// - Dashboard is first loading
  /// - User triggers refresh
  /// - Any underlying data changes (budget, allocation, transaction, category)
  const factory DashboardState.loading() = _Loading;

  /// Success state with loaded budget pages and monthly overview.
  ///
  /// Contains the aggregated data for all active budgets and monthly spending overview.
  /// Each [BudgetPageModel] has all the data needed to render one budget card.
  ///
  /// **Parameters**:
  /// - `budgetPages`: List of aggregated budget data (can be empty if no active budgets)
  /// - `monthlyOverview`: Monthly spending overview for current calendar month
  const factory DashboardState.success({
    required List<BudgetPageModel> budgetPages,
    required MonthlyOverviewModel monthlyOverview,
  }) = _Success;

  /// Error state when data loading fails.
  ///
  /// Shown when:
  /// - Data aggregation fails
  /// - Service throws an exception
  ///
  /// **Parameters**:
  /// - `message`: Human-readable error description
  const factory DashboardState.error(String message) = _Error;
}

/// Aggregated view model for one budget page in the dashboard.
///
/// This is NOT a freezed class because it's a simple data holder that doesn't
/// need serialization or complex equality. It's created fresh on each state
/// emission by [DashboardCubit].
///
/// **Contains All Data for One Budget Card**:
/// - Budget metadata (name, amount, dates)
/// - BAR metric (spending health indicator)
/// - Chart data (allocations vs transactions per category)
/// - Spending totals
///
/// **Data Flow**:
/// ```
/// Services (4) → DashboardCubit._buildBudgetPageModel()
///   ↓
/// Combines: Budget + Allocations + Transactions + Categories
///   ↓
/// Creates: BudgetPageModel
///   ↓
/// Emits: DashboardState.success([BudgetPageModel, ...])
///   ↓
/// UI: BudgetReportSection renders PageView
/// ```
///
/// **Example**:
/// ```dart
/// final page = BudgetPageModel(
///   budget: decemberBudget,
///   barIndexValue: 0.85, // Spending slower than planned (good!)
///   chartData: [
///     TransactionsChartData(
///       categoryId: '123',
///       categoryName: 'Groceries',
///       categoryIconName: 'cart',
///       allocationAmount: 400.0,
///       transactionAmount: 325.50,
///     ),
///     // ... more categories
///   ],
///   totalBudget: 1550.0,
///   totalSpent: 892.45,
/// );
/// ```
class BudgetPageModel {
  /// The budget this page represents.
  ///
  /// Contains name, amount, startDate, endDate, etc.
  final BudgetModel budget;

  /// Budget Available Ratio (BAR) value.
  ///
  /// **Calculation**:
  /// ```
  /// BAR = (totalSpent / totalBudget) / (elapsedDays / totalDays)
  /// ```
  ///
  /// **Interpretation**:
  /// - < 1.0: Under-spending, on track or ahead
  /// - = 1.0: Spending at exactly expected pace
  /// - > 1.0: Over-spending, may run out of budget early
  /// - > 1.2: Significantly over budget (triggers error color)
  ///
  /// **Example**:
  /// ```
  /// Budget: $1000, Period: 30 days
  /// Spent: $400 in 10 days
  /// Elapsed: 10/30 = 0.33 (33%)
  /// Spend ratio: 400/1000 = 0.40 (40%)
  /// BAR = 0.40 / 0.33 = 1.21 ⚠️ Over pace!
  /// ```
  final double barIndexValue;

  /// Chart data for all categories.
  ///
  /// Contains one entry per category with:
  /// - Allocation amount (budgeted)
  /// - Transaction amount (actual spending)
  /// - Category metadata (name, icon)
  ///
  /// Used by [BudgetBarChart] to render side-by-side bars.
  final List<TransactionsChartData> chartData;

  /// Total budgeted amount across all allocations.
  ///
  /// Sum of all allocation amounts for this budget.
  /// May be less than `budget.amount` if not fully allocated.
  ///
  /// **Example**:
  /// ```
  /// Budget.amount: $2000
  /// Total allocations: $1550 (7 categories)
  /// Unallocated: $450
  /// ```
  final double totalBudget;

  /// Total spent amount across all transactions.
  ///
  /// Sum of all transaction amounts for this budget.
  /// Credit transactions are subtracted (income reduces spending).
  ///
  /// **Calculation**:
  /// ```
  /// totalSpent = sum of transactions where:
  ///   - type == debit: add amount
  ///   - type == credit: subtract amount
  /// ```
  final double totalSpent;

  /// Creates a budget page model with all required data.
  ///
  /// All fields are required and must be computed by [DashboardCubit].
  const BudgetPageModel({
    required this.budget,
    required this.barIndexValue,
    required this.chartData,
    required this.totalBudget,
    required this.totalSpent,
  });

  /// Calculates remaining budget.
  ///
  /// Returns: `totalBudget - totalSpent`
  ///
  /// **Interpretation**:
  /// - Positive: Funds remaining
  /// - Zero: Exactly on budget
  /// - Negative: Over budget
  double get remainingBudget => totalBudget - totalSpent;

  /// Calculates spending percentage.
  ///
  /// Returns: `(totalSpent / totalBudget) * 100`
  ///
  /// **Special Cases**:
  /// - Returns 0% if totalBudget is 0
  /// - Can exceed 100% if overspending
  double get spendingPercentage {
    if (totalBudget <= 0) return 0.0;
    return (totalSpent / totalBudget) * 100;
  }

  /// Checks if spending exceeds budget.
  ///
  /// Returns `true` if `totalSpent > totalBudget`.
  bool get isOverBudget => totalSpent > totalBudget;

  /// Returns a string representation for debugging.
  ///
  /// **Example Output**:
  /// ```
  /// BudgetPageModel(
  ///   December 2025: spent=$892.45/$1550.00 (57.6%), BAR=0.85
  /// )
  /// ```
  @override
  String toString() {
    return 'BudgetPageModel('
        '${budget.name}: '
        'spent=\$${totalSpent.toStringAsFixed(2)}/\$${totalBudget.toStringAsFixed(2)} '
        '(${spendingPercentage.toStringAsFixed(1)}%), '
        'BAR=${barIndexValue.toStringAsFixed(2)}'
        ')';
  }

  /// Equality based on budget ID.
  ///
  /// Two page models are equal if they represent the same budget.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetPageModel && other.budget.id == budget.id;
  }

  @override
  int get hashCode => budget.id.hashCode;
}

/// View model for monthly spending overview.
///
/// Provides a summary of spending for the current calendar month,
/// breaking down transactions into budgeted vs unassigned categories.
///
/// **Purpose**:
/// This model enables users to see all spending for the month regardless
/// of budget assignments, addressing the selective BAR calculation issue
/// where users need visibility into unassigned transactions.
///
/// **Time Period**: Current calendar month (not budget period)
/// - Month starts: 1st day at 00:00:00
/// - Month ends: Last day at 23:59:59
///
/// **Data Breakdown**:
/// - **Budgeted**: Transactions with `budgetId != null`
/// - **Unassigned**: Transactions with `budgetId == null`
/// - **Total**: Sum of both categories
///
/// **Example**:
/// ```dart
/// MonthlyOverviewModel(
///   month: DateTime(2024, 12, 1),
///   totalSpent: 1523.45,
///   budgetedSpent: 1245.30,
///   unassignedSpent: 278.15,
///   budgetedCount: 23,
///   unassignedCount: 5,
///   percentageSpent: 80.3, // 1245.30 / 1550.00 total budget
///   hasUnassignedSpending: true,
/// )
/// ```
class MonthlyOverviewModel {
  /// The month this overview represents (normalized to first day of month).
  ///
  /// Always set to: `DateTime(year, month, 1)`
  final DateTime month;

  /// Total amount spent in the month (budgeted + unassigned).
  ///
  /// Includes only debit transactions. Credit transactions are excluded
  /// from monthly overview calculations.
  final double totalSpent;

  /// Amount spent on budgeted transactions.
  ///
  /// Transactions where `budgetId != null`.
  final double budgetedSpent;

  /// Amount spent on unassigned transactions.
  ///
  /// Transactions where `budgetId == null`.
  /// This is highlighted with a warning if > 0 to encourage budget assignment.
  final double unassignedSpent;

  /// Number of budgeted transactions.
  ///
  /// Count of transactions with `budgetId != null`.
  final int budgetedCount;

  /// Number of unassigned transactions.
  ///
  /// Count of transactions with `budgetId == null`.
  final int unassignedCount;

  /// Percentage of budgeted spending vs total budget allocations.
  ///
  /// **Calculation**:
  /// ```dart
  /// percentageSpent = (budgetedSpent / totalBudgetedAmount) * 100
  /// ```
  ///
  /// Where `totalBudgetedAmount` is the sum of all allocations for active
  /// budgets overlapping with this month.
  ///
  /// **Special Cases**:
  /// - Returns 0% if no active budgets
  /// - Can exceed 100% if overspending
  final double percentageSpent;

  /// Whether there are any unassigned transactions.
  ///
  /// `true` if `unassignedSpent > 0`, used to trigger warning UI.
  final bool hasUnassignedSpending;

  /// Creates a monthly overview model.
  ///
  /// All fields are required and must be computed by [DashboardCubit].
  const MonthlyOverviewModel({
    required this.month,
    required this.totalSpent,
    required this.budgetedSpent,
    required this.unassignedSpent,
    required this.budgetedCount,
    required this.unassignedCount,
    required this.percentageSpent,
    required this.hasUnassignedSpending,
  });

  /// Total number of transactions (budgeted + unassigned).
  int get totalCount => budgetedCount + unassignedCount;

  /// Percentage of unassigned spending vs total spending.
  ///
  /// Returns: `(unassignedSpent / totalSpent) * 100`
  ///
  /// **Special Cases**:
  /// - Returns 0% if totalSpent is 0
  double get unassignedPercentage {
    if (totalSpent <= 0) return 0.0;
    return (unassignedSpent / totalSpent) * 100;
  }

  /// Percentage of budgeted spending vs total spending.
  ///
  /// Returns: `(budgetedSpent / totalSpent) * 100`
  ///
  /// **Special Cases**:
  /// - Returns 0% if totalSpent is 0
  double get budgetedPercentage {
    if (totalSpent <= 0) return 0.0;
    return (budgetedSpent / totalSpent) * 100;
  }

  /// Returns a string representation for debugging.
  ///
  /// **Example Output**:
  /// ```
  /// MonthlyOverviewModel(
  ///   December 2024: total=$1523.45, budgeted=$1245.30 (81.7%), unassigned=$278.15 (18.3%)
  /// )
  /// ```
  @override
  String toString() {
    final monthName = _getMonthName(month.month);
    return 'MonthlyOverviewModel('
        '$monthName ${month.year}: '
        'total=\$${totalSpent.toStringAsFixed(2)}, '
        'budgeted=\$${budgetedSpent.toStringAsFixed(2)} (${budgetedPercentage.toStringAsFixed(1)}%), '
        'unassigned=\$${unassignedSpent.toStringAsFixed(2)} (${unassignedPercentage.toStringAsFixed(1)}%)'
        ')';
  }

  /// Helper to get month name from month number.
  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  /// Equality based on month.
  ///
  /// Two models are equal if they represent the same month/year.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthlyOverviewModel &&
        other.month.year == month.year &&
        other.month.month == month.month;
  }

  @override
  int get hashCode => month.hashCode;
}
