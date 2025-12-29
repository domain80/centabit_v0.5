# Architecture Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                       Presentation Layer                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐                │
│  │   Pages    │  │  Widgets   │  │   Cubits   │                │
│  │  (UI)      │  │  (UI)      │  │ (BLoC)     │                │
│  └────────────┘  └────────────┘  └─────┬──────┘                │
│                                         │                        │
│                              Stream subscriptions               │
└─────────────────────────────────────────┼─────────────────────┘
                                          │
                                          ↓
┌─────────────────────────────────────────────────────────────────┐
│                       Repository Layer                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ TransactionRepository │ CategoryRepository │ etc...      │  │
│  │  - Broadcast streams                                     │  │
│  │  - Transform Drift ↔ Domain models                      │  │
│  │  - Sync stubs (ready for API)                           │  │
│  └──────────────────┬───────────────────┬───────────────────┘  │
└─────────────────────┼───────────────────┼──────────────────────┘
                      │                   │
                      ↓                   ↓
         ┌────────────────────┐  ┌─────────────────┐
         │   LocalSources     │  │  RemoteSources  │
         │   (Drift/SQLite)   │  │   (Future API)  │
         ├────────────────────┤  ├─────────────────┤
         │ • userId filtering │  │ • HTTP client   │
         │ • Reactive watch() │  │ • Auth headers  │
         │ • CRUD operations  │  │ • Error handling│
         └─────────┬──────────┘  └─────────────────┘
                   │
                   ↓
         ┌────────────────────┐
         │  Drift Database    │
         │  (centabit.sqlite) │
         ├────────────────────┤
         │ Tables:            │
         │ • transactions     │
         │ • categories       │
         │ • budgets          │
         │ • allocations      │
         │ • sync_queue       │
         │                    │
         │ All with userId    │
         │ + sync metadata    │
         └────────────────────┘
                   ║
                   ║ (Sync in isolate)
                   ↓
         ┌────────────────────┐
         │   SyncManager      │
         │   (Background)     │
         ├────────────────────┤
         │ • Isolate-based    │
         │ • Periodic timer   │
         │ • Status streaming │
         └────────────────────┘
```

## Layer Responsibilities

### 1. Presentation Layer

**Location**: `lib/features/[feature]/presentation/`

**Components**:
- **Pages**: Full-screen UI components that represent app routes
- **Widgets**: Reusable UI components specific to a feature
- **Cubits**: State management using BLoC pattern

**Responsibilities**:
- Display data to users
- Capture user input
- Subscribe to state changes from Cubits
- Trigger actions via Cubit methods
- NO business logic (kept in Cubits)
- NO direct data access (goes through Cubits → Repositories)

**Example**:
```dart
// TransactionsPage subscribes to TransactionListCubit
BlocBuilder<TransactionListCubit, TransactionListState>(
  builder: (context, state) => state.when(
    success: (transactions) => ListView(/* display */),
    loading: () => CircularProgressIndicator(),
    error: (msg) => ErrorWidget(msg),
  ),
)
```

### 2. Repository Layer

**Location**: `lib/data/repositories/`

**Components**:
- `TransactionRepository`
- `CategoryRepository`
- `BudgetRepository`
- `AllocationRepository`

**Responsibilities**:
- Coordinate LocalSources (and future RemoteSources)
- Transform Drift entities ↔ Domain models
- Emit broadcast streams for reactive updates
- Cache latest data for synchronous access
- Manage sync operations (stubs for now)
- Provide clean API to Cubits

**Key Pattern**:
```dart
class TransactionRepository {
  final TransactionLocalSource _localSource;
  final _controller = StreamController<List<TransactionModel>>.broadcast();

  // Subscribe to Drift's reactive queries
  TransactionRepository(this._localSource) {
    _localSource.watchAllTransactions().listen((driftData) {
      final models = driftData.map(_mapToModel).toList();
      _latestTransactions = models;  // Cache
      _controller.add(models);        // Emit
    });
  }

