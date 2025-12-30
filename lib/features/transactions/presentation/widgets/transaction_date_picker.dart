import 'package:centabit/core/utils/date_formatter.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Date picker field for transaction form
///
/// Uses Cupertino-style calendar picker from cupertino_calendar_picker package.
/// Displays "Today", "Yesterday", or formatted date (e.g., "December 24, 2024").
/// Wrapped in FormBuilderField for form state management.
///
/// Date range: ±10 years from today
/// Default date: Current date (DateTime.now())
class TransactionDatePicker extends StatelessWidget {
  const TransactionDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      spacing: 40, // v4 exact
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'Transaction date',
            style: const TextStyle(
              fontSize: 18, // v4's large
              fontWeight: FontWeight.w400, // Regular, not semibold
            ),
          ),
        ),
        FormBuilderField<DateTime>(
          name: 'date',
          builder: (field) {
            return CupertinoCalendarPickerButton(
              minimumDateTime: DateTime.now().subtract(
                const Duration(days: 365 * 10),
              ),
              maximumDateTime: DateTime.now().add(
                const Duration(days: 365 * 10),
              ),
              formatter: (dateTime) => DateFormatter.formatHeaderDate(dateTime),
              initialDateTime: field.value ?? DateTime.now(),
              onDateTimeChanged: (dateTime) {
                field.didChange(dateTime);
              },
              buttonDecoration: PickerButtonDecoration(
                textStyle: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                backgroundColor: Colors.transparent,
              ),
            );
          },
        ),
      ],
    );
  }
}
