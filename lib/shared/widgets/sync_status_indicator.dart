import 'package:flutter/material.dart';
import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/data/sync/sync_manager.dart';
import 'package:centabit/data/sync/sync_status.dart';

/// Sync status indicator widget for SharedAppBar
///
/// **Placement**: Top-right of AppBar, next to search/filter actions
///
/// **States**:
/// - `idle`: Hidden (no indicator)
/// - `syncing`: Circular progress indicator
/// - `synced`: Cloud checkmark icon (tappable to show last sync time)
/// - `failed`: Cloud-off icon in red (tappable to show error + retry)
/// - `offline`: Cloud-off icon (static)
///
/// **Usage**:
/// ```dart
/// AppBar(
///   title: Text('My Page'),
///   actions: [
///     const SyncStatusIndicator(),
///     // other actions...
///   ],
/// )
/// ```
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final syncManager = getIt<SyncManager>();

    return StreamBuilder<SyncStatus>(
      stream: syncManager.statusStream,
      initialData: syncManager.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? const SyncStatus.idle();

        return status.when(
          idle: () => const SizedBox.shrink(), // Hide when idle
          syncing: () => const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          synced: (lastSyncTime) => IconButton(
            icon: const Icon(TablerIcons.cloudCheck, size: 20),
            onPressed: () => _showSyncInfo(context, lastSyncTime),
            tooltip: 'Last synced: ${_formatSyncTime(lastSyncTime)}',
          ),
          failed: (error) => IconButton(
            icon: const Icon(TablerIcons.cloudOff, size: 20, color: Colors.red),
            onPressed: () => _showErrorDialog(context, error),
            tooltip: 'Sync failed',
          ),
          offline: () => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(TablerIcons.cloudOff, size: 20),
          ),
        );
      },
    );
  }

  /// Format sync time as relative string
  ///
  /// **Examples**:
  /// - "Just now" (< 60 seconds)
  /// - "5m ago" (< 60 minutes)
  /// - "2h ago" (< 24 hours)
  /// - "3d ago" (>= 24 hours)
  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Show sync info snackbar
  void _showSyncInfo(BuildContext context, DateTime lastSyncTime) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Last synced: ${_formatSyncTime(lastSyncTime)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error dialog with retry option
  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Failed'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              getIt<SyncManager>().triggerSync(); // Retry sync
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
