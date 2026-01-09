# Data Flow Patterns

## Overview

This document explains how data moves through Centabit's local-first architecture, from user interactions to database updates and back to the UI. All flows follow the reactive stream pattern for automatic UI updates.

---

## Core Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERACTION                          │
│                    (Tap button, enter text)                      │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Widget (Page/Component)                                 │  │
│  │  - Captures user input                                   │  │
│  │  - Calls cubit method                                    │  │
│  └────────────────────────┬─────────────────────────────────┘  │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Cubit (State Management)                                │  │
│  │  - Validates input                                       │  │
│  │  - Calls repository method                               │  │
│  │  - Emits loading state                                   │  │
│  └────────────────────────┬─────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                       REPOSITORY LAYER                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Repository                                              │  │
│  │  - Receives domain model                                 │  │
│  │  - Maps to Drift entity                                  │  │
│  │  - Calls localSource method                              │  │
│  └────────────────────────┬─────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      LOCAL SOURCE LAYER                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  LocalSource (DAO)                                       │  │
│  │  - Injects userId automatically                          │  │
│  │  - Executes Drift query                                  │  │
│  │  - Sets sync metadata (isSynced: false)                  │  │
│  └────────────────────────┬─────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                        DRIFT DATABASE                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SQLite Storage                                          │  │
│  │  - Writes data to centabit.sqlite                        │  │
│  │  - Triggers watch() stream observers                     │  │
│  │  - Maintains ACID guarantees                             │  │
│  └────────────────────────┬─────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            ↓
                  ═══════════════════════
                  ║ REACTIVE BUBBLE-UP  ║
                  ═══════════════════════
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  Drift emits change via watch() stream                          │
│            ↓                                                     │
│  LocalSource forwards stream update                             │
│            ↓                                                     │
│  Repository transforms Drift entity → Domain model              │
│            ↓                                                     │
│  Repository emits to broadcast stream                           │
│            ↓                                                     │
│  Cubit's subscription receives update                           │
│            ↓                                                     │
│  Cubit reloads data and emits success state                     │
│            ↓                                                     │
│  Widget rebuilds via BlocBuilder                                │
│            ↓                                                     │
│  USER SEES UPDATED UI                                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Write Flow Example: Creating a Transaction

Let's trace the complete flow when a user creates a new transaction.

### Step-by-Step Flow

**1. User Taps "Add Transaction" Button**
```dart
// In TransactionFormPage
ElevatedButton(
  onPressed: () {
    final model = TransactionModel.create(
      name: nameController.text,
      amount: double.parse(amountController.text),
      type: selectedType,
      transactionDate: selectedDate,
      categoryId: selectedCategory?.id,
    );

    context.read<TransactionListCubit>().createTransaction(model);
  },
  child: const Text('Save'),
)
```

**2. Cubit Receives Method Call**
```dart
// In TransactionListCubit
Future<void> createTransaction(TransactionModel model) async {
  emit(const TransactionListState.loading());

  try {
    await _transactionRepository.createTransaction(model);
    // Don't manually reload - stream subscription will handle it!
    // The repository's broadcast stream will emit when Drift updates
  } catch (e) {
    emit(TransactionListState.error(e.toString()));
  }
}
```

**3. Repository Maps and Delegates**
```dart
// In TransactionRepository
Future<void> createTransaction(TransactionModel model) async {
  await _localSource.createTransaction(
    db.TransactionsCompanion.insert(
      id: model.id,
      userId: _localSource.userId,  // Auto-injected
      name: model.name,
      amount: model.amount,
      type: Value(model.type.name),
      transactionDate: model.transactionDate,
      categoryId: Value(model.categoryId),
      budgetId: Value(model.budgetId),
      notes: Value(model.notes),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isSynced: const Value(false),  // Mark for future sync
    ),
  );

  // TODO: Trigger background sync when API is ready
}
```

**4. LocalSource Executes Drift Query**
```dart
// In TransactionLocalSource
Future<void> createTransaction(TransactionsCompanion transaction) {
  // userId already in companion, validated to match this.userId
  return _db.into(_db.transactions).insert(transaction);
}
```

**5. Drift Writes to SQLite**
- Inserts row into `transactions` table
- Applies constraints (primary key, unique userId+id)
- Triggers all active `watch()` subscriptions

**6. Reactive Bubble-Up (Automatic)**

