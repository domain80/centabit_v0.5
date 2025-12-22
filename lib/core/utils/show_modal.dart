import 'package:flutter/material.dart';

void showModalBottomSheetUtil(
  BuildContext context, {
  Widget Function(BuildContext context)? builder,
  double modalFractionalHeight = 0.7,
}) {
  showModalBottomSheet<dynamic>(
    context: context,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * modalFractionalHeight,
        child: builder?.call(context),
      );
    },
    showDragHandle: true,
    enableDrag: true,
    useRootNavigator: true,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    elevation: 32,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
  );
}
