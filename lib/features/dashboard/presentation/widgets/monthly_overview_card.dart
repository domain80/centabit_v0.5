import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_state.dart';
import 'package:centabit/features/dashboard/presentation/widgets/monthly_overview_summary.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Collapsible monthly spending overview card for dashboard.
///
/// **Features**:
/// - Default minimized state (collapsed)
/// - Tap header to expand/collapse
/// - Shows month title with chevron icon
/// - Displays spending summary via [MonthlyOverviewSummary]
/// - Progress bar in expanded state
/// - "View Full Breakdown" button navigates to detail page
///
/// **Usage**:
/// ```dart
/// MonthlyOverviewCard(overview: state.monthlyOverview)
/// ```
///
/// **State Management**:
/// Uses internal StatefulWidget state for expand/collapse animation.
/// Data comes from parent via [MonthlyOverviewModel].
class MonthlyOverviewCard extends StatefulWidget {
  /// The monthly overview data to display.
  final MonthlyOverviewModel overview;

  const MonthlyOverviewCard({
    super.key,
    required this.overview,
  });

  @override
  State<MonthlyOverviewCard> createState() => _MonthlyOverviewCardState();
}

class _MonthlyOverviewCardState extends State<MonthlyOverviewCard> {
  /// Whether the card is expanded (showing full content).
  ///
  /// Default: `false` (minimized)
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            spreadRadius: 2,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(theme, spacing),

          // Expanded content: progress bar → breakdown boxes → button
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                children: [
                  // 1. Progress bar FIRST
                  _buildProgressBar(theme, spacing),
                  SizedBox(height: spacing.md),

                  // 2. Breakdown boxes (side-by-side)
                  MonthlyOverviewSummary(
                    overview: widget.overview,
                    showCounts: true, // Always show counts in expanded state
                  ),
                  SizedBox(height: spacing.md),

                  // 3. Detail button LAST
                  _buildDetailButton(theme),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds collapsible header with month title, total amount, and chevron.
  ///
  /// **Interaction**: Tap to toggle expand/collapse state.
  /// **Displays**: Month name on line 1, total amount on line 2 (both states)
  Widget _buildHeader(ThemeData theme, AppSpacing spacing) {
    final monthYear = DateFormat('MMMM yyyy').format(widget.overview.month);

    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              TablerIcons.calendarMonth,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthYear,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '\$${widget.overview.totalSpent.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _isExpanded
                  ? TablerIcons.chevronUp
                  : TablerIcons.chevronDown,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds simplified progress bar showing budgeted vs unassigned proportions.
  ///
  /// Clean bar with no labels, just green (budgeted) and orange (unassigned) sections.
  Widget _buildProgressBar(ThemeData theme, AppSpacing spacing) {
    final customColors = theme.extension<AppCustomColors>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8, // Thinner bar for cleaner look
        child: Row(
          children: [
            // Budgeted portion (green)
            if (widget.overview.budgetedSpent > 0)
              Expanded(
                flex: (widget.overview.budgetedPercentage * 100).toInt(),
                child: Container(
                  color: Colors.green.shade400,
                ),
              ),

            // Unassigned portion (orange)
            if (widget.overview.unassignedSpent > 0)
              Expanded(
                flex: (widget.overview.unassignedPercentage * 100).toInt(),
                child: Container(
                  color: customColors.warning,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds "View Full Breakdown" button.
  ///
  /// Navigates to monthly overview detail page using named route.
  Widget _buildDetailButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => context.pushNamed('monthly-overview-detail'),
        icon: const Icon(TablerIcons.arrowRight, size: 16),
        label: Text(
          'View Full Breakdown',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
      ),
    );
  }
}
