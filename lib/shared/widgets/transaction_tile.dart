import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';
import 'package:flutter/material.dart';
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
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
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
      },
      confirmDismiss: (direction) {
        if (direction == DismissDirection.endToStart) {
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
        return Future.value(false);
      },
      background: Padding(
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

  IconData _getTablerIcon(String? iconName) {
    if (iconName == null) return TablerIcons.wallet;
    return TablerIcons.all[iconName] ?? TablerIcons.wallet;
  }
}
