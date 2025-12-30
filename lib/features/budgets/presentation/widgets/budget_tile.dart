import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_list_state.dart';
import 'package:flutter/material.dart';

/// Budget tile widget for displaying budget in list.
///
/// Shows:
/// - Budget name (bold, primary color)
/// - Status badge (Active/Upcoming/Expired with days info)
/// - Allocated amount / Total amount
/// - Progress bar (allocation percentage)
/// - Trailing arrow icon
///
/// **Props**:
/// - `budget`: Budget view model with all display data
/// - `onTap`: Callback when tile is tapped (navigates to details)
///
/// **Usage**:
/// ```dart
/// BudgetTile(
///   budget: budgetViewModel,
///   onTap: () => context.go('/budgets/${budget.budget.id}'),
/// )
/// ```
class BudgetTile extends StatelessWidget {
  final BudgetListVModel budget;
  final VoidCallback? onTap;

  const BudgetTile({
    super.key,
    required this.budget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    // Calculate allocation percentage (clamped to 0-1)
    final allocationProgress = budget.budget.amount > 0
        ? (budget.totalAllocated / budget.budget.amount).clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius.md),
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(radius.md),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Budget name + Status badge
            Row(
              children: [
                // Budget name
                Expanded(
                  child: Text(
                    budget.budget.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: spacing.sm),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(colorScheme).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(radius.sm),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(colorScheme),
                    ),
                  ),
                ),
                SizedBox(width: spacing.xs),
                // Arrow icon
                Icon(
                  TablerIcons.chevronRight,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),

            // Amounts: Allocated / Total
            Text(
              '\$${budget.totalAllocated.toStringAsFixed(2)} / \$${budget.budget.amount.toStringAsFixed(2)}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
            SizedBox(height: spacing.xs),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(radius.sm),
              child: LinearProgressIndicator(
                value: allocationProgress,
                minHeight: 6,
                backgroundColor: colorScheme.onSurface.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(colorScheme),
                ),
              ),
            ),
            SizedBox(height: spacing.xs),

            // Footer: Days info
            Text(
              budget.statusText,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets status label text.
  String _getStatusLabel() {
    if (budget.isUpcoming) return 'Upcoming';
    if (budget.isActive) return 'Active';
    return 'Expired';
  }

  /// Gets status badge color.
  Color _getStatusColor(ColorScheme colorScheme) {
    if (budget.isUpcoming) return colorScheme.secondary;
    if (budget.isActive) return colorScheme.primary;
    return colorScheme.onSurface.withValues(alpha: 0.5);
  }

  /// Gets progress bar color.
  ///
  /// - Primary: If under 90% allocated
  /// - Warning: If 90-100% allocated
  /// - Error: If over-allocated (should be prevented by validation)
  Color _getProgressColor(ColorScheme colorScheme) {
    final percentage = budget.allocationPercentage;

    if (percentage > 100) return colorScheme.error; // Over-allocated
    if (percentage >= 90) {
      // Near full allocation - use warning color (could be secondary or custom)
      return colorScheme.secondary;
    }
    return colorScheme.primary; // Normal
  }
}
