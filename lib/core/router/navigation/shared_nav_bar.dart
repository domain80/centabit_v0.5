import 'dart:ui';

import 'package:centabit/core/router/navigation/nav_action_button.dart';
import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

/// Semantic navigation bar with tabs and action button
///
/// Combines navigation tabs and contextual action button in a row,
/// following the v0.4 semantic pattern where nav and action are siblings.
/// Includes glassmorphic styling with backdrop blur.
class SharedNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final NavActionType actionType;

  const SharedNavBar({
    super.key,
    required this.navigationShell,
    required this.actionType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    return Row(
      spacing: spacing.sm,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Navigation tabs container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.xl),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius.xl4),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 2.0),
              child: Container(
                color: colorScheme.surface.withValues(alpha: 0.95),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xs,
                  vertical: spacing.xs,
                ),
                child: GNav(
                  selectedIndex: navigationShell.currentIndex,
                  onTabChange: (index) => _onTabChange(context, index),
                  tabBorderRadius: radius.xl2,
                  duration: const Duration(milliseconds: 200),
                  iconSize: 20,
                  gap: 2,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  activeColor: colorScheme.onSecondaryContainer,
                  tabBackgroundColor: colorScheme.secondaryContainer,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  tabs: [
                    GButton(icon: TablerIcons.home),
                    GButton(icon: TablerIcons.arrowsUpDown),
                    GButton(icon: TablerIcons.chartPie),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Contextual action button next to nav
        NavActionButton(actionType: actionType),
      ],
    );
  }

  void _onTabChange(BuildContext context, int index) {
    context.read<NavCubit>().updateTab(index);
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
