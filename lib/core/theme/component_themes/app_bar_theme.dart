import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AppBar theme configuration for the Centabit app.
///
/// Provides clean, minimal AppBar styling with proper contrast.
class AppAppBarTheme {
  // Private constructor to prevent instantiation
  AppAppBarTheme._();

  /// Light mode app bar theme
  static AppBarTheme light(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      surfaceTintColor: colorScheme.surfaceTint,
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: 64,

      // Title text style - uses titleLarge from textTheme (25px)
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // System overlay style for status bar
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Dark mode app bar theme
  static AppBarTheme dark(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      surfaceTintColor: colorScheme.surfaceTint,
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: 64,

      // Title text style - uses titleLarge from textTheme (25px)
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // System overlay style for status bar
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}
