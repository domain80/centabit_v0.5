# AllocationRepository

Manages budget allocation data with reactive streams and specialized filtering methods.

## Overview

`AllocationRepository` coordinates allocation data access. It provides reactive streams and synchronous methods for filtering allocations by budget or category.

**Location:** `lib/data/repositories/allocation_repository.dart`

## Class Definition

```dart
class AllocationRepository with RepositoryLogger {
  @override
  String get repositoryName => 'AllocationRepository';

  final AllocationLocalSource _localSource;
  final _allocationsController =
    StreamController<List<AllocationModel>>.broadcast();
  StreamSubscription? _dbSubscription;
  List<AllocationModel> _latestAllocations = [];

  AllocationRepository(this._localSource) {
    _subscribeToLocalChanges();
  }

  Stream<List<AllocationModel>> get allocationsStream =>
    _allocationsController.stream;

  List<AllocationModel> get allocations => _latestAllocations;

  List<AllocationModel> getAllocationsForBudget(String budgetId) =>
    _latestAllocations.forBudget(budgetId);

  List<AllocationModel> getAllocationsForCategory(String categoryId) =>
    _latestAllocations.forCategory(categoryId);
}
```

## Properties

### `allocationsStream` (Stream, read-only)
Reactive broadcast stream that emits when allocation data changes.

**Type:** `Stream<List<AllocationModel>>`

**Usage:**
```dart
_allocationSubscription = _allocationRepository
  .allocationsStream
  .listen((_) => _loadDashboard());
```

### `allocations` (List, read-only)
Synchronous getter for cached allocation list.

**Type:** `List<AllocationModel>`

**Usage:**
```dart
final allAllocations = _allocationRepository.allocations;
```

## Methods

### `createAllocation()`

Creates a new allocation.

**Signature:**
```dart
Future<void> createAllocation(AllocationModel model)
```

**Example:**
```dart
final allocation = AllocationModel.create(
  amount: 500.00,
  categoryId: groceryCategoryId,
  budgetId: decemberBudgetId,
);

await repository.createAllocation(allocation);
```

### `updateAllocation()`

Updates an existing allocation.

**Signature:**
```dart
Future<void> updateAllocation(AllocationModel model)
```

**Side effects:**
- Automatically updates `updatedAt` via `.withUpdatedTimestamp()`

**Example:**
```dart
final updated = allocation
  .withUpdatedTimestamp()
  .copyWith(amount: 600.00);

await repository.updateAllocation(updated);
```

### `deleteAllocation()`

Soft deletes an allocation.

**Signature:**
```dart
Future<void> deleteAllocation(String id)
```

**Example:**
```dart
await repository.deleteAllocation(allocationId);
```

### `getAllocationById()`

Fetches a single allocation by ID (async).

**Signature:**
```dart
Future<AllocationModel?> getAllocationById(String id)
```

**Returns:** Allocation model or `null` if not found.

**Example:**
```dart
final allocation = await repository.getAllocationById(allocationId);
```

### `getAllocationsForBudget()`

Gets allocations for a specific budget (synchronous).

**Signature:**
```dart
List<AllocationModel> getAllocationsForBudget(String budgetId)
```

**Returns:** Filtered list of allocations for the budget.

**Implementation:** Uses `AllocationListExtensions.forBudget()`.

**Example:**
```dart
// Get all allocations for December budget
final allocations = repository
  .getAllocationsForBudget(decemberBudgetId);

// Calculate total allocated
final totalAllocated = allocations.fold<double>(
  0,
  (sum, alloc) => sum + alloc.amount,
);

print('Total allocated: \$${totalAllocated.toStringAsFixed(2)}');
```

**Use case:** Dashboard chart data, budget detail pages.

### `getAllocationsForCategory()`

Gets allocations for a specific category (synchronous).

**Signature:**
```dart
List<AllocationModel> getAllocationsForCategory(String categoryId)
```

