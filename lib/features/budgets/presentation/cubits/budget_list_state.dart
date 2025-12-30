import 'package:centabit/data/models/allocation_model.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_list_state.freezed.dart';

/// States for the budget list screen.
///
/// Represents the different states the budget list can be in while loading
/// and displaying budgets with their allocations.
///
/// **State Flow**:
/// ```
/// initial → loading → success (with budgets list)
///                  ↓
///                error (if something fails)
/// ```
///
/// **Usage in Widgets**:
/// ```dart
/// BlocBuilder<BudgetListCubit, BudgetListState>(
///   builder: (context, state) {
///     return state.when(
///       initial: () => const SizedBox(),
///       loading: () => const CircularProgressIndicator(),
///       success: (budgets) => BudgetList(budgets: budgets),
///       error: (message) => Text('Error: $message'),
///     );
///   },
/// )
/// ```
@freezed
abstract class BudgetListState with _$BudgetListState {
  /// Initial state before any data is loaded.
  ///
  /// Shown briefly when the budgets page first opens.
  const factory BudgetListState.initial() = _Initial;

  /// Loading state while fetching budgets and allocations.
  ///
  /// Shown when:
  /// - Page is first loading
  /// - User triggers refresh
  /// - Any underlying data changes (budget or allocation)
  const factory BudgetListState.loading() = _Loading;

  /// Success state with loaded budgets.
  ///
  /// Contains the aggregated data for all budgets with their allocations.
  /// Each [BudgetListVModel] has all the data needed to render one budget tile.
  ///
  /// **Parameters**:
  /// - `budgets`: List of budget view models (can be empty if no budgets exist)
  const factory BudgetListState.success({
    required List<BudgetListVModel> budgets,
  }) = _Success;

  /// Error state when data loading fails.
  ///
  /// Shown when:
  /// - Data aggregation fails
  /// - Repository throws an exception
  ///
  /// **Parameters**:
  /// - `message`: Human-readable error description
  const factory BudgetListState.error(String message) = _Error;
}

/// Aggregated view model for one budget in the list.
///
/// This is NOT a freezed class because it's a simple data holder that doesn't
/// need serialization or complex equality. It's created fresh on each state
/// emission by [BudgetListCubit].
///
/// **Contains All Data for One Budget Tile**:
/// - Budget metadata (name, amount, dates)
/// - Associated allocations
/// - Calculated metrics (total allocated, days remaining)
/// - Status flags (active, upcoming, expired)
///
/// **Data Flow**:
/// ```
/// Repositories (2) → BudgetListCubit._loadBudgets()
///   ↓
/// Combines: Budget + Allocations
///   ↓
/// Creates: BudgetListVModel
///   ↓
/// Emits: BudgetListState.success([BudgetListVModel, ...])
///   ↓
/// UI: BudgetTile renders each item
/// ```
///
/// **Example**:
/// ```dart
/// final viewModel = BudgetListVModel(
///   budget: decemberBudget,
///   allocations: [groceriesAlloc, diningAlloc],
///   totalAllocated: 700.0,
///   isActive: true,
/// );
/// ```
class BudgetListVModel {
  /// The budget this view model represents.
  ///
  /// Contains name, amount, startDate, endDate, createdAt, updatedAt.
  final BudgetModel budget;

  /// All allocations associated with this budget.
  ///
  /// Used to display:
  /// - Allocation count (e.g., "7 categories")
  /// - Total allocated vs budget amount
  /// - Progress indicator
  final List<AllocationModel> allocations;

  /// Total amount allocated across all categories.
  ///
  /// Sum of all allocation amounts for this budget.
  /// May be less than `budget.amount` if not fully allocated.
  ///
  /// **Example**:
  /// ```
  /// Budget.amount: $2000
  /// Total allocations: $1550 (7 categories)
  /// Unallocated: $450 (22.5%)
  /// ```
  final double totalAllocated;

  /// Whether this budget's period is currently active.
  ///
  /// Returns `true` if current date is between startDate and endDate.
  ///
  /// **Usage**:
  /// - Display status badge ("Active", "Upcoming", "Expired")
  /// - Highlight active budgets
  /// - Filter for dropdown selections
  final bool isActive;

  /// Creates a budget list view model.
  ///
  /// All fields are required and must be computed by [BudgetListCubit].
  const BudgetListVModel({
    required this.budget,
    required this.allocations,
    required this.totalAllocated,
    required this.isActive,
  });

  /// Calculates days remaining in budget period.
  ///
  /// Returns:
  /// - Positive: Days remaining until endDate
  /// - Zero: Last day of period
  /// - Negative: Days since period ended
  int get daysRemaining => budget.endDate.difference(DateTime.now()).inDays;

  /// Calculates days until budget period starts.
  ///
  /// Returns:
  /// - Positive: Days until startDate
  /// - Zero or negative: Period has started
  int get daysUntilStart => budget.startDate.difference(DateTime.now()).inDays;

  /// Calculates unallocated budget amount.
  ///
  /// Returns: `budget.amount - totalAllocated`
  ///
  /// **Interpretation**:
  /// - Positive: Funds available to allocate
  /// - Zero: Fully allocated
  /// - Negative: Over-allocated (should be prevented by validation)
  double get unallocated => budget.amount - totalAllocated;

  /// Calculates allocation percentage.
  ///
  /// Returns: `(totalAllocated / budget.amount) * 100`
  ///
  /// **Special Cases**:
  /// - Returns 0% if budget.amount is 0
  /// - Can exceed 100% if over-allocated
  double get allocationPercentage {
    if (budget.amount <= 0) return 0.0;
    return (totalAllocated / budget.amount) * 100;
  }

  /// Checks if budget is upcoming (not yet started).
  ///
  /// Returns `true` if current date is before startDate.
  bool get isUpcoming => DateTime.now().isBefore(budget.startDate);

  /// Checks if budget period has expired.
  ///
  /// Returns `true` if current date is after endDate.
  bool get isExpired => DateTime.now().isAfter(budget.endDate);

  /// Returns status text for display.
  ///
  /// **Returns**:
  /// - "Active • X days left" if active
  /// - "Upcoming • Starts in X days" if upcoming
  /// - "Expired • Ended X days ago" if expired
  String get statusText {
    if (isUpcoming) {
      final days = daysUntilStart;
      return days == 1 ? 'Upcoming • Starts tomorrow' : 'Upcoming • Starts in $days days';
    } else if (isActive) {
      final days = daysRemaining;
      if (days == 0) return 'Active • Last day';
      return days == 1 ? 'Active • 1 day left' : 'Active • $days days left';
    } else {
      final days = -daysRemaining;
      return days == 1 ? 'Expired • Ended yesterday' : 'Expired • Ended $days days ago';
    }
  }

  /// Returns a string representation for debugging.
  ///
  /// **Example Output**:
  /// ```
  /// BudgetListVModel(
  ///   December 2025: allocated=$1550.00/$2000.00 (77.5%), status=Active
  /// )
  /// ```
  @override
  String toString() {
    return 'BudgetListVModel('
        '${budget.name}: '
        'allocated=\$${totalAllocated.toStringAsFixed(2)}/\$${budget.amount.toStringAsFixed(2)} '
        '(${allocationPercentage.toStringAsFixed(1)}%), '
        'status=${isActive ? "Active" : isUpcoming ? "Upcoming" : "Expired"}'
        ')';
  }

  /// Equality based on budget ID.
  ///
  /// Two view models are equal if they represent the same budget.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetListVModel && other.budget.id == budget.id;
  }

  @override
  int get hashCode => budget.id.hashCode;
}
