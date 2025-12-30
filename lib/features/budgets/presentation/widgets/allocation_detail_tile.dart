import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_details_vmodel.dart';
import 'package:flutter/material.dart';

class AllocationDetailTile extends StatelessWidget {
  final AllocationDetailVModel allocation;

  const AllocationDetailTile({
    super.key,
    required this.allocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    final percentage = allocation.spentPercentage;
    final progressColor = _getProgressColor(percentage, colorScheme);

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Icon(
                TablerIcons.all[allocation.category.iconName] ??
                    TablerIcons.circle,
                size: 24,
                color: colorScheme.primary,
              ),
              SizedBox(width: spacing.sm),
              Text(
                allocation.category.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),

          // Budgeted amount
          Text(
            'Budgeted: ${_formatCurrency(allocation.allocation.amount)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          // Spent amount with percentage
          Text(
            'Spent: ${_formatCurrency(allocation.spent)} (${percentage.toStringAsFixed(0)}%)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: progressColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Remaining amount
          Text(
            'Remaining: ${_formatCurrency(allocation.remaining)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          SizedBox(height: spacing.sm),

          // Progress bar
          LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(radius.sm),
          ),

          SizedBox(height: spacing.xs),

          // Transaction count
          Text(
            '${allocation.transactions.length} transaction${allocation.transactions.length != 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage, ColorScheme colorScheme) {
    if (percentage > 100) return colorScheme.error;
    if (percentage >= 90) return Colors.orange;
    return Colors.green;
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
