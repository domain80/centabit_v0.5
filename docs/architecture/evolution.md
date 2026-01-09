# Architecture Evolution (v0.4 → v0.5)

Complete architectural rewrite addressing fundamental limitations discovered in [v0.4](https://github.com/domain80/centabit-mobile_v0.4).

## Why Rewrite?

v0.4 successfully implemented core features (transactions, budgets, categories, authentication) but the architecture couldn't scale.

### Problems with v0.4

1. **State Management Complexity** - Provider + Command pattern led to verbose boilerplate and tight coupling
2. **Monolithic Services** - Large service classes handled too many responsibilities
3. **No Multi-User Support** - Data wasn't filtered by userId
4. **Main Thread Sync** - Synchronization caused UI jank
5. **Layer-Based Organization** - Code scattered across multiple directories
6. **Implicit Dependencies** - Hard to understand dependency graphs
7. **Limited Type Safety** - Runtime errors from missing code generation

## Architecture Comparison

### v0.4 (Archived)

```
┌─────────────────────────────────────────┐
│  UI Layer (Provider + Command Pattern) │
│  - ViewModels with Command<T>           │
│  - Direct repository access             │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Service Layer (Monolithic)             │
│  - AppRepo (all-in-one service)         │
│  - Mixed concerns (data + sync + cache) │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Database (Drift) + Queue-Based Sync    │
│  - No userId filtering                  │
│  - Sync runs on main thread             │
└─────────────────────────────────────────┘
```

**Stack:**
- State: `provider` + `command_it`
- Navigation: `routemaster`
- DI: `provider` (implicit)
- Models: Hand-written classes
- Sync: Queue-based on main thread

### v0.5 (Current)

```
┌─────────────────────────────────────────┐
│  Presentation Layer (Cubits + Freezed)  │
│  - Feature-specific Cubits              │
│  - Immutable states with union types    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Repository Layer (Clean Architecture)  │
│  - Single Responsibility repos          │
│  - Broadcast streams for reactivity     │
│  - Transform DB ↔ Domain models         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  LocalSources (userId-filtered)         │
│  - Automatic userId injection           │
│  - Secure multi-user data isolation     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Database (Drift) + Isolate-Based Sync  │
│  - Reactive queries                     │
│  - Background sync (off main thread)    │
└─────────────────────────────────────────┘
```

**Stack:**
- State: `flutter_bloc` (Cubits) + `freezed`
- Navigation: `go_router`
- DI: `get_it` (explicit)
- Models: `freezed` (immutable, code-gen)
- Sync: Isolate-based background
- Logging: `talker_flutter`

## Key Improvements

### 1. Feature-First Organization

**v0.4 (Layer-Based):**
```
lib/
├── ui/
│   ├── budget/
│   ├── transaction/
│   └── category/
├── data/
│   ├── db/
│   └── repo/
└── domain/
    └── models/
```

Finding budget code required navigating 3+ directories.

**v0.5 (Feature-First):**
```
lib/
├── features/
│   ├── budgets/
│   │   ├── presentation/
│   │   │   ├── cubits/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   └── domain/
│   ├── transactions/
│   └── categories/
├── data/
│   ├── repositories/
│   ├── local/
│   └── models/
└── core/
    ├── di/
    ├── router/
    └── theme/
```

All budget code in `features/budgets/`. Benefits:
- Faster development
- Better code isolation
- Easier to scale

### 2. Repository Pattern

**v0.4:**
```dart
class AppRepo {
  // Monolithic: 500+ lines for everything
  Future<void> create(...) { }
  Future<void> sync() { }
  Stream<List> watch() { }
}
```

**v0.5:**
```dart
// Single Responsibility
class TransactionRepository {
  final TransactionLocalSource _localSource;
  final _controller = StreamController<List<TransactionModel>>.broadcast();

  Stream<List<TransactionModel>> get transactionsStream => _controller.stream;
  Future<void> createTransaction(TransactionModel model) async { }
}

// LocalSource handles userId-filtered access
class TransactionLocalSource {
  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
      ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
    ).watch();
  }
}
```

Benefits:
- Easy to test
- Multi-user support built-in
- Better maintainability
- Reactive updates

### 3. State Management: Cubit + Freezed

**v0.4 (Provider + Commands):**
```dart
class BudgetsViewModel extends ChangeNotifier {
  final Command<List<BudgetModel>> getBudgets = Command.createAsync(
    () async => await repo.budgets.getAll(),
    initialValue: null,
  );
  // Lots of boilerplate
}
```

**v0.5 (Cubit + Freezed):**
```dart
@freezed
class BudgetListState with _$BudgetListState {
  const factory BudgetListState.initial() = _Initial;
  const factory BudgetListState.loading() = _Loading;
  const factory BudgetListState.loaded(List<BudgetModel> budgets) = _Loaded;
  const factory BudgetListState.error(String message) = _Error;
}

class BudgetListCubit extends Cubit<BudgetListState> {
  BudgetListCubit(this._budgetRepository) : super(BudgetListState.initial()) {
    _budgetRepository.budgetsStream.listen((budgets) {
      emit(BudgetListState.loaded(budgets));
    });
  }
}
```

Benefits:
- Type-safe state transitions
- Less boilerplate via code generation
- Immutable states
- Better DevTools debugging

### 4. Dependency Injection: Breaking Free from BuildContext

The shift from Provider to GetIt solved one critical problem: **BuildContext coupling**. Provider requires widget context, making it unusable in pure Dart classes, tests, and background isolates.

#### The Core Problem with Provider

**Setup (scattered across widget tree):**
```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppRepo()),
    ChangeNotifierProvider(create: (_) => BudgetsViewModel()),
    // ... more providers
  ],
  child: MyApp(),
)
```

**Usage in widgets:**
```dart
class BudgetListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dependencies resolved at runtime via BuildContext
    final vm = context.read<BudgetsViewModel>();

    // What does BudgetsViewModel need? You have to check its constructor
    // or read the entire file to know
    return ListView(...);
  }
}
```

**Why this broke down:**

Provider works well for Flutter widgets, but v0.5 architecture requires dependency injection in contexts where BuildContext doesn't exist:

1. **Pure Dart classes** (business logic, utilities):
   ```dart
   class BudgetCalculator {
     // ❌ No BuildContext available in pure Dart
     void calculate() {
       final repo = context.read<BudgetRepository>(); // Won't compile
     }
   }
   ```

2. **Background isolates** (SyncManager):
   ```dart
   static void _syncIsolateEntryPoint(SendPort port) {
     // ❌ No BuildContext in isolate
     final api = context.read<ApiClient>(); // Won't work
   }
   ```

3. **Repository layer** (data access):
   ```dart
   class TransactionRepository {
     // ❌ Repositories shouldn't depend on Flutter
     final _localSource = context.read<TransactionLocalSource>();
   }
   ```

4. **Unit tests** (non-widget tests):
   ```dart
   test('calculate BAR', () {
     // ❌ No widget tree, no BuildContext
     final calc = BudgetCalculator();
   });
   ```

The architecture requires **separation of concerns**: business logic, data access, and background processing must be independent of the UI layer. Provider's BuildContext requirement couples everything to Flutter widgets.

#### v0.5: Service Locator with GetIt

GetIt is a **service locator pattern** - a centralized registry for dependencies accessible from anywhere. While service locators are often considered an anti-pattern (global state, hidden dependencies), they're the pragmatic choice for Flutter apps that need DI beyond the widget tree.

**Setup (centralized in one file):**
```dart
// lib/core/di/injection.dart
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Register database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Register LocalSources (created once, reused)
  getIt.registerLazySingleton<TransactionLocalSource>(
    () => TransactionLocalSource(
      getIt<AppDatabase>(),
      getIt<AuthManager>().userId,
    ),
  );

  // Register Repositories (singletons with broadcast streams)
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(getIt<TransactionLocalSource>()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<CategoryLocalSource>()),
  );

  // Register Cubits (new instance per request)
  getIt.registerFactory<TransactionListCubit>(
    () => TransactionListCubit(
      getIt<TransactionRepository>(),
      getIt<CategoryRepository>(),
    ),
  );

  getIt.registerFactory<BudgetFormCubit>(
    () => BudgetFormCubit(
      getIt<BudgetRepository>(),
      getIt<AllocationRepository>(),
      getIt<CategoryRepository>(),
    ),
  );
}
```

**Usage anywhere:**
```dart
// In widgets
class BudgetListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Dependency resolution is explicit
      create: (_) => getIt<BudgetListCubit>(),
      child: BlocBuilder<BudgetListCubit, BudgetListState>(
        builder: (context, state) => ListView(...),
      ),
    );
  }
}

// In pure Dart classes (no BuildContext needed!)
class BudgetCalculator {
  final BudgetRepository _repo = getIt<BudgetRepository>();

  double calculate() {
    final budgets = _repo.getActiveBudgets();
    return budgets.fold(0.0, (sum, b) => sum + b.amount);
  }
}

// In tests
void main() {
  setUp(() {
    // Register mocks for testing
    getIt.registerLazySingleton<TransactionRepository>(
      () => MockTransactionRepository(),
    );
  });

  test('budget calculation', () {
    final calculator = BudgetCalculator();
    expect(calculator.calculate(), 1000.0);
  });
}
```

**What GetIt solves:**

1. **No BuildContext dependency** - Access anywhere (repositories, isolates, tests, utilities)
   ```dart
   // Works in pure Dart classes
   class BudgetCalculator {
     final _repo = getIt<BudgetRepository>();
   }

   // Works in background isolates
   static void _syncIsolate(SendPort port) {
     final api = getIt<ApiClient>();
   }

   // Works in unit tests
   test('calculate', () {
     final calc = BudgetCalculator();
   });
   ```

2. **Centralized configuration** - One file (`injection.dart`) shows entire dependency graph
   - All singletons vs factories visible at a glance
   - Clear initialization order
   - Single place to refactor

3. **Explicit lifecycles**:
   - `registerLazySingleton`: Created on first access, shared instance
   - `registerFactory`: New instance every call
   - `registerSingleton`: Created immediately, shared instance

4. **Easy testing** - Swap implementations without rebuilding widget tree
   ```dart
   setUp(() {
     getIt.registerLazySingleton<BudgetRepository>(
       () => MockBudgetRepository(),
     );
   });
   ```

**Usage rules to prevent service locator abuse:**

1. **Prefer constructor injection** - Pass dependencies explicitly when possible
   ```dart
   // ✅ Good: Dependencies visible in constructor
   class TransactionListCubit {
     TransactionListCubit(this._transactionRepo, this._categoryRepo);
   }

   // ❌ Avoid: Hidden dependencies
   class TransactionListCubit {
     final _transactionRepo = getIt<TransactionRepository>();
     final _categoryRepo = getIt<CategoryRepository>();
   }
   ```

2. **Use GetIt only at composition root** - Register dependencies in `injection.dart`, resolve at app startup
   ```dart
   // ✅ Good: Resolve once when creating cubit
   BlocProvider(create: (_) => getIt<TransactionListCubit>())

   // ❌ Avoid: Accessing getIt deep in business logic
   void processTransaction() {
     final repo = getIt<TransactionRepository>(); // Hidden dependency
   }
   ```

3. **Register interfaces, not implementations** - Dependency inversion principle
   ```dart
   // ✅ Good: Depends on abstraction
   getIt.registerLazySingleton<BudgetRepository>(
     () => BudgetRepositoryImpl(getIt()),
   );

   // ❌ Avoid: Depends on concrete class everywhere
   getIt.registerLazySingleton<BudgetRepositoryImpl>(...)
   ```

**Acknowledged tradeoffs:**

1. **Global state** - GetIt is a global singleton, which can make dependency flow less obvious at call sites
2. **Runtime errors** - Missing registrations fail at runtime, not compile time (mitigated by failing fast at app startup)
3. **Easy to abuse** - Tempting to call `getIt<T>()` everywhere instead of proper constructor injection

#### Real-World Impact

**v0.4 scenario**: "Background sync needs to access BudgetRepository"
1. ❌ Can't use `context.read<BudgetRepository>()` in isolate
2. ❌ Can't pass BuildContext to isolate (BuildContext isn't serializable)
3. ❌ Options:
   - Restructure to pass all dependencies as serializable data (breaks architecture)
   - Move sync logic into widget tree (couples business logic to UI)
   - Use global singletons (defeats purpose of DI)

