# Repositories Overview

Repositories coordinate data access between the local database (Drift) and domain models. They implement the **local-first repository pattern** with reactive streams for state management.

## Architecture

Repositories live in the **data access layer** and mediate between LocalSources and domain models:

```
Cubits (Presentation)
    ↓ (subscribe to streams)
Repositories (Data coordination)
    ↓ (transform entities)
LocalSources (Drift queries)
    ↓ (userId-filtered)
Drift Database (SQLite)
```

**Key Responsibilities:**
1. **Coordinate** LocalSources (and future RemoteSources)
2. **Emit** broadcast streams for reactive updates
3. **Transform** Drift entities ↔ Domain models
4. **Cache** latest data for synchronous access
5. **Log** operations with metadata

## Core Repositories

### [TransactionRepository](./transaction-repository.md)
Manages transaction data (CRUD + streams).

**Key Features:**
- Reactive `transactionsStream` for real-time updates
- Synchronous `transactions` getter for immediate access
- userId-filtered queries (multi-user ready)
- Automatic timestamp management
- Soft delete pattern

### [BudgetRepository](./budget-repository.md)
Manages budget data with active budget filtering.

**Key Features:**
- Reactive `budgetsStream` for real-time updates
- Synchronous `budgets` getter
- `getActiveBudgets()` for current period filtering
- Budget period calculations (isActive, totalDays, elapsedDays)

### [CategoryRepository](./category-repository.md)
Manages category data with synchronous lookups.

**Key Features:**
- Reactive `categoriesStream` for real-time updates
- Synchronous `categories` getter
- `getCategoryByIdSync()` for denormalization
- Icon name mappings

### [AllocationRepository](./allocation-repository.md)
Manages budget-category allocations.

**Key Features:**
- Reactive `allocationsStream` for real-time updates
- `getAllocationsForBudget()` for budget filtering
- `getAllocationsForCategory()` for category filtering
- List extension methods (totalAmount, groupByBudget, etc.)

## Repository Pattern

### V5 Local-First Architecture

All repositories follow a consistent pattern:

```dart
class EntityRepository with RepositoryLogger {
  final EntityLocalSource _localSource;

  // Broadcast stream for reactive updates
  final _controller = StreamController<List<EntityModel>>.broadcast();
  StreamSubscription? _dbSubscription;

  // Cache for synchronous access
  List<EntityModel> _latestData = [];

  EntityRepository(this._localSource) {
    _subscribeToLocalChanges();
  }

  // Public API
  Stream<List<EntityModel>> get entitiesStream => _controller.stream;
  List<EntityModel> get entities => _latestData;

  // Subscribe to Drift's reactive watch() streams
  void _subscribeToLocalChanges() {
    _dbSubscription = _localSource.watchAll().listen((dbEntities) {
      final models = dbEntities.map(_mapToModel).toList();
      _latestData = models; // Update cache
      _controller.add(models); // Emit to cubits
    });
  }

  // CRUD operations with logging
  Future<void> create(EntityModel model) async {
    return trackRepositoryOperation(
      operation: 'create',
      execute: () async {
        await _localSource.create(...);
      },
      metadata: {'id': model.id},
    );
  }

  void dispose() {
    _dbSubscription?.cancel();
    _controller.close();
  }
}
```

### Key Components

#### Broadcast Streams
All repositories emit broadcast streams that multiple cubits can subscribe to:

```dart
final _transactionsController =
  StreamController<List<TransactionModel>>.broadcast();

Stream<List<TransactionModel>> get transactionsStream =>
  _transactionsController.stream;
```

**Why broadcast?** Multiple cubits may need to listen to the same repository.

#### Cached Data
Repositories maintain the latest data snapshot for synchronous access:

```dart
List<TransactionModel> _latestTransactions = [];

List<TransactionModel> get transactions => _latestTransactions;
```

**Benefits:**
- No async overhead for immediate access
- Consistent with v0.5 service pattern
- Enables synchronous filtering/mapping in cubits

#### Entity Transformation
Repositories handle conversion between database and domain layers:

```dart
// Domain → Database (includes userId, sync metadata)
db.Transaction _mapToDbModel(TransactionModel model) {
  return db.Transaction(
    id: model.id,
    userId: _localSource.userId, // Add userId
    name: model.name,
    amount: model.amount,
    // ... other fields
    isSynced: false,  // Add sync metadata
    isDeleted: false,
    lastSyncedAt: null,
  );
}

// Database → Domain (strips userId, sync metadata)
TransactionModel _mapToModel(db.Transaction dbTransaction) {
  return TransactionModel(
    id: dbTransaction.id,
    name: dbTransaction.name,
    amount: dbTransaction.amount,
    // ... (excludes userId, isSynced, etc.)
  );
}
```

