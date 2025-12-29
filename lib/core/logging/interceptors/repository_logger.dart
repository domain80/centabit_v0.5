import 'package:centabit/core/logging/app_logger.dart';

/// Mixin for repository logging with automatic operation tracking
///
/// Usage:
/// ```dart
/// class TransactionRepository with RepositoryLogger {
///   @override
///   String get repositoryName => 'TransactionRepository';
///
///   Future<void> sync() async {
///     return trackRepositoryOperation(
///       operation: 'sync',
///       execute: () async {
///         // Your sync logic here
///       },
///     );
///   }
/// }
/// ```
mixin RepositoryLogger {
  AppLogger get _logger => AppLogger.instance;

  /// Repository name for logging (override this in your repository)
  String get repositoryName;

  /// Track a repository operation with automatic timing and error handling
  ///
  /// Logs:
  /// - Operation start (debug level)
  /// - Operation completion with duration (debug level)
  /// - Errors with stack trace (error level)
  ///
  /// Example:
  /// ```dart
  /// Future<List<Transaction>> getAll() async {
  ///   return trackRepositoryOperation(
  ///     operation: 'getAll',
  ///     execute: () async {
  ///       return await _localSource.getAll();
  ///     },
  ///     metadata: {'count': transactions.length},
  ///   );
  /// }
  /// ```
  Future<T> trackRepositoryOperation<T>({
    required String operation,
    required Future<T> Function() execute,
    Map<String, dynamic>? metadata,
  }) async {
    final fullOperation = '$repositoryName.$operation';
    _logger.debug('[$fullOperation] Starting');

    final stopwatch = Stopwatch()..start();

    try {
      final result = await execute();
      stopwatch.stop();

      _logger.logWithContext(
        message: '[$fullOperation] Completed',
        context: {
          'duration_ms': stopwatch.elapsedMilliseconds,
          ...?metadata,
        },
      );

      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      _logger.error(
        '[$fullOperation] Failed after ${stopwatch.elapsedMilliseconds}ms',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Track a synchronous repository operation
  ///
  /// Similar to [trackRepositoryOperation] but for synchronous operations.
  T trackRepositoryOperationSync<T>({
    required String operation,
    required T Function() execute,
    Map<String, dynamic>? metadata,
  }) {
    final fullOperation = '$repositoryName.$operation';
    _logger.debug('[$fullOperation] Starting');

    final stopwatch = Stopwatch()..start();

    try {
      final result = execute();
      stopwatch.stop();

      _logger.logWithContext(
        message: '[$fullOperation] Completed',
        context: {
          'duration_ms': stopwatch.elapsedMilliseconds,
          ...?metadata,
        },
      );

      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      _logger.error(
        '[$fullOperation] Failed after ${stopwatch.elapsedMilliseconds}ms',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