**v0.5 scenario**: "Background sync needs to access BudgetRepository"
1. ✅ Register BudgetRepository in `injection.dart`
2. ✅ Access in isolate:
   ```dart
   static void _syncIsolate(SendPort port) {
     final repo = getIt<BudgetRepository>();
     final budgets = repo.getActiveBudgets();
     // Sync logic here
   }
   ```
3. ✅ Repository is available anywhere - widgets, isolates, tests, utilities

**The key win**: GetIt enabled clean architecture by removing the BuildContext requirement. The service locator pattern is a pragmatic tradeoff for Flutter apps that need dependency injection in non-widget contexts.

### 5. Isolate-Based Background Sync

**v0.4:**
```dart
class InMemorySyncQueue {
  // Runs on main thread - causes jank
  Future<void> processQueue() async {
    for (var item in _queue) {
      await _api.sync(item); // Blocks UI
    }
  }
}
```

**v0.5:**
```dart
class SyncManager {
  Future<void> startPeriodicSync() async {
    _syncIsolate = await Isolate.spawn(
      _syncIsolateEntryPoint,
      _syncReceivePort!.sendPort,
    );

    _periodicSyncTimer = Timer.periodic(Duration(minutes: 5), (_) {
      triggerSync(); // Runs in background - UI stays smooth
    });
  }

  static void _syncIsolateEntryPoint(SendPort mainSendPort) {
    // Sync work happens here, off main thread
  }
}
```