#### Repository Logger Mixin
All repositories use `RepositoryLogger` mixin for operation tracking:

```dart
class TransactionRepository with RepositoryLogger {
  @override
  String get repositoryName => 'TransactionRepository';

  Future<void> createTransaction(TransactionModel model) async {
    return trackRepositoryOperation(
      operation: 'createTransaction',
      execute: () async {
        await _localSource.createTransaction(...);
      },
      metadata: {'transactionId': model.id},
    );
  }
}
```

**Logged information:**
- Operation name and repository
- Start time and duration
- Success/failure status
- Metadata (IDs, counts, etc.)
- Error details and stack traces

## Data Flow

### Reactive Update Pattern

```
1. User action in UI
   ↓
2. Cubit calls repository method
   repository.createTransaction(model)
   ↓
3. Repository writes to LocalSource
   _localSource.createTransaction(...)
   ↓
4. Drift emits change via watch() stream
   _localSource.watchAllTransactions().listen(...)
   ↓
5. Repository receives update
   _subscribeToLocalChanges() callback
   ↓
6. Repository transforms & caches
   _latestTransactions = models
   ↓
7. Repository emits to broadcast stream
   _transactionsController.add(models)
   ↓
8. Cubit's subscription triggers reload
   _transactionSubscription.listen(() => _loadData())
   ↓
9. UI updates
   BlocBuilder rebuilds widget
```

### Example Flow

```dart
// 1. User creates transaction in UI
await context.read<TransactionFormCubit>().saveTransaction(
  name: 'Coffee',
  amount: 5.50,
  type: TransactionType.debit,
);

// 2. FormCubit calls repository
await _transactionRepository.createTransaction(model);

// 3. Repository writes to database
await _localSource.createTransaction(...);

// 4. Drift watch() emits change
// 5-7. Repository processes and emits
// 8. TransactionListCubit receives update
_transactionSubscription.listen((_) {
  _loadTransactions(); // Reload from repository.transactions
});

// 9. UI rebuilds with new transaction
```

## Dependency Injection

Repositories are registered as **lazy singletons** in GetIt:

```dart
// lib/core/di/injection.dart

// LocalSources (singletons)
getIt.registerLazySingleton<TransactionLocalSource>(
  () => TransactionLocalSource(getIt()),
);

// Repositories (singletons with broadcast streams)
getIt.registerLazySingleton<TransactionRepository>(
  () => TransactionRepository(getIt()),
);
getIt.registerLazySingleton<BudgetRepository>(
  () => BudgetRepository(getIt()),
);
getIt.registerLazySingleton<CategoryRepository>(
  () => CategoryRepository(getIt()),
);
getIt.registerLazySingleton<AllocationRepository>(
  () => AllocationRepository(getIt()),
);

// Cubits (factories - new instance per request)
getIt.registerFactory<TransactionListCubit>(
  () => TransactionListCubit(
    getIt<TransactionRepository>(),
    getIt<CategoryRepository>(),
  ),
);
```

**Why lazy singletons?**
- Created on first access (not app startup)
- Single instance shared across all cubits
- Broadcast streams support multiple listeners
- Consistent state across the app

## CRUD Operations

All repositories provide standard CRUD operations:

### Create
```dart
Future<void> createTransaction(TransactionModel model) async {
  await _localSource.createTransaction(...);
  // Stream automatically emits update
}
```

### Read
```dart
// Async (one-time fetch)
Future<TransactionModel?> getTransactionById(String id) async {
  final dbTransaction = await _localSource.getTransactionById(id);
  return dbTransaction != null ? _mapToModel(dbTransaction) : null;
}

// Sync (from cache)
List<TransactionModel> get transactions => _latestTransactions;

// Stream (reactive)
Stream<List<TransactionModel>> get transactionsStream =>
  _transactionsController.stream;
```

### Update
```dart
Future<void> updateTransaction(TransactionModel model) async {
  final updatedModel = model.copyWith(updatedAt: DateTime.now());
  await _localSource.updateTransaction(_mapToDbModel(updatedModel));
  // Stream automatically emits update
}
```

### Delete (Soft)
```dart
Future<void> deleteTransaction(String id) async {
  await _localSource.deleteTransaction(id); // Marks as deleted
  // Stream automatically emits update
}
```

## UserId Filtering

All repositories work with userId-filtered data for multi-user support:

**LocalSource (where filtering happens):**
```dart
Stream<List<db.Transaction>> watchAllTransactions() {
  return (_db.select(_db.transactions)
    ..where((t) =>
        t.userId.equals(userId) &  // CRITICAL: userId filter
        t.isDeleted.equals(false)))
    .watch();
}
```

