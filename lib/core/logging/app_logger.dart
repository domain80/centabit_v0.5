import 'package:logger/logger.dart';
import 'package:centabit/core/logging/log_config.dart';

/// Singleton logger for the entire application
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
  late final Logger _logger;

  AppLogger._internal() {
    final config = LogConfig.current;
    _logger = Logger(
      filter: config.filter,
      printer: config.printer,
      output: config.output,
      level: config.level,
    );
  }

  static AppLogger get instance {
    _instance ??= AppLogger._internal();
    return _instance!;
  }

  /// Log verbose/trace level message
  void verbose(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log debug level message
  void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info level message
  void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning level message
  void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error level message
  void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal level message
  void fatal(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log with additional context metadata
  ///
  /// Example:
  /// ```dart
  /// logger.logWithContext(
  ///   message: 'User logged in',
  ///   level: Level.info,
  ///   context: {'userId': '123', 'method': 'google'},
  /// );
  /// ```
  void logWithContext({
    required String message,
    required Level level,
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final contextStr = context != null
        ? ' | ${context.entries.map((e) => '${e.key}=${e.value}').join(', ')}'
        : '';
    final fullMessage = '$message$contextStr';

    switch (level) {
      case Level.trace:
        verbose(fullMessage, error: error, stackTrace: stackTrace);
      case Level.debug:
        debug(fullMessage, error: error, stackTrace: stackTrace);
      case Level.info:
        info(fullMessage, error: error, stackTrace: stackTrace);
      case Level.warning:
        warning(fullMessage, error: error, stackTrace: stackTrace);
      case Level.error:
        this.error(fullMessage, error: error, stackTrace: stackTrace);
      case Level.fatal:
        fatal(fullMessage, error: error, stackTrace: stackTrace);
      default:
        info(fullMessage, error: error, stackTrace: stackTrace);
    }
  }
}
