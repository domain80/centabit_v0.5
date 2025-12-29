import 'package:centabit/core/router/app_router.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/shared/widgets/sync_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

AppBar sharedAppBar(BuildContext context, {required Widget title}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final spacing = theme.extension<AppSpacing>()!;

  return AppBar(
    toolbarHeight: spacing.xl * 3,
    title: DefaultTextStyle(
      style: theme.textTheme.headlineSmall!.copyWith(
        color: colorScheme.onSurface,
      ),
      child: title,
    ),
    actions: [
      const SyncStatusIndicator(), // Sync status indicator (top-right)
      IconButton(
        icon: const Icon(TablerIcons.logout),
        onPressed: () {
          context.go(AppRouter.login);
        },
        tooltip: 'Logout',
      ),
    ],
  );
}
