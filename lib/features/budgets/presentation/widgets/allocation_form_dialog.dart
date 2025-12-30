import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/shared/widgets/select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Dialog for adding or editing budget allocations.
///
/// Shows a simple form with:
/// - Category dropdown (excludes already-allocated categories)
/// - Amount input field
/// - Save/Cancel buttons
///
/// **Modes**:
/// - Add: initialCategoryId = null, initialAmount = null
/// - Edit: initialCategoryId = existing, initialAmount = existing
///
/// **Props**:
/// - `categories`: All available categories
/// - `existingCategoryIds`: Categories already allocated (to exclude from dropdown)
/// - `initialCategoryId`: Selected category (for edit mode)
/// - `initialAmount`: Amount value (for edit mode)
/// - `onSave`: Callback with (categoryId, amount) when saved
///
/// **Usage** (in BudgetFormModal):
/// ```dart
/// // Add mode
/// showDialog(
///   context: context,
///   builder: (_) => AllocationFormDialog(
///     categories: cubit.categories,
///     existingCategoryIds: cubit.allocations.map((a) => a.categoryId).toList(),
///     onSave: (categoryId, amount) => cubit.addAllocation(categoryId, amount),
///   ),
/// );
///
/// // Edit mode
/// showDialog(
///   context: context,
///   builder: (_) => AllocationFormDialog(
///     categories: cubit.categories,
///     existingCategoryIds: [...], // Exclude self
///     initialCategoryId: allocation.categoryId,
///     initialAmount: allocation.amount,
///     onSave: (categoryId, amount) =>
///       cubit.updateAllocation(allocation.id, categoryId, amount),
///   ),
/// );
/// ```
class AllocationFormDialog extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<String> existingCategoryIds;
  final String? initialCategoryId;
  final double? initialAmount;
  final Function(String categoryId, double amount) onSave;

  const AllocationFormDialog({
    super.key,
    required this.categories,
    required this.existingCategoryIds,
    this.initialCategoryId,
    this.initialAmount,
    required this.onSave,
  });

  @override
  State<AllocationFormDialog> createState() => _AllocationFormDialogState();
}

class _AllocationFormDialogState extends State<AllocationFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>()!;

    // Filter out already-allocated categories
    final availableCategories = widget.categories
        .where((cat) => !widget.existingCategoryIds.contains(cat.id))
        .toList();

    // Check if editing mode
    final isEditMode = widget.initialCategoryId != null;

    // Debug logging
    print('📋 AllocationFormDialog build');
    print('   Total categories: ${widget.categories.length}');
    print('   Existing IDs: ${widget.existingCategoryIds}');
    print('   Available categories: ${availableCategories.length}');
    print('   Edit mode: $isEditMode');

    return AlertDialog(
      title: Text(isEditMode ? 'Edit Allocation' : 'Add Allocation'),
      content: SizedBox(
        width: double.maxFinite,
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'categoryId': widget.initialCategoryId ?? '',
            'amount': widget.initialAmount?.toStringAsFixed(2) ?? '',
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.md,
            children: [
              // Category Dropdown
              Text(
                'Category',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              FormBuilderField<String>(
                name: 'categoryId',
                validator: FormBuilderValidators.required(
                  errorText: 'Please select a category',
                ),
                builder: (field) {
                  // In edit mode, include the currently selected category
                  // even if it's in existingCategoryIds (so user can keep same category)
                  final displayCategories = isEditMode
                      ? widget.categories
                          .where((cat) =>
                              cat.id == widget.initialCategoryId ||
                              !widget.existingCategoryIds.contains(cat.id))
                          .toList()
                      : availableCategories;

                  if (displayCategories.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(spacing.md),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        'No categories available. Create categories first.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }

                  final selected = field.value != null && field.value!.isNotEmpty
                      ? displayCategories
                          .where((c) => c.id == field.value)
                          .firstOrNull
                      : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: spacing.xs,
                    children: [
                      SelectDropdown<CategoryModel>(
                        items: displayCategories,
                        selected: selected,
                        onItemTap: (category) {
                          field.didChange(category?.id);
                        },
                        buttonBuilder: (context, selectedCategory) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Category icon (if selected)
                              if (selectedCategory != null) ...[
                                Icon(
                                  _getIconData(selectedCategory.iconName),
                                  size: 18,
                                  color: colorScheme.onSurface,
                                ),
                                SizedBox(width: spacing.xs),
                              ],
                              // Category name
                              Expanded(
                                child: Text(
                                  selectedCategory?.name ?? 'Select category',
                                  style: textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Chevron down
                              Icon(
                                TablerIcons.chevronDown,
                                size: 16,
                                color: colorScheme.onSurface,
                              ),
                            ],
                          );
                        },
                        itemBuilder: (context, category, isSelected) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.md,
                              vertical: spacing.xs,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getIconData(category.iconName),
                                  size: 18,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                                SizedBox(width: spacing.xs),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (field.hasError)
                        Padding(
                          padding: EdgeInsets.only(
                            left: spacing.sm,
                            top: spacing.xs,
                          ),
                          child: Text(
                            field.errorText!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Amount Input
              Text(
                'Amount',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              FormBuilderTextField(
                name: 'amount',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefixText: '\$ ',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  fillColor: Colors.transparent,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 1,
                    ),
                  ),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Amount is required',
                  ),
                  (value) {
                    if (value == null || value.isEmpty) return null;
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ]),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: Text(isEditMode ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  /// Handle save button tap.
  void _handleSave() {
    if (!_formKey.currentState!.saveAndValidate()) {
      return; // Validation failed
    }

    final formData = _formKey.currentState!.value;
    final categoryId = formData['categoryId'] as String;
    final amount = double.parse(formData['amount'] as String);

    widget.onSave(categoryId, amount);
    Navigator.of(context).pop();
  }

  /// Map iconName string to TablerIcons.
  IconData _getIconData(String iconName) {
    return TablerIcons.all[iconName] ?? TablerIcons.category;
  }
}
