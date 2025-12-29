import 'dart:async';
import 'dart:isolate';
import 'package:centabit/data/sync/sync_status.dart';

/// Manages background sync in isolates
///
/// Pattern: Main isolate (UI) ← SendPort/ReceivePort → Background isolate (sync work)
///
/// **Responsibilities**:
/// 1. Spawn background isolate for sync operations
/// 2. Manage periodic sync timer (every 5 minutes by default)
/// 3. Communicate sync status via broadcast stream
/// 4. Handle manual sync triggers
///
/// **Architecture**:
/// ```
/// Main Isolate (UI Thread)
///   ├── SyncManager (this class)
///   ├── Repositories (local DB reads/writes on main thread)
///   └── Spawns background isolate for:
///       ├── Periodic sync (every 5 minutes)
///       ├── API calls
///       └── Expensive operations
/// ```
///
/// **Usage**:
/// ```dart
/// final syncManager = SyncManager();
/// await syncManager.startPeriodicSync();
///
/// syncManager.statusStream.listen((status) {
///   status.when(
///     syncing: () => showSyncIndicator(),
///     synced: (time) => showSyncSuccess(time),
///     failed: (error) => showSyncError(error),
///     idle: () => hideSyncIndicator(),
///     offline: () => showOfflineIndicator(),
///   );
/// });
/// ```
class SyncManager {
  Timer? _periodicSyncTimer;
  Isolate? _syncIsolate;
  SendPort? _syncSendPort;
  ReceivePort? _syncReceivePort;

  final _statusController = StreamController<SyncStatus>.broadcast();

  /// Stream of sync status updates
  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncStatus _currentStatus = const SyncStatus.idle();

  /// Current sync status (synchronous access)
  SyncStatus get currentStatus => _currentStatus;

  /// Start periodic sync in background isolate
  ///
  /// **Parameters**:
  /// - `interval`: Time between sync attempts (default: 5 minutes)
  ///
  /// **Example**:
  /// ```dart
  /// await syncManager.startPeriodicSync(
  ///   interval: Duration(minutes: 10),
  /// );
  /// ```
  Future<void> startPeriodicSync({
    Duration interval = const Duration(minutes: 5),
  }) async {
    await _spawnSyncIsolate();

    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(interval, (_) {
      triggerSync();
    });
  }

  /// Spawn background isolate for sync operations
  Future<void> _spawnSyncIsolate() async {
    if (_syncIsolate != null) return; // Already spawned

    _syncReceivePort = ReceivePort();

    _syncIsolate = await Isolate.spawn(
      _syncIsolateEntryPoint,
      _syncReceivePort!.sendPort,
    );

    // Listen for messages from isolate
    _syncReceivePort!.listen((message) {
      if (message is SendPort) {
        // Initial handshake - save SendPort for communication
        _syncSendPort = message;
      } else if (message is SyncStatus) {
        // Sync status update from isolate
        _currentStatus = message;
        _statusController.add(message);
      }
    });

    // Wait for handshake
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Trigger manual sync
  ///
  /// Sends sync command to background isolate.
  ///
  /// **Example**:
  /// ```dart
  /// // User pulls to refresh
  /// syncManager.triggerSync();
  /// ```
  void triggerSync() {
    if (_syncSendPort == null) {
      print('Sync isolate not ready');
      return;
    }

    _syncSendPort!.send('SYNC');
  }

  /// Stop periodic sync and kill isolate
  ///
  /// Call this on app shutdown or when disabling background sync.
  ///
  /// **Example**:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   syncManager.stopPeriodicSync();
  ///   super.dispose();
  /// }
  /// ```
  void stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _syncIsolate?.kill();
    _syncReceivePort?.close();
    _syncIsolate = null;
    _syncSendPort = null;
  }

  /// Dispose resources
  void dispose() {
    stopPeriodicSync();
    _statusController.close();
  }

  /// Isolate entry point (runs in background)
  ///
  /// This function executes in a separate isolate, isolated from the main UI thread.
  static void _syncIsolateEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();

    // Send our SendPort to main isolate (handshake)
    mainSendPort.send(receivePort.sendPort);

    // Listen for sync requests from main isolate
    receivePort.listen((message) {
      if (message == 'SYNC') {
        _performSyncInIsolate(mainSendPort);
      }
    });
  }

  /// Perform actual sync work in isolate
  ///
  /// TODO: When API is ready:
  /// 1. Open drift database in isolate
  /// 2. Query unsynced records
  /// 3. Call API endpoints
  /// 4. Update sync status in database
  /// 5. Send status updates to main isolate
  static void _performSyncInIsolate(SendPort mainSendPort) {
    // Send syncing status
    mainSendPort.send(const SyncStatus.syncing());

    try {
      // TODO: When API is ready, perform actual sync here
      // For now, just simulate work

      // Simulate network delay
      Future.delayed(const Duration(seconds: 2), () {
        mainSendPort.send(
          SyncStatus.synced(lastSyncTime: DateTime.now()),
        );
      });
    } catch (e) {
      mainSendPort.send(
        SyncStatus.failed(error: e.toString()),
      );
    }
  }
}
