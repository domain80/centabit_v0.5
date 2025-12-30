import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Amount input field for transaction form
///
/// Most complex field widget with:
/// - Large text styling (displayLarge) for visibility
/// - Decimal validation (regex: ^\d+\.?\d{0,2})
/// - TextEditingController + FormBuilderField sync
/// - Error state color changes
///
/// Validator: Required + must be > 0
class TransactionAmountInput extends StatefulWidget {
  const TransactionAmountInput({super.key});

  @override
  State<TransactionAmountInput> createState() => _TransactionAmountInputState();
}

class _TransactionAmountInputState extends State<TransactionAmountInput> {
  late final TextEditingController _controller;
  final _formatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d+\.?\d{0,2}'),
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Apply decimal formatter to raw text input
  TextEditingValue _applyFormatterTo(String raw, [TextEditingValue? old]) {
    final oldValue = old ?? _controller.value;
    final formatted = _formatter.formatEditUpdate(
      oldValue,
      TextEditingValue(text: raw),
    );
    return formatted.copyWith(
      selection: TextSelection.collapsed(offset: formatted.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount (USD)', // TODO: Get currency from settings
        ),
        SizedBox(height: spacing.xs),
        FormBuilderField<String>(
          name: 'amount',
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Amount is required'),
            (value) {
              if (value == null || value.isEmpty) return null;
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Amount must be greater than 0';
              }
              return null;
            },
          ]),
          builder: (field) {
            final hasError = field.errorText != null;

            // Sync controller with field value (apply formatter)
            final raw = field.value ?? '';
            final newControllerValue = _applyFormatterTo(
              raw,
              _controller.value,
            );
            if (_controller.value.text != newControllerValue.text) {
              _controller.value = newControllerValue;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [_formatter],
                  onChanged: (val) {
                    final filtered = _applyFormatterTo(
                      val,
                      _controller.value,
                    ).text;
                    if (filtered != val) {
                      _controller.value = TextEditingValue(
                        text: filtered,
                        selection: TextSelection.collapsed(
                          offset: filtered.length,
                        ),
                      );
                    }
                    field.didChange(filtered);
                  },
                  style: TextStyle(
                    fontSize: 36, // v4's h1
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: -spacing.sm,
                    ),
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: .none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    errorText: null, // Suppress inline error text (shown below)
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: hasError
                          ? colorScheme.error.withValues(
                              alpha: 180 / 255,
                            ) // v4: alpha 180
                          : colorScheme.onSurface.withValues(
                              alpha: 100 / 255,
                            ), // v4: alpha 100
                    ),
                  ),
                ),
                // Show error message below input
                if (hasError) ...[
                  SizedBox(height: spacing.xs),
                  Text(
                    field.errorText!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
