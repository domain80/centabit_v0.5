# DashboardCubit

Manages dashboard state with budget reports, BAR calculations, and monthly spending overview.

## Overview

`DashboardCubit` orchestrates data from 4 repositories to build comprehensive budget reports with BAR (Budget Adherence Ratio) calculations and chart data.

**Location:** `lib/features/dashboard/presentation/cubits/dashboard_cubit.dart`

## Class Definition

```dart
class DashboardCubit extends Cubit<DashboardState> {
  final BudgetRepository _budgetRepository;
  final AllocationRepository _allocationRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final SmartBudgetCalculator _barCalculator = SmartBudgetCalculator();

  StreamSubscription? _budgetSubscription;
  StreamSubscription? _allocationSubscription;
  StreamSubscription? _transactionSubscription;
  StreamSubscription? _categorySubscription;

  DashboardCubit(
    this._budgetRepository,
    this._allocationRepository,
    this._transactionRepository,
    this._categoryRepository,
  ) : super(const DashboardState.initial()) {
    _subscribeToStreams();
  }
}
```

## State

### DashboardState

```dart
@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = _Initial;
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.success({
    required List<BudgetPageModel> budgetPages,
    required MonthlyOverviewModel monthlyOverview,
  }) = _Success;
  const factory DashboardState.error(String message) = _Error;
}
```

**State Flow:**
```
initial (cubit created)
  ↓
loading (data being aggregated)
  ↓
success (budget pages + monthly overview ready)
or
error (aggregation failed)
```

### BudgetPageModel

Aggregate view model for one budget page:

```dart
class BudgetPageModel {
  final BudgetModel budget;                    // Budget metadata
  final double barIndexValue;                  // BAR calculation
  final List<TransactionsChartData> chartData; // Chart data per category
  final double totalBudget;                    // Sum of allocations
  final double totalSpent;                     // Sum of transactions

  // Computed properties
  double get remainingBudget => totalBudget - totalSpent;
  double get spendingPercentage => (totalSpent / totalBudget) * 100;
  bool get isOverBudget => totalSpent > totalBudget;
}
```

### MonthlyOverviewModel

Monthly spending breakdown:

```dart
class MonthlyOverviewModel {
  final DateTime month;            // Month being displayed
  final double totalSpent;         // All debit transactions
  final double budgetedSpent;      // Transactions with budgetId
  final double unassignedSpent;    // Transactions without budgetId
  final int budgetedCount;         // Count of budgeted transactions
  final int unassignedCount;       // Count of unassigned transactions
  final double percentageSpent;    // Budgeted vs total budget
  final bool hasUnassignedSpending; // Warning flag
}
```

## Methods

### Constructor

Initializes cubit and subscribes to repository streams.

**Signature:**
```dart
DashboardCubit(
  BudgetRepository budgetRepository,
  AllocationRepository allocationRepository,
  TransactionRepository transactionRepository,
  CategoryRepository categoryRepository,
)
```

**Side effects:**
- Subscribes to 4 repository streams
- Triggers initial data load

**Example (via GetIt):**
```dart
BlocProvider(
  create: (_) => getIt<DashboardCubit>(),
  child: DashboardPage(),
)
```

### `refresh()`

Manually triggers dashboard data reload.

**Signature:**
```dart
Future<void> refresh()
```

**Returns:** Future that completes immediately (for RefreshIndicator).

**Example:**
```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<DashboardCubit>().refresh();
  },
  child: DashboardView(),
)
```

## Private Methods

### `_subscribeToStreams()`

Subscribes to all repository streams for reactive updates.

**Triggers reload on:**
- Budget changes (create, update, delete)
- Allocation changes (create, update, delete)
- Transaction changes (create, update, delete)
- Category changes (update - affects chart labels)

**Implementation:**
```dart
void _subscribeToStreams() {
  _budgetSubscription = _budgetRepository.budgetsStream
    .listen((_) => _loadDashboardData());

  _allocationSubscription = _allocationRepository.allocationsStream
    .listen((_) => _loadDashboardData());

  _transactionSubscription = _transactionRepository.transactionsStream
    .listen((_) => _loadDashboardData());

  _categorySubscription = _categoryRepository.categoriesStream
    .listen((_) => _loadDashboardData());

  _loadDashboardData(); // Initial load
}
```

### `_loadDashboardData()`

Main data aggregation method.

