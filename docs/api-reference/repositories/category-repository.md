# CategoryRepository

Manages category data with reactive streams and synchronous lookups for denormalization.

## Overview

`CategoryRepository` coordinates category data access. It provides reactive streams for updates and synchronous lookups optimized for denormalizing transaction and allocation data.

**Location:** `lib/data/repositories/category_repository.dart`

## Class Definition

```dart
class CategoryRepository with RepositoryLogger {
  @override
  String get repositoryName => 'CategoryRepository';

  final CategoryLocalSource _localSource;
  final _categoriesController =
    StreamController<List<CategoryModel>>.broadcast();
  StreamSubscription? _dbSubscription;
  List<CategoryModel> _latestCategories = [];

  CategoryRepository(this._localSource) {
    _subscribeToLocalChanges();
  }

  Stream<List<CategoryModel>> get categoriesStream =>
    _categoriesController.stream;

  List<CategoryModel> get categories => _latestCategories;

  CategoryModel? getCategoryByIdSync(String id) =>
    _latestCategories.firstWhere((cat) => cat.id == id, orElse: () => null);
}
```

## Properties

### `categoriesStream` (Stream, read-only)
Reactive broadcast stream that emits when category data changes.

**Type:** `Stream<List<CategoryModel>>`

**Usage:**
```dart
_categorySubscription = _categoryRepository
  .categoriesStream
  .listen((_) => _loadTransactions());
```

### `categories` (List, read-only)
Synchronous getter for cached category list.

**Type:** `List<CategoryModel>`

**Usage:**
```dart
final allCategories = _categoryRepository.categories;
```

## Methods

### `createCategory()`

Creates a new category.

**Signature:**
```dart
Future<void> createCategory(CategoryModel model)
```

**Example:**
```dart
final category = CategoryModel.create(
  name: 'Groceries',
  iconName: 'shopping_cart',
);

await repository.createCategory(category);
```

### `updateCategory()`

Updates an existing category.

**Signature:**
```dart
Future<void> updateCategory(CategoryModel model)
```

**Side effects:**
- Automatically updates `updatedAt` timestamp

**Example:**
```dart
final updated = category.copyWith(
  name: 'Food & Groceries',
  updatedAt: DateTime.now(),
);

await repository.updateCategory(updated);
```

### `deleteCategory()`

Soft deletes a category.

**Signature:**
```dart
Future<void> deleteCategory(String id)
```

**Example:**
```dart
await repository.deleteCategory(categoryId);
```

**Note:** Deleting a category does NOT cascade delete transactions or allocations. Existing references remain valid but point to deleted category.

### `getCategoryById()`

Fetches a single category by ID (async).

**Signature:**
```dart
Future<CategoryModel?> getCategoryById(String id)
```

**Returns:** Category model or `null` if not found.

**Example:**
```dart
final category = await repository.getCategoryById(categoryId);
if (category != null) {
  print('Category: ${category.name}');
}
```

### `getCategoryByIdSync()`

Fetches a single category by ID from cache (synchronous).

**Signature:**
```dart
CategoryModel? getCategoryByIdSync(String id)
```

**Returns:** Category model from cache or `null` if not found.

**Use case:** Denormalization in cubits without async overhead.

**Example:**
```dart
// In TransactionListCubit
final viewModels = transactions.map((tx) {
  final category = tx.categoryId != null
    ? _categoryRepository.getCategoryByIdSync(tx.categoryId!)
    : null;

  return TransactionVModel(
    id: tx.id,
    name: tx.name,
    amount: tx.amount,
    categoryName: category?.name,         // Denormalized
    categoryIconName: category?.iconName, // Denormalized
  );
}).toList();
```

**Performance:** O(n) lookup in cached list. Acceptable for <100 categories.

### `sync()`

Stub for future API sync.

**Signature:**
```dart
Future<void> sync()
```

## Usage Examples

### Create Default Categories

```dart
final defaultCategories = [
  CategoryModel.create(name: 'Groceries', iconName: 'shopping_cart'),
  CategoryModel.create(name: 'Dining', iconName: 'restaurant'),
  CategoryModel.create(name: 'Transportation', iconName: 'directions_car'),
  CategoryModel.create(name: 'Entertainment', iconName: 'movie'),
  CategoryModel.create(name: 'Healthcare', iconName: 'local_hospital'),
  CategoryModel.create(name: 'Utilities', iconName: 'lightbulb'),
];

for (final category in defaultCategories) {
  await categoryRepository.createCategory(category);
}
```

### Denormalize Transaction Data

```dart
// Build view models with category data
final transactionVModels = transactions.map((tx) {
  final category = tx.categoryId != null
    ? categoryRepository.getCategoryByIdSync(tx.categoryId!)
    : null;

  return TransactionVModel(
    id: tx.id,
    name: tx.name,
    amount: tx.amount,
    type: tx.type,
    transactionDate: tx.transactionDate,
    categoryId: tx.categoryId,
    categoryName: category?.name ?? 'Uncategorized',
    categoryIconName: category?.iconName ?? 'category',
  );
}).toList();
```

