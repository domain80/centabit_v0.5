import 'dart:ui';

import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

/// Semantic action button for navigation bar
///
/// Composable action button widget that appears next to the navigation tabs.
/// Icon and tooltip change based on the current context (NavActionType).
class NavActionButton extends StatelessWidget {
  final NavActionType actionType;

  const NavActionButton({super.key, required this.actionType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<AppRadius>()!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.xl3),
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
        borderRadius: BorderRadius.circular(radius.xl2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 2.0),
          child: Material(
            color: colorScheme.primary.withValues(alpha: 0.95),
            child: InkWell(
              onTap: () => _handleAction(context, actionType),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  _getIconForAction(actionType),
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForAction(NavActionType actionType) {
    return switch (actionType) {
      NavActionType.addTransaction => TablerIcons.plus,
      NavActionType.addBudget => TablerIcons.hexagonPlus,
      _ => TablerIcons.plus,
    };
  }

  void _handleAction(BuildContext context, NavActionType actionType) {
    final message = switch (actionType) {
      NavActionType.addTransaction => 'Add transaction - coming soon',
      NavActionType.addBudget => 'Add budget - coming soon',
      _ => 'Action coming soon',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(milliseconds: 800)),
    );
  }
}
