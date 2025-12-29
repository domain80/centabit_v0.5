import 'package:flutter/material.dart';
import 'package:centabit/core/theme/tabler_icons.dart';

class FormHeader extends StatelessWidget {
  final void Function()? onDelete;
  final String headerText;

  const FormHeader({
    super.key,
    this.onDelete,
    required this.headerText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          headerText,
          textAlign: TextAlign.left,
          style: textTheme.headlineLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            iconSize: 24,
            padding: const EdgeInsets.all(8),
            icon: Icon(
              TablerIcons.trash,
              color: colorScheme.error,
            ),
            style: IconButton.styleFrom(
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(81),
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
            ),
          ),
      ],
    );
  }
}