Benefits:
- No UI jank
- Periodic automatic sync
- Better battery life
- Scalable architecture

### 6. Multi-User Support

**v0.4:**
```sql
-- No userId filtering
SELECT * FROM transactions;
```

**v0.5:**
```dart
class TransactionLocalSource {
  final String userId; // Injected via DI

  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
      ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
    ).watch();
  }
}
```

Benefits:
- Secure data isolation
- Account switching ready
- OAuth preparation
- Soft deletes for sync

### 7. Improved Logging

**v0.4:**
```dart
loggy.info("Transaction created");
```

**v0.5:**
```dart
// Repository-level logging mixin
mixin RepositoryLogger {
  Future<T> trackRepositoryOperation<T>({
    required String operation,
    required Future<T> Function() execute,
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      AppLogger.instance.debug('[$repositoryName] Starting $operation');
      final result = await execute();
      AppLogger.instance.debug('Completed in ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e, st) {
      AppLogger.instance.error('Failed $operation', e, st);
      rethrow;
    }
  }
}
```

Benefits:
- Performance monitoring
- Better error context
- In-app log viewer
- Production debugging

### 8. Type Safety

**v0.4:**
```dart
class TransactionModel {
  final String id;
  final String name;
  final double amount;

  TransactionModel({required this.id, required this.name, required this.amount});

  // Manual toJson, fromJson, copyWith, ==, hashCode
}
```

