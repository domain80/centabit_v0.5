# Cubits Overview

Cubits manage UI state and business logic in Centabit v0.5 using the BLoC pattern with Cubit simplification.

## Architecture

Cubits live in the **presentation layer** and coordinate between repositories and UI:

```
UI (Widgets)
    ↓ (listens to state)
Cubits (State management)
    ↓ (subscribes to streams)
Repositories (Data access)
    ↓
LocalSources & Database
```

**Key Responsibilities:**
1. **Subscribe** to repository streams for reactive updates
2. **Transform** domain models into view models for UI
3. **Manage** UI state (loading, success, error)
4. **Execute** business logic (calculations, validation, filtering)
5. **Emit** state changes that trigger UI rebuilds

## Core Cubits

### [DashboardCubit](./dashboard-cubit.md)
Manages dashboard state with BAR calculations and budget reports.

**Responsibilities:**
- Subscribes to 4 repositories (budgets, allocations, transactions, categories)
- Builds `BudgetPageModel` for each active budget
- Calculates BAR (Budget Adherence Ratio)
- Generates chart data (allocations vs spending)
- Builds monthly overview for current calendar month

**State:** `DashboardState` (initial, loading, success, error)

### [TransactionListCubit](./transaction-list-cubit.md)
Manages transaction list with search, filtering, and pagination.

**Responsibilities:**
- Subscribes to transaction and category repositories
- Denormalizes transactions with category data
- Implements pagination (20 items per page)
- Filters by search query
- Handles scroll-to-date functionality

**State:** `TransactionListState` (initial, loading, success, error)

## Cubit Pattern

### MVVM Architecture

Centabit uses the **Model-View-ViewModel (MVVM)** pattern with Cubit as ViewModel:

```
Model (Domain Models)
  ↓
ViewModel (Cubit)
  ↓
View (Widgets)
```

**Benefits:**
- Clear separation of concerns
- Testable business logic
- Reactive UI updates
- Single source of truth

### State Management with Freezed

All cubit states use Freezed union types:

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
initial → loading → success
              ↓
            error
```

### Reactive Updates with Stream Subscriptions

Cubits subscribe to repository streams for automatic UI updates:

```dart
class DashboardCubit extends Cubit<DashboardState> {
  final BudgetRepository _budgetRepository;
  final TransactionRepository _transactionRepository;

  StreamSubscription? _budgetSubscription;
  StreamSubscription? _transactionSubscription;

  DashboardCubit(
    this._budgetRepository,
    this._transactionRepository,
  ) : super(const DashboardState.initial()) {
    // Subscribe to repository streams
    _budgetSubscription = _budgetRepository
      .budgetsStream
      .listen((_) => _loadData());

    _transactionSubscription = _transactionRepository
      .transactionsStream
      .listen((_) => _loadData());

    _loadData(); // Initial load
  }

