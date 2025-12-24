import 'package:centabit/core/localizations/app_localizations.dart';

/// English language implementation of app localizations.
///
/// This class provides all English translations for the app.
/// All strings are defined here in one place for easy management.
///
/// **Maintenance Notes**:
/// - Keep strings concise but clear
/// - Use proper punctuation and capitalization
/// - Avoid technical jargon when possible
/// - Test all strings in actual UI context
///
/// **String Organization**:
/// Strings are grouped by feature/screen to match the abstract class.
class AppLocalizationsEn extends AppLocalizations {
  // ========================================
  // Dashboard Strings
  // ========================================

  @override
  String get bar => 'BAR';

  @override
  String get barFull => 'Budget Available Ratio (BAR)';

  @override
  String get barDefinition =>
      'BAR is a metric that helps you track if you\'re on pace with your spending. '
      'It compares how much you\'ve spent versus how much time has passed in your budget period.';

  @override
  String get barUsageExplanation =>
      'The BAR value shows your spending rate relative to the budget timeline. '
      'A value of 1.0 means you\'re spending at exactly the expected pace.';

  @override
  String get barKeyRule => 'Key Rule: Stay below 1.0';

  @override
  String get barHigherLowerExplanation =>
      'Higher than 1.0 means you\'re spending faster than planned and may run out of budget early. '
      'Lower than 1.0 means you\'re under-spending and have budget left over.\n\n'
      'Example:\n'
      '• BAR of 0.8: You\'re spending slower than planned (good!)\n'
      '• BAR of 1.0: Perfect pace\n'
      '• BAR of 1.2: You\'re overspending (warning!)\n'
      '• BAR of 1.5+: Significantly over budget (critical!)';

  @override
  String get barUpdateFrequency =>
      'Updates in real-time as you add transactions or as time passes.';

  @override
  String activeBudget(String name) => 'Active Budget: $name';

  @override
  String get noData => 'No data available';

  @override
  String get transactionsForDate => 'Transactions';

  @override
  String get noTransactionsForDate => 'No transactions for this date';

  // ========================================
  // Common UI Strings
  // ========================================

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get gotIt => 'GOT IT';

  @override
  String get delete => 'Delete';

  @override
  String get areYouSure => 'Are you sure?';

  // ========================================
  // Chart Strings
  // ========================================

  @override
  String get budget => 'Budget';

  @override
  String get actual => 'Actual';

  @override
  String get spending => 'Spending';

  // ========================================
  // Date/Time Strings
  // ========================================

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
