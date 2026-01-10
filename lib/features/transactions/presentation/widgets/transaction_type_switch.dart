import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Transaction type switch field (Debit/Credit toggle)
///
/// Uses FormBuilderSwitch to toggle between debit and credit types.
/// - true = Debit (money going out)
/// - false = Credit (money coming in)
///
/// Material 3 colors for active/inactive states.
class TransactionTypeSwitch extends StatelessWidget {
  const TransactionTypeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return FormBuilderSwitch(
      name: 'isDebit',
      title: Text('Debit', style: textTheme.bodyLarge?.copyWith()),
      activeColor: theme.colorScheme.secondary,
      inactiveThumbColor: theme.colorScheme.onSurface,
      activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      // inactiveTrackColor: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      contentPadding: EdgeInsets.zero,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.zero,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
    );
  }
}