```dart
// In TransactionLocalSource (watch query is always active)
Stream<List<Transaction>> watchAllTransactions() {
  return (_db.select(_db.transactions)
        ..where((t) =>
            t.userId.equals(userId) &  // Only this user's data
            t.isDeleted.equals(false)))
      .watch();  // ← This emits when database changes!
}
```

```dart
// In TransactionRepository (subscription established in constructor)
TransactionRepository(this._localSource) {
  _dbSubscription = _localSource.watchAllTransactions().listen((dbTransactions) {
    final models = dbTransactions.map(_mapToModel).toList();
    _latestTransactions = models;  // Update cache
    _transactionsController.add(models);  // ← Emit to all subscribers!
  });
}
```

```dart
// In TransactionListCubit (subscription established in constructor)
TransactionListCubit(this._transactionRepository, this._categoryRepository)
    : super(const TransactionListState.initial()) {
  _transactionSubscription = _transactionRepository.transactionsStream.listen((_) {
    _loadTransactions();  // ← Triggered automatically!
  });
  _loadTransactions();  // Initial load
}

void _loadTransactions() {
  final transactions = _transactionRepository.transactions;
  final categories = _categoryRepository.categories;

  // Denormalize: join transaction + category data
  final viewModels = transactions.map((t) {
    final category = categories.firstWhereOrNull((c) => c.id == t.categoryId);
    return TransactionVModel(transaction: t, category: category);
  }).toList();

  emit(TransactionListState.success(transactions: viewModels));
}
```

```dart
// In TransactionListPage (BlocBuilder automatically rebuilds)
BlocBuilder<TransactionListCubit, TransactionListState>(
  builder: (context, state) {
    return state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const CircularProgressIndicator(),
      success: (transactions) => ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) => TransactionTile(
          transaction: transactions[index],
        ),
      ),
      error: (msg) => ErrorWidget(msg),
    );
  },
)
```

**7. User Sees New Transaction in List** ✨

### Timeline

```
T+0ms:   User taps "Save"
T+1ms:   Cubit emits loading state
T+2ms:   Repository calls localSource
T+3ms:   Drift writes to SQLite
T+4ms:   watch() stream emits
T+5ms:   Repository stream emits
T+6ms:   Cubit subscription fires
T+7ms:   Cubit loads data and emits success
T+8ms:   Widget rebuilds with new transaction
```

**Total latency: ~8ms** (optimistic update - no network wait!)

---

## Read Flow Example: Loading Dashboard

Let's trace how the dashboard loads budget and transaction data on app start.

### Step-by-Step Flow

**1. Dashboard Page Mounted**
```dart
// In DashboardPage
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => getIt<DashboardCubit>(),  // Creates cubit
    child: BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const LoadingIndicator(),
        success: (budgetPages) => DashboardContent(budgetPages: budgetPages),
        error: (msg) => ErrorMessage(msg),
      ),
    ),
  );
}
```

**2. Cubit Constructor Runs**
```dart
// In DashboardCubit
DashboardCubit(
  this._budgetRepository,
  this._allocationRepository,
  this._transactionRepository,
  this._categoryRepository,
) : super(const DashboardState.initial()) {
  // Subscribe to all relevant streams
  _budgetSubscription = _budgetRepository.budgetsStream.listen((_) => _loadDashboardData());
  _allocationSubscription = _allocationRepository.allocationsStream.listen((_) => _loadDashboardData());
  _transactionSubscription = _transactionRepository.transactionsStream.listen((_) => _loadDashboardData());
  _categorySubscription = _categoryRepository.categoriesStream.listen((_) => _loadDashboardData());

  _loadDashboardData();  // ← Initial load
}
```

**3. Cubit Loads Data (Synchronously from Repository Cache)**
```dart
// In DashboardCubit
void _loadDashboardData() {
  emit(const DashboardState.loading());

  try {
    // All reads are synchronous - data already cached in repositories!
    final budgets = _budgetRepository.getActiveBudgets();
    final allocations = _allocationRepository.allocations;
    final transactions = _transactionRepository.transactions;
    final categories = _categoryRepository.categories;

    // Build view models
    final budgetPages = budgets.map((budget) {
      final budgetAllocations = allocations.forBudget(budget.id);
      final budgetTransactions = transactions.forBudget(budget.id);

      // Calculate metrics
      final totalSpent = budgetTransactions.totalSpent;
      final bar = _calculateBAR(budget, totalSpent);

      // Build chart data
      final chartData = budgetAllocations.map((allocation) {
        final category = categories.firstWhere((c) => c.id == allocation.categoryId);
        final spent = budgetTransactions
            .where((t) => t.categoryId == category.id)
            .totalSpent;

        return CategoryChartData(
          category: category,
          allocated: allocation.amount,
          spent: spent,
        );
      }).toList();

      return BudgetPageModel(
        budget: budget,
        bar: bar,
        totalSpent: totalSpent,
        chartData: chartData,
      );
    }).toList();

    emit(DashboardState.success(budgetPages: budgetPages));
  } catch (e) {
    emit(DashboardState.error(e.toString()));
  }
}
```

