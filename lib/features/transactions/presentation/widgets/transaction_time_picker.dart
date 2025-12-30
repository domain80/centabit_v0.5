import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Time picker field for transaction form
///
/// Uses Cupertino-style time picker from cupertino_calendar_picker package
/// to match the date picker styling. Wrapped in FormBuilderField for form
/// state management.
///
/// Default time: Current time (TimeOfDay.now())
class TransactionTimePicker extends StatelessWidget {
  const TransactionTimePicker({super.key});

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
            'Transaction time',
            style: const TextStyle(
              fontSize: 18, // v4's large
              fontWeight: FontWeight.w400, // Regular, not semibold
            ),
          ),
        ),
        FormBuilderField<TimeOfDay>(
          name: 'time',
          builder: (field) {
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: theme.colorScheme.secondary,
                ),
              ),
              child: CupertinoTimePickerButton(
                initialTime: field.value ?? TimeOfDay.now(),
                onTimeChanged: (time) {
                  field.didChange(time);
                },
                buttonDecoration: PickerButtonDecoration(
                  textStyle: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
