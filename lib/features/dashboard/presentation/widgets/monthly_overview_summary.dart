import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_state.dart';
import 'package:flutter/material.dart';

/// Monthly spending overview summary with side-by-side breakdown boxes.
///
/// Displays budgeted and unassigned spending as two equal-width colored boxes
/// positioned side-by-side in a Row layout.
///
/// **Design**:
/// - Budgeted box: Light green background
/// - Unassigned box: Light orange background
/// - Each box shows: icon, label, amount, percentage, and transaction count badge
///
/// **Usage**:
/// ```dart
/// MonthlyOverviewSummary(
///   overview: state.monthlyOverview,
///   showCounts: true,
/// )
/// ```
class MonthlyOverviewSummary extends StatelessWidget {
  /// The monthly overview data to display.
  final MonthlyOverviewModel overview;

  /// Whether to show transaction count badges.
  ///
  /// When `true`, displays transaction count badges in the bottom-right corner
  /// of each breakdown box.
  final bool showCounts;

  const MonthlyOverviewSummary({
    super.key,
    required this.overview,
    this.showCounts = false,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final customColors = Theme.of(context).extension<AppCustomColors>()!;

    return Row(
      children: [
        // Budgeted box (left)
        Expanded(
          child: _buildBreakdownBox(
            context,
            icon: TablerIcons.trendingUp,
            label: 'Budgeted',
            amount: overview.budgetedSpent,
            percentage: overview.budgetedPercentage,
            count: overview.budgetedCount,
            backgroundColor: Colors.green.withAlpha(40),
            textColor: Colors.green.shade700,
          ),
        ),

        SizedBox(width: spacing.sm),

        // Unassigned box (right)
        Expanded(
          child: _buildBreakdownBox(
            context,
            icon: TablerIcons.alertTriangle,
            label: 'Unassigned',
            amount: overview.unassignedSpent,
            percentage: overview.unassignedPercentage,
            count: overview.unassignedCount,
            backgroundColor: customColors.warning.withAlpha(40),
            textColor: customColors.warning.withAlpha(255),
          ),
        ),
      ],
    );
  }

  /// Builds a single breakdown box with colored background.
  ///
  /// **Layout**:
  /// ```
  /// ┌──────────────────────┐
  /// │ [Icon] Label         │  Top: icon + label
  /// │                      │
  /// │ $XXX.XX              │  Middle: large amount
  /// │ XX.X%                │  Below: percentage
  /// │                      │
  /// │              X txns  │  Bottom-right: badge
  /// └──────────────────────┘
  /// ```
  Widget _buildBreakdownBox(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required double percentage,
    required int count,
    required Color backgroundColor,
    required Color textColor,
  }) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and label at top
          Row(
            children: [
              Icon(icon, color: textColor, size: 18),
              SizedBox(width: spacing.xs),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: spacing.sm),

          // Amount (large, bold)
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor.withAlpha(255),
            ),
          ),

          SizedBox(height: 2),

          // Percentage (smaller, muted)
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor.withAlpha(180),
            ),
          ),

          SizedBox(height: spacing.sm),

          // Transaction count badge (bottom-right)
          if (showCounts)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: textColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count txn${count == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