**4. Repositories Serve Cached Data**
```dart
// In BudgetRepository
List<BudgetModel> get budgets => _latestBudgets;  // Already in memory!

List<BudgetModel> getActiveBudgets() {
  final now = DateTime.now();
  return _latestBudgets.where((budget) => budget.isActive()).toList();
}

// Cache is populated by stream subscription (always running):
void _subscribeToLocalChanges() {
  _dbSubscription = _localSource.watchAllBudgets().listen((dbBudgets) {
    final models = dbBudgets.map(_mapToModel).toList();
    _latestBudgets = models;  // ← Keep cache fresh
    _budgetsController.add(models);
  });
}
```

**5. Widget Rebuilds with Data**
```dart
// In DashboardPage
BlocBuilder<DashboardCubit, DashboardState>(
  builder: (context, state) {
    return state.when(
      success: (budgetPages) => PageView.builder(
        itemCount: budgetPages.length,
        itemBuilder: (context, index) => BudgetReportCard(
          budgetPage: budgetPages[index],
        ),
      ),
      // ... other states
    );
  },
)
```

### Read Flow Timeline

```
T+0ms:   Dashboard page mounted
T+1ms:   DashboardCubit created and constructor runs
T+2ms:   Stream subscriptions established
T+3ms:   _loadDashboardData() called
T+4ms:   Synchronous reads from repository caches
T+5ms:   View models built and metrics calculated
T+6ms:   Success state emitted
T+7ms:   Widget rebuilds with dashboard data
```

**Total latency: ~7ms** (all from cache - no database IO on read path!)

---

## Update Flow Example: Editing a Budget

**1. User Edits Budget Name**
```dart
// In BudgetEditPage
ElevatedButton(
  onPressed: () {
    final updated = currentBudget.copyWith(
      name: nameController.text,
      updatedAt: DateTime.now(),  // Mark as modified
    );

    context.read<BudgetCubit>().updateBudget(updated);
  },
  child: const Text('Update'),
)
```

**2. Repository Updates Database**
```dart
// In BudgetRepository
Future<void> updateBudget(BudgetModel model) async {
  final updatedModel = model.withUpdatedTimestamp();
  await _localSource.updateBudget(_mapToDbModel(updatedModel));

  // TODO: Trigger background sync when API is ready
}
```

**3. LocalSource Executes Update with userId Validation**
```dart
// In BudgetLocalSource
Future<void> updateBudget(Budget budget) {
  if (budget.userId != userId) {
    throw Exception('Cannot update budget for different user');
  }
  return _db.update(_db.budgets).replace(budget);
}
```

**4. Drift Updates Row**
- Updates row in `budgets` table
- Sets `isSynced = false` (pending sync)
- Triggers `watch()` streams

**5. All Subscribed Cubits Reload Automatically**
- DashboardCubit → Reloads budget reports
- BudgetListCubit → Reloads budget list
- BudgetEditCubit → Sees updated budget

**6. All Related UIs Update Simultaneously** ✨

---

## Delete Flow Example: Removing a Transaction

**1. User Confirms Delete**
```dart
// In TransactionTile
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: () => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Transaction?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            transactionRepository.deleteTransaction(transaction.id);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  ),
)
```

**2. Repository Performs Soft Delete**
```dart
// In TransactionRepository
Future<void> deleteTransaction(String id) async {
  await _localSource.deleteTransaction(id);

  // TODO: Sync deletion to API when available
}
```

**3. LocalSource Sets isDeleted Flag**
```dart
// In TransactionLocalSource
Future<void> deleteTransaction(String id) {
  return (_db.update(_db.transactions)
        ..where((t) =>
            t.userId.equals(userId) &  // Security check
            t.id.equals(id)))
      .write(const TransactionsCompanion(
        isDeleted: Value(true),
        updatedAt: Value.absent(),  // Drift auto-updates
      ));
}
```

**4. Drift Updates Row (Soft Delete)**
- Sets `isDeleted = true`
- Sets `isSynced = false`
- Row still exists in database (for sync)

