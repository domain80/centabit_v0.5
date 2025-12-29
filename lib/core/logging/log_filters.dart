import 'package:logger/logger.dart';

/// Development filter - allows all log levels
class AppDevelopmentFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true; // Log everything in development
  }
}

/// Production filter - only allows warnings, errors, and fatal logs
class AppProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= Level.error.index;
  }
}