**Process:**
1. Emit loading state
2. Get all active budgets
3. Build `BudgetPageModel` for each budget
4. Build monthly overview for current month
5. Emit success state

**Error handling:** Catches exceptions and emits error state.

### `_buildBudgetPageModel(BudgetModel budget)`

Builds complete data for one budget page.

**Aggregates:**
- Budget metadata
- Allocations for this budget
- Transactions for this budget (budgetId matches AND in date range)
- All categories (for chart display)

**Computes:**
- Chart data (allocations vs transactions per category)
- Total budgeted amount (sum of allocations)
- Total spent amount (sum of transactions)
- BAR value

**Returns:** `BudgetPageModel` ready for UI rendering.

**Transaction filtering:**
```dart
final transactions = _transactionRepository.transactions.where((t) {
  final isInDateRange = !t.transactionDate.isBefore(budget.startDate) &&
                        !t.transactionDate.isAfter(budget.endDate);
  final isLinkedToBudget = t.budgetId == budget.id;
  return isInDateRange && isLinkedToBudget;
}).toList();
```

### `_buildChartData()`

Builds chart data combining allocations and transactions by category.

**Algorithm:**
1. Create map of allocations by category ID
2. Create map of transaction totals by category ID
3. For each category, create `TransactionsChartData` with both amounts

**Parameters:**
- `allocations` - Allocations for the budget
- `transactions` - Transactions for the budget
- `categories` - All categories (for complete chart)

**Returns:** List of `TransactionsChartData`, one per category.

**Example output:**
```
Groceries: allocated=$400, spent=$325.50
Dining: allocated=$300, spent=$187.20
Transport: allocated=$150, spent=$0
```

### `_calculateBAR()`

Calculates Budget Adherence Ratio using smart calculator.

**Parameters:**
- `totalBudget` - Total allocated amount
- `totalSpent` - Total spent so far
- `startDate` - Budget period start
- `endDate` - Budget period end
- `now` - Current date/time

**Returns:** BAR value from `SmartBudgetCalculator`.

**Formula (front-loaded curve):**
```
BAR = actualSpent / expectedSpent
where expectedSpent uses curve: a*t - (a-1)*t²
```

**Interpretation:**
- BAR < 0.85: Well under budget
- BAR 0.85-0.95: Slightly under budget
- BAR 0.95-1.05: Right on track
- BAR 1.05-1.15: Slightly over budget
- BAR > 1.15: Significantly over budget

**Example:**
```
Budget: $1500, Period: 30 days, Elapsed: 15 days, Spent: $800

Linear expected: $750 (50% of budget)
Smart expected: $938 (62.5% of budget - front-loaded)

Linear BAR: 1.07 (warning)
Smart BAR: 0.85 (good - under budget!)
```

### `_buildMonthlyOverviewModel(DateTime month)`

Builds monthly spending overview for current calendar month.

**Purpose:** Provides visibility into all spending, breaking down budgeted vs unassigned transactions.

**Algorithm:**
1. Calculate month's date range (1st day 00:00 to last day 23:59:59)
2. Filter transactions for current month (debit only)
3. Separate budgeted (budgetId != null) vs unassigned (budgetId == null)
4. Calculate spending totals for each category
5. Calculate percentage vs total budgeted amount

**Returns:** `MonthlyOverviewModel` with all metrics.

## Usage Examples

### Basic Setup

```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>(),
      child: DashboardView(),
    );
  }
}
```

### Display Budget Pages

```dart
class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          success: (budgetPages, monthlyOverview) => Column(
            children: [
              // Budget report section with PageView
              Expanded(
                child: PageView.builder(
                  itemCount: budgetPages.length,
                  itemBuilder: (context, index) {
                    final page = budgetPages[index];
                    return BudgetReportCard(page: page);
                  },
                ),
              ),

              // Monthly overview card
              MonthlyOverviewCard(overview: monthlyOverview),
            ],
          ),
          error: (message) => ErrorView(message: message),
        );
      },
    );
  }
}
```

### Refresh on Pull

```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<DashboardCubit>().refresh();
  },
  child: DashboardView(),
)
```

### Display BAR Indicator

