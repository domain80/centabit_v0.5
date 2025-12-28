import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';

/// Custom date picker with icon button trigger instead of text
class CustomDatePickerIcon extends StatelessWidget {
  const CustomDatePickerIcon({
    super.key,
    required this.currentDate,
    required this.onDateChanged,
    this.icon,
  });

  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
        foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
      ),
      icon: Icon(icon ?? TablerIcons.calendarCode),
      tooltip: 'Select date',
      onPressed: () async {
        // Get the RenderBox for positioning
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

        // Show the calendar picker
        await showCupertinoCalendarPicker(
          context,
          widgetRenderBox: renderBox,
          minimumDateTime: DateTime.now().subtract(const Duration(days: 365 * 2)),
          maximumDateTime: DateTime.now().add(const Duration(days: 180)),
          initialDateTime: currentDate,
          mode: CupertinoCalendarMode.date,
          mainColor: colorScheme.secondary,
          containerDecoration: PickerContainerDecoration(
            backgroundType: PickerBackgroundType.transparentAndBlured,
            backgroundColor: colorScheme.surface.withAlpha(120),
          ),
          monthPickerDecoration: CalendarMonthPickerDecoration(
            defaultDayStyle: CalendarMonthPickerDefaultDayStyle(
              textStyle: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            currentDayStyle: CalendarMonthPickerCurrentDayStyle(
              textStyle: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.secondary,
              ),
            ),
          ),
          onDateTimeChanged: onDateChanged,
        );
      },
    );
  }
}
