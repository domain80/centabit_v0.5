# Centabit v0.5

A budgeting app that gets better with each iteration.

**[Join the FREE Waitlist](https://tally.so/r/eqQo4k)** to be notified when we launch!

## Demo

<div align="center">
  <img src="docs/demo.gif" alt="Centabit v0.5 Demo" width="350">
  <br>
  <a href="docs/demo.mp4">📹 Watch Full Demo Video (3 min, 2.6MB)</a>
</div>

---

## Why v0.5? The Architectural Evolution

Centabit v0.5 represents a complete architectural rewrite of the application, addressing fundamental limitations discovered in [v0.4](https://github.com/domain80/centabit_v0.4). While v0.4 successfully implemented core features (transactions, budgets, categories, authentication), its architecture couldn't support the evolving needs of a production-ready budgeting application.

### Problems with v0.4

The v0.4 architecture faced several critical limitations:

1. **State Management Complexity**: The combination of Provider + Command pattern (`command_it`) led to verbose boilerplate and tight coupling between UI and business logic.

2. **Monolithic Services**: Large service classes handled multiple responsibilities (data access, business logic, sync, caching), violating the Single Responsibility Principle.

3. **No Multi-User Support**: Data wasn't filtered by `userId`, making it impossible to support multiple accounts or secure data isolation.

4. **Main Thread Sync**: Synchronization operations ran on the UI thread, causing potential jank during network operations.

5. **Layer-Based Organization**: Files organized by type (`/ui`, `/data`, `/domain`) made it difficult to locate feature-related code scattered across multiple directories.

6. **Implicit Dependencies**: Provider-based DI obscured dependency graphs, making it hard to understand what each component required.

7. **Limited Type Safety**: Lack of code generation for models meant runtime errors for typos and missing null safety guarantees.

---

## Architecture Comparison

### v0.4 Architecture (Archived)

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

**Technology Stack:**
- State Management: `provider` + `command_it`
- Navigation: `routemaster`
- DI: `provider` (implicit)
- Data Models: Hand-written classes
- Sync: Queue-based on main thread

### v0.5 Architecture (Current)

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

**Technology Stack:**
- State Management: `flutter_bloc` (Cubits) + `freezed`
- Navigation: `go_router`
- DI: `get_it` (explicit)
- Data Models: `freezed` (immutable, code-gen)
- Sync: Isolate-based background sync
- Logging: `talker_flutter`

---

## Key Improvements

### 1. **Feature-First Organization**

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
Finding budget-related code required navigating 3+ directories.

**v0.5 (Feature-First):**
```
lib/
├── features/
│   ├── budgets/
│   │   ├── presentation/
│   │   │   ├── cubits/
│   │   │   ├── screens/
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
All budget-related code lives in `features/budgets/`. This improves:
- **Developer velocity**: Find related code faster
- **Code isolation**: Features are self-contained
- **Scalability**: Add new features without touching existing ones

### 2. **Repository Pattern with Clean Separation**

**v0.4:**
```dart
class AppRepo {
  // Monolithic: 500+ lines handling transactions, budgets, categories, sync
  Future<void> create(...) { /* ... */ }
  Future<void> sync() { /* ... */ }
  Stream<List> watch() { /* ... */ }
}
```

**v0.5:**
```dart
// Single Responsibility: Each repository handles one domain
class TransactionRepository {
  final TransactionLocalSource _localSource;
  final _controller = StreamController<List<TransactionModel>>.broadcast();

  Stream<List<TransactionModel>> get transactionsStream => _controller.stream;

  Future<void> createTransaction(TransactionModel model) async { /* ... */ }
}

// LocalSource handles userId-filtered database access
class TransactionLocalSource {
  final AppDatabase _db;
  final String userId;

  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
      ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
    ).watch();
  }
}
```

**Benefits:**
- **Testability**: Mock repositories easily without mocking the entire app
- **Multi-user support**: `userId` filtering at the data source layer
- **Maintainability**: Changes to transaction logic don't affect budgets
- **Reactive streams**: Broadcast streams notify UI of changes automatically

### 3. **State Management: Cubit + Freezed**

**v0.4 (Provider + Commands):**
```dart
class BudgetsViewModel extends ChangeNotifier {
  final Command<List<BudgetModel>> getBudgets = Command.createAsync(
    () async => await repo.budgets.getAll(),
    initialValue: null,
  );

  // Lots of boilerplate for loading/error states
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
  final BudgetRepository _budgetRepository;

  BudgetListCubit(this._budgetRepository) : super(BudgetListState.initial()) {
    _listenToBudgets();
  }

