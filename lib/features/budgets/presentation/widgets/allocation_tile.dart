import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_form_cubit.dart';
import 'package:flutter/material.dart';

/// Allocation tile widget for budget form.
///
/// Displays a single allocation in the budget form's allocation list.
/// Shows category icon, name, amount, and edit/delete buttons.
///
/// **Props**:
/// - `allocation`: AllocationEditModel with category and amount data
/// - `categories`: List of categories to find category info
/// - `onEdit`: Callback when edit button is tapped
/// - `onDelete`: Callback when delete button is tapped
///
/// **Usage** (in BudgetFormModal):
/// ```dart
/// AllocationTile(
///   allocation: allocEditModel,
///   categories: cubit.categories,
///   onEdit: () => _handleEditAllocation(context, allocEditModel),
///   onDelete: () => cubit.removeAllocation(allocEditModel.id),
/// )
/// ```
class AllocationTile extends StatelessWidget {
  final AllocationEditModel allocation;
  final List<CategoryModel> categories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AllocationTile({
    super.key,
    required this.allocation,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    // Find category for this allocation
    final category = categories
        .where((cat) => cat.id == allocation.categoryId)
        .firstOrNull;

    // Fallback if category not found (shouldn't happen)
    final categoryName = category?.name ?? 'Unknown Category';
    final categoryIcon = category?.iconName ?? 'help';

    // Get icon from TablerIcons.all map (same pattern as category dropdown)
    final IconData iconData = TablerIcons.all[categoryIcon] ?? TablerIcons.category;

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
        children: [
          // Category Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(radius.sm),
            ),
            child: Icon(
              iconData,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: spacing.md),

          // Category Name & Amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  categoryName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${allocation.amount.toStringAsFixed(2)}',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          IconButton(
            icon: Icon(
              TablerIcons.edit,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            tooltip: 'Edit Allocation',
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),

          // Delete Button
          IconButton(
            icon: Icon(
              TablerIcons.trash,
              size: 18,
              color: colorScheme.error.withValues(alpha: 0.8),
            ),
            tooltip: 'Delete Allocation',
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
