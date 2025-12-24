import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:centabit/core/localizations/app_localizations_en.dart';

/// Abstract base class for app localizations.
///
/// Provides a type-safe way to access localized strings throughout the app.
/// Follow this pattern to maintain consistency with v0.4 and enable easy
/// addition of new languages.
///
/// **Usage in Widgets**:
/// ```dart
/// Text(AppLocalizations.of(context).bar)
/// Text(AppLocalizations.of(context).activeBudget('December 2025'))
/// ```
///
/// **Adding a New Language**:
/// 1. Create `app_localizations_es.dart` extending `AppLocalizations`
/// 2. Implement all getter methods with Spanish translations
/// 3. Add to `load()` method below
/// 4. Add `Locale('es', '')` to `supportedLocales` in main.dart
///
/// **Current Languages**:
/// - English (en) - Default
///
/// **Architecture Notes**:
/// - Uses Flutter's built-in localization system
/// - Each language is a separate class file
/// - Loaded dynamically based on device/app locale
/// - Accessed via `AppLocalizations.of(context)`
abstract class AppLocalizations {
  /// Returns the localized instance for the given context.
  ///
  /// This is the primary way to access translations in widgets.
  ///
  /// **Example**:
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   final l10n = AppLocalizations.of(context);
  ///   return Text(l10n.bar);
  /// }
  /// ```
  ///
  /// **Note**: Context must have MaterialApp with localizationsDelegates
  /// configured, or this will throw.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Creates localization delegate for MaterialApp.
  ///
  /// Add this to MaterialApp.localizationsDelegates:
  /// ```dart
  /// MaterialApp(
  ///   localizationsDelegates: [
  ///     AppLocalizations.delegate,
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate,
  ///   ],
  ///   supportedLocales: [
  ///     Locale('en', ''),
  ///   ],
  ///   ...
  /// )
  /// ```
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // ========================================
  // Dashboard Strings
  // ========================================

  /// "BAR" - Short form for Budget Available Ratio
  ///
  /// Used as label next to the BAR metric value.
  String get bar;

  /// "Budget Available Ratio (BAR)" - Full name
  ///
  /// Used as dialog title when explaining BAR.
  String get barFull;

  /// BAR definition text for info dialog
  ///
  /// Explains what BAR is and how it works.
  String get barDefinition;

  /// BAR usage explanation for info dialog
  ///
  /// Explains how to interpret the BAR value.
  String get barUsageExplanation;

  /// "Key Rule: Stay below 1.0" - BAR threshold guidance
  ///
  /// Shown in info dialog to explain the target BAR value.
  String get barKeyRule;

  /// Explanation of what higher/lower BAR values mean
  ///
  /// Shown in info dialog with examples.
  String get barHigherLowerExplanation;

  /// "Updates in real-time..." - BAR update frequency note
  ///
  /// Tells users when BAR recalculates.
  String get barUpdateFrequency;

  /// "Active Budget: {name}" - Budget title format
  ///
  /// Used to display the current budget name in the report section.
  ///
  /// **Example**:
  /// ```dart
  /// Text(l10n.activeBudget('December 2025'))
  /// // Output: "Active Budget: December 2025"
  /// ```
  String activeBudget(String name);

  /// "No data available" - Empty state message
  ///
  /// Shown when no budgets or data exist.
  String get noData;

  /// "Transactions" - Section header
  ///
  /// Header for the daily transactions section.
  String get transactionsForDate;

  /// "No transactions for this date" - Empty state for date filter
  ///
  /// Shown when selected date has no transactions.
  String get noTransactionsForDate;

  // ========================================
  // Common UI Strings
  // ========================================

  /// "OK" - Generic confirmation button
  String get ok;

  /// "Cancel" - Generic cancel button
  String get cancel;

  /// "GOT IT" - Dismissal button for info dialogs
  String get gotIt;

  /// "Delete" - Delete confirmation button
  String get delete;

  /// "Are you sure?" - Generic confirmation question
  String get areYouSure;

  // ========================================
  // Chart Strings
  // ========================================

  /// "Budget" - Legend label for budgeted amounts
  String get budget;

  /// "Actual" - Legend label for actual spending
  String get actual;

  /// "Spending" - Generic spending label
  String get spending;

  // ========================================
  // Date/Time Strings
  // ========================================

  /// "Today" - Relative date for current day
  String get today;

  /// "Yesterday" - Relative date for previous day
  String get yesterday;
}

/// Private delegate class for loading localizations.
///
/// Handles locale resolution and loading the appropriate language class.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  /// Checks if the given locale is supported.
  ///
  /// Currently only English is supported.
  /// Add new locales here as they're implemented.
  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  /// Loads the appropriate localization class for the locale.
  ///
  /// **Adding a new language**:
  /// ```dart
  /// switch (locale.languageCode) {
  ///   case 'en':
  ///     return SynchronousFuture<AppLocalizations>(AppLocalizationsEn());
  ///   case 'es':
  ///     return SynchronousFuture<AppLocalizations>(AppLocalizationsEs());
  ///   default:
  ///     return SynchronousFuture<AppLocalizations>(AppLocalizationsEn());
  /// }
  /// ```
  @override
  Future<AppLocalizations> load(Locale locale) {
    // For now, only English is supported
    return SynchronousFuture<AppLocalizations>(AppLocalizationsEn());
  }

  /// Whether localizations should be reloaded when locale changes.
  ///
  /// Return false for performance - localizations are stateless.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
