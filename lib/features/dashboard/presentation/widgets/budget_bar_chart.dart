import 'dart:async';

import 'package:centabit/data/models/transactions_chart_data.dart';
import 'package:centabit/core/localizations/app_localizations.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bar chart displaying budget allocations vs actual transactions per category.
///
/// Shows side-by-side bars for each category:
/// - Left bar (onSurface color): Budget allocation
/// - Right bar (secondary color): Actual transactions
///
/// **Ported from v0.4**: `lib/ui/transactions/widgets/budget_chart.dart`
/// **Adaptations for v0.5**:
/// - Removed CurrencyViewModel dependency (hardcoded "$" for now)
/// - Uses AppLocalizations for legend strings
/// - Uses Material 3 theme colors
/// - Maintains all visual design and interactions
/// - Added horizontal scrolling for many categories (60px per category)
///
/// **Features**:
/// 1. **Touch Interaction**: Tap a bar to highlight it temporarily (1 second)
/// 2. **Tooltips**: Shows category name and amount on hover/tap
/// 3. **Legend**: Shows color coding for Budget vs Transactions
/// 4. **Icons**: Category icons as bottom axis labels
/// 5. **Auto-scaling**: Y-axis adjusts to data with 25% buffer
/// 6. **Animation**: Smooth 500ms animation when data changes
/// 7. **Horizontal Scroll**: Automatically scrollable when 7+ categories
///
/// **Usage**:
/// ```dart
/// BudgetBarChart(
///   data: [
///     TransactionsChartData(
///       categoryId: '1',
///       categoryName: 'Groceries',
///       categoryIconName: 'shopping_cart',
///       allocationAmount: 400.0,
///       transactionAmount: 325.50,
///     ),
///     // ... more categories
///   ],
/// )
/// ```
///
/// **Layout**:
/// ```
/// ┌────────────────────────────────┐
/// │  ● Budget  ● Transactions      │  <- Legend
/// ├────────────────────────────────┤
/// │   500 ─                        │
/// │        │                       │
/// │   250 ─│  ││  ││               │  <- Bars (allocation | transaction)
/// │        │  ││  ││               │
/// │     0 ─┴──┴┴──┴┴───            │
/// │         🛒   🍔                 │  <- Category icons
/// └────────────────────────────────┘
/// ```
class BudgetBarChart extends StatefulWidget {
  /// Chart data with allocations and transactions per category.
  ///
  /// Each [TransactionsChartData] contains:
  /// - Category metadata (id, name, icon)
  /// - Allocation amount (budgeted)
  /// - Transaction amount (actual spending)
  final List<TransactionsChartData> data;

  const BudgetBarChart({super.key, required this.data});

  @override
  State<BudgetBarChart> createState() => _BudgetBarChartState();
}

class _BudgetBarChartState extends State<BudgetBarChart> {
  /// Currently touched bar group index (category).
  ///
  /// Null when no bar is touched.
  int? touchedGroupIndex;

  /// Currently touched rod index within group (0=allocation, 1=transaction).
  ///
  /// Null when no bar is touched.
  int? touchedRodIndex;

  /// Tooltip text to display in fixed position
  String? tooltipText;

  /// Scroll controller to track horizontal scroll position
  final ScrollController _scrollController = ScrollController();

  /// Timestamp when tooltip was shown (for min display duration)
  DateTime? _tooltipShowTime;

  /// Timer for auto-hiding tooltip
  Timer? _tooltipTimer;