```dart
class BARIndicator extends StatelessWidget {
  final double barValue;

  Color _getBarColor(double bar) {
    if (bar > 1.15) return Colors.red;
    if (bar > 1.05) return Colors.orange;
    if (bar > 0.95) return Colors.blue;
    return Colors.green;
  }

  String _getBarLabel(double bar) {
    if (bar > 1.15) return 'Significantly Over Budget';
    if (bar > 1.05) return 'Slightly Over Pace';
    if (bar > 0.95) return 'On Track';
    if (bar > 0.85) return 'Under Budget';
    return 'Well Under Budget';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'BAR: ${barValue.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getBarColor(barValue),
          ),
        ),
        Text(_getBarLabel(barValue)),
      ],
    );
  }
}
```

### Display Monthly Overview

```dart
class MonthlyOverviewCard extends StatelessWidget {
  final MonthlyOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Monthly Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),

            // Total spent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Spent:'),
                Text(
                  '\$${overview.totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Budgeted vs unassigned
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budgeted:'),
                Text('\$${overview.budgetedSpent.toStringAsFixed(2)}'),
              ],
            ),

            if (overview.hasUnassignedSpending) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unassigned:',
                    style: TextStyle(color: Colors.orange),
                  ),
                  Text(
                    '\$${overview.unassignedSpent.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ],

            // Percentage of budget spent
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: overview.percentageSpent / 100,
              backgroundColor: Colors.grey[300],
              color: overview.percentageSpent > 100
                ? Colors.red
                : Colors.blue,
            ),
            Text(
              '${overview.percentageSpent.toStringAsFixed(1)}% of budget',
            ),
          ],
        ),
      ),
    );
  }
}
```

## Data Flow

### Complete Update Cycle

```
1. User creates transaction
   ↓
2. FormCubit calls transactionRepository.createTransaction()
   ↓
3. Repository writes to LocalSource/database
   ↓
4. Drift watch() stream emits change
   ↓
5. TransactionRepository emits to transactionsStream
   ↓
6. DashboardCubit's _transactionSubscription fires
   ↓
7. _loadDashboardData() called
   ↓
8. For each active budget:
   - Get allocations
   - Filter transactions (budgetId + date range)
   - Build chart data
   - Calculate BAR
   - Create BudgetPageModel
   ↓
9. Build monthly overview
   ↓
10. Emit DashboardState.success(...)
   ↓
11. BlocBuilder rebuilds UI
   ↓
12. User sees updated BAR, chart, and monthly overview
```

## Performance Notes

### Full Reload on Any Change

Current implementation recalculates everything on any data change:

```dart
_transactionSubscription = _transactionRepository.transactionsStream
  .listen((_) {
    _loadDashboardData(); // Rebuilds ALL budget pages
  });
```

**Acceptable for:**
- In-memory data with <100 items
- Active budgets <10
- Modern devices

**Future optimizations:**
- Debouncing to prevent rapid successive updates
- Incremental updates (only recalculate changed budgets)
- Caching last computation

## Best Practices

### Subscribe to All Relevant Repositories

Dashboard depends on 4 repositories:

```dart
// ✅ Good - subscribes to all dependencies
_budgetSubscription = _budgetRepository.budgetsStream.listen(...);
_allocationSubscription = _allocationRepository.allocationsStream.listen(...);
_transactionSubscription = _transactionRepository.transactionsStream.listen(...);
_categorySubscription = _categoryRepository.categoriesStream.listen(...);

// ❌ Bad - misses category updates
// Only subscribes to budgets/transactions
// UI won't update when category names change
```

### Always Cancel Subscriptions

```dart
@override
Future<void> close() {
  _budgetSubscription?.cancel();
  _allocationSubscription?.cancel();
  _transactionSubscription?.cancel();
  _categorySubscription?.cancel();
  return super.close();
}
```

### Filter Transactions by Budget AND Date

```dart
// ✅ Good - both filters
final transactions = _transactionRepository.transactions.where((t) {
  final isInDateRange = !t.transactionDate.isBefore(budget.startDate) &&
                        !t.transactionDate.isAfter(budget.endDate);
  final isLinkedToBudget = t.budgetId == budget.id;
  return isInDateRange && isLinkedToBudget;
}).toList();

// ❌ Bad - only checks budgetId
// May include transactions outside budget period
final transactions = _transactionRepository.transactions
  .where((t) => t.budgetId == budget.id)
  .toList();
```

## See Also

- [DashboardState](./dashboard-cubit.md#dashboardstate) - State definition
- [BudgetRepository](../repositories/budget-repository.md) - Budget data access
- [TransactionRepository](../repositories/transaction-repository.md) - Transaction data
- [Understanding BAR](../../user-guide/understanding-bar.md) - BAR algorithm
