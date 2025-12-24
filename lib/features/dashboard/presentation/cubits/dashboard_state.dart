import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/models/transactions_chart_data.dart';

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

  /// Success state with loaded budget pages.
  ///
  /// Contains the aggregated data for all active budgets.
  /// Each [BudgetPageModel] has all the data needed to render one budget card.
  ///
  /// **Parameters**:
  /// - `budgetPages`: List of aggregated budget data (can be empty if no active budgets)
  const factory DashboardState.success({
    required List<BudgetPageModel> budgetPages,
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
