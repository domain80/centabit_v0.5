import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/router/navigation/nav_scroll_behavior.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/core/utils/show_modal.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_details_cubit.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_details_state.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_details_vmodel.dart';
import 'package:centabit/features/budgets/presentation/cubits/chart_type.dart';
import 'package:centabit/features/budgets/presentation/widgets/allocation_detail_tile.dart';
import 'package:centabit/features/budgets/presentation/widgets/allocations_pie_chart.dart';
import 'package:centabit/features/budgets/presentation/widgets/budget_form_modal.dart';
import 'package:centabit/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:centabit/features/budgets/presentation/widgets/chart_type_toggle.dart';
import 'package:centabit/features/dashboard/presentation/widgets/budget_bar_chart.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Budget details page displaying comprehensive budget information.
///
/// **Features**:
/// - Budget metrics card (total, allocated, spent, remaining, BAR)
/// - Allocations breakdown with progress bars
/// - Recent transactions filtered by budgetId and date range
/// - Edit budget action (opens form modal)
/// - Delete budget action (with confirmation dialog)
/// - Pull-to-refresh
/// - Reactive updates via 4-stream subscription
///
/// **Architecture**:
/// - Uses BudgetDetailsCubit for state management
/// - Subscribes to Budget, Allocation, Transaction, Category streams
/// - Denormalizes data into BudgetDetailsVModel
class BudgetDetailsPage extends StatelessWidget {
  final String budgetId;

  const BudgetDetailsPage({super.key, required this.budgetId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BudgetDetailsCubit>(param1: budgetId),
      child: const _BudgetDetailsContent(),
    );
  }
}

/// Internal content widget for budget details page.
///
/// Separated from BudgetDetailsPage to allow BlocProvider scoping.
class _BudgetDetailsContent extends StatelessWidget {
  const _BudgetDetailsContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<BudgetDetailsCubit, BudgetDetailsState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: colorScheme.error,
              ),
            );

            // If budget not found, navigate back
            if (message.contains('not found')) {
              context.pop();
            }
          },
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (details) => _buildSuccessContent(context, details),
            error: (message) => _buildErrorContent(context, message),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    BudgetDetailsState state,
  ) {
    final budgetName = state.maybeWhen(
      success: (details) => details.budget.name,
      orElse: () => 'Budget Details',
    );

    return AppBar(
      title: Text(budgetName),
      actions: [
        state.maybeWhen(
          success: (details) => IconButton(
            icon: const Icon(TablerIcons.edit),
            onPressed: () => _showEditBudgetModal(context, details.budget),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        state.maybeWhen(
          success: (details) => IconButton(
            icon: const Icon(TablerIcons.trash),
            onPressed: () => _confirmDeleteBudget(context),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(
    BuildContext context,
    BudgetDetailsVModel details,
  ) {
    final cubit = context.read<BudgetDetailsCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: NavScrollWrapper(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BudgetSummaryCard(details: details),
                SizedBox(height: spacing.lg),

                // Chart section with toggle
                if (details.chartData.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader(context, 'Breakdown'),
                      const ChartTypeToggle(),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: cubit.selectedChartType == ChartType.bar ? 220 : 180,
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withAlpha(125),
                      borderRadius: BorderRadius.circular(radius.md),
                      border: Border.all(
                        color: colorScheme.outline.withAlpha(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.onSurface.withAlpha(10),
                          spreadRadius: 2,
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: BlocBuilder<BudgetDetailsCubit, BudgetDetailsState>(
                      buildWhen: (previous, current) => true,
                      builder: (context, state) {
                        final cubit = context.read<BudgetDetailsCubit>();

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: state.maybeWhen(
                            success: (details) {
                              switch (cubit.selectedChartType) {
                                case ChartType.bar:
                                  return BudgetBarChart(
                                    key: const ValueKey('bar_chart'),
                                    data: details.chartData,
                                  );
                                case ChartType.pie:
                                  return AllocationsPieChart(
                                    key: const ValueKey('pie_chart'),
                                    data: details.chartData,
                                  );
                              }
                            },
                            orElse: () => const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                ],

                if (details.allocations.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Allocations Breakdown'),
                  SizedBox(height: spacing.md),
                  ...details.allocations.map(
                    (allocation) => Padding(
                      padding: EdgeInsets.only(bottom: spacing.md),
                      child: AllocationDetailTile(allocation: allocation),
                    ),
                  ),
                ],

                if (details.transactions.isNotEmpty) ...[
                  SizedBox(height: spacing.lg),
                  _buildSectionHeader(
                    context,
                    'Recent Transactions (${details.transactions.length})',
                  ),
                  SizedBox(height: spacing.md),
                  ...details.transactions
                      .take(15)
                      .map(
                        (transaction) =>
                            TransactionTile(transaction: transaction),
                      ),
                ],

                if (details.allocations.isEmpty &&
                    details.transactions.isEmpty) ...[
                  _buildEmptyState(context),
                ],

                // Bottom spacing for content visibility
                SizedBox(height: spacing.xl3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildErrorContent(BuildContext context, String message) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              TablerIcons.alertCircle,
              size: 64,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: spacing.md),
            Text('Error', style: theme.textTheme.titleLarge),
            SizedBox(height: spacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.lg),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Budgets'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              TablerIcons.databaseOff,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: spacing.md),
            Text('No Data Yet', style: theme.textTheme.titleMedium),
            SizedBox(height: spacing.sm),
            Text(
              'Add allocations and transactions to see details.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetModal(BuildContext context, BudgetModel budget) {
    showModalBottomSheetUtil(
      context,
      builder: (_) => BudgetFormModal(initialBudget: budget),
      modalFractionalHeight: 0.85,
    );

    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   showDragHandle: true,
    //   builder: (_) => BudgetFormModal(initialBudget: budget),
    // );
  }

  void _confirmDeleteBudget(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text(
          'Are you sure? This will also delete all allocations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BudgetDetailsCubit>().deleteBudget();
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
