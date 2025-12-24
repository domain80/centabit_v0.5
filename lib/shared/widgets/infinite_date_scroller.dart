import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// A horizontally scrollable date picker with infinite scrolling behavior.
///
/// Displays dates as pill-shaped widgets that can be scrolled and selected.
/// Implements smart range rebuilding to maintain performance while giving
/// the appearance of infinite scrolling.
///
/// **Ported from v0.4**: `lib/ui/transactions/widgets/infinite_date_scroller.dart`
/// **Adaptations for v0.5**:
/// - Removed AppTextStyles and AppColors dependencies
/// - Uses Material 3 theme colors directly
/// - Uses v0.5 theme system
/// - Maintains all original functionality
///
/// **Architecture**:
/// - StatefulWidget with PageController (viewport fraction: 0.16)
/// - Smart range rebuilding: Initialize with 90 days, rebuild when scrolling near edges
/// - Haptic feedback on selection
/// - Prevents navbar hiding with NotificationListener
///
/// **Key Features**:
/// 1. **Infinite Scrolling Illusion**: Maintains finite date range but rebuilds
///    around selected date when user scrolls near edges (25% threshold)
/// 2. **Smart Range Management**: Initial range of 90 days on each side of center,
///    rebuilds when within 25% of edge
/// 3. **External Updates**: Responds to `currentDate` changes from parent
/// 4. **Smooth Animations**: Animates to new dates with easeInOut curve
/// 5. **Tap to Select**: Can tap any date pill to jump to that date
///
/// **Usage**:
/// ```dart
/// InfiniteDateScroller(
///   currentDate: DateTime.now(),
///   onDateChanged: (date) {
///     // Handle date selection
///     context.read<DateFilterCubit>().changeDate(date);
///   },
/// )
/// ```
///
/// **Performance Notes**:
/// - PageView with 180 items (90 days on each side) is performant
/// - Rebuilds only when scrolling near edges (25% threshold)
/// - Uses jumpToPage (no animation) when rebuilding range
/// - AnimateToPage only for user-initiated selections
class InfiniteDateScroller extends StatefulWidget {
  /// The currently selected date.
  ///
  /// When this changes from parent, the scroller will animate to the new date
  /// if it's within the current range, or rebuild the range around it.
  final DateTime currentDate;

  /// Callback when user selects a new date.
  ///
  /// Called immediately when:
  /// - User taps a date pill
  /// - User scrolls to a new date
  /// - Widget initializes (first frame)
  final ValueChanged<DateTime>? onDateChanged;

  /// Number of days to show on each side of center date.
  ///
  /// Default: 90 days (total range of 180 days)
  ///
  /// **Example**: With daysRange=90:
  /// - Center date: Dec 20, 2025
  /// - Range: Sep 21, 2025 to Mar 19, 2026 (180 days)
  final int daysRange;

  /// Maximum range to prevent memory issues.
  ///
  /// Default: 365 days (1 year range)
  ///
  /// Not currently enforced, but could be used to limit range in future.
  final int maxRange;

  /// Creates an infinite date scroller.
  ///
  /// **Parameters**:
  /// - `currentDate`: Initially selected date (required)
  /// - `onDateChanged`: Callback for date selection (optional)
  /// - `daysRange`: Days on each side of center (default: 90)
  /// - `maxRange`: Maximum range limit (default: 365)
  const InfiniteDateScroller({
    super.key,
    required this.currentDate,
    this.onDateChanged,
    this.daysRange = 90,
    this.maxRange = 365,
  });

  @override
  State<InfiniteDateScroller> createState() => _InfiniteDateScrollerState();
}

class _InfiniteDateScrollerState extends State<InfiniteDateScroller> {
  late PageController _controller;
  late DateTime _centerDate;
  late DateTime _selected;
  late List<DateTime> _dateRange;
  late int _selectedIndex;
  late bool _isAnimatingToDate;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentDate;
    _centerDate = _selected;
    _isAnimatingToDate = false;
    _buildDateRange();
    _updateSelectedIndex();

    _controller = PageController(
      initialPage: _selectedIndex,
      viewportFraction: 0.16, // Shows ~6 pills at once
    );

