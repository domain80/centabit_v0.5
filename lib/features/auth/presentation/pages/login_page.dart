import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/tabler_icons.dart';

/// Login page for user authentication
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final spacing = theme.extension<AppSpacing>()!;

    return Scaffold(
      body: Container(
        // Gradient background matching the design
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [customColors.gradientStart, customColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(spacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  _buildAppIcon(context),

                  // Tagline
                  Text(
                    'Every cent counts.',
                    style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),

                  SizedBox(height: spacing.xl),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to dashboard
                        context.go(AppRouter.dashboard);
                      },
                      icon: const Icon(TablerIcons.login),
                      label: const Text('Continue with Google'),
                    ),
                  ),

                  SizedBox(height: spacing.md),

                  // Secondary tagline
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Center(
                // The centabit icon inside the card
                child: SvgPicture.asset(
                  Theme.of(context).brightness == Brightness.light
                      ? "assets/images/logo.light.svg"
                      : "assets/images/logo.dark.svg",
                  // colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface.withAlpha(160), BlendMode.srcIn),
                ),
              ),
            ),
          ),

          // App name
          Text('Centabit', style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
