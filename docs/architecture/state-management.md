# State Management

How Centabit manages state using Cubit and reactive streams.

## Pattern Overview

Centabit uses **Cubit** (from flutter_bloc) with reactive stream subscriptions.

## Key Components

### 1. Cubit

State management logic that emits states based on events.

```dart
class DashboardCubit extends Cubit<DashboardState> {
  final BudgetRepository _budgetRepository;
  StreamSubscription? _budgetSubscription;

  DashboardCubit(this._budgetRepository) 
      : super(const DashboardState.initial()) {
    // Subscribe to repository streams
    _budgetSubscription = _budgetRepository.stream.listen((_) => _load());
    _load();
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    return super.close();
  }
}
```

### 2. Freezed States

Immutable state with union types:

```dart
@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = _Initial;
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.success(Data data) = _Success;
  const factory DashboardState.error(String message) = _Error;
}
```

### 3. Repository Streams

Repositories expose broadcast streams:

```dart
class BudgetRepository {
  final _controller = StreamController<List<Budget>>.broadcast();

  Stream<List<Budget>> get stream => _controller.stream;

  BudgetRepository(LocalSource source) {
    source.watchAll().listen((data) {
      _controller.add(data.map(_toModel).toList());
    });
  }
}
```

## Data Flow

```
User Action
  ↓
Cubit Method Call
  ↓
Repository Method Call
  ↓
LocalSource Database Query
  ↓
Drift Watch Stream Emits
  ↓
Repository Transforms & Emits
  ↓
Cubit Stream Subscription Triggers
  ↓
Cubit Reloads Data & Emits State
  ↓
BlocBuilder Rebuilds UI
```

## Critical Pattern: Reactive Cubits

Cubits subscribe to repository streams for automatic updates:

```dart
class TransactionListCubit extends Cubit<TransactionListState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  StreamSubscription? _transactionSub;
  StreamSubscription? _categorySub;

  TransactionListCubit(
    this._transactionRepository,
    this._categoryRepository,
  ) : super(const TransactionListState.initial()) {
    // Subscribe to both streams
    _transactionSub = _transactionRepository.stream.listen((_) => _load());
    _categorySub = _categoryRepository.stream.listen((_) => _load());
    _load();
  }

  Future<void> _load() async {
    emit(const TransactionListState.loading());
    try {
      final transactions = _transactionRepository.getAll();
      final categories = _categoryRepository.getAll();
      // Denormalize data for UI
      final viewModels = _buildViewModels(transactions, categories);
      emit(TransactionListState.success(viewModels));
    } catch (e) {
      emit(TransactionListState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _transactionSub?.cancel();
    _categorySub?.cancel();
    return super.close();
  }
}
```

## UI Integration

### BlocProvider

Provide cubit to widget tree:

```dart
BlocProvider(
  create: (_) => getIt<DashboardCubit>(),
  child: DashboardView(),
)
```

### BlocBuilder

Rebuild on state changes:

```dart
BlocBuilder<DashboardCubit, DashboardState>(
  builder: (context, state) => state.when(
    initial: () => const SizedBox.shrink(),
    loading: () => const CircularProgressIndicator(),
    success: (data) => DashboardContent(data: data),
    error: (msg) => ErrorWidget(message: msg),
  ),
)
```

### BlocListener

Side effects without rebuilding:

```dart
BlocListener<FormCubit, FormState>(
  listener: (context, state) {
    state.whenOrNull(
      success: () => Navigator.pop(context),
      error: (msg) => showSnackBar(msg),
    );
  },
  child: FormView(),
)
```

## Best Practices

1. **One cubit per feature** - Don't share cubits across features
2. **Subscribe to streams** - For automatic updates
3. **Cancel subscriptions** - Always in close()
4. **Use factories in DI** - New cubit instance per widget
5. **Emit loading states** - Show progress to users
6. **Handle errors** - Always catch and emit error states

## Next Steps

- [Repository Pattern](/architecture/data-flow.html)
- [Adding Features](/development/adding-features.html)
