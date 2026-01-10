import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/features/categories/presentation/cubits/category_form_cubit.dart';
import 'package:centabit/features/categories/presentation/cubits/category_form_state.dart';
import 'package:centabit/features/categories/presentation/widgets/category_icon_grid.dart';
import 'package:centabit/features/categories/presentation/widgets/category_icon_search.dart';
import 'package:centabit/shared/widgets/form/custom_text_input.dart';
import 'package:centabit/shared/widgets/form/form_actions_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Main category form modal widget
///
/// Supports two modes via initialValue parameter:
/// - Create (initialValue = null): Creates new category
/// - Edit (initialValue = existing): Updates existing category with delete button
///
/// Uses BlocProvider to scope CategoryFormCubit to modal lifecycle.
/// BlocListener handles navigation (close on success) and error display.
///
/// V4 Styling:
/// - 26px horizontal padding
/// - 22px column spacing
/// - 28px gradient header
/// - Icon search and grid sections
/// - Selected icon display with secondary color
class CategoryFormModal extends StatefulWidget {
  final CategoryModel? initialValue; // null = create, non-null = edit

  const CategoryFormModal({super.key, this.initialValue});

  @override
  State<CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends State<CategoryFormModal> {
  String? _selectedIconName;

  @override
  void initState() {
    super.initState();
    _selectedIconName = widget.initialValue?.iconName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => getIt<CategoryFormCubit>(),
        child: BlocListener<CategoryFormCubit, CategoryFormState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              success: () {
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.initialValue != null
                          ? 'Category updated successfully'
                          : 'Category created successfully',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              },
              error: (msg) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  duration: const Duration(seconds: 4),
                ),
              ),
            );
          },
          child: SafeArea(
            child: _CategoryFormContent(
              initialValue: widget.initialValue,
              selectedIconName: _selectedIconName,
              onIconSelected: (iconName) {
                setState(() => _selectedIconName = iconName);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal form content widget
///
/// Manages FormBuilder state and composes all field widgets.
/// Handles submit, cancel, and delete actions.
class _CategoryFormContent extends StatefulWidget {
  final CategoryModel? initialValue;
  final String? selectedIconName;
  final Function(String) onIconSelected;

  const _CategoryFormContent({
    this.initialValue,
    this.selectedIconName,
    required this.onIconSelected,
  });

  @override
  State<_CategoryFormContent> createState() => _CategoryFormContentState();
}

class _CategoryFormContentState extends State<_CategoryFormContent> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryFormCubit>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 26, // v4 exact
        vertical: 12,
      ),
      child: FormBuilder(
        key: cubit.formKey,
        initialValue: {'categoryName': widget.initialValue?.name ?? ''},
        child: SingleChildScrollView(
          child: Column(
            spacing: 22, // v4 exact (main column spacing)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Header with gradient
              Row(
                children: [
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        widget.initialValue != null
                            ? 'Update Category'
                            : 'Add Category',
                        style: const TextStyle(
                          fontSize: 28, // v4's h2
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // Required for ShaderMask
                        ),
                      ),
                    ),
                  ),
                  if (widget.initialValue != null)
                    IconButton(
                      icon: Icon(
                        TablerIcons.trash,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () =>
                          _handleDelete(context, widget.initialValue!.id),
                    ),
                ],
              ),

              // Icon Search Section
              Column(
                spacing: 12, // v4: search to grid = 12px
                children: [
                  CategoryIconSearch(
                    onSearchChanged: (query) {
                      cubit.searchIcons(query);
                      setState(() {}); // Rebuild to show filtered icons
                    },
                  ),
                  CategoryIconGrid(
                    iconNames: cubit.filteredIcons,
                    selectedIconName: widget.selectedIconName,
                    onIconTap: widget.onIconSelected,
                  ),
                ],
              ),

              // Name + Selected Icon Row
              Row(
                spacing: 14, // v4 exact
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected icon display
                  if (widget.selectedIconName != null)
                    Container(
                      padding: const EdgeInsets.all(10), // v4 exact
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 25 / 255,
                        ),
                        border: Border.all(
                          color: theme.colorScheme.secondary,
                          width: 1.8, // v4 exact
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconData(widget.selectedIconName!),
                        color: theme.colorScheme.secondary,
                        size: 24,
                      ),
                    ),

                  // Name input (takes remaining space)
                  Expanded(
                    child: CustomTextInput(
                      name: 'categoryName',
                      hintText: 'Category name',
                      validator: (value) => cubit.validateName(
                        value,
                        excludeId: widget.initialValue?.id,
                      ),
                    ),
                  ),
                ],
              ),

              // Actions
              FormActionsRow(
                actionWidget: Text(
                  widget.initialValue != null ? 'Update' : 'Add',
                ),
                actionHandler: () => _handleSubmit(context),
                onCancel: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle form submission (create or update)
  void _handleSubmit(BuildContext context) {
    final cubit = context.read<CategoryFormCubit>();

    if (widget.selectedIconName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an icon')));
      return;
    }

    // Validate form first
    if (!cubit.formKey.currentState!.saveAndValidate()) {
      return; // Validation failed
    }

    final formData = cubit.formKey.currentState?.value ?? {};
    final name = (formData['categoryName'] as String?) ?? '';

    if (name.isEmpty) {
      return; // Should not happen after validation, but safety check
    }

    if (widget.initialValue != null) {
      cubit.updateCategory(
        widget.initialValue!.id,
        name,
        widget.selectedIconName!,
      );
    } else {
      cubit.createCategory(name, widget.selectedIconName!);
    }
  }

  /// Handle delete with confirmation dialog
  void _handleDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CategoryFormCubit>().deleteCategory(id);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Map iconName string to TablerIcons using centralized lookup
  ///
  /// Uses TablerIcons.all map for dynamic icon resolution.
  /// Falls back to category icon if iconName not found.
  IconData _getIconData(String iconName) {
    return TablerIcons.all[iconName] ?? TablerIcons.category;
  }
}