  void _listenToBudgets() {
    _budgetRepository.budgetsStream.listen((budgets) {
      emit(BudgetListState.loaded(budgets));
    });
  }
}
```

**Benefits:**
- **Type safety**: Exhaustive pattern matching prevents missing states
- **Less boilerplate**: Code generation handles equals, hashCode, copyWith
- **Clear state transitions**: States are immutable and explicit
- **Better DevTools**: BlocObserver provides excellent debugging insights

### 4. **Dependency Injection: GetIt**

**v0.4 (Implicit):**
```dart
// Hidden dependencies - hard to see what each widget needs
final vm = context.read<BudgetsViewModel>();
```

**v0.5 (Explicit):**
```dart
// injection.dart - Dependency graph is clear and documented
Future<void> configureDependencies() async {
  // Singletons
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(getIt<TransactionLocalSource>()),
  );

  // Factories (new instance per request)
  getIt.registerFactory<TransactionListCubit>(
    () => TransactionListCubit(
      getIt<TransactionRepository>(),
      getIt<CategoryRepository>(),
    ),
  );
}

// Usage
BlocProvider(create: (_) => getIt<TransactionListCubit>())
```

**Benefits:**
- **Explicit dependencies**: See exactly what each component needs
- **Lifecycle control**: Singletons vs Factories
- **No BuildContext required**: Access dependencies anywhere
- **Better testing**: Register mocks easily for unit tests

### 5. **Isolate-Based Background Sync**

**v0.4:**
```dart
class InMemorySyncQueue {
  // Runs on main thread - can cause UI jank
  Future<void> processQueue() async {
    for (var item in _queue) {
      await _api.sync(item); // Blocks UI thread
    }
  }
}
```

**v0.5:**
```dart
class SyncManager {
  Isolate? _syncIsolate;

  Future<void> startPeriodicSync() async {
    _syncIsolate = await Isolate.spawn(
      _syncIsolateEntryPoint,
      _syncReceivePort!.sendPort,
    );

    _periodicSyncTimer = Timer.periodic(Duration(minutes: 5), (_) {
      triggerSync(); // Runs in background isolate - UI stays smooth
    });
  }

  static void _syncIsolateEntryPoint(SendPort mainSendPort) {
    // All sync work happens here, off the main thread
  }
}
```

**Benefits:**
- **No UI jank**: Sync runs completely off the main thread
- **Periodic background sync**: Every 5 minutes automatically
- **Better battery life**: Batch operations in isolate
- **Scalable**: Can spawn multiple isolates for different tasks

### 6. **Multi-User Support with userId Filtering**

**v0.4:**
```sql
-- No userId filtering - can't support multiple accounts
SELECT * FROM transactions;
```

**v0.5:**
```dart
class TransactionLocalSource {
  final String userId; // Injected during DI setup

  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
      ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
    ).watch();
  }
}

// All queries automatically filter by userId
// Makes multi-user and account switching trivial
```

**Benefits:**
- **Secure data isolation**: Users can't see each other's data
- **Account switching**: Just reinitialize DI with new userId
- **Ready for auth**: Anonymous tokens now, OAuth later
- **Soft deletes**: `isDeleted` flag enables sync-friendly deletions

### 7. **Improved Logging and Debugging**

**v0.4:**
```dart
// Basic loggy logging
loggy.info("Transaction created");
```

**v0.5:**
```dart
// Talker Flutter with rich logging
class AppLogger {
  final talker = TalkerFlutter.init(
    settings: TalkerSettings(useConsoleLogs: kDebugMode),
  );

  void info(String message) => talker.info(message);
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    talker.error(message, error, stackTrace);
  }
}

// Repository-level logging mixin
mixin RepositoryLogger {
  String get repositoryName;

  Future<T> trackRepositoryOperation<T>({
    required String operation,
    required Future<T> Function() execute,
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      AppLogger.instance.debug(
        '[$repositoryName] Starting $operation',
        metadata,
      );
      final result = await execute();
      stopwatch.stop();
      AppLogger.instance.debug(
        '[$repositoryName] Completed $operation in ${stopwatch.elapsedMilliseconds}ms',
      );
      return result;
    } catch (e, st) {
      AppLogger.instance.error(
        '[$repositoryName] Failed $operation',
        e,
        st,
      );
      rethrow;
    }
  }
}
```

**Benefits:**
- **Performance monitoring**: Track operation duration
- **Better error context**: Stack traces and metadata
- **In-app log viewer**: Talker Flutter provides UI for viewing logs
- **Production debugging**: Filter logs by severity

### 8. **Type Safety with Freezed**

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
    required TransactionType type,
    DateTime? transactionDate,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

// Code generation provides:
// - Immutability
// - copyWith (for updates)
// - == and hashCode (value equality)
// - toString (debugging)
// - fromJson/toJson (serialization)
```