**v0.5:**
```dart
@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String name,
    required double amount,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

// Generated: toJson, fromJson, copyWith, ==, hashCode, toString
```

Benefits:
- No boilerplate
- Compile-time safety
- Immutability guaranteed
- Deep copy operations

## Migration Impact

### Code Reduction
- **50% less boilerplate** with Freezed code generation
- **Clearer dependencies** with GetIt vs Provider
- **Better organized** with feature-first structure

### Performance
- **No UI jank** from background sync in isolates
- **Faster builds** with better code organization
- **Efficient updates** via reactive streams

### Developer Experience
- **Faster feature development** with feature-first organization
- **Better debugging** with Talker logging and BlocObserver
- **Easier testing** with explicit dependencies and mockable repositories
- **Type safety** prevents entire classes of runtime errors

### Scalability
- **Multi-user ready** with userId filtering throughout
- **OAuth preparation** with anonymous token infrastructure
- **Cloud sync ready** with isolate-based background sync
- **Feature independence** allows parallel development

## Lessons Learned

1. **Start with architecture** - Getting it right early saves months of refactoring
2. **Feature-first scales better** than layer-based organization
3. **Explicit is better than implicit** - Clear dependencies help everyone
4. **Code generation reduces bugs** - Less manual code = fewer mistakes
5. **Background processing matters** - Keep the UI thread responsive
6. **Plan for multi-user from day one** - Retrofitting userId filtering is painful
7. **Invest in logging infrastructure** - Debugging production issues requires good logs

## Next Steps

See [Roadmap](/roadmap/) for current features and potential future development.