**Repository (transparent to domain layer):**
```dart
// Repository receives only current user's data
_dbSubscription = _localSource.watchAllTransactions().listen((dbTxs) {
  final models = dbTxs.map(_mapToModel).toList();
  _latestTransactions = models; // Only current user's transactions
  _transactionsController.add(models);
});
```

**AuthManager provides userId:**
```dart
// lib/core/auth/auth_manager.dart
final userId = await getIt<AuthManager>().getUserId();
// Returns: "anon_{uuid}" for anonymous users
// Future: Will support OAuth (Google Sign-In)
```

## Sync Stubs (Future API)

All repositories have TODO comments for future API integration:

```dart
Future<void> createTransaction(TransactionModel model) async {
  await _localSource.createTransaction(...);

  // TODO: When API is ready, trigger background sync in isolate
  // syncManager.scheduleSyncOperation(
  //   type: SyncOperationType.create,
  //   entity: 'transactions',
  //   data: model.toJson(),
  // );
}
```

**Local-first approach:**
- All writes go to local database first (optimistic updates)
- Background sync happens asynchronously in isolates
- App works fully offline
- Sync happens when online

## Common Patterns

### Stream Subscription in Cubits

```dart
class TransactionListCubit extends Cubit<TransactionListState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  StreamSubscription? _transactionSubscription;
  StreamSubscription? _categorySubscription;

  TransactionListCubit(this._transactionRepository, this._categoryRepository)
    : super(const TransactionListState.initial()) {
    _subscribeToStreams();
  }

  void _subscribeToStreams() {
    _transactionSubscription = _transactionRepository
      .transactionsStream
      .listen((_) => _loadTransactions());

    _categorySubscription = _categoryRepository
      .categoriesStream
      .listen((_) => _loadTransactions()); // Reload on category changes

    _loadTransactions(); // Initial load
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    _categorySubscription?.cancel();
    return super.close();
  }
}
```

### Synchronous Filtering

```dart
// In cubit, using cached data
void _loadActiveBudgets() {
  final activeBudgets = _budgetRepository
    .getActiveBudgets(); // Synchronous!

  emit(BudgetListState.success(budgets: activeBudgets));
}
```

### Denormalization Pattern

```dart
// Join transaction + category data
final viewModels = _transactionRepository.transactions.map((tx) {
  final category = tx.categoryId != null
    ? _categoryRepository.getCategoryByIdSync(tx.categoryId!)
    : null;

  return TransactionVModel(
    id: tx.id,
    name: tx.name,
    amount: tx.amount,
    categoryName: category?.name, // Denormalized
    categoryIconName: category?.iconName, // Denormalized
  );
}).toList();
```

## File Naming Convention

All repositories follow this convention:

**File naming:**
```
lib/data/repositories/[entity]_repository.dart
```

**Class naming:**
```dart
class [Entity]Repository with RepositoryLogger {
  @override
  String get repositoryName => '[Entity]Repository';
}
```

**Examples:**
- `TransactionRepository` in `transaction_repository.dart`
- `BudgetRepository` in `budget_repository.dart`
- `CategoryRepository` in `category_repository.dart`
- `AllocationRepository` in `allocation_repository.dart`

## Best Practices

### Always Cancel Subscriptions
Prevent memory leaks by disposing subscriptions:

```dart
void dispose() {
  _dbSubscription?.cancel();
  _transactionsController.close();
}
```

### Use Broadcast Streams
Allow multiple listeners:

```dart
// ✅ Good - broadcast stream
final _controller = StreamController<List<Model>>.broadcast();

// ❌ Bad - single subscription only
final _controller = StreamController<List<Model>>();
```

### Cache Latest Data
Provide synchronous access:

```dart
// ✅ Good - both sync and async access
List<Model> _latestData = [];
Stream<List<Model>> get stream => _controller.stream;
List<Model> get data => _latestData;

// ❌ Bad - async only
Stream<List<Model>> get stream => _controller.stream;
// No synchronous access!
```

### Track Operations with Logger
Log all operations for debugging:

```dart
// ✅ Good - logged operation
return trackRepositoryOperation(
  operation: 'createTransaction',
  execute: () async {
    await _localSource.create(...);
  },
  metadata: {'id': model.id},
);

// ❌ Bad - no logging
await _localSource.create(...);
```

## Next Steps

- [TransactionRepository →](./transaction-repository.md) - Transaction data access
- [BudgetRepository →](./budget-repository.md) - Budget data access
- [CategoryRepository →](./category-repository.md) - Category data access
- [AllocationRepository →](./allocation-repository.md) - Allocation data access

See also:
- [Models →](../models/index.md) - Domain models
- [Cubits →](../cubits/index.md) - State management