  void _loadData() {
    emit(const DashboardState.loading());

    try {
      final budgets = _budgetRepository.budgets;
      final transactions = _transactionRepository.transactions;

      // Build view models...

      emit(DashboardState.success(...));
    } catch (e) {
      emit(DashboardState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    _transactionSubscription?.cancel();
    return super.close();
  }
}
```

**Critical Pattern:** Always cancel subscriptions in `close()` to prevent memory leaks.

### Data Flow

**Reactive Update Cycle:**

```
1. User creates transaction
   ↓
2. FormCubit calls repository.createTransaction()
   ↓
3. Repository writes to database
   ↓
4. Drift emits change to repository stream
   ↓
5. Repository broadcasts to subscribed cubits
   ↓
6. ListCubit's subscription triggers _load()
   ↓
7. Cubit emits new state
   ↓
8. BlocBuilder rebuilds UI
   ↓
9. User sees updated list
```

## Dependency Injection

Cubits are registered as **factories** in GetIt (new instance per request):

```dart
// lib/core/di/injection.dart

// Repositories (singletons)
getIt.registerLazySingleton<TransactionRepository>(
  () => TransactionRepository(getIt()),
);
getIt.registerLazySingleton<CategoryRepository>(
  () => CategoryRepository(getIt()),
);

// Cubits (factories)
getIt.registerFactory<DashboardCubit>(
  () => DashboardCubit(
    getIt<BudgetRepository>(),
    getIt<AllocationRepository>(),
    getIt<TransactionRepository>(),
    getIt<CategoryRepository>(),
  ),
);

getIt.registerFactory<TransactionListCubit>(
  () => TransactionListCubit(
    getIt<TransactionRepository>(),
    getIt<CategoryRepository>(),
  ),
);
```

**Why factories?**
- New instance per widget/screen
- Scoped lifecycle (disposed when widget removed)
- Independent state per instance

## Usage in Widgets

### BlocProvider

Provide cubit at widget tree root:

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

**Lifecycle:** Cubit created when widget built, disposed when widget removed.

### BlocBuilder

Listen to state changes and rebuild:

```dart
BlocBuilder<DashboardCubit, DashboardState>(
  builder: (context, state) {
    return state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const CircularProgressIndicator(),
      success: (budgetPages, monthlyOverview) => Column(
        children: [
          BudgetReportSection(pages: budgetPages),
          MonthlyOverviewCard(overview: monthlyOverview),
        ],
      ),
      error: (message) => ErrorWidget(message: message),
    );
  },
)
```

**Pattern:** Use Freezed's `.when()` for exhaustive state handling.

### BlocListener

Listen to state changes without rebuilding:

```dart
BlocListener<TransactionFormCubit, TransactionFormState>(
  listener: (context, state) {
    state.whenOrNull(
      success: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction saved')),
        );
      },
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $message')),
        );
      },
    );
  },
  child: TransactionForm(),
)
```

**Use case:** Navigation, snackbars, dialogs (side effects).

### BlocConsumer

Combine builder + listener:

```dart
BlocConsumer<TransactionListCubit, TransactionListState>(
  listener: (context, state) {
    // Handle errors
    state.whenOrNull(
      error: (message) => showErrorSnackbar(context, message),
    );
  },
  builder: (context, state) {
    // Build UI
    return state.when(
      initial: () => const SizedBox(),
      loading: () => const LoadingIndicator(),
      success: (transactions, ...) => TransactionList(transactions),
      error: (_) => const ErrorPlaceholder(),
    );
  },
)
```

## View Models

Cubits often transform domain models into view models for UI:

### Denormalization Pattern

**Problem:** Domain models contain only IDs, not full related data.

```dart
// TransactionModel has categoryId but not category name/icon
class TransactionModel {
  final String id;
  final String? categoryId; // Just the ID
  // ...
}
```

**Solution:** Cubit denormalizes data into view models.

```dart
// TransactionVModel includes denormalized category data
class TransactionVModel {
  final String id;
  final String? categoryId;
  final String? categoryName;      // Denormalized
  final String? categoryIconName;  // Denormalized
  // ...
}

// In TransactionListCubit
void _loadTransactions() {
  final viewModels = _transactionRepository.transactions.map((tx) {
    final category = tx.categoryId != null
      ? _categoryRepository.getCategoryByIdSync(tx.categoryId!)
      : null;

    return TransactionVModel(
      id: tx.id,
      name: tx.name,
      amount: tx.amount,
      categoryId: tx.categoryId,
      categoryName: category?.name,         // Joined
      categoryIconName: category?.iconName, // Joined
    );
  }).toList();

  emit(TransactionListState.success(transactions: viewModels));
}
```

**Benefits:**
- UI widgets get all data in one object
- No async lookups in widget build
- Better performance
- Cleaner widget code

### Page Models

Cubits build aggregate page models for complex screens:

```dart
// BudgetPageModel aggregates data from 4 sources
class BudgetPageModel {
  final BudgetModel budget;                    // From BudgetRepository
  final double barIndexValue;                  // Calculated
  final List<TransactionsChartData> chartData; // Built from 3 sources
  final double totalBudget;                    // Calculated
  final double totalSpent;                     // Calculated
}

// Built in DashboardCubit
BudgetPageModel _buildBudgetPageModel(BudgetModel budget) {
  final allocations = _allocationRepository.getAllocationsForBudget(budget.id);
  final transactions = _transactionRepository.transactions
    .where((tx) => tx.budgetId == budget.id)
    .toList();
  final categories = _categoryRepository.categories;

  final chartData = _buildChartData(
    allocations: allocations,
    transactions: transactions,
    categories: categories,
  );

  final totalBudget = allocations.fold<double>(0, (sum, a) => sum + a.amount);
  final totalSpent = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
  final barValue = _calculateBAR(...);

  return BudgetPageModel(
    budget: budget,
    barIndexValue: barValue,
    chartData: chartData,
    totalBudget: totalBudget,
    totalSpent: totalSpent,
  );
}
```

**Use case:** Complex screens that need data from multiple sources.

## Common Patterns

### Initial Data Load

```dart
DashboardCubit(...) : super(const DashboardState.initial()) {
  _subscribeToStreams();
  _loadData(); // Initial load after subscriptions
}
```

### Refresh Method

```dart
Future<void> refresh() async {
  _loadData();
  return Future.value(); // For RefreshIndicator
}
```

### Search/Filter Methods

```dart
void searchTransactions(String query) {
  _currentPage = 0; // Reset pagination
  _loadTransactions(); // Reload with query
}

