import 'dart:async';

import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_form_cubit.dart';
import 'package:flutter/material.dart';

/// Allocation tile widget with inline amount editing.
///
/// Displays a single allocation in the budget form's allocation list.
/// Shows category icon, name, editable amount field, and delete button.
///
/// **Props**:
/// - `allocation`: AllocationEditModel with category and amount data
/// - `categories`: List of categories to find category info
/// - `onAmountChanged`: Callback when amount is changed (debounced)
/// - `onDelete`: Callback when delete button is tapped
///
/// **Usage** (in BudgetFormModal):
/// ```dart
/// AllocationTile(
///   allocation: allocEditModel,
///   categories: cubit.categories,
///   onAmountChanged: (amount) {
///     cubit.updateAllocation(allocEditModel.id, allocEditModel.categoryId, amount);
///   },
///   onDelete: () => cubit.removeAllocation(allocEditModel.id),
/// )
/// ```
class AllocationTile extends StatefulWidget {
  final AllocationEditModel allocation;
  final List<CategoryModel> categories;
  final Function(double amount) onAmountChanged;
  final VoidCallback onDelete;

  const AllocationTile({
    super.key,
    required this.allocation,
    required this.categories,
    required this.onAmountChanged,
    required this.onDelete,
  });

  @override
  State<AllocationTile> createState() => _AllocationTileState();
}

class _AllocationTileState extends State<AllocationTile> {
  late TextEditingController _amountController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.allocation.amount.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(AllocationTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update controller if amount changed externally (not from this widget's input)
    // // This prevents cursor jumping during typing
    // if (widget.allocation.amount != oldWidget.allocation.amount &&
    //     _amountController.text != widget.allocation.amount.toStringAsFixed(2)) {
    //   _amountController.text = widget.allocation.amount.toStringAsFixed(2);
    // }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _handleAmountChange(String value) {
    // Debounce to avoid excessive cubit calls during typing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final amount = double.tryParse(value);
      if (amount != null && amount >= 0) {
        widget.onAmountChanged(amount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    // Find category for this allocation
    final category = widget.categories
        .where((cat) => cat.id == widget.allocation.categoryId)
        .firstOrNull;

    final categoryName = category?.name ?? 'Unknown Category';
    final categoryIcon = category?.iconName ?? 'help';
    final IconData iconData =
        TablerIcons.all[categoryIcon] ?? TablerIcons.category;

    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          // Category Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(radius.sm),
            ),
            child: Icon(iconData, size: 20, color: colorScheme.primary),
          ),
          SizedBox(width: spacing.md),

          // Category Name
          Expanded(
            flex: 3,
            child: Text(
              categoryName,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.9),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: spacing.sm),

          // INLINE EDITABLE AMOUNT FIELD
          Expanded(
            flex: 2,
            child: Container(
              constraints: .new(maxHeight: 40),
              height: 30,
              child: TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.right,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  prefixText: '\$',
                  prefixStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: colorScheme.error),
                  ),
                ),
                onChanged: _handleAmountChange,
              ),
            ),
          ),

          SizedBox(width: spacing.xs),

          // Delete Button
          IconButton(
            icon: Icon(
              TablerIcons.trash,
              size: 18,
              color: colorScheme.error.withValues(alpha: 0.8),
            ),
            tooltip: 'Delete Allocation',
            onPressed: widget.onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