**Returns:** Filtered list of allocations for the category.

**Implementation:** Uses `AllocationListExtensions.forCategory()`.

**Example:**
```dart
// Get all budgets allocating to groceries
final groceryAllocations = repository
  .getAllocationsForCategory(groceryCategoryId);

print('Grocery allocations across ${groceryAllocations.length} budgets');

for (final alloc in groceryAllocations) {
  print('  Budget ${alloc.budgetId}: \$${alloc.amount}');
}
```

**Use case:** Category spending history, multi-budget analysis.

### `sync()`

Stub for future API sync.

**Signature:**
```dart
Future<void> sync()
```

## Usage Examples

### Create Budget with Allocations

```dart
// 1. Create budget
final budget = BudgetModel.create(
  name: 'December 2025',
  amount: 2000.00,
  startDate: DateTime(2025, 12, 1),
  endDate: DateTime(2025, 12, 31, 23, 59, 59),
);
await budgetRepository.createBudget(budget);

// 2. Create allocations
final allocations = [
  AllocationModel.create(
    amount: 500.00,
    categoryId: groceryCategoryId,
    budgetId: budget.id,
  ),
  AllocationModel.create(
    amount: 300.00,
    categoryId: diningCategoryId,
    budgetId: budget.id,
  ),
  AllocationModel.create(
    amount: 200.00,
    categoryId: transportCategoryId,
    budgetId: budget.id,
  ),
];

for (final allocation in allocations) {
  await allocationRepository.createAllocation(allocation);
}
```

### Build Chart Data (Allocation vs Spending)

```dart
// In DashboardCubit
List<TransactionsChartData> _buildChartData({
  required String budgetId,
  required List<TransactionModel> transactions,
  required List<CategoryModel> categories,
}) {
  // Get allocations for this budget
  final allocations = _allocationRepository
    .getAllocationsForBudget(budgetId);

  // Map allocations by category
  final allocationMap = <String, double>{
    for (var alloc in allocations)
      alloc.categoryId: alloc.amount,
  };

  // Map transaction totals by category
  final transactionMap = <String, double>{};
  for (var tx in transactions) {
    if (tx.categoryId != null) {
      transactionMap[tx.categoryId!] =
        (transactionMap[tx.categoryId!] ?? 0) + tx.amount;
    }
  }

  // Build chart data per category
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
```

### Update Allocation Amount

```dart
final allocation = await repository.getAllocationById(allocationId);

if (allocation != null) {
  final updated = allocation
    .withUpdatedTimestamp()
    .copyWith(amount: 600.00);

  await repository.updateAllocation(updated);
}
```

### Calculate Budget Utilization

```dart
final budget = await budgetRepository.getBudgetById(budgetId);
final allocations = allocationRepository
  .getAllocationsForBudget(budgetId);

// Use AllocationListExtensions
final totalAllocated = allocations.totalAmount();
final unallocated = budget.amount - totalAllocated;
final percentage = (totalAllocated / budget.amount) * 100;

print('Budget: \$${budget.amount.toStringAsFixed(2)}');
print('Allocated: \$${totalAllocated.toStringAsFixed(2)} '
      '(${percentage.toStringAsFixed(1)}%)');
print('Unallocated: \$${unallocated.toStringAsFixed(2)}');
```

### Delete Budget with Allocations

```dart
// Delete allocations first (cascade)
final allocations = allocationRepository
  .getAllocationsForBudget(budgetId);

for (final allocation in allocations) {
  await allocationRepository.deleteAllocation(allocation.id);
}

// Then delete budget
await budgetRepository.deleteBudget(budgetId);
```

## List Extension Methods

The repository uses `AllocationListExtensions` for list operations:

### `totalAmount()`
```dart
final allocations = repository.getAllocationsForBudget(budgetId);
final total = allocations.totalAmount();
```

