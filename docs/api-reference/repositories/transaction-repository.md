# TransactionRepository

Manages transaction data with reactive streams and CRUD operations.

## Overview

`TransactionRepository` coordinates transaction data access between the local database (Drift) and domain models. It provides reactive streams for real-time updates and synchronous getters for immediate access.

**Location:** `lib/data/repositories/transaction_repository.dart`

## Class Definition

```dart
class TransactionRepository with RepositoryLogger {
  @override
  String get repositoryName => 'TransactionRepository';

  final TransactionLocalSource _localSource;
  final _transactionsController =
    StreamController<List<TransactionModel>>.broadcast();
  StreamSubscription? _dbSubscription;
  List<TransactionModel> _latestTransactions = [];

  TransactionRepository(this._localSource) {
    _subscribeToLocalChanges();
  }

  Stream<List<TransactionModel>> get transactionsStream =>
    _transactionsController.stream;

  List<TransactionModel> get transactions => _latestTransactions;
}
```

## Properties

### `transactionsStream` (Stream, read-only)
Reactive broadcast stream that emits when transaction data changes.

**Type:** `Stream<List<TransactionModel>>`

**Emits when:**
- Transaction created
- Transaction updated
- Transaction deleted
- Any underlying database change

**Usage:**
```dart
// In cubit
_transactionSubscription = _transactionRepository
  .transactionsStream
  .listen((_) {
    _loadTransactions(); // Reload data
  });
```

### `transactions` (List, read-only)
Synchronous getter for cached transaction list.

**Type:** `List<TransactionModel>`

**Returns:** Latest transaction snapshot (cached from stream).

**Usage:**
```dart
// Immediate access, no async needed
final allTransactions = _transactionRepository.transactions;

// Filter synchronously
final debitTransactions = _transactionRepository.transactions
  .where((tx) => tx.type == TransactionType.debit)
  .toList();
```

## Methods

### `createTransaction()`

Creates a new transaction with optimistic update.

**Signature:**
```dart
Future<void> createTransaction(TransactionModel model)
```

**Parameters:**
- `model` - Transaction to create (must have valid ID)

**Returns:** Future that completes when transaction is saved.

**Side effects:**
- Writes to local database
- Stream automatically emits update
- Logged with metadata

**Example:**
```dart
final transaction = TransactionModel.create(
  name: 'Coffee',
  amount: 5.50,
  type: TransactionType.debit,
  categoryId: diningCategoryId,
);

await repository.createTransaction(transaction);
// Stream emits → Subscribed cubits reload
```

**Error handling:**
```dart
try {
  await repository.createTransaction(transaction);
} catch (e) {
  print('Failed to create transaction: $e');
  // Handle error (show snackbar, etc.)
}
```

### `updateTransaction()`

Updates an existing transaction.

**Signature:**
```dart
Future<void> updateTransaction(TransactionModel model)
```

**Parameters:**
- `model` - Updated transaction (must have existing ID)

**Returns:** Future that completes when transaction is updated.

**Side effects:**
- Automatically updates `updatedAt` timestamp
- Writes to local database
- Stream automatically emits update

**Example:**
```dart
// Get existing
final existing = await repository.getTransactionById(transactionId);

// Update amount
final updated = existing!.copyWith(amount: 50.00);

// Save changes
await repository.updateTransaction(updated);
```

### `deleteTransaction()`

