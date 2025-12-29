import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Singleton logger for the entire application using Talker
///
/// Talker provides:
/// - Beautiful colored console output (works in DevTools)
/// - In-app log viewer screen
/// - HTTP logging support
/// - Error handling with stack traces
/// - Performance monitoring
///
/// Usage:
/// ```dart
/// final logger = AppLogger.instance;
/// logger.debug('Debug message');
/// logger.info('Info message');
/// logger.error('Error occurred', error: e, stackTrace: st);
/// ```
class AppLogger {
  static AppLogger? _instance;
  late final Talker _talker;

  AppLogger._internal() {
    _talker = TalkerFlutter.init(
      settings: TalkerSettings(
        // In development: log everything
        // In production: only errors and critical
        enabled: true,
        useConsoleLogs: kDebugMode,
        useHistory: true,
        maxHistoryItems: 1000,
      ),
      logger: TalkerLogger(
        settings: TalkerLoggerSettings(
          // Environment-aware log level
          level: kDebugMode ? LogLevel.verbose : LogLevel.error,
          // Clean output without ANSI colors
          enableColors: false,
        ),
      ),
    );
  }

  static AppLogger get instance {
    _instance ??= AppLogger._internal();
    return _instance!;
  }

  /// Get the underlying Talker instance
  /// Useful for TalkerScreen and advanced features
  Talker get talker => _talker;

  /// Log verbose/trace level message
  void verbose(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.verbose(message, error, stackTrace);
  }

  /// Log debug level message
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.debug(message, error, stackTrace);
  }

  /// Log info level message
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.info(message, error, stackTrace);
  }

  /// Log warning level message
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.warning(message, error, stackTrace);
  }

  /// Log error level message
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.error(message, error, stackTrace);
  }

  /// Log critical/fatal level message
  void critical(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.critical(message, error, stackTrace);
  }

  /// Log with additional context metadata
  ///
  /// Example:
  /// ```dart
  /// logger.logWithContext(
  ///   message: 'User logged in',
  ///   context: {'userId': '123', 'method': 'google'},
  /// );
  /// ```
  void logWithContext({
    required String message,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
    LogLevel level = LogLevel.info,
  }) {
    final contextStr = context != null
        ? ' | ${context.entries.map((e) => '${e.key}=${e.value}').join(', ')}'
        : '';
    final fullMessage = '$message$contextStr';

    // Use appropriate log method based on level
    switch (level) {
      case LogLevel.verbose:
        verbose(fullMessage, error: error, stackTrace: stackTrace);
      case LogLevel.debug:
        debug(fullMessage, error: error, stackTrace: stackTrace);
      case LogLevel.info:
        info(fullMessage, error: error, stackTrace: stackTrace);
      case LogLevel.warning:
        warning(fullMessage, error: error, stackTrace: stackTrace);
      case LogLevel.error:
        this.error(fullMessage, error: error, stackTrace: stackTrace);
      case LogLevel.critical:
        critical(fullMessage, error: error, stackTrace: stackTrace);
    }
  }
}