    // Notify parent of initial date after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateChanged?.call(_selected);
    });
  }

  /// Builds the date range array centered around `_centerDate`.
  ///
  /// Creates a list of dates: [centerDate - daysRange, ..., centerDate + daysRange]
  ///
  /// **Example** (daysRange=90, centerDate=Dec 20):
  /// - Start: Sep 21 (90 days before)
  /// - End: Mar 19 (90 days after)
  /// - Total: 181 items (90 + 1 + 90)
  void _buildDateRange() {
    _dateRange = [];
    final startDate = _centerDate.subtract(Duration(days: widget.daysRange));

    for (int i = 0; i <= widget.daysRange * 2; i++) {
      _dateRange.add(startDate.add(Duration(days: i)));
    }
  }

  /// Updates `_selectedIndex` to match `_selected` date in `_dateRange`.
  ///
  /// Finds the index where date matches by year/month/day.
  /// If not found, defaults to center of range.
  void _updateSelectedIndex() {
    _selectedIndex = _dateRange.indexWhere(
      (date) =>
          date.year == _selected.year &&
          date.month == _selected.month &&
          date.day == _selected.day,
    );

    // If selected date is not in range, default to center
    if (_selectedIndex == -1) {
      _selectedIndex = widget.daysRange;
    }
  }

  /// Rebuilds date range centered around a new date.
  ///
  /// Only rebuilds if `newCenter` is significantly different from current
  /// `_centerDate` (more than half of daysRange).
  ///
  /// **Process**:
  /// 1. Check if rebuild is needed (daysDiff > daysRange/2)
  /// 2. Update center date
  /// 3. Rebuild date range array
  /// 4. Update selected index
  /// 5. Jump PageController to new index (no animation)
  ///
  /// **Example**: daysRange=90, centerDate=Dec 20
  /// - User scrolls to Oct 1 (80 days away, > 45 threshold)
  /// - Rebuild with new center: Oct 1
  /// - New range: Jul 3 to Dec 29
  ///
  /// **Parameters**:
  /// - `newCenter`: New date to center range around
  void _rebuildRangeAroundDate(DateTime newCenter) {
    // Only rebuild if the new center is significantly different
    final daysDiff = newCenter.difference(_centerDate).inDays.abs();
    if (daysDiff > widget.daysRange ~/ 2) {
      setState(() {
        _centerDate = newCenter;
        _buildDateRange();
        _updateSelectedIndex();

        // Jump to new position without animation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.jumpToPage(_selectedIndex);
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant InfiniteDateScroller oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle external date changes (from parent)
    if (widget.currentDate != oldWidget.currentDate) {
      final newDate = widget.currentDate;

      // Check if new date is within current range (excluding edges)
      final isInRange = _dateRange.length > 10 &&
          _dateRange.sublist(5, _dateRange.length - 5).any(
                (date) =>
                    date.year == newDate.year &&
                    date.month == newDate.month &&
                    date.day == newDate.day,
              );

      if (isInRange) {
        // Date is in range, just animate to it
        setState(() {
          _selected = newDate;
          _updateSelectedIndex();
        });

        _controller.animateToPage(
          _selectedIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Date is out of range, rebuild around it
        setState(() {
          _selected = newDate;
        });
        _rebuildRangeAroundDate(newDate);
      }
    }
  }

  /// Handles page changes from user scrolling.
  ///
  /// **Process**:
  /// 1. Ignore if animating to a tapped date
  /// 2. Validate index is in range
  /// 3. Trigger haptic feedback
  /// 4. Update selected date and index
  /// 5. Notify parent via callback
  /// 6. Check if near edge and rebuild if needed (25% threshold)
  ///
  /// **Edge Detection**: Rebuilds when within 25% of either edge
  /// - Example (daysRange=90, total=180):
  ///   - Threshold: 45 (90/4)
  ///   - Rebuild if: index <= 45 OR index >= 135
  ///
  /// **Parameters**:
  /// - `index`: New page index from PageController
  void _onPageChanged(int index) {
    if (_isAnimatingToDate) return;
    if (index < 0 || index >= _dateRange.length) return;

    final selectedDate = _dateRange[index];
    HapticFeedback.selectionClick();

    setState(() {
      _selected = selectedDate;
      _selectedIndex = index;
    });

    widget.onDateChanged?.call(selectedDate);

    // Check if we need to rebuild range (when getting close to edges)
    final edgeThreshold =
        widget.daysRange ~/ 4; // Rebuild when within 25% of edge
    if (index <= edgeThreshold || index >= _dateRange.length - edgeThreshold) {
      _rebuildRangeAroundDate(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            // Reset animation flag when scroll ends
            _isAnimatingToDate = true;
          }

          // Prevent navbar from hiding when scrolling date picker
          // Return true to stop notification from bubbling up
          return true;
        },
        child: PageView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          onPageChanged: _onPageChanged,
          itemCount: _dateRange.length,
          itemBuilder: (context, index) {
            if (index < 0 || index >= _dateRange.length) {
              return const SizedBox.shrink();
            }

            final date = _dateRange[index];
            final isSelected = index == _selectedIndex;

            return GestureDetector(
              onTap: () {
                // Update selection immediately on tap
                final selectedDate = _dateRange[index];
                setState(() {
                  _isAnimatingToDate = true;
                  _selected = selectedDate;
                  _selectedIndex = index;
                });

                widget.onDateChanged?.call(selectedDate);
                HapticFeedback.selectionClick();

                // Animate to tapped date
                _controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              },
              child: Center(
                child: _DatePill(date: date, isSelected: isSelected),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Individual date pill widget showing day name and number.
///
/// **Visual Design**:
/// - Pill-shaped with rounded borders (radius: 30)
/// - Selected: primary color with shadow
/// - Unselected: surface color with subtle shadow
/// - Animated transitions (200ms)
///
/// **Ported from v0.4**: Internal `_DatePill` class
/// **Adaptations**:
/// - Uses Material 3 theme colors instead of AppColors
/// - Uses theme text styles instead of AppTextStyles
/// - Maintains all animation and visual behavior
///
/// **Layout**:
/// ```
/// ┌──────────┐
/// │   Mon    │  <- Day name (E format)
/// │    15    │  <- Day number (d format)
/// └──────────┘
/// ```
class _DatePill extends StatelessWidget {
  /// The date to display in this pill.
  final DateTime date;

  /// Whether this date is currently selected.
  ///
  /// Selected pills have different styling:
  /// - Primary color background
  /// - Stronger shadow
  /// - Different text colors
  final bool isSelected;

  const _DatePill({required this.date, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Format date strings
    final dayName = DateFormat('E').format(date); // Mon, Tue, etc.
    final dayNum = DateFormat('d').format(date); // 1, 2, 3, etc.

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      width: 40,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : colorScheme.surface,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(20),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected
              ? colorScheme.onSurface.withAlpha(80)
              : colorScheme.onSurface.withAlpha(40),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day name (Mon, Tue, etc.)
          Text(
            dayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withAlpha(180),
            ),
          ),
          // Day number (1, 2, 3, etc.)
          Text(
            dayNum,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}