**Benefits:**
- **No boilerplate**: Code generation handles everything
- **Immutability**: Prevents accidental mutations
- **Value equality**: Compare objects by value, not reference
- **Union types**: Use for states (loading | loaded | error)
- **Null safety**: Compile-time guarantees

---

## How v0.5 Supports App Functions Better

### 1. **Offline-First with Sync**

**v0.4 limitations:**
- Queue-based sync on main thread caused UI stutters
- No periodic background sync
- Single-user only

**v0.5 improvements:**
- Isolate-based sync runs completely off main thread
- Automatic periodic sync every 5 minutes
- userId filtering enables multi-user offline support
- Soft deletes (`isDeleted` flag) prevent sync conflicts

### 2. **Scalability**

**v0.4 limitations:**
- Monolithic services grew to 500+ lines
- Adding features required modifying existing services
- Layer-based structure made navigation difficult

**v0.5 improvements:**
- Feature-first structure keeps features isolated
- Repository pattern enables horizontal scaling (add new repos without touching existing ones)
- GetIt DI makes it easy to add new dependencies without rebuilding the entire widget tree

### 3. **Developer Experience**

**v0.4 pain points:**
- Hidden dependencies made code hard to follow
- Layer-based organization required jumping between directories
- Manual model serialization was error-prone
- Limited debugging tools

**v0.5 improvements:**
- Explicit DI with GetIt shows dependency graph clearly
- Feature-first organization keeps related code together
- Freezed eliminates serialization boilerplate
- Talker Flutter provides in-app log viewer
- BlocObserver enables state transition debugging

### 4. **Production Readiness**

**v0.4 blockers:**
- No multi-user support
- Sync on main thread not suitable for production
- Limited error handling and logging
- No performance monitoring

**v0.5 production-ready:**
- userId filtering supports multiple accounts
- Isolate-based sync won't block UI
- Repository-level logging tracks all operations
- Performance monitoring (operation duration tracking)
- Soft deletes enable conflict resolution
- Ready for API integration (sync stubs in place)

---

## Technology Stack Summary

| Aspect | v0.4 | v0.5 | Benefit |
|--------|------|------|---------|
| **State Management** | Provider + command_it | flutter_bloc (Cubit) | Less boilerplate, better DevTools |
| **Models** | Hand-written classes | Freezed (code-gen) | Immutability, type safety, no boilerplate |
| **Navigation** | Routemaster | GoRouter | Official Flutter solution, better typed routes |
| **DI** | Provider (implicit) | GetIt (explicit) | Clear dependencies, better testability |
| **Sync** | Queue on main thread | Isolate-based background | No UI jank, periodic sync |
| **Logging** | loggy | Talker Flutter | In-app log viewer, rich context |
| **Organization** | Layer-based | Feature-first | Faster navigation, better isolation |
| **Multi-User** | No | Yes (userId filtering) | Account switching, data isolation |
| **Soft Deletes** | No | Yes (isDeleted flag) | Sync-friendly deletions |

---

## Migration Path (v0.4 → v0.5)

The v0.5 rewrite is a **clean slate** - not a gradual migration. Key differences:

1. **State Management**: Command pattern → Cubits + Freezed states
2. **DI**: Provider context reads → GetIt service locator
3. **Navigation**: Routemaster → GoRouter with StatefulShellRoute
4. **Data Layer**: Monolithic services → Repository pattern with LocalSources
5. **Sync**: Queue-based → Isolate-based background sync

---

## What's Next?

v0.5 provides a solid foundation for future features:

- **API Integration**: Sync stubs are ready for backend integration
- **Real-time Sync**: Isolate architecture supports WebSocket streams
- **OAuth Authentication**: Anonymous tokens can be swapped for OAuth
- **Shared Budgets**: Multi-user architecture enables collaboration
- **Advanced Analytics**: Isolate-based processing for expensive calculations
- **Offline-First PWA**: Architecture supports web platform

---

## Conclusion

Centabit v0.5 represents a fundamental shift from a prototype to a production-ready architecture. By addressing v0.4's limitations—state management complexity, monolithic services, lack of multi-user support, and main thread sync—v0.5 provides a scalable, maintainable foundation that supports the app's evolving needs.

The feature-first organization, repository pattern, Cubit state management, isolate-based sync, and explicit dependency injection create a codebase that's easier to understand, test, and extend. With userId filtering, soft deletes, and sync-ready architecture, v0.5 is positioned to support multi-user collaboration, real-time sync, and advanced features that weren't possible in v0.4.

**v0.4 was a successful prototype. v0.5 is built for a longer haul (until v0.6) 😜**