  @override
  void dispose() {
    _scrollController.dispose();
    _tooltipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Calculate width: 60px per category, with minimum of screen width
    // This makes the chart scrollable when there are many categories
    final barWidth = 60.0;
    final minWidth = MediaQuery.of(context).size.width - 140; // Account for padding and Y-axis
    final calculatedWidth = widget.data.length * barWidth;
    final chartWidth = calculatedWidth > minWidth ? calculatedWidth : minWidth;

    return Column(
      children: [
        // Legend at top
        _Legend(
          budgetLabel: l10n.budget,
          transactionsLabel: l10n.spending,
        ),
        // Chart with fixed Y-axis and scrollable content
        Expanded(
          child: Stack(
            children: [
              Row(
                children: [
                  // Fixed Y-axis labels
                  SizedBox(
                    width: 40,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 8),
                      child: _buildYAxisLabels(context),
                    ),
                  ),
                  // Scrollable chart content
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: SizedBox(
                        width: chartWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 8),
                          child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchCallback: _handleTouch,
                            // Disable built-in tooltips since we use fixed position tooltip
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
                            ),
                          ),
                          extraLinesData: ExtraLinesData(extraLinesOnTop: true),
                          titlesData: FlTitlesData(
                            // Left axis: Hide (we render it separately)
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            // Bottom axis: Category icons
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= widget.data.length) return Container();

                                  final iconName = widget.data[index].categoryIconName;
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Icon(
                                      TablerIcons.all[iconName],
                                      size: 16,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles:
                                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles:
                                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _buildGroups(context),
                          ),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutQuad,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              // Floating tooltip (centered in visible viewport)
              if (tooltipText != null)
                Positioned(
                  top: 8,
                  left: 40, // Y-axis width
                  right: 0,
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          tooltipText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds fixed Y-axis labels that don't scroll with the chart
  Widget _buildYAxisLabels(BuildContext context) {
    final maxY = _getMaxY();
    final interval = maxY / 3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Top label
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            maxY.toInt().toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        // Middle label
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            (maxY - interval).toInt().toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        // Second middle label
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            (maxY - interval * 2).toInt().toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        // Bottom label (0)
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 20), // Extra padding for bottom icons
          child: Text(
            '0',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Handles touch events on bars.
  ///
  /// When a bar is touched:
  /// 1. Highlights the bar with tertiary color border
  /// 2. Shows tooltip in fixed position above chart
  /// 3. Resets highlight and tooltip after 1 second
  ///
  /// **Parameters**:
  /// - `event`: Touch event (tap, drag, etc.)
  /// - `response`: Bar chart touch response with touched bar info
  void _handleTouch(FlTouchEvent event, BarTouchResponse? response) {
    if (!event.isInterestedForInteractions || response?.spot == null) {
      // Only hide if tooltip has been visible for at least 1 second
      final now = DateTime.now();
      if (_tooltipShowTime != null && tooltipText != null) {
        final elapsed = now.difference(_tooltipShowTime!);
        if (elapsed.inMilliseconds < 1000) {
          // Tooltip shown less than 1 second ago, delay hiding
          final remainingTime = 1000 - elapsed.inMilliseconds;
          _tooltipTimer?.cancel();
          _tooltipTimer = Timer(Duration(milliseconds: remainingTime), () {
            if (mounted) {
              setState(() {
                touchedGroupIndex = null;
                touchedRodIndex = null;
                tooltipText = null;
                _tooltipShowTime = null;
              });
            }
          });
          return;
        }
      }

      // Clear tooltip when not touching
      if (tooltipText != null) {
        setState(() {
          touchedGroupIndex = null;
          touchedRodIndex = null;
          tooltipText = null;
          _tooltipShowTime = null;
        });
      }
      _tooltipTimer?.cancel();
      return;
    }

    final groupIndex = response!.spot!.touchedBarGroupIndex;
    final rodIndex = response.spot!.touchedRodDataIndex;
    final categoryName = widget.data[groupIndex].categoryName;
    final amount = response.spot!.touchedRodData.toY;
    final label = rodIndex == 0 ? 'Budget' : 'Spending';

    setState(() {
      touchedGroupIndex = groupIndex;
      touchedRodIndex = rodIndex;
      // TODO: Replace hardcoded "$" with currency from settings
      tooltipText = '$categoryName ($label): \$${amount.toStringAsFixed(2)}';
      _tooltipShowTime = DateTime.now(); // Track when shown
    });

    // Reset highlight and tooltip after 2 seconds total (1 second min + 1 second grace)
    _tooltipTimer?.cancel();
    _tooltipTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          touchedGroupIndex = null;
          touchedRodIndex = null;
          tooltipText = null;
          _tooltipShowTime = null;
        });
      }
    });
  }

  /// Calculates maximum Y-axis value with buffer.
  ///
  /// **Algorithm**:
  /// 1. Find max value across all allocations and transactions
  /// 2. Add 25% buffer (minimum 20)
  /// 3. Return buffered max
  ///
  /// **Example**:
  /// - Max value: 400
  /// - Buffer: 400 * 0.25 = 100
  /// - Return: 500
  ///
  /// **Edge Case**:
  /// - If all values are 0, returns 20.0 (minimum buffer)
  ///
  /// **Returns**: Maximum Y value for chart scaling
  double _getMaxY() {
    final allValues = widget.data
        .expand((d) => [d.allocationAmount, d.transactionAmount])
        .toList();
    final maxVal = allValues.isEmpty
        ? 0
        : allValues.reduce((a, b) => a > b ? a : b);

    final double buffer = maxVal * 0.25;
    const double minBuffer = 20.0;

    return maxVal + (buffer > minBuffer ? buffer : minBuffer);
  }

  /// Builds bar chart groups (one per category).
  ///
  /// Each group contains 2 bars:
  /// - Rod 0: Allocation amount (onSurface color)
  /// - Rod 1: Transaction amount (secondary color)
  ///
  /// **Touch Highlighting**:
  /// - Touched bar gets tertiary color border (2px)
  /// - Light mode: tertiary color with 90% opacity
  /// - Dark mode: tertiary color with 90% opacity
  ///
  /// **Parameters**:
  /// - `context`: Build context for theme access
  ///
  /// **Returns**: List of bar chart groups
  List<BarChartGroupData> _buildGroups(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Highlight color for touched bars
    final highlightColor = colorScheme.tertiary.withValues(alpha: 0.9);

    return List.generate(widget.data.length, (i) {
      final d = widget.data[i];
      return BarChartGroupData(
        x: i,
        barsSpace: 2,
        barRods: [
          // Allocation bar (left)
          _buildRod(
            context,
            d.allocationAmount,
            colorScheme.onSurface,
            i,
            0,
            highlightColor,
          ),
          // Transaction bar (right)
          _buildRod(
            context,
            d.transactionAmount,
            colorScheme.secondary,
            i,
            1,
            highlightColor,
          ),
        ],
      );
    });
  }

  /// Builds a single bar (rod) for the chart.
  ///
  /// **Visual Design**:
  /// - Width: 12px
  /// - Border radius: 12px (rounded top)
  /// - Normal state: Solid color, no border
  /// - Touched state: Solid color + highlight border (2px)
  ///
  /// **Parameters**:
  /// - `context`: Build context
  /// - `toY`: Bar height (data value)
  /// - `color`: Bar color (onSurface or secondary)
  /// - `groupIndex`: Category index
  /// - `rodIndex`: Rod index within group (0=allocation, 1=transaction)
  /// - `highlightColor`: Border color when touched
  ///
  /// **Returns**: Configured bar chart rod data
  BarChartRodData _buildRod(
    BuildContext context,
    double toY,
    Color color,
    int groupIndex,
    int rodIndex,
    Color highlightColor,
  ) {
    final isTouched =
        (groupIndex == touchedGroupIndex && rodIndex == touchedRodIndex);

    return BarChartRodData(
      toY: toY,
      color: color,
      width: 12,
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isTouched ? highlightColor : Colors.transparent,
        width: 2,
      ),
      backDrawRodData: BackgroundBarChartRodData(show: false),
    );
  }
}