void clearFilters() {
  _currentPage = 0;
  _loadTransactions();
}
```

### Pagination

```dart
void loadNextPage() {
  _currentPage++;
  _loadTransactions();
}
```

### Error Handling

```dart
void _loadData() {
  emit(const DashboardState.loading());

  try {
    // Load and transform data
    emit(DashboardState.success(...));
  } catch (e, stackTrace) {
    logger.error('Failed to load dashboard', error: e, stackTrace: stackTrace);
    emit(DashboardState.error(e.toString()));
  }
}
```

## Critical State Management Pattern

### setState-During-Build Error Prevention

When cubit methods emit states that trigger UI rebuilds, use `scheduleMicrotask()`:

```dart
void updateAllocation(String id, String categoryId, double amount) {
  _allocations = _allocations.map((alloc) {
    if (alloc.id == id) {
      return AllocationEditModel(
        id: alloc.id,
        categoryId: categoryId,
        amount: amount,
      );
    }
    return alloc;
  }).toList();

  // Defer state emission to avoid setState-during-build errors
  scheduleMicrotask(() {
    _rebuildCounter++;
    emit(BudgetFormState.initial(rebuildCounter: _rebuildCounter));
  });
}
```

**Why?** Widget callbacks (onTap, onChange) may fire during build phase. Emitting immediately causes setState-during-build error.

**Solution:** `scheduleMicrotask()` defers emission until after current build completes.

## File Naming Convention

All cubits follow this convention:

**File naming:**
```
lib/features/[feature]/presentation/cubits/[feature]_cubit.dart
lib/features/[feature]/presentation/cubits/[feature]_state.dart
```

**Class naming:**
```dart
class [Feature]Cubit extends Cubit<[Feature]State> { }

@freezed
abstract class [Feature]State with _$[Feature]State { }
```

**Examples:**
- `DashboardCubit` + `DashboardState` in `dashboard_cubit.dart` + `dashboard_state.dart`
- `TransactionListCubit` + `TransactionListState`
- `BudgetFormCubit` + `BudgetFormState`

## Best Practices

### Always Cancel Subscriptions

```dart
// ✅ Good - prevents memory leaks
@override
Future<void> close() {
  _subscription1?.cancel();
  _subscription2?.cancel();
  return super.close();
}

// ❌ Bad - memory leak
@override
Future<void> close() {
  return super.close(); // Subscriptions never cancelled!
}
```

### Use Synchronous Repository Getters

```dart
// ✅ Good - synchronous data access
void _loadData() {
  final budgets = _budgetRepository.budgets;
  final transactions = _transactionRepository.transactions;
  // ...
}

// ❌ Bad - unnecessary async
Future<void> _loadData() async {
  final budgets = await _budgetRepository.getAllBudgets();
  final transactions = await _transactionRepository.getAllTransactions();
  // ...
}
```

### Handle All State Cases

```dart
// ✅ Good - exhaustive handling
return state.when(
  initial: () => const SizedBox(),
  loading: () => const LoadingIndicator(),
  success: (data) => DataView(data),
  error: (msg) => ErrorView(msg),
);

// ❌ Bad - may crash on unhandled state
return state.maybeWhen(
  success: (data) => DataView(data),
  orElse: () => const SizedBox(), // What about errors?
);
```

### Emit Loading State First

```dart
// ✅ Good - shows loading indicator
void _loadData() {
  emit(const DashboardState.loading());
  // Load data...
  emit(DashboardState.success(...));
}

// ❌ Bad - UI stuck in previous state
void _loadData() {
  // Load data...
  emit(DashboardState.success(...)); // No loading feedback!
}
```

## Logging

Cubits are automatically logged via `CubitLogger` (BlocObserver):

```dart
// Automatically logged:
// - State changes
// - Cubit creation/closure
// - Errors

// Example log output:
[DashboardCubit] State changed:
  Previous: _Loading()
  Current: _Success(budgetPages: [3 items], monthlyOverview: ...)
```

**Setup in main.dart:**
```dart
Bloc.observer = CubitLogger();
```

## Next Steps

- [DashboardCubit →](./dashboard-cubit.md) - Dashboard state management
- [TransactionListCubit →](./transaction-list-cubit.md) - Transaction list state

See also:
- [Models →](../models/index.md) - Domain models
- [Repositories →](../repositories/index.md) - Data access
