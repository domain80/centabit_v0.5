import 'package:flutter/material.dart';
import 'package:centabit/core/theme/tabler_icons.dart';

class FormActionsRow extends StatelessWidget {
  final Widget? actionWidget;
  final void Function() actionHandler;
  final void Function()? onCancel;

  const FormActionsRow({
    super.key,
    this.actionWidget = const Text("Add"),
    required this.actionHandler,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: actionHandler,
            child: actionWidget,
          ),
        ),
        IconButton(
          onPressed: onCancel,
          icon: const Icon(TablerIcons.x),
        ),
      ],
    );
  }
}