/// Legend widget showing color coding for chart bars.
///
/// Displays:
/// - Budget (onSurface color)
/// - Transactions (secondary color)
///
/// **Visual Design**:
/// - Right-aligned
/// - Circle indicators (12px)
/// - Bold text labels (12px)
/// - 16px spacing between items
///
/// **Ported from v0.4**: Internal `_Legend` class
class _Legend extends StatelessWidget {
  /// Label for budget bars.
  ///
  /// Localized string from AppLocalizations.
  final String budgetLabel;

  /// Label for transaction bars.
  ///
  /// Localized string from AppLocalizations.
  final String transactionsLabel;

  const _Legend({
    required this.budgetLabel,
    required this.transactionsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _LegendIndicator(
            color: colorScheme.onSurface,
            text: budgetLabel,
            isSquare: false,
          ),
          const SizedBox(width: 16),
          _LegendIndicator(
            color: colorScheme.secondary,
            text: transactionsLabel,
            isSquare: false,
          ),
        ],
      ),
    );
  }
}

/// Individual legend indicator with color dot and text label.
///
/// **Visual Design**:
/// - Color indicator: 12x12px
/// - Shape: Circle or square with rounded corners
/// - Label: Bold text, 12px font size
/// - Spacing: 4px between indicator and label
///
/// **Ported from v0.4**: Internal `_LegendIndicator` class
class _LegendIndicator extends StatelessWidget {
  /// Indicator color.
  final Color color;

  /// Text label.
  final String text;

  /// Whether to use square shape instead of circle.
  ///
  /// If true: Rounded square (3px radius)
  /// If false: Circle
  final bool isSquare;

  const _LegendIndicator({
    required this.color,
    required this.text,
    required this.isSquare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
            borderRadius: isSquare ? BorderRadius.circular(3) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
