# BudgetRepository

Manages budget data with reactive streams, active budget filtering, and period calculations.

## Overview

`BudgetRepository` coordinates budget data access between the local database and domain models. It provides reactive streams, synchronous getters, and specialized methods for filtering active budgets.

**Location:** `lib/data/repositories/budget_repository.dart`

## Class Definition

```dart
class BudgetRepository with RepositoryLogger {
  @override
  String get repositoryName => 'BudgetRepository';

  final BudgetLocalSource _localSource;
  final _budgetsController =
    StreamController<List<BudgetModel>>.broadcast();
  StreamSubscription? _dbSubscription;
  List<BudgetModel> _latestBudgets = [];

  BudgetRepository(this._localSource) {
    _subscribeToLocalChanges();
  }

  Stream<List<BudgetModel>> get budgetsStream =>
    _budgetsController.stream;

  List<BudgetModel> get budgets => _latestBudgets;

  List<BudgetModel> getActiveBudgets() =>
    _latestBudgets.where((b) => b.isActive()).toList();
}
```

## Properties

### `budgetsStream` (Stream, read-only)
Reactive broadcast stream that emits when budget data changes.

**Type:** `Stream<List<BudgetModel>>`

**Usage:**
```dart
_budgetSubscription = _budgetRepository
  .budgetsStream
  .listen((_) => _loadDashboard());
```

### `budgets` (List, read-only)
Synchronous getter for cached budget list.

**Type:** `List<BudgetModel>`

**Usage:**
```dart
final allBudgets = _budgetRepository.budgets;
```

## Methods

### `createBudget()`

Creates a new budget.

**Signature:**
```dart
Future<void> createBudget(BudgetModel model)
```

**Example:**
```dart
final budget = BudgetModel.create(
  name: 'December 2025',
  amount: 2000.00,
  startDate: DateTime(2025, 12, 1),
  endDate: DateTime(2025, 12, 31, 23, 59, 59),
);

await repository.createBudget(budget);
```

### `updateBudget()`

Updates an existing budget.

**Signature:**
```dart
Future<void> updateBudget(BudgetModel model)
```

**Side effects:**
- Automatically updates `updatedAt` via `.withUpdatedTimestamp()`

**Example:**
```dart
final updated = budget
  .withUpdatedTimestamp()
  .copyWith(amount: 2500.00);

await repository.updateBudget(updated);
```

### `deleteBudget()`

Soft deletes a budget.

**Signature:**
```dart
Future<void> deleteBudget(String id)
```

**Example:**
```dart
await repository.deleteBudget(budgetId);
```

### `getBudgetById()`

Fetches a single budget by ID.

**Signature:**
```dart
Future<BudgetModel?> getBudgetById(String id)
```

**Returns:** Budget model or `null` if not found.

**Example:**
```dart
final budget = await repository.getBudgetById(budgetId);
if (budget != null) {
  print('Budget: ${budget.name}, Amount: ${budget.amount}');
}
```

### `getActiveBudgets()`

Gets budgets that are currently active (synchronous).

**Signature:**
```dart
List<BudgetModel> getActiveBudgets()
```

**Returns:** List of budgets where current date falls within period.

**Algorithm:**
Uses `BudgetModel.isActive()` extension:
```dart
bool isActive() {
  final now = DateTime.now();
  return !now.isBefore(startDate) && !now.isAfter(endDate);
}
```

**Example:**
```dart
// Get all active budgets
final activeBudgets = repository.getActiveBudgets();

print('Active budgets:');
for (final budget in activeBudgets) {
  final progress = budget.elapsedDays() / budget.totalDays();
  print('${budget.name}: ${(progress * 100).toInt()}% complete');
}
```

**Use cases:**
- Dashboard displays active budgets only
- Budget list filters (Active / Archived tabs)
- BAR calculations focus on active periods

### `sync()`

Stub for future API sync.

**Signature:**
```dart
Future<void> sync()
```

## Usage Examples

### Create Monthly Budget

```dart
final now = DateTime.now();
final startDate = DateTime(now.year, now.month, 1);
final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

final budget = BudgetModel.create(
  name: _getMonthName(now.month),
  amount: 2000.00,
  startDate: startDate,
  endDate: endDate,
);

await budgetRepository.createBudget(budget);
```

