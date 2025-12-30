import 'dart:ui';

import 'package:flutter/material.dart';

const _horizontalPadding = 12.0;

/// Sentinel to detect uncontrolled mode
class _SelectDropdownSentinel {
  const _SelectDropdownSentinel();
}

const _kSentinel = _SelectDropdownSentinel();

/// The button that opens the dropdown menu.
class SelectDropdownButton<T> extends StatelessWidget {
  final GlobalKey buttonKey;
  final MenuController menuController;
  final Widget Function(BuildContext context, T? selected) buttonBuilder;
  final T? selected;
  final VoidCallback onOpen;
  final ButtonStyle? buttonStyle;

  const SelectDropdownButton({
    super.key,
    required this.buttonKey,
    required this.menuController,
    required this.buttonBuilder,
    this.selected,
    required this.onOpen,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: buttonKey,
      style:
          buttonStyle ??
          OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: 0,
            ),
            minimumSize: const Size(
              0,
              40,
            ), // Override Material's default 48px height
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      onPressed: onOpen,
      child: buttonBuilder(context, selected),
    );
  }
}

// The dropdown menu itself, with the blurred background.
class SelectDropdownMenu<T> extends StatelessWidget {
  final double buttonWidth;
  final List<T> items;
  final T? selected;

  final ValueChanged<T?>? onItemTap;
  final ValueChanged<T?>? onLongPress;

  final Widget Function(BuildContext context, T item, bool selected)
  itemBuilder;
  final MenuController menuController;
  final Widget? actionWidget;
  final VoidCallback? onActionTap;

  const SelectDropdownMenu({
    super.key,
    required this.buttonWidth,
    required this.items,
    this.selected,
    this.onItemTap,
    required this.itemBuilder,
    required this.menuController,
    this.actionWidget,
    this.onActionTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.surface.withAlpha(150),
            BlendMode.color,
          ),
          child: Container(
            width: buttonWidth,
            constraints: const BoxConstraints(minWidth: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (actionWidget != null)
                  TextButton(
                    onPressed: () {
                      onActionTap?.call();
                      menuController.close();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: actionWidget!,
                  ),
                if (actionWidget != null)
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(80),
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items
                          .map(
                            (item) => SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onLongPress: () {
                                  onLongPress?.call(item);
                                  menuController.close();
                                },
                                onPressed: () {
                                  onItemTap?.call(item);
                                  menuController.close();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  overlayColor: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                child: itemBuilder(
                                  context,
                                  item,
                                  selected == item,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The main stateful widget to be used in your application.
class SelectDropdown<T> extends StatefulWidget {
  final List<T> items;
  final Object? selected; // can be T? or sentinel
  final ValueChanged<T?>? onItemTap;
  final Widget Function(BuildContext context, T item, bool selected)
  itemBuilder;
  final Widget Function(BuildContext context, T? selected) buttonBuilder;
  final Widget? actionWidget;
  final VoidCallback? onActionTap;
  final ValueChanged<T?>? onItemLongPress;
  final ButtonStyle? buttonStyle;
  final Offset? alignmentOffset;

  const SelectDropdown({
    super.key,
    this.items = const [],
    this.selected = _kSentinel, // sentinel by default
    this.onItemTap,
    required this.itemBuilder,
    required this.buttonBuilder,
    this.actionWidget,
    this.onActionTap,
    this.onItemLongPress,
    this.buttonStyle,
    this.alignmentOffset,
  });

  bool get isControlled => selected != _kSentinel;

  @override
  State<SelectDropdown<T>> createState() => _SelectDropdownState<T>();
}

class _SelectDropdownState<T> extends State<SelectDropdown<T>> {
  final GlobalKey _buttonKey = GlobalKey();
  double _buttonWidth = 0;
  final MenuController _menuController = MenuController();

  T? _uncontrolledSelected;

  T? get _effectiveSelected =>
      widget.isControlled ? widget.selected as T? : _uncontrolledSelected;

  void _handleItemTap(T? item) {
    if (!widget.isControlled) {
      setState(() {
        _uncontrolledSelected = item;
      });
    }
    widget.onItemTap?.call(item);
  }

  void _updateButtonWidth() {
    final context = _buttonKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        setState(() {
          _buttonWidth = box.size.width;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateButtonWidth());
  }

  @override
  void didUpdateWidget(covariant SelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isControlled && !oldWidget.isControlled) {
      // reset local state when switching from uncontrolled → controlled
      _uncontrolledSelected = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateButtonWidth());
  }

  @override
  Widget build(BuildContext context) {
    final selected = _effectiveSelected;

    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: widget.alignmentOffset ?? const Offset(0, 4),
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.all(0)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(30),
              width: 1,
            ),
          ),
        ),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(20),
        shadowColor: WidgetStatePropertyAll(
          Theme.of(context).shadowColor.withAlpha(200),
        ),
      ),
      menuChildren: [
        SelectDropdownMenu<T>(
          buttonWidth: _buttonWidth,
          items: widget.items,
          selected: selected,
          onItemTap: (item) {
            if (item == selected) {
              _handleItemTap(null);
              return;
            }
            _handleItemTap(item);
          },
          onLongPress: widget.onItemLongPress,
          itemBuilder: widget.itemBuilder,
          menuController: _menuController,
          actionWidget: widget.actionWidget,
          onActionTap: widget.onActionTap,
        ),
      ],
      child: SelectDropdownButton<T>(
        buttonKey: _buttonKey,
        menuController: _menuController,
        buttonBuilder: widget.buttonBuilder,
        selected: selected,
        onOpen: () {
          _updateButtonWidth();
          if (_menuController.isOpen) {
            _menuController.close();
          } else {
            _menuController.open();
          }
        },
        buttonStyle: widget.buttonStyle,
      ),
    );
  }
}
