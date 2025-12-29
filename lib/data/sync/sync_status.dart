import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';

/// Represents the current sync status for background data synchronization.
///
/// Used by SyncManager to communicate sync state to UI components via streams.
///
/// **States**:
/// - `idle`: No sync operation in progress
/// - `syncing`: Actively syncing data with API
/// - `synced`: Successfully completed sync (includes timestamp)
/// - `failed`: Sync operation failed (includes error message)
/// - `offline`: Device is offline, sync not possible
///
/// **Usage**:
/// ```dart
/// syncManager.statusStream.listen((status) {
///   status.when(
///     idle: () => print('Ready to sync'),
///     syncing: () => print('Syncing...'),
///     synced: (time) => print('Last synced: $time'),
///     failed: (error) => print('Sync failed: $error'),
///     offline: () => print('Offline'),
///   );
/// });
/// ```
@freezed
class SyncStatus with _$SyncStatus {
  /// No sync operation in progress
  const factory SyncStatus.idle() = _Idle;

  /// Actively syncing data
  const factory SyncStatus.syncing() = _Syncing;

  /// Successfully synced (with timestamp)
  const factory SyncStatus.synced({required DateTime lastSyncTime}) = _Synced;

  /// Sync failed (with error message)
  const factory SyncStatus.failed({required String error}) = _Failed;

  /// Device is offline
  const factory SyncStatus.offline() = _Offline;
}
