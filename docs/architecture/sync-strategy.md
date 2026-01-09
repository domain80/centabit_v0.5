# Background Sync Strategy

## Overview

Centabit uses an **isolate-based background sync pattern** to synchronize local database changes with a remote API without blocking the UI thread. This document explains the current stub implementation and the planned API integration strategy.

**Current State**: Stub implementation (no API yet)
**Future State**: Full API sync with conflict resolution
**Performance**: Non-blocking background operations

---

## Why Isolates for Sync?

### 1. **Non-Blocking UI**
- API calls run in separate isolate
- UI thread remains responsive
- No frame drops or jank

### 2. **Periodic Background Execution**
- Sync happens automatically every 5 minutes
- No manual intervention required
- Works while app is in foreground

### 3. **Separation of Concerns**
- Sync logic isolated from UI logic
- Database operations can run in parallel
- Clear responsibility boundaries

### 4. **Resource Management**
- Isolates can be killed if sync takes too long
- Memory isolated from main thread
- Prevents memory leaks in sync code

---

## Isolate Communication Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      MAIN ISOLATE (UI Thread)                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SyncManager                                             │  │
│  │  - Spawns background isolate                             │  │
│  │  - Manages periodic timer (every 5 minutes)              │  │
│  │  - Broadcasts status updates                             │  │
│  │                                                          │  │
│  │  ReceivePort ←─────── Receives messages from isolate    │  │
│  │  SendPort    ─────────→ Sends commands to isolate       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  UI Components                                           │  │
│  │  - Listen to statusStream                                │  │
│  │  - Display sync indicators                               │  │
│  │  - Trigger manual sync on pull-to-refresh               │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                 Isolate.spawn() │
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  BACKGROUND ISOLATE (Sync Thread)                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  _syncIsolateEntryPoint                                  │  │
│  │  - Receives sync commands via ReceivePort                │  │
│  │  - Executes _performSyncInIsolate                        │  │
│  │  - Sends status updates via SendPort                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  _performSyncInIsolate                                   │  │
│  │  - Opens database connection                             │  │
│  │  - Queries unsynced records                              │  │
│  │  - Calls API endpoints                                   │  │
│  │  - Updates sync status                                   │  │
│  │  - Handles errors and retries                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                   SendPort   │
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              Status Messages (SyncStatus)                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  - SyncStatus.idle()                                     │  │
│  │  - SyncStatus.syncing()                                  │  │
│  │  - SyncStatus.synced(lastSyncTime: DateTime)            │  │
│  │  - SyncStatus.failed(error: String)                     │  │
│  │  - SyncStatus.offline()                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Sync Status State Machine

```
┌─────────┐
│  idle   │  ← Initial state, no sync in progress
└────┬────┘
     │
     │ triggerSync() or periodic timer
     ↓
┌─────────┐
│ syncing │  ← API calls in progress (background isolate)
└────┬────┘
     │
     ├─ Success ────────→ ┌─────────────────────────┐
     │                    │ synced(lastSyncTime)    │
     │                    └──────────┬──────────────┘
     │                               │
     │                               │ (stays for 5 min)
     │                               ↓
     │                            ┌─────────┐
     │                            │  idle   │
     │                            └─────────┘
     │
     ├─ Network Error ───→ ┌─────────────────────────┐
     │                     │ offline()               │
     │                     └──────────┬──────────────┘
     │                                │
     │                                │ (retry on next timer)
     │                                ↓
     │                             ┌─────────┐
     │                             │  idle   │
     │                             └─────────┘
     │
     └─ Other Error ─────→ ┌─────────────────────────┐
                           │ failed(error)           │
                           └──────────┬──────────────┘
                                      │
                                      │ (manual retry or timer)
                                      ↓
                                   ┌─────────┐
                                   │  idle   │
                                   └─────────┘
```

---

## Current Stub Implementation

### SyncManager Class

**File**: `lib/data/sync/sync_manager.dart`