### Category Picker Widget

```dart
class CategoryPicker extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final categoryRepo = getIt<CategoryRepository>();
    final categories = categoryRepo.categories;

    return DropdownButton<String>(
      value: selectedCategoryId,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('Uncategorized'),
        ),
        ...categories.map((cat) {
          return DropdownMenuItem(
            value: cat.id,
            child: Row(
              children: [
                Icon(_getIconData(cat.iconName)),
                SizedBox(width: 8),
                Text(cat.name),
              ],
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
```

### Calculate Category Spending

```dart
final categories = categoryRepository.categories;
final transactions = transactionRepository.transactions;

for (final category in categories) {
  final categoryTxs = transactions.where((tx) =>
    tx.categoryId == category.id &&
    tx.type == TransactionType.debit
  ).toList();

  final totalSpent = categoryTxs.fold<double>(
    0,
    (sum, tx) => sum + tx.amount,
  );

  print('${category.name}: \$${totalSpent.toStringAsFixed(2)}');
}
```

### Update Category Name

```dart
final category = await categoryRepository.getCategoryById(categoryId);

if (category != null) {
  final updated = category.copyWith(
    name: 'Food & Groceries',
    updatedAt: DateTime.now(),
  );

  await categoryRepository.updateCategory(updated);
}
```

## Denormalization Pattern

Categories are frequently denormalized into view models:

### Why Denormalize?

**Problem:**
```dart
// ❌ Bad - repeated lookups in UI
ListView.builder(
  itemBuilder: (context, index) {
    final tx = transactions[index];
    // Async lookup in widget build!
    final category = await categoryRepo.getCategoryById(tx.categoryId);
    return ListTile(title: Text(category?.name ?? 'Unknown'));
  },
)
```

**Solution:**
```dart
// ✅ Good - denormalize in cubit
void _loadTransactions() {
  final viewModels = _transactionRepository.transactions.map((tx) {
    final category = tx.categoryId != null
      ? _categoryRepository.getCategoryByIdSync(tx.categoryId!)
      : null;

    return TransactionVModel(
      ...
      categoryName: category?.name,
      categoryIconName: category?.iconName,
    );
  }).toList();

  emit(TransactionListState.success(transactions: viewModels));
}

// Widget just displays denormalized data
ListTile(title: Text(viewModel.categoryName ?? 'Uncategorized'))
```

### Benefits
- No async lookups in UI
- Single transformation in cubit
- Better performance
- Simpler widget code

## Stream Subscription

```dart
class TransactionListCubit extends Cubit<TransactionListState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  StreamSubscription? _transactionSubscription;
  StreamSubscription? _categorySubscription;

  TransactionListCubit(
    this._transactionRepository,
    this._categoryRepository,
  ) : super(const TransactionListState.initial()) {
    // Subscribe to both repositories
    _transactionSubscription = _transactionRepository
      .transactionsStream
      .listen((_) => _loadTransactions());

    _categorySubscription = _categoryRepository
      .categoriesStream
      .listen((_) => _loadTransactions()); // Reload on category changes

    _loadTransactions();
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    _categorySubscription?.cancel();
    return super.close();
  }
}
```

**Why subscribe to categories?**
If a category name/icon changes, transaction view models need to reload with updated category data.

## Best Practices

### Use `getCategoryByIdSync()` for Denormalization
Avoid async overhead:

```dart
// ✅ Good - synchronous lookup
final category = _categoryRepository.getCategoryByIdSync(categoryId);

// ❌ Bad - unnecessary async
final category = await _categoryRepository.getCategoryById(categoryId);
```

### Subscribe to Category Stream
Keep denormalized data in sync:

```dart
// ✅ Good - reloads when categories change
_categorySubscription = _categoryRepository
  .categoriesStream
  .listen((_) => _loadTransactions());

// ❌ Bad - stale category data
// Only subscribes to transactions, misses category updates
```

### Handle Null Categories
Always provide fallback for missing categories:

```dart
// ✅ Good - handles null
final categoryName = category?.name ?? 'Uncategorized';
final iconName = category?.iconName ?? 'category';

// ❌ Bad - crashes on null
final categoryName = category!.name; // Null pointer exception!
```

### Pre-populate Default Categories
Improve UX with common categories:

```dart
// ✅ Good - seed on first launch
if (categoryRepository.categories.isEmpty) {
  await seedDefaultCategories();
}

// ❌ Bad - empty category list
// User has to create every category manually
```

## See Also

- [CategoryModel](../models/category-model.md) - Category domain model
- [TransactionRepository](./transaction-repository.md) - Transaction lookups
- [AllocationRepository](./allocation-repository.md) - Allocation lookups
- [TransactionListCubit](../cubits/transaction-list-cubit.md) - Denormalization example
