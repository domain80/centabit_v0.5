import 'dart:async';

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
  Timer? _clearTimer;
  DateTime? _selectionShowTime;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _clearTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToItem(int index) {
    if (!_scrollController.hasClients) return;

    // Calculate item position: item height (12) + text height (~16) + spacing (8) = ~36px per item
    final double itemHeight = 36.0;
    final double targetOffset = index * itemHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleSelection(int index) {
    setState(() {
      touchedIndex = index;
      _selectionShowTime = DateTime.now();
    });

    // Scroll to item in legend
    _scrollToItem(index);

    // Auto-clear selection after 3 seconds total (1.5s min + 1.5s grace)
    _clearTimer?.cancel();
    _clearTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          touchedIndex = null;
          _selectionShowTime = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState(context);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left column: Pie chart
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sections: _buildSections(),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Clear selection if not touching
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse?.touchedSection == null) {
                    // Only hide if selection has been visible for at least 1.5 seconds
                    final now = DateTime.now();
                    if (_selectionShowTime != null && touchedIndex != null) {
                      final elapsed = now.difference(_selectionShowTime!);
                      if (elapsed.inMilliseconds < 1500) {
                        // Selection shown less than 1.5 seconds ago, delay hiding
                        final remainingTime = 1500 - elapsed.inMilliseconds;
                        _clearTimer?.cancel();
                        _clearTimer = Timer(Duration(milliseconds: remainingTime), () {
                          if (mounted) {
                            setState(() {
                              touchedIndex = null;
                              _selectionShowTime = null;
                            });
                          }
                        });
                        return;
                      }
                    }

                    setState(() {
                      touchedIndex = null;
                      _selectionShowTime = null;
                    });
                    _clearTimer?.cancel();
                    return;
                  }

                  // Get touched section
                  final section = pieTouchResponse!.touchedSection!;
                  final index = section.touchedSectionIndex;

                  _handleSelection(index);
                },
              ),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
        ),

        const SizedBox(width: 16),

        // Right column: Scrollable legend (fills full height)
        Expanded(
          child: _buildLegend(context),
        ),
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

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = widget.data[index];
        final isSelected = index == touchedIndex;
        return _buildLegendItem(
          colors[index],
          item,
          theme,
          isSelected,
          () => _handleSelection(index),
        );
      },
    );
  }

  Widget _buildLegendItem(
    Color color,
    TransactionsChartData item,
    ThemeData theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withAlpha(100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: colorScheme.primary.withAlpha(150),
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${item.categoryName}: \$${item.allocationAmount.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
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
