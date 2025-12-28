import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  const CustomDatePicker({
    super.key,
    required this.currentDate,
    required this.onDateChanged,
    this.buttonTextStyle,
    this.formatter,
  });

  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChanged;
  final TextStyle? buttonTextStyle;
  final String Function(DateTime)? formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoCalendarPickerButton(
      minimumDateTime: DateTime.now().subtract(const Duration(days: 365 * 2)),
      maximumDateTime: DateTime.now().add(const Duration(days: 180)),
      initialDateTime: currentDate,
      onDateTimeChanged: onDateChanged,

      mode: CupertinoCalendarMode.date,
      mainColor: Theme.of(context).colorScheme.secondary,
      containerDecoration: PickerContainerDecoration(
        backgroundType: PickerBackgroundType.transparentAndBlured,
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(120),
      ),
      formatter:
          formatter ?? (dateTime) => DateFormat('MMMM yyyy').format(dateTime),
      monthPickerDecoration: CalendarMonthPickerDecoration(
        defaultDayStyle: CalendarMonthPickerDefaultDayStyle(
          textStyle: theme.textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        currentDayStyle: CalendarMonthPickerCurrentDayStyle(
          textStyle: theme.textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      buttonDecoration: PickerButtonDecoration.withDynamicColor(
        context,
        textStyle:
            buttonTextStyle ??
            theme.textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
        backgroundColor: CupertinoDynamicColor(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(00),
          darkColor: Theme.of(context).colorScheme.onSurface.withAlpha(00),
          highContrastColor: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha(00),
          darkElevatedColor: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha(00),
          darkHighContrastColor: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha(00),
          elevatedColor: Theme.of(context).colorScheme.onSurface.withAlpha(00),
          highContrastElevatedColor: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha(00),
          darkHighContrastElevatedColor: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha(00),
        ),
      ),
    );
  }
}
