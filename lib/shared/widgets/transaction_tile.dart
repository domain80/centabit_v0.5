import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:toastification/toastification.dart';

class TransactionTile extends StatelessWidget {
  final TransactionVModel transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;
    final isCredit = transaction.type == TransactionType.credit;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // Swipe left → Delete
          onDelete?.call();
          toastification.show(
            type: ToastificationType.error,
            title: const Text("Transaction deleted"),
            style: ToastificationStyle.simple,
            closeButton: const ToastCloseButton(
              showType: CloseButtonShowType.none,
            ),
            closeOnClick: true,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.xs,
            ),
            autoCloseDuration: const Duration(seconds: 5),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            margin: .only(top: spacing.xl4),
            alignment: .topCenter,
            animationDuration: Duration(milliseconds: 200),
            dragToClose: true,
            borderRadius: BorderRadius.circular(400),
            applyBlurEffect: true,
            borderSide: BorderSide(
              color: colorScheme.secondary.withValues(alpha: 0.5),
              width: 1,
            ),
            context: context,
          );
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right → Copy
          onCopy?.call();
          toastification.show(
            type: ToastificationType.success,
            title: const Text("Transaction copied"),
            style: ToastificationStyle.simple,
            closeButton: const ToastCloseButton(
              showType: CloseButtonShowType.none,
            ),
            closeOnClick: true,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.xs,
            ),
            autoCloseDuration: const Duration(seconds: 2),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            margin: .only(top: spacing.xl4),
            alignment: .topCenter,
            animationDuration: Duration(milliseconds: 200),
            dragToClose: true,
            borderRadius: BorderRadius.circular(400),
            applyBlurEffect: true,
            borderSide: BorderSide(
              color: colorScheme.secondary.withValues(alpha: 0.5),
              width: 1,
            ),
            context: context,
          );
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete requires confirmation
          return await _showDeleteConfirmation(context) ?? false;
        } else if (direction == DismissDirection.startToEnd) {
          // Copy action - don't dismiss, just trigger copy
          onCopy?.call();
          toastification.show(
            type: ToastificationType.success,
            title: const Text("Transaction copied"),
            style: ToastificationStyle.simple,
            closeButton: const ToastCloseButton(
              showType: CloseButtonShowType.none,
            ),
            closeOnClick: true,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.xs,
            ),
            autoCloseDuration: const Duration(seconds: 2),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            margin: .only(top: spacing.xl4),
            alignment: .topCenter,
            animationDuration: Duration(milliseconds: 200),
            dragToClose: true,
            borderRadius: BorderRadius.circular(400),
            applyBlurEffect: true,
            borderSide: BorderSide(
              color: colorScheme.secondary.withValues(alpha: 0.5),
              width: 1,
            ),
            context: context,
          );
          return false; // Don't dismiss the tile
        }
        return false;
      },
      background: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(TablerIcons.copy, color: colorScheme.secondary),
            const Spacer(),
          ],
        ),
      ),
      secondaryBackground: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(TablerIcons.trash, color: colorScheme.error),
          ],
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showTransactionActionSheet(context);
        },
        // radius: radius.lg,
        borderRadius: BorderRadius.circular(radius.sm),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: spacing.md,
            // horizontal: spacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category icon in bordered container
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: GradientBoxBorder(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.onSurface.withValues(alpha: 0.35),
                        colorScheme.onSurface.withValues(alpha: 0.2),
                      ],
                    ),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing.sm),
                  child: Icon(
                    _getTablerIcon(transaction.categoryIconName),
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: spacing.lg + 2,
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              // Transaction name and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.formattedTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(transaction.name),
                  ],
                ),
              ),
              SizedBox(width: spacing.lg),
              // Amount with +/- prefix
              Text(
                "${isCredit ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show transaction action popup with Edit, Copy, Delete options
  void _showTransactionActionSheet(BuildContext context) {
    // Get the position of the tile
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Calculate position (show below the tile, or above if not enough space)
    final double top = offset.dy + size.height;
    final double left = offset.dx;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        left,
        top,
        left + size.width,
        top,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(TablerIcons.edit, size: 20),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'copy',
          child: Row(
            children: [
              Icon(TablerIcons.copy, size: 20),
              SizedBox(width: 12),
              Text('Copy'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(TablerIcons.trash, size: 20, color: Theme.of(context).colorScheme.error),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        onEdit?.call();
      } else if (value == 'copy') {
        onCopy?.call();
      } else if (value == 'delete') {
        _showDeleteConfirmation(context).then((confirmed) {
          if (confirmed == true) {
            onDelete?.call();
          }
        });
      }
    });
  }

  /// Show delete confirmation dialog
  ///
  /// Returns Future<bool?> - true if confirmed, false if canceled, null if dismissed
  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text(
            'Are you sure you want to delete this transaction?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getTablerIcon(String? iconName) {
    if (iconName == null) return TablerIcons.wallet;
    return TablerIcons.all[iconName] ?? TablerIcons.wallet;
  }
}