Soft deletes a transaction (marks as deleted, doesn't remove).

**Signature:**
```dart
Future<void> deleteTransaction(String id)
```

**Parameters:**
- `id` - Transaction ID to delete

**Returns:** Future that completes when transaction is deleted.

**Side effects:**
- Marks transaction as `isDeleted = true` in database
- Transaction no longer appears in queries
- Stream automatically emits update
- Data preserved for sync (future feature)

**Example:**
```dart
await repository.deleteTransaction(transactionId);
// Transaction no longer in repository.transactions
```

### `getTransactionById()`

Fetches a single transaction by ID.

**Signature:**
```dart
Future<TransactionModel?> getTransactionById(String id)
```

**Parameters:**
- `id` - Transaction ID to fetch

**Returns:** Transaction model or `null` if not found.

**Example:**
```dart
final transaction = await repository.getTransactionById(txId);

if (transaction != null) {
  print('Found: ${transaction.name}');
} else {
  print('Transaction not found');
}
```

**Note:** This is an async database query. For immediate access to all transactions, use the synchronous `transactions` getter instead.

### `sync()`

Stub for future API sync functionality.

**Signature:**
```dart
Future<void> sync()
```

**Returns:** Future that completes immediately (stub).

**Status:** Not yet implemented. Will sync local changes to API when backend is ready.

**Example:**
```dart
// Future usage
await repository.sync();
// Will upload pending changes to server
```

### `dispose()`

Cleans up resources (cancels subscriptions, closes streams).

**Signature:**
```dart
void dispose()
```

**Side effects:**
- Cancels database subscription
- Closes broadcast stream controller

**Usage:**
Typically called automatically when repository is removed from DI container (app shutdown).

```dart
@override
void dispose() {
  _dbSubscription?.cancel();
  _transactionsController.close();
}
```

## Usage Examples

### Basic CRUD Operations

```dart
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';

final repository = getIt<TransactionRepository>();

// Create
final transaction = TransactionModel.create(
  name: 'Grocery Shopping',
  amount: 125.50,
  type: TransactionType.debit,
  categoryId: groceryCategoryId,
  budgetId: decemberBudgetId,
);
await repository.createTransaction(transaction);

// Read (sync)
final all = repository.transactions;
print('${all.length} transactions');

// Read (async by ID)
final fetched = await repository.getTransactionById(transaction.id);

// Update
final updated = fetched!.copyWith(amount: 150.00);
await repository.updateTransaction(updated);

// Delete
await repository.deleteTransaction(transaction.id);
```

### Stream Subscription in Cubit

```dart
class TransactionListCubit extends Cubit<TransactionListState> {
  final TransactionRepository _repository;
  StreamSubscription? _subscription;

  TransactionListCubit(this._repository)
    : super(const TransactionListState.initial()) {
    // Subscribe to changes
    _subscription = _repository.transactionsStream.listen((_) {
      _loadTransactions();
    });

    // Initial load
    _loadTransactions();
  }

  void _loadTransactions() {
    final transactions = _repository.transactions; // Sync access
    emit(TransactionListState.success(transactions: transactions));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### Filter Transactions

```dart
// By date range
final startDate = DateTime(2025, 12, 1);
final endDate = DateTime(2025, 12, 31);

final decemberTxs = repository.transactions.where((tx) {
  return !tx.transactionDate.isBefore(startDate) &&
         !tx.transactionDate.isAfter(endDate);
}).toList();

// By type
final debitTxs = repository.transactions
  .where((tx) => tx.type == TransactionType.debit)
  .toList();

// By budget
final budgetTxs = repository.transactions
  .where((tx) => tx.budgetId == budgetId)
  .toList();

// By category
final categoryTxs = repository.transactions
  .where((tx) => tx.categoryId == categoryId)
  .toList();
```

### Calculate Totals

```dart
// Total spent (debit only)
final totalSpent = repository.transactions
  .where((tx) => tx.type == TransactionType.debit)
  .fold<double>(0, (sum, tx) => sum + tx.amount);

// Net spending (debit - credit)
final netSpending = repository.transactions.fold<double>(0, (sum, tx) {
  if (tx.type == TransactionType.credit) {
    return sum - tx.amount;
  } else {
    return sum + tx.amount;
  }
});

// Category spending
final categorySpending = <String, double>{};
for (final tx in repository.transactions) {
  if (tx.categoryId != null && tx.type == TransactionType.debit) {
    categorySpending[tx.categoryId!] =
      (categorySpending[tx.categoryId!] ?? 0) + tx.amount;
  }
}
```

### Bulk Operations

```dart
// Create multiple transactions
final transactions = [
  TransactionModel.create(name: 'Coffee', amount: 5.50, ...),
  TransactionModel.create(name: 'Lunch', amount: 12.00, ...),
  TransactionModel.create(name: 'Gas', amount: 40.00, ...),
];

for (final tx in transactions) {
  await repository.createTransaction(tx);
}
// Each create triggers stream update (consider batching in future)
```

## Data Flow

### Create Transaction Flow

```
1. User submits form
   ↓
2. FormCubit calls repository.createTransaction(model)
   ↓
3. Repository writes to LocalSource
   await _localSource.createTransaction(...)
   ↓
4. Drift database emits change
   watchAllTransactions() stream fires
   ↓
5. Repository receives update
   _subscribeToLocalChanges() callback
   ↓
6. Repository transforms & caches
   _latestTransactions = models.map(_mapToModel)
   ↓
7. Repository emits to broadcast stream
   _transactionsController.add(models)
   ↓
8. ListCubit's subscription triggers
   _transactionSubscription.listen(() => _load())
   ↓
9. UI rebuilds with new transaction
   BlocBuilder<TransactionListCubit, ...>
```

## UserId Filtering

All transactions are automatically filtered by userId:

**LocalSource (where filtering happens):**
```dart
Stream<List<db.Transaction>> watchAllTransactions() {
  return (_db.select(_db.transactions)
    ..where((t) =>
        t.userId.equals(userId) &  // Multi-user filtering
        t.isDeleted.equals(false))) // Exclude deleted
    .watch();
}
```

**Repository (transparent):**
```dart
// Repository only sees current user's transactions
_dbSubscription = _localSource.watchAllTransactions().listen((dbTxs) {
  // Only current user's data arrives here
  final models = dbTxs.map(_mapToModel).toList();
  _latestTransactions = models;
  _transactionsController.add(models);
});
```

**Result:** Cubits and UI only have access to current user's transactions.

## Entity Transformation

Repository handles conversion between database and domain layers:

### Domain → Database

```dart
db.Transaction _mapToDbModel(TransactionModel model) {
  return db.Transaction(
    id: model.id,
    userId: _localSource.userId,        // Add userId
    name: model.name,
    amount: model.amount,
    type: model.type.name,
    transactionDate: model.transactionDate,
    categoryId: model.categoryId,
    budgetId: model.budgetId,
    notes: model.notes,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
    isSynced: false,      // Add sync metadata
    isDeleted: false,
    lastSyncedAt: null,
  );
}
```

### Database → Domain

```dart
TransactionModel _mapToModel(db.Transaction dbTransaction) {
  return TransactionModel(
    id: dbTransaction.id,
    name: dbTransaction.name,
    amount: dbTransaction.amount,
    type: TransactionType.values.firstWhere(
      (e) => e.name == dbTransaction.type,
    ),
    transactionDate: dbTransaction.transactionDate,
    categoryId: dbTransaction.categoryId,
    budgetId: dbTransaction.budgetId,
    notes: dbTransaction.notes,
    createdAt: dbTransaction.createdAt,
    updatedAt: dbTransaction.updatedAt,
    // Excludes: userId, isSynced, isDeleted, lastSyncedAt
  );
}
```

## Logging

All operations are automatically logged via `RepositoryLogger` mixin:

```dart
// Logged operations
await repository.createTransaction(model);
// Logs: [TransactionRepository] createTransaction started
//       metadata: {transactionId: "...", type: "debit"}
//       duration: 45ms, status: success

await repository.updateTransaction(model);
// Logs: [TransactionRepository] updateTransaction started
//       metadata: {transactionId: "..."}
//       duration: 32ms, status: success
```

**Log includes:**
- Repository name
- Operation name
- Start timestamp
- Duration
- Success/failure status
- Metadata (IDs, counts, etc.)
- Error details (if failed)

## Best Practices

### Always Subscribe to Streams
Keep UI in sync with data changes:

```dart
// ✅ Good - subscribes to updates
_subscription = _repository.transactionsStream.listen((_) {
  _loadTransactions();
});

// ❌ Bad - one-time load, no updates
_loadTransactions(); // Won't see new transactions
```

### Use Synchronous Getter for Filtering
Avoid repeated async calls:

```dart
// ✅ Good - synchronous filtering
final debitTxs = _repository.transactions
  .where((tx) => tx.type == TransactionType.debit)
  .toList();

// ❌ Bad - unnecessary async
final debitTxs = await _repository.getAllTransactions()
  .where((tx) => tx.type == TransactionType.debit)
  .toList();
```

### Cancel Subscriptions
Prevent memory leaks:

```dart
// ✅ Good - cleanup
@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}

// ❌ Bad - memory leak
@override
Future<void> close() {
  return super.close(); // Subscription never cancelled!
}
```

### Let Repository Handle Timestamps
Don't manually set `updatedAt`:

```dart
// ✅ Good - repository updates timestamp
await repository.updateTransaction(model);

// ❌ Bad - manual timestamp
await repository.updateTransaction(
  model.copyWith(updatedAt: DateTime.now()),
);
```

## See Also

- [TransactionModel](../models/transaction-model.md) - Transaction domain model
- [BudgetRepository](./budget-repository.md) - Related budget operations
- [CategoryRepository](./category-repository.md) - Category lookups
- [TransactionListCubit](../cubits/transaction-list-cubit.md) - UI state management