```dart
class SyncManager {
  Timer? _periodicSyncTimer;
  Isolate? _syncIsolate;
  SendPort? _syncSendPort;
  ReceivePort? _syncReceivePort;

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncStatus _currentStatus = const SyncStatus.idle();
  SyncStatus get currentStatus => _currentStatus;

  /// Start periodic sync (every 5 minutes by default)
  Future<void> startPeriodicSync({
    Duration interval = const Duration(minutes: 5),
  }) async {
    await _spawnSyncIsolate();

    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(interval, (_) {
      triggerSync();
    });
  }

  /// Spawn background isolate
  Future<void> _spawnSyncIsolate() async {
    if (_syncIsolate != null) return;

    _syncReceivePort = ReceivePort();

    _syncIsolate = await Isolate.spawn(
      _syncIsolateEntryPoint,
      _syncReceivePort!.sendPort,
    );

    // Listen for messages from isolate
    _syncReceivePort!.listen((message) {
      if (message is SendPort) {
        _syncSendPort = message;  // Handshake complete
      } else if (message is SyncStatus) {
        _currentStatus = message;
        _statusController.add(message);  // Broadcast to UI
      }
    });

    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Trigger manual sync
  void triggerSync() {
    if (_syncSendPort == null) {
      print('Sync isolate not ready');
      return;
    }

    _syncSendPort!.send('SYNC');
  }

  /// Isolate entry point (runs in background)
  static void _syncIsolateEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);  // Handshake

    receivePort.listen((message) {
      if (message == 'SYNC') {
        _performSyncInIsolate(mainSendPort);
      }
    });
  }

  /// Perform sync work (STUB - no API yet)
  static void _performSyncInIsolate(SendPort mainSendPort) {
    mainSendPort.send(const SyncStatus.syncing());

    try {
      // TODO: Actual sync implementation
      Future.delayed(const Duration(seconds: 2), () {
        mainSendPort.send(
          SyncStatus.synced(lastSyncTime: DateTime.now()),
        );
      });
    } catch (e) {
      mainSendPort.send(SyncStatus.failed(error: e.toString()));
    }
  }
}
```

### SyncStatus State

**File**: `lib/data/sync/sync_status.dart`

```dart
@freezed
class SyncStatus with _$SyncStatus {
  const factory SyncStatus.idle() = _Idle;
  const factory SyncStatus.syncing() = _Syncing;
  const factory SyncStatus.synced({required DateTime lastSyncTime}) = _Synced;
  const factory SyncStatus.failed({required String error}) = _Failed;
  const factory SyncStatus.offline() = _Offline;
}
```

### UI Integration

**File**: `lib/shared/widgets/sync_status_indicator.dart`

```dart
class SyncStatusIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final syncManager = getIt<SyncManager>();

    return StreamBuilder<SyncStatus>(
      stream: syncManager.statusStream,
      initialData: syncManager.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? const SyncStatus.idle();

        return status.when(
          idle: () => const SizedBox.shrink(),
          syncing: () => const CircularProgressIndicator(),
          synced: (time) => IconButton(
            icon: const Icon(Icons.cloud_done),
            onPressed: () => _showSyncInfo(context, time),
          ),
          failed: (error) => IconButton(
            icon: const Icon(Icons.cloud_off, color: Colors.red),
            onPressed: () => _showErrorDialog(context, error),
          ),
          offline: () => const Icon(Icons.cloud_off),
        );
      },
    );
  }
}
```

---

## Future: Full API Sync Implementation

When the API is ready, the sync flow will work as follows:

### Sync Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     BACKGROUND SYNC ISOLATE                      │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
                   ┌────────────────┐
                   │ Receive "SYNC" │
                   └────────┬───────┘
                            ↓
                   Send: SyncStatus.syncing()
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: Open Database Connection                               │
│  - Open Drift database in isolate                               │
│  - Can run in parallel with main thread                         │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  STEP 2: Query Unsynced Records                                 │
│  - SELECT * FROM transactions WHERE isSynced = false            │
│  - SELECT * FROM categories WHERE isSynced = false              │
│  - SELECT * FROM budgets WHERE isSynced = false                 │
│  - SELECT * FROM allocations WHERE isSynced = false             │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
                   ┌────────────────┐
                   │ Any unsynced?  │
                   └────┬───────┬───┘
                        │       │
                   Yes  │       │ No
                        ↓       ↓
                        │    ┌──────────────────┐
                        │    │ Send: synced()   │
                        │    └──────────────────┘
                        │    Return
                        ↓