### `groupByBudget()`
```dart
final allAllocations = repository.allocations;
final byBudget = allAllocations.groupByBudget();

for (final budgetId in byBudget.keys) {
  final budgetAllocs = byBudget[budgetId]!;
  print('Budget $budgetId: ${budgetAllocs.length} allocations');
}
```

### `groupByCategory()`
```dart
final allAllocations = repository.allocations;
final byCategory = allAllocations.groupByCategory();

for (final categoryId in byCategory.keys) {
  final categoryAllocs = byCategory[categoryId]!;
  final total = categoryAllocs.totalAmount();
  print('Category $categoryId: \$${total.toStringAsFixed(2)}');
}
```

### `forBudget(String budgetId)`
```dart
final budgetAllocations = allAllocations.forBudget(budgetId);
```

### `forCategory(String categoryId)`
```dart
final categoryAllocations = allAllocations.forCategory(categoryId);
```

See [AllocationModel](../models/allocation-model.md) for complete extension documentation.

## Stream Subscription

```dart
class DashboardCubit extends Cubit<DashboardState> {
  final BudgetRepository _budgetRepository;
  final AllocationRepository _allocationRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  StreamSubscription? _allocationSubscription;

  DashboardCubit(
    this._budgetRepository,
    this._allocationRepository,
    this._transactionRepository,
    this._categoryRepository,
  ) : super(const DashboardState.initial()) {
    // Subscribe to all 4 repositories
    _allocationSubscription = _allocationRepository
      .allocationsStream
      .listen((_) => _loadDashboardData());

    // ... other subscriptions

    _loadDashboardData();
  }

  void _loadDashboardData() {
    final activeBudgets = _budgetRepository.getActiveBudgets();

    final budgetPages = activeBudgets.map((budget) {
      // Get allocations for this budget
      final allocations = _allocationRepository
        .getAllocationsForBudget(budget.id);

      // Build budget page model...
      return BudgetPageModel(...);
    }).toList();

    emit(DashboardState.success(budgetPages: budgetPages));
  }

  @override
  Future<void> close() {
    _allocationSubscription?.cancel();
    return super.close();
  }
}
```

## Best Practices

### Use Specialized Filter Methods
Repository provides optimized filtering:

```dart
// ✅ Good - use repository method
final allocations = repository.getAllocationsForBudget(budgetId);

// ❌ Bad - manual filtering
final allocations = repository.allocations
  .where((a) => a.budgetId == budgetId)
  .toList();
```

### Use List Extensions
Leverage helper methods:

```dart
// ✅ Good - use extension
final total = allocations.totalAmount();

// ❌ Bad - manual fold
final total = allocations.fold<double>(
  0,
  (sum, alloc) => sum + alloc.amount,
);
```

### Validate Sum Before Creating
Warn if over-allocating:

```dart
// ✅ Good - validate before creating
final existingAllocs = repository.getAllocationsForBudget(budgetId);
final currentTotal = existingAllocs.totalAmount();
final newTotal = currentTotal + newAllocation.amount;

if (newTotal > budget.amount) {
  showWarning('Total allocations exceed budget amount');
}

await repository.createAllocation(newAllocation);
```

### Handle Empty Allocations
Check for empty lists:

```dart
// ✅ Good - handles empty
final allocations = repository.getAllocationsForBudget(budgetId);

if (allocations.isEmpty) {
  print('No allocations for this budget');
} else {
  final total = allocations.totalAmount();
  print('Total allocated: \$${total.toStringAsFixed(2)}');
}

// ❌ Bad - assumes non-empty
final total = allocations.totalAmount(); // OK but misleading if empty (returns 0)
```

## See Also

- [AllocationModel](../models/allocation-model.md) - Allocation domain model
- [BudgetRepository](./budget-repository.md) - Budget operations
- [CategoryRepository](./category-repository.md) - Category lookups
- [DashboardCubit](../cubits/dashboard-cubit.md) - Chart data building
