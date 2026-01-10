import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_details_vmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetDetailsVModel details;

  const BudgetSummaryCard({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    final barValue = details.barValue;
    final barColor = _getBarColor(barValue, colorScheme, customColors);

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)), // Increased from 0.2 to 0.4
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spacing.md),

          _buildMetricRow(context, 'Total Budget', details.budget.amount),
          _buildMetricRow(context, 'Allocated', details.totalAllocated),
          _buildMetricRow(context, 'Spent', details.totalSpent,
              color: barColor),
          _buildMetricRow(context, 'Remaining', details.remaining),

          if (details.unallocated > 0) ...[
            Divider(height: spacing.md * 2),
            _buildMetricRow(context, 'Unallocated', details.unallocated,
                color: colorScheme.secondary),
          ],

          Divider(height: spacing.md * 2),

          // BAR indicator
          Text(
            'Budget Health (BAR): ${barValue.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: spacing.sm),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: barColor.withValues(alpha: 0.3),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(radius.sm),
            ),
            child: LinearProgressIndicator(
              value: (details.spentPercentage / 100).clamp(0.0, 1.0),
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 12,
              borderRadius: BorderRadius.circular(radius.sm),
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            _getBarStatusText(barValue),
            style: theme.textTheme.bodySmall?.copyWith(
              color: barColor,
            ),
          ),

          // Date range
          SizedBox(height: spacing.md),
          Text(
            '${_formatDate(details.budget.startDate)} - ${_formatDate(details.budget.endDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7), // Increased from 0.6 to 0.7
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, double amount,
      {Color? color}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            _formatCurrency(amount),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(
    double barValue,
    ColorScheme colorScheme,
    AppCustomColors customColors,
  ) {
    if (barValue > 1.0) return colorScheme.error;
    if (barValue >= 0.9) return customColors.warningDark;
    return customColors.successDark;
  }

  String _getBarStatusText(double barValue) {
    if (barValue > 1.0) return 'Overspending - adjust spending pace';
    if (barValue >= 0.9) return 'Close to budget - monitor carefully';
    return 'On track - spending within budget';
  }

  String _formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
}