┌─────────────────────────────────────────────────────────────────┐
│  STEP 3: Batch Records by Operation Type                        │
│  - Creates: POST /api/transactions (bulk)                       │
│  - Updates: PATCH /api/transactions/:id (individual)            │
│  - Deletes: DELETE /api/transactions/:id (individual)           │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  STEP 4: Execute API Calls                                      │
│  - Use Dio HTTP client                                          │
│  - Include auth token in headers                                │
│  - Batch creates for efficiency                                 │
│  - Individual updates/deletes for conflict detection            │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
                   ┌────────────────┐
                   │   Success?     │
                   └────┬───────┬───┘
                        │       │
                   Yes  │       │ No (error)
                        ↓       ↓
                        │    ┌──────────────────────┐
                        │    │ Handle Error         │
                        │    │ - Network?           │
                        │    │   → Send: offline()  │
                        │    │ - Conflict?          │
                        │    │   → Resolve          │
                        │    │ - Other?             │
                        │    │   → Send: failed()   │
                        │    └──────────────────────┘
                        │    Return
                        ↓
┌─────────────────────────────────────────────────────────────────┐
│  STEP 5: Update Local Records                                   │
│  - UPDATE transactions SET isSynced = true, lastSyncedAt = NOW  │
│  - UPDATE categories SET isSynced = true, lastSyncedAt = NOW    │
│  - UPDATE budgets SET isSynced = true, lastSyncedAt = NOW       │
│  - UPDATE allocations SET isSynced = true, lastSyncedAt = NOW   │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  STEP 6: Pull Remote Changes                                    │
│  - GET /api/sync?since={lastSyncedAt}                           │
│  - Receive new/updated records from other devices               │
│  - Apply to local database with conflict resolution             │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
                   Send: SyncStatus.synced(lastSyncTime: now)
