import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/data/models/transactions_chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Interactive pie chart widget displaying budget allocations per category
///
/// **Features**:
/// - Pie segments sized by allocation amount
/// - Touch interaction to highlight segments (1 second duration)
/// - HSL color generation for distinct, evenly distributed colors
/// - Legend showing category breakdown with amounts
/// - Empty state when no allocations exist
/// - Smooth animations (300ms)
///
/// **Architecture**:
/// - Uses fl_chart package for rendering
/// - Material 3 theme integration
/// - StatefulWidget for touch state tracking
class AllocationsPieChart extends StatefulWidget {
  final List<TransactionsChartData> data;

  const AllocationsPieChart({super.key, required this.data});

  @override
  State<AllocationsPieChart> createState() => _AllocationsPieChartState();
}

class _AllocationsPieChartState extends State<AllocationsPieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Pie chart
        Expanded(
          child: PieChart(
            PieChartData(
              sections: _buildSections(),
              sectionsSpace: 2,
              centerSpaceRadius: 26,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (event is! FlTapUpEvent ||
                        pieTouchResponse?.touchedSection == null) {
                      touchedIndex = null;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse!.touchedSection!.touchedSectionIndex;
                  });

                  // Auto-clear highlight after 1 second
                  if (touchedIndex != null) {
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) setState(() => touchedIndex = null);
                    });
                  }
                },
              ),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        _buildLegend(context),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = _generateColors(widget.data.length, colorScheme);

    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 50.0 : 40.0;
      final fontSize = isTouched ? 12.0 : 10.0;

      return PieChartSectionData(
        color: colors[index],
        value: item.allocationAmount,
        title: isTouched ? '\$${item.allocationAmount.toStringAsFixed(0)}' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = _generateColors(widget.data.length, colorScheme);

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${item.categoryName}: \$${item.allocationAmount.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Generate distinct colors using HSL color space for even distribution
  ///
  /// - Hue varies evenly across segments (360° / count)
  /// - Saturation: 60% for vibrant but not overwhelming colors
  /// - Lightness: 50% for balanced brightness
  List<Color> _generateColors(int count, ColorScheme colorScheme) {
    return List.generate(count, (index) {
      final hue = (index * 360 / count) % 360;
      return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            TablerIcons.chartPieOff,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No allocations to display',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
