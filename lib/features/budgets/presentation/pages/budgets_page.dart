import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_list_cubit.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_list_state.dart';
import 'package:centabit/features/budgets/presentation/widgets/budget_tile.dart';
import 'package:centabit/shared/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Budgets page displaying a list of all budgets.
///
/// **Features**:
/// - Budget list with status badges and progress bars
/// - Create new budget button in AppBar
/// - Pull-to-refresh
/// - Navigate to budget details on tap
/// - Empty state message when no budgets exist
/// - Loading and error states
///
/// **Architecture**:
/// - Uses BudgetListCubit for state management
/// - Reactive updates via repository stream subscriptions
/// - Material 3 design with theme extensions
class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BudgetListCubit>(),
      child: const _BudgetsView(),
    );
  }
}

/// Internal view widget for budgets page.
///
/// Separated from BudgetsPage to allow BlocProvider scoping.
class _BudgetsView extends StatelessWidget {
  const _BudgetsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sharedAppBar(
        context,
        title: const Text('Budgets'),
      ),
      body: BlocBuilder<BudgetListCubit, BudgetListState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            success: (budgets) => _BudgetList(budgets: budgets),
            error: (message) => _ErrorView(message: message),
          );
        },
      ),
    );
  }
}

/// Budget list widget with pull-to-refresh.
///
/// Shows either:
/// - List of budget tiles (if budgets exist)
/// - Empty state message (if no budgets)
class _BudgetList extends StatelessWidget {
  final List<BudgetListVModel> budgets;

  const _BudgetList({required this.budgets});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    // Show empty state if no budgets
    if (budgets.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<BudgetListCubit>().refresh(),
        child: _EmptyState(),
      );
    }

    // Show budget list
    return RefreshIndicator(
      onRefresh: () => context.read<BudgetListCubit>().refresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(spacing.lg),
        itemCount: budgets.length,
        separatorBuilder: (_, __) => SizedBox(height: spacing.md),
        itemBuilder: (context, index) {
          final budgetViewModel = budgets[index];

          return BudgetTile(
            budget: budgetViewModel,
            onTap: () {
              // Navigate to budget details page
              context.go('/budgets/${budgetViewModel.budget.id}');
            },
          );
        },
      ),
    );
  }
}

/// Empty state shown when no budgets exist.
///
/// Displays:
/// - Icon
/// - "No budgets yet" message
/// - Hint to create first budget
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>()!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(), // Enables pull-to-refresh
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                TablerIcons.chartPie,
                size: 64,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              SizedBox(height: spacing.lg),
              Text(
                'No budgets yet',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
              SizedBox(height: spacing.sm),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.xl2),
                child: Text(
                  'Create your first budget to start tracking spending',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: spacing.xl),
              Text(
                'Tap the + button above to get started',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state shown when budget loading fails.
///
/// Displays:
/// - Error icon
/// - Error message
/// - Retry button
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              TablerIcons.alertCircle,
              size: 64,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
            SizedBox(height: spacing.lg),
            Text(
              'Error Loading Budgets',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
            ),
            SizedBox(height: spacing.sm),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.xl),
            FilledButton.icon(
              onPressed: () => context.read<BudgetListCubit>().refresh(),
              icon: const Icon(TablerIcons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
