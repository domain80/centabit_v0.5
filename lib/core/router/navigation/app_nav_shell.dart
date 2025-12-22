import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/router/navigation/shared_nav_bar.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Main navigation shell widget for authenticated pages
///
/// Provides semantic layout with:
/// - Content area that extends behind the nav bar
/// - Bottom navigation bar with tabs and action button
/// - Proper spacing and padding
///
/// Follows v0.4 semantic patterns for clean, composable architecture.
class AppNavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavCubit, NavState>(
      builder: (context, state) {
        return Scaffold(
          body: navigationShell,
          extendBody: true,
          bottomNavigationBar: _buildStyledNavBar(context, state),
        );
      },
    );
  }

  /// Build styled nav bar with glassmorphic effect
  Widget _buildStyledNavBar(BuildContext context, NavState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Container(
      color: colorScheme.surface.withValues(alpha: 0.1),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: spacing.md, bottom: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SharedNavBar(
                  navigationShell: navigationShell,
                  actionType: state.actionType,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
