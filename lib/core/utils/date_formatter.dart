import 'package:intl/intl.dart';

/// Utility class for consistent date formatting across the app
///
/// Provides standardized date formatting methods used throughout the application
/// for displaying transaction dates, header labels, and time information.
class DateFormatter {
  DateFormatter._(); // Private constructor to prevent instantiation

  /// Format transaction date with smart relative strings.
  ///
  /// Returns:
  /// - "Today | 02:30 PM" for today's transactions
  /// - "Yesterday | 09:15 AM" for yesterday's transactions
  /// - "Dec 18, 25 | 11:45 AM" for other dates
  ///
  /// Example:
  /// ```dart
  /// final formatted = DateFormatter.formatTransactionDateTime(transaction.date);
  /// // Returns: "Today | 02:30 PM"
  /// ```
  static String formatTransactionDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    final timeStr = DateFormat('hh:mm a').format(date);

    if (transactionDate == today) {
      return "Today | $timeStr";
    } else if (transactionDate == yesterday) {
      return "Yesterday | $timeStr";
    } else {
      return "${DateFormat('MMM d, yy').format(date)} | $timeStr";
    }
  }

  /// Format date for sticky headers (no time component).
  ///
  /// Returns:
  /// - "Today" for today
  /// - "Yesterday" for yesterday
  /// - "December 24, 2024" for other dates
  ///
  /// Example:
  /// ```dart
  /// final headerText = DateFormatter.formatHeaderDate(date);
  /// // Returns: "Today"
  /// ```
  static String formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (normalizedDate == today) {
      return "Today";
    } else if (normalizedDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  /// Normalize date to start of day (strip time component).
  ///
  /// Converts a DateTime to midnight of the same day, removing hours,
  /// minutes, seconds, and milliseconds.
  ///
  /// Example:
  /// ```dart
  /// final normalized = DateFormatter.normalizeToDay(DateTime.now());
  /// // Returns: DateTime(2024, 12, 29, 0, 0, 0)
  /// ```
  static DateTime normalizeToDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Format time only (no date component).
  ///
  /// Returns: "02:30 PM", "09:15 AM"
  ///
  /// Example:
  /// ```dart
  /// final time = DateFormatter.formatTime(DateTime.now());
  /// // Returns: "02:30 PM"
  /// ```
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}
