import 'dart:async';

import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/core/utils/show_modal.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/features/categories/presentation/widgets/category_form_modal.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_form_cubit.dart';
import 'package:centabit/shared/widgets/select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Category dropdown field for transaction form
///
/// Uses SelectDropdown widget with reactive updates from cubit's categories.
/// Supports inline category creation via action widget.
///
/// Optional field - category can be null.
/// Auto-resets if selected category is deleted elsewhere.
class TransactionCategoryDropdown extends StatefulWidget {
  const TransactionCategoryDropdown({super.key});

  @override
  State<TransactionCategoryDropdown> createState() =>
      _TransactionCategoryDropdownState();
}

class _TransactionCategoryDropdownState
    extends State<TransactionCategoryDropdown> {
  StreamSubscription? _categorySubscription;
  List<CategoryModel> _categories = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe to category changes
    final cubit = context.read<TransactionFormCubit>();
    _categories = cubit.categories;

    // Cancel previous subscription if any
    _categorySubscription?.cancel();

    // Subscribe to category repository stream directly to rebuild when categories change
    _categorySubscription = getIt<CategoryRepository>().categoriesStream.listen(
      (categories) {
        if (mounted) {
          setState(() {
            _categories = categories;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Row(
      spacing: 40, // v4 exact
      children: [
        Expanded(flex: 1, child: Text('Category')),
        Expanded(
          flex: 2,
          child: FormBuilderField<String>(
            name: 'categoryId',
            builder: (field) {
              // Reset to null if selected category no longer exists
              if (field.value != null &&
                  field.value!.isNotEmpty &&
                  !_categories.any((c) => c.id == field.value)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  field.didChange(null);
                });
              }

              // Find selected category
              final selected = field.value != null && field.value!.isNotEmpty
                  ? _categories.firstWhere(
                      (c) => c.id == field.value,
                      orElse: () => CategoryModel(
                        id: '',
                        name: '',
                        iconName: 'category',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    )
                  : null;

              return SelectDropdown<CategoryModel>(
                items: _categories,
                selected: selected,
                onItemTap: (category) {
                  field.didChange(category?.id);
                },
                // Action widget for inline creation (Phase 1: Navigation)
                actionWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(TablerIcons.plus, size: 16),
                    SizedBox(width: spacing.xs),
                    Text('Create category'),
                  ],
                ),
                onActionTap: () => _showCreateCategoryModal(context),
                // Long-press to edit category
                onItemLongPress: (category) {
                  if (category != null) {
                    _showEditCategoryModal(context, category);
                  }
                },
                buttonBuilder: (context, selectedCategory) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedCategory?.name ?? 'Select category',
                          style: textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        TablerIcons.chevronDown,
                        size: 16,
                        color: theme.colorScheme.onSurface,
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
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
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
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Show category creation modal
  void _showCreateCategoryModal(BuildContext context) {
    showModalBottomSheetUtil(
      context,
      builder: (_) => const CategoryFormModal(),
      modalFractionalHeight: 0.7, // Category form is shorter than transaction
    );
  }

  /// Show category edit modal
  void _showEditCategoryModal(BuildContext context, CategoryModel category) {
    showModalBottomSheetUtil(
      context,
      builder: (_) => CategoryFormModal(initialValue: category),
      modalFractionalHeight: 0.7,
    );
  }

  /// Map iconName string to TablerIcons
  ///
  /// TODO: Implement proper icon mapping from category.iconName
  /// For now, returns default category icon
  IconData _getIconData(String iconName) {
    // Basic icon mapping - can be expanded later
    switch (iconName.toLowerCase()) {
      case 'cart':
      case 'shopping':
        return TablerIcons.shoppingCart;
      case 'food':
      case 'restaurant':
        return TablerIcons.toolsKitchen2;
      case 'home':
      case 'house':
        return TablerIcons.home;
      case 'car':
      case 'transport':
        return TablerIcons.car;
      case 'health':
      case 'medical':
        return TablerIcons.firstAidKit;
      case 'entertainment':
      case 'movie':
        return TablerIcons.deviceTv;
      default:
        return TablerIcons.category;
    }
  }
}