```

---

## Conflict Resolution Strategy

### Last-Write-Wins (Timestamp-Based)

When syncing, conflicts can occur if the same record was modified on multiple devices.

**Resolution Algorithm**:

```dart
Future<void> _resolveConflict({
  required Transaction localRecord,
  required TransactionDTO remoteRecord,
}) async {
  // Compare updatedAt timestamps
  if (remoteRecord.updatedAt.isAfter(localRecord.updatedAt)) {
    // Remote is newer - accept remote changes
    await _db.update(_db.transactions).replace(
      localRecord.copyWith(
        name: remoteRecord.name,
        amount: remoteRecord.amount,
        updatedAt: remoteRecord.updatedAt,
        isSynced: true,
        lastSyncedAt: DateTime.now(),
      ),
    );
  } else {
    // Local is newer - keep local changes
    // Re-mark as unsynced to push to API
    await _db.update(_db.transactions).replace(
      localRecord.copyWith(isSynced: false),
    );
  }
}
```

**Conflict Scenarios**:

| Scenario | Local State | Remote State | Resolution |
|----------|-------------|--------------|------------|
| Create-Create | New transaction | Same ID exists | Accept remote (UUID collision impossible) |
| Update-Update | Modified locally | Modified remotely | Last-write-wins based on `updatedAt` |
| Update-Delete | Modified locally | Deleted remotely | Accept delete (remote wins) |
| Delete-Update | Deleted locally | Modified remotely | Accept delete (local wins) |

---

## API Sync Implementation Plan

### Phase 1: Push Local Changes

**Endpoint**: `POST /api/sync/push`

**Request Body**:
```json
{
  "userId": "anon_abc123",
  "changes": {
    "transactions": {
      "created": [/* TransactionDTO[] */],
      "updated": [/* TransactionDTO[] */],
      "deleted": [/* { id, deletedAt } */]
    },
    "categories": { /* ... */ },
    "budgets": { /* ... */ },
    "allocations": { /* ... */ }
  }
}
```

**Response**:
```json
{
  "success": true,
  "conflicts": [
    {
      "entityType": "transaction",
      "entityId": "tx123",
      "remoteVersion": { /* latest from server */ },
      "message": "Record modified remotely"
    }
  ]
}
```

**Implementation** (`_performSyncInIsolate`):

```dart
static Future<void> _performSyncInIsolate(SendPort mainSendPort) async {
  mainSendPort.send(const SyncStatus.syncing());

  try {
    // 1. Open database in isolate
    final db = AppDatabase();

    // 2. Query unsynced records
    final unsyncedTransactions = await (db.select(db.transactions)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    final unsyncedCategories = await (db.select(db.categories)
          ..where((c) => c.isSynced.equals(false)))
        .get();

    // ... repeat for budgets, allocations

    if (unsyncedTransactions.isEmpty &&
        unsyncedCategories.isEmpty /* ... */) {
      // Nothing to sync - go to pull phase
      await _pullRemoteChanges(db, mainSendPort);
      return;
    }

    // 3. Build sync request
    final syncRequest = SyncPushRequest(
      userId: unsyncedTransactions.first.userId,  // All have same userId
      changes: SyncChanges(
        transactions: SyncEntityChanges(
          created: unsyncedTransactions
              .where((t) => t.createdAt == t.updatedAt)
              .map((t) => TransactionDTO.fromDrift(t))
              .toList(),
          updated: unsyncedTransactions
              .where((t) => t.createdAt != t.updatedAt && !t.isDeleted)
              .map((t) => TransactionDTO.fromDrift(t))
              .toList(),
          deleted: unsyncedTransactions
              .where((t) => t.isDeleted)
              .map((t) => DeletedEntity(id: t.id, deletedAt: t.updatedAt))
              .toList(),
        ),
        // ... repeat for categories, budgets, allocations
      ),
    );

    // 4. Make API call
    final dio = Dio();
    final response = await dio.post(
      'https://api.centabit.com/sync/push',
      data: syncRequest.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      ),
    );

    final syncResponse = SyncPushResponse.fromJson(response.data);

    // 5. Handle conflicts
    for (final conflict in syncResponse.conflicts) {
      await _resolveConflict(db, conflict);
    }

    // 6. Mark synced records
    for (final transaction in unsyncedTransactions) {
      await (db.update(db.transactions)
            ..where((t) => t.id.equals(transaction.id)))
          .write(TransactionsCompanion(
            isSynced: const Value(true),
            lastSyncedAt: Value(DateTime.now()),
          ));
    }
    // ... repeat for other entities

    // 7. Pull remote changes
    await _pullRemoteChanges(db, mainSendPort);

    mainSendPort.send(SyncStatus.synced(lastSyncTime: DateTime.now()));
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      mainSendPort.send(const SyncStatus.offline());
    } else {
      mainSendPort.send(SyncStatus.failed(error: e.message ?? 'Unknown error'));
    }
  } catch (e) {
    mainSendPort.send(SyncStatus.failed(error: e.toString()));
  }
}
```

### Phase 2: Pull Remote Changes

**Endpoint**: `GET /api/sync/pull?since={timestamp}`

**Query Parameters**:
- `since`: ISO8601 timestamp of last successful sync

**Response**:
```json
{
  "changes": {
    "transactions": [/* TransactionDTO[] */],
    "categories": [/* CategoryDTO[] */],
    "budgets": [/* BudgetDTO[] */],
    "allocations": [/* AllocationDTO[] */]
  },
  "deletions": {
    "transactions": ["id1", "id2"],
    "categories": ["id3"],
    "budgets": [],
    "allocations": ["id4"]
  }
}
```

**Implementation**:

```dart
static Future<void> _pullRemoteChanges(
  AppDatabase db,
  SendPort mainSendPort,
) async {
  // Get last sync time from database
  final lastSyncedAt = await _getLastSyncTime(db);

  final dio = Dio();
  final response = await dio.get(
    'https://api.centabit.com/sync/pull',
    queryParameters: {'since': lastSyncedAt?.toIso8601String()},
    options: Options(
      headers: {'Authorization': 'Bearer ${await _getAuthToken()}'},
    ),
  );

  final pullResponse = SyncPullResponse.fromJson(response.data);

  // Apply remote changes
  for (final remoteTransaction in pullResponse.changes.transactions) {
    final localTransaction = await (db.select(db.transactions)
          ..where((t) => t.id.equals(remoteTransaction.id)))
        .getSingleOrNull();

    if (localTransaction == null) {
      // New record from remote - insert
      await db.into(db.transactions).insert(
        Transaction.fromDTO(remoteTransaction),
      );
    } else if (localTransaction.isSynced) {
      // Local is synced - safe to update
      await db.update(db.transactions).replace(
        Transaction.fromDTO(remoteTransaction),
      );
    } else {
      // Conflict - resolve
      await _resolveConflict(
        localRecord: localTransaction,
        remoteRecord: remoteTransaction,
      );
    }
  }

  // Handle deletions
  for (final deletedId in pullResponse.deletions.transactions) {
    await (db.delete(db.transactions)
          ..where((t) => t.id.equals(deletedId)))
        .go();  // Hard delete (already soft deleted remotely)
  }

  // ... repeat for other entities
}
```

---

## Performance Optimizations

### 1. Batch Creates

Instead of individual POST requests for each new transaction:

```dart
// ❌ Bad: Individual API calls
for (final transaction in newTransactions) {
  await dio.post('/api/transactions', data: transaction.toJson());
}

