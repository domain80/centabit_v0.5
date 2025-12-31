import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/core/utils/date_formatter.dart';
import 'package:centabit/core/utils/show_modal.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_state.dart';
import 'package:centabit/features/dashboard/presentation/widgets/monthly_overview_summary.dart';
import 'package:centabit/features/transactions/presentation/widgets/transaction_form_modal.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Monthly spending overview detail page.
///
/// **Purpose**:
/// Displays comprehensive breakdown of monthly spending with:
/// - Summary metrics (via MonthlyOverviewSummary)
/// - Budgeted transactions section
/// - Unassigned transactions section
/// - Pull-to-refresh support
///
/// **Navigation**:
/// - Route: `/monthly-overview` (sub-route under dashboard)
/// - Accessed from: MonthlyOverviewCard "View Full Breakdown" button
/// - Back navigation: Returns to dashboard
///
/// **Data Source**:
/// Reads from DashboardCubit (no separate cubit needed).
/// Filters transactions locally based on month from MonthlyOverviewModel.
///
/// **Layout**:
/// ```
/// ┌────────────────────────────────────┐
/// │ ← December 2024 Breakdown          │  <- App bar
/// ├────────────────────────────────────┤
/// │ Summary Card                       │  <- MonthlyOverviewSummary
/// │ Total: $1523.45                    │
/// │ Budgeted: $1245.30 (81.7%)         │
/// │ Unassigned: $278.15 (18.3%)        │
/// ├────────────────────────────────────┤
/// │ 💼 Budgeted Transactions (23)      │  <- Section header
/// │ ┌────────────────────────────────┐ │
/// │ │ 🛒 Groceries    -$45.23        │ │  <- TransactionTiles
/// │ │ 🍔 Dining       -$28.50        │ │
/// │ └────────────────────────────────┘ │
/// ├────────────────────────────────────┤
/// │ ⚠️  Unassigned Transactions (5)    │  <- Section header (warning)
/// │ ┌────────────────────────────────┐ │
/// │ │ 🛒 Random Item  -$55.00        │ │  <- TransactionTiles
/// │ └────────────────────────────────┘ │
/// └────────────────────────────────────┘
/// ```
///
/// **Usage**:
/// ```dart
/// // Navigate from card
/// context.push('/monthly-overview');
/// ```
class MonthlyOverviewDetailPage extends StatelessWidget {
  const MonthlyOverviewDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return state.when(
          initial: () => Scaffold(
            appBar: _buildAppBar(context, null),
            body: const SizedBox.shrink(),
          ),
          loading: () => Scaffold(
            appBar: _buildAppBar(context, null),
            body: const Center(child: CircularProgressIndicator()),
          ),
          success: (budgetPages, monthlyOverview) => Scaffold(
            appBar: _buildAppBar(context, monthlyOverview),
            body: _buildContent(context, monthlyOverview),
          ),
          error: (msg) => Scaffold(
            appBar: _buildAppBar(context, null),
            body: Center(
              child: Text(
                'Error: $msg',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds app bar with month title from current data.
  AppBar _buildAppBar(BuildContext context, MonthlyOverviewModel? overview) {
    final monthYear = overview != null
        ? DateFormat('MMMM yyyy').format(overview.month)
        : 'Monthly';

    return AppBar(
      title: Text('$monthYear Breakdown'),
      leading: IconButton(
        icon: const Icon(TablerIcons.arrowLeft),
        onPressed: () => context.pop(),
      ),
    );
  }

  /// Builds main content with summary and transaction sections.
  Widget _buildContent(
    BuildContext context,
    MonthlyOverviewModel overview,
  ) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final transactionRepo = getIt<TransactionRepository>();

    // Filter transactions for current month (debit only)
    final monthStart = DateTime(overview.month.year, overview.month.month, 1);
    final monthEnd =
        DateTime(overview.month.year, overview.month.month + 1, 0, 23, 59, 59);

    final monthTransactions = transactionRepo.transactions.where((t) {
      return !t.transactionDate.isBefore(monthStart) &&
          !t.transactionDate.isAfter(monthEnd) &&
          t.type == TransactionType.debit;
    }).toList();

    // Separate budgeted vs unassigned
    final budgetedTxns =
        monthTransactions.where((t) => t.budgetId != null).toList();
    final unassignedTxns =
        monthTransactions.where((t) => t.budgetId == null).toList();

    // Sort by date (newest first)
    budgetedTxns.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    unassignedTxns
        .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardCubit>().refresh();
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card (non-collapsible, always expanded)
              _buildSummaryCard(context, overview, spacing),
              SizedBox(height: spacing.xl2),

              // Budgeted transactions section
              _buildSection(
                context,
                title: 'Budgeted Transactions',
                count: budgetedTxns.length,
                transactions: budgetedTxns,
                icon: TablerIcons.wallet,
                isWarning: false,
                spacing: spacing,
              ),
              SizedBox(height: spacing.xl2),

              // Unassigned transactions section
              _buildSection(
                context,
                title: 'Unassigned Transactions',
                count: unassignedTxns.length,
                transactions: unassignedTxns,
                icon: TablerIcons.alertTriangle,
                isWarning: overview.hasUnassignedSpending,
                spacing: spacing,
              ),

              // Bottom padding
              SizedBox(height: spacing.xl3),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds summary card with metrics.
  Widget _buildSummaryCard(
    BuildContext context,
    MonthlyOverviewModel overview,
    AppSpacing spacing,
  ) {
    final theme = Theme.of(context);
    final radius = theme.extension<AppRadius>()!;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: MonthlyOverviewSummary(
        overview: overview,
        showCounts: true, // Always show counts in detail page
      ),
    );
  }

  /// Builds a transaction section (budgeted or unassigned).
  ///
  /// **Parameters**:
  /// - `title`: Section title (e.g., "Budgeted Transactions")
  /// - `count`: Number of transactions
  /// - `transactions`: List of transaction models
  /// - `icon`: Section icon
  /// - `isWarning`: Whether to show warning styling
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required int count,
    required List<TransactionModel> transactions,
    required IconData icon,
    required bool isWarning,
    required AppSpacing spacing,
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final headerColor =
        isWarning ? customColors.warning : theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(icon, color: headerColor, size: 24),
            SizedBox(width: spacing.sm),
            Text(
              '$title ($count)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: headerColor,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.md),

        // Transaction list or empty state
        if (transactions.isEmpty)
          _buildEmptyState(context, spacing)
        else
          ...transactions.map((txn) => _buildTransactionTile(context, txn)),
      ],
    );
  }

  /// Builds empty state message.
  Widget _buildEmptyState(BuildContext context, AppSpacing spacing) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.xl),
      child: Text(
        'No transactions in this category',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Builds a transaction tile with edit/delete/copy actions.
  ///
  /// Reuses [TransactionTile] widget from shared widgets.
  Widget _buildTransactionTile(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final transactionRepo = getIt<TransactionRepository>();

    return TransactionTile(
      transaction: _mapToVModel(transaction),
      onEdit: () {
        showModalBottomSheetUtil(
          context,
          builder: (_) => TransactionFormModal(
            initialValue: transaction,
          ),
          modalFractionalHeight: 0.78,
        );
      },
      onDelete: () {
        transactionRepo.deleteTransaction(transaction.id);
      },
      onCopy: () {
        final copy = TransactionModel.create(
          name: transaction.name,
          amount: transaction.amount,
          type: transaction.type,
          transactionDate: DateTime.now(),
          categoryId: transaction.categoryId,
          budgetId: transaction.budgetId,
          notes: transaction.notes,
        );

        showModalBottomSheetUtil(
          context,
          builder: (_) => TransactionFormModal(
            initialValue: copy,
            isCopy: true,
          ),
          modalFractionalHeight: 0.78,
        );
      },
    );
  }

  /// Maps TransactionModel to TransactionVModel for display.
  ///
  /// Denormalizes transaction by fetching category data from repository.
  TransactionVModel _mapToVModel(TransactionModel txn) {
    final categoryRepo = getIt<CategoryRepository>();

    // Find category if transaction has one
    final category = txn.categoryId != null
        ? categoryRepo.categories.firstWhere(
            (c) => c.id == txn.categoryId,
            orElse: () => throw Exception('Category not found'),
          )
        : null;

    return TransactionVModel(
      id: txn.id,
      name: txn.name,
      amount: txn.amount,
      type: txn.type,
      transactionDate: txn.transactionDate,
      formattedDate: DateFormatter.formatTransactionDateTime(txn.transactionDate),
      formattedTime: DateFormatter.formatTime(txn.transactionDate),
      categoryId: txn.categoryId,
      categoryName: category?.name,
      categoryIconName: category?.iconName,
      notes: txn.notes,
    );
  }
}