  // Public API for Cubits
  Stream<List<TransactionModel>> get transactionsStream => _controller.stream;
  List<TransactionModel> get transactions => _latestTransactions;
}
```

### 3. LocalSource Layer

**Location**: `lib/data/local/`

**Components**:
- `database.dart` - Drift schema definition
- `*_local_source.dart` - Data access objects (DAOs)

**Responsibilities**:
- Execute type-safe SQL queries via Drift
- Filter ALL queries by userId (security + multi-user)
- Provide reactive streams via Drift's `watch()` API
- Handle CRUD operations
- Inject userId automatically on create
- Validate userId on update/delete

**Key Pattern** (userId filtering):
```dart
class TransactionLocalSource {
  final AppDatabase _db;
  final String userId;  // Injected at construction

  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) &      // ALWAYS filter by userId
              t.isDeleted.equals(false)))
        .watch();
  }
}
```

### 4. Drift Database

**Location**: `lib/data/local/database.dart`

**Tables**:
- `Transactions` - Financial transactions
- `Categories` - Spending categories
- `Budgets` - Budget periods
- `Allocations` - Budget-to-category allocations
- `SyncQueue` - Offline changes pending sync

**Common Columns** (all tables):
- `id` - Primary key (UUID)
- `userId` - Owner identifier (for filtering)
- `createdAt` - Creation timestamp
- `updatedAt` - Last modification timestamp
- `isSynced` - Sync status flag
- `isDeleted` - Soft delete flag
- `lastSyncedAt` - Last sync timestamp

**Key Features**:
- Type-safe queries (compile-time validation)
- Reactive streams via `watch()`
- Automatic code generation
- Foreign key support
- Composite unique constraints

### 5. SyncManager (Background)

**Location**: `lib/data/sync/`

**Components**:
- `SyncManager` - Orchestrates background sync
- `SyncStatus` - Sync state (Freezed union type)

**Responsibilities**:
- Run periodic sync in background isolate
- Communicate sync status to UI
- Trigger manual sync on demand
- Handle sync failures with retry logic
- Keep UI thread responsive (non-blocking)

**States**:
- `idle` - No sync in progress
- `syncing` - Currently syncing
- `synced(DateTime)` - Last successful sync
- `failed(String)` - Sync error with message
- `offline` - No network connection

## Component Interaction Flow

```
User Action (tap button)
        ↓
Page calls cubit.method()
        ↓
Cubit calls repository.method()
        ↓
Repository calls localSource.method()
        ↓
LocalSource executes Drift query (with userId filter)
        ↓
Drift emits change via watch() stream
        ↓
LocalSource forwards stream update
        ↓
Repository transforms Drift → Domain model
        ↓
Repository emits to broadcast stream
        ↓
Cubit's subscription receives update
        ↓
Cubit reloads data and emits new state
        ↓
Page rebuilds with new state
        ↓
User sees updated UI
```

## Key Architectural Principles

### 1. Offline-First
- Local database is the **single source of truth**
- All writes go to local DB first (optimistic updates)
- Background sync happens asynchronously
- App works fully offline

### 2. Reactive Streams
- Data changes automatically propagate through layers
- Drift's `watch()` emits when database changes
- Repositories forward as broadcast streams
- Cubits subscribe and reload automatically
- UI rebuilds via BLoC pattern

### 3. Type Safety
- Drift provides compile-time query validation
- Freezed ensures immutable models
- Strong typing throughout the stack

### 4. Separation of Concerns
- Each layer has a single responsibility
- Clear boundaries between layers
- Dependencies flow inward (Presentation → Data → Database)

### 5. Multi-User Ready
- All queries filter by userId
- Prepared for OAuth integration
- Anonymous users get unique UUID tokens
- Data isolation between users

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| UI | Flutter + Material 3 | Cross-platform UI framework |
| State Management | flutter_bloc (Cubit) | Reactive state management |
| Routing | go_router | Declarative navigation |
| Dependency Injection | get_it | Service locator pattern |
| Local Database | Drift | Type-safe SQLite ORM |
| Models | Freezed | Immutable data classes |
| Serialization | json_serializable | JSON ↔ Dart conversion |
| Background Sync | Dart Isolates | Non-blocking operations |
| Future API | Dio | HTTP client (not yet used) |

## Next Steps for API Integration

When the backend API is ready:

1. **Create RemoteSource classes** (`lib/data/remote/`)
   - API client with Dio
   - DTOs for API responses
   - Auth token interceptors

2. **Update Repositories**
   - Implement sync logic in isolates
   - Handle conflict resolution
   - Merge local + remote data

3. **Activate SyncManager**
   - Remove stub implementations
   - Implement actual API calls
   - Handle network errors

4. **Add OAuth**
   - Implement `AuthManager.signInWithGoogle()`
   - Migrate anonymous data to authenticated user
   - Update userId filtering

See [sync-strategy.md](./sync-strategy.md) for detailed sync implementation plans.