### Display Active Budgets

```dart
final activeBudgets = budgetRepository.getActiveBudgets();

if (activeBudgets.isEmpty) {
  print('No active budgets');
} else {
  for (final budget in activeBudgets) {
    final elapsed = budget.elapsedDays();
    final total = budget.totalDays();
    final percent = (elapsed / total * 100).toInt();

    print('${budget.name}: Day $elapsed/$total ($percent%)');
  }
}
```

### Check Budget Status

```dart
final budget = await budgetRepository.getBudgetById(budgetId);

if (budget == null) {
  print('Budget not found');
  return;
}

if (budget.isActive()) {
  print('${budget.name} is active');
  print('Days remaining: ${budget.totalDays() - budget.elapsedDays()}');
} else {
  final now = DateTime.now();
  if (now.isBefore(budget.startDate)) {
    print('Budget has not started yet');
  } else {
    print('Budget has ended');
  }
}
```

### Update Budget Period

```dart
// Extend budget by 7 days
final budget = await budgetRepository.getBudgetById(budgetId);
final extended = budget!
  .withUpdatedTimestamp()
  .copyWith(
    endDate: budget.endDate.add(Duration(days: 7)),
  );

await budgetRepository.updateBudget(extended);
```

## Stream Subscription

```dart
class DashboardCubit extends Cubit<DashboardState> {
  final BudgetRepository _budgetRepository;
  StreamSubscription? _budgetSubscription;

  DashboardCubit(this._budgetRepository)
    : super(const DashboardState.initial()) {
    _budgetSubscription = _budgetRepository
      .budgetsStream
      .listen((_) => _loadData());

    _loadData();
  }

  void _loadData() {
    final activeBudgets = _budgetRepository.getActiveBudgets();
    // Build dashboard data...
    emit(DashboardState.success(budgets: activeBudgets));
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    return super.close();
  }
}
```

## Period Calculations

BudgetRepository leverages `BudgetModel` extension methods:

### `isActive()`
```dart
final isActive = budget.isActive();
// true if current time is within budget period
```

### `totalDays()`
```dart
final totalDays = budget.totalDays();
// Total days in budget period (inclusive)
```

### `elapsedDays()`
```dart
final elapsedDays = budget.elapsedDays();
// Days elapsed in budget period
// Returns 0 if before start, totalDays if after end
```

### Example: Calculate Progress
```dart
final budget = await budgetRepository.getBudgetById(budgetId);
final elapsed = budget.elapsedDays();
final total = budget.totalDays();
final progress = elapsed / total;

print('${budget.name}: ${(progress * 100).toInt()}% complete');
print('Days remaining: ${total - elapsed}');
```

## Best Practices

### Use `getActiveBudgets()` for Dashboard
Filter active budgets synchronously:

```dart
// ✅ Good - synchronous active filtering
final activeBudgets = repository.getActiveBudgets();

// ❌ Bad - manual filtering
final allBudgets = repository.budgets;
final activeBudgets = allBudgets.where((b) {
  final now = DateTime.now();
  return !now.isBefore(b.startDate) && !now.isAfter(b.endDate);
}).toList();
```

### Use `withUpdatedTimestamp()` for Updates
Let helper manage timestamp:

```dart
// ✅ Good - timestamp managed automatically
final updated = budget
  .withUpdatedTimestamp()
  .copyWith(amount: 2500.00);

// ❌ Bad - manual timestamp
final updated = budget.copyWith(
  amount: 2500.00,
  updatedAt: DateTime.now(),
);
```

### Set Proper Date Boundaries
Use full day ranges:

```dart
// ✅ Good - full day coverage
BudgetModel.create(
  startDate: DateTime(2025, 12, 1, 0, 0, 0),
  endDate: DateTime(2025, 12, 31, 23, 59, 59),
  ...
)

// ❌ Bad - may miss transactions at end of day
BudgetModel.create(
  startDate: DateTime(2025, 12, 1),
  endDate: DateTime(2025, 12, 31), // Only to midnight!
  ...
)
```

## See Also

- [BudgetModel](../models/budget-model.md) - Budget domain model
- [AllocationRepository](./allocation-repository.md) - Budget allocations
- [DashboardCubit](../cubits/dashboard-cubit.md) - BAR calculations