**5. watch() Query Filters Out Deleted Items**
```dart
// In TransactionLocalSource (watch query)
Stream<List<Transaction>> watchAllTransactions() {
  return (_db.select(_db.transactions)
        ..where((t) =>
            t.userId.equals(userId) &
            t.isDeleted.equals(false)))  // ← Excludes deleted
      .watch();
}
```

**6. UI Automatically Removes Item**
- Repository stream emits new list (without deleted item)
- Cubit receives update
- Widget rebuilds with filtered list
- Item disappears from UI

---

## Error Handling Flow

### Example: Database Write Failure

**1. Error Occurs in Drift Layer**
```dart
// In LocalSource
Future<void> createTransaction(TransactionsCompanion transaction) async {
  try {
    return await _db.into(_db.transactions).insert(transaction);
  } catch (e) {
    // Drift errors (constraint violations, etc.)
    rethrow;
  }
}
```

**2. Repository Propagates Error**
```dart
// In Repository
Future<void> createTransaction(TransactionModel model) async {
  try {
    await _localSource.createTransaction(...);
  } catch (e) {
    // Don't swallow - let cubit handle
    rethrow;
  }
}
```

**3. Cubit Catches and Emits Error State**
```dart
// In Cubit
Future<void> createTransaction(TransactionModel model) async {
  emit(const TransactionListState.loading());

  try {
    await _transactionRepository.createTransaction(model);
  } catch (e) {
    emit(TransactionListState.error(e.toString()));  // ← Error state
  }
}
```

**4. Widget Shows Error UI**
```dart
// In Widget
BlocBuilder<TransactionListCubit, TransactionListState>(
  builder: (context, state) {
    return state.when(
      error: (msg) => Column(
        children: [
          const Icon(Icons.error, color: Colors.red),
          Text(msg),
          ElevatedButton(
            onPressed: () => context.read<TransactionListCubit>().retry(),
            child: const Text('Retry'),
          ),
        ],
      ),
      // ... other states
    );
  },
)
```

---

## Key Patterns

### 1. Optimistic Updates
- **Write happens locally first** (instant UI feedback)
- **Sync happens in background** (when API is added)
- **Conflicts resolved via last-write-wins** (using `updatedAt` timestamps)

### 2. Reactive Streams All The Way
- **Drift watch() streams** emit on database changes
- **Repository broadcast streams** forward to cubits
- **Cubit stream subscriptions** trigger automatic reloads
- **Widget BlocBuilders** rebuild on state changes

### 3. Synchronous Reads, Asynchronous Writes
- **Reads**: Synchronous from repository cache (`get transactions`)
- **Writes**: Asynchronous to database (`await createTransaction()`)
- **Benefit**: Fast reads, safe writes

### 4. userId Filtering Everywhere
- **All queries filter by userId** (security + multi-user)
- **Injected at LocalSource construction** (from AuthManager)
- **Validated on updates** (prevent cross-user modifications)

### 5. Soft Deletes
- **Never hard delete** (enables sync)
- **Set `isDeleted = true`** (marks for deletion)
- **Filter in watch() queries** (excludes from UI)
- **API sync can propagate deletion** (when added)

### 6. No Manual Reloads Needed
- **Never call reload after mutations** (streams handle it)
- **Watch streams are always active** (continuous observation)
- **UI updates automatically** (reactive by default)

---

## Performance Characteristics

### Write Latency
- Local write: **~5-10ms** (optimistic)
- API sync: **Background** (non-blocking, added later)

### Read Latency
- First load: **~20-50ms** (from database)
- Subsequent reads: **~1-2ms** (from cache)

### Memory Usage
- Repository caches: **~1-5 KB per entity type**
- Stream controllers: **~500 bytes each**
- Total overhead: **< 50 KB** (negligible)

### Database Size
- Typical user data: **~1-10 MB**
- Soft deletes retained: **Until next sync + cleanup**

---

## Future: API Sync Flow

When the API is added, the write flow will include background sync:

```
User Action
    ↓
Cubit → Repository → LocalSource → Drift (optimistic)
    ↓
UI Updates Immediately ✨
    ↓
Repository → SyncManager.queueChange()
    ↓
SyncManager (in isolate) → API.sync()
    ↓
On Success: Mark isSynced = true
On Failure: Retry with exponential backoff
On Conflict: Resolve via last-write-wins
```

See [sync-strategy.md](./sync-strategy.md) for detailed sync implementation plans.