// ✅ Good: Batch create
await dio.post('/api/transactions/batch', data: {
  'transactions': newTransactions.map((t) => t.toJson()).toList(),
});
```

### 2. Delta Sync

Only pull changes since last sync:

```dart
// ✅ Efficient: Only new changes
GET /api/sync/pull?since=2024-01-01T10:00:00Z

// ❌ Inefficient: Full sync every time
GET /api/transactions
```

### 3. Compression

Compress request/response bodies for large sync payloads:

```dart
final dio = Dio();
dio.interceptors.add(/* compression interceptor */);
```

### 4. Background Fetch (iOS/Android)

Integrate with platform background execution APIs:

```dart
// Future enhancement: Use WorkManager for periodic background sync
// This allows sync even when app is closed
```

---

## Error Handling & Retry Logic

### Retry Strategy

```dart
Future<void> _syncWithRetry({
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 5),
}) async {
  int retryCount = 0;
  Duration delay = initialDelay;

  while (retryCount < maxRetries) {
    try {
      await _performSync();
      return;  // Success!
    } on DioException catch (e) {
      retryCount++;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        // Network issue - retry with exponential backoff
        if (retryCount < maxRetries) {
          await Future.delayed(delay);
          delay *= 2;  // Exponential backoff
        } else {
          throw Exception('Max retries exceeded');
        }
      } else if (e.response?.statusCode == 401) {
        // Auth error - don't retry
        throw Exception('Authentication failed');
      } else if (e.response?.statusCode == 409) {
        // Conflict - resolve and retry
        await _resolveConflicts();
        // Retry immediately (no delay)
      } else {
        // Other error - rethrow
        rethrow;
      }
    }
  }
}
```

### Network Status Detection

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncManager {
  final Connectivity _connectivity = Connectivity();

  Future<void> startPeriodicSync() async {
    // Listen for network changes
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // Network available - trigger sync
        triggerSync();
      } else {
        // Offline - update status
        _statusController.add(const SyncStatus.offline());
      }
    });

    // ... rest of initialization
  }
}
```

---

## Testing Sync Logic

### Unit Test: Conflict Resolution

```dart
test('conflict resolution prefers newer timestamp', () async {
  final db = AppDatabase();

  // Local record (older)
  final localTransaction = Transaction(
    id: 'tx1',
    userId: 'user1',
    name: 'Coffee',
    amount: 4.50,
    updatedAt: DateTime(2024, 1, 1, 10, 0),
    // ...
  );

  // Remote record (newer)
  final remoteTransaction = TransactionDTO(
    id: 'tx1',
    userId: 'user1',
    name: 'Coffee Updated',
    amount: 5.00,
    updatedAt: DateTime(2024, 1, 1, 11, 0),
    // ...
  );

  await _resolveConflict(
    localRecord: localTransaction,
    remoteRecord: remoteTransaction,
  );

  final result = await db.select(db.transactions)
      .getSingle();

  expect(result.name, 'Coffee Updated');  // Remote wins
  expect(result.amount, 5.00);
  expect(result.isSynced, true);
});
```

### Integration Test: Full Sync Flow

```dart
testWidgets('sync pushes local changes and pulls remote', (tester) async {
  // Setup mock API server
  final mockServer = MockWebServer();
  await mockServer.start();

  // Create local unsynced transaction
  final repository = getIt<TransactionRepository>();
  await repository.createTransaction(/* ... */);

  // Trigger sync
  final syncManager = getIt<SyncManager>();
  syncManager.triggerSync();

  // Wait for sync to complete
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Verify API was called
  expect(mockServer.requests.length, 2);  // Push + Pull
  expect(mockServer.requests[0].uri.path, '/sync/push');
  expect(mockServer.requests[1].uri.path, '/sync/pull');

  // Verify local record marked as synced
  final transactions = await repository.transactions;
  expect(transactions.first.isSynced, true);
});
```

---

## Summary

The isolate-based sync strategy provides:

✅ **Non-Blocking**: Sync happens in background without UI jank
✅ **Automatic**: Periodic sync every 5 minutes (configurable)
✅ **Manual Triggers**: Pull-to-refresh support
✅ **Status Updates**: Real-time sync status via broadcast stream
✅ **Conflict Resolution**: Last-write-wins based on timestamps
✅ **Error Handling**: Retry logic with exponential backoff
✅ **Offline Support**: Detects network status and queues changes
✅ **Efficient**: Batch creates, delta sync, compression
✅ **Testable**: Clear separation enables unit and integration tests

**Current State**: Stub implementation ready for API integration
**Next Steps**: Implement API endpoints and replace stub sync logic
