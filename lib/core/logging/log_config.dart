import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:centabit/core/logging/log_filters.dart';
import 'package:centabit/core/logging/log_outputs.dart';

/// Environment-aware logging configuration
class LogConfig {
  final Level level;
  final LogFilter filter;
  final LogPrinter printer;
  final LogOutput output;

  const LogConfig({
    required this.level,
    required this.filter,
    required this.printer,
    required this.output,
  });

  /// Get current configuration based on build mode
  static LogConfig get current => kDebugMode ? development : production;

  /// Development configuration - verbose logging with pretty output
  static final development = LogConfig(
    level: Level.trace,
    filter: AppDevelopmentFilter(),
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to show
      errorMethodCount: 8, // Number of method calls for errors
      lineLength: 120, // Width of output
      colors: true, // Colorful output
      printEmojis: true, // Print emojis for log levels
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: ConsoleOutput(),
  );

  /// Production configuration - errors only with simple output
  static final production = LogConfig(
    level: Level.error,
    filter: AppProductionFilter(),
    printer: SimplePrinter(colors: false),
    output: MultiOutput([
      ConsoleOutput(),
      RemoteLogOutput(), // Send to remote service
    ]),
  );
}
