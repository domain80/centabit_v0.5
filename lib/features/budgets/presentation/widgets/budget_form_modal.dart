import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/core/utils/date_formatter.dart';
import 'package:centabit/core/utils/show_modal.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_form_cubit.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_form_state.dart';
import 'package:centabit/features/budgets/presentation/widgets/allocation_tile.dart';
import 'package:centabit/features/categories/presentation/widgets/category_form_modal.dart';
import 'package:centabit/shared/widgets/form/custom_text_input.dart';
import 'package:centabit/shared/widgets/form/form_actions_row.dart';
import 'package:centabit/shared/widgets/select_dropdown.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Main budget form modal widget.
///
/// Supports two modes via initialBudget parameter:
/// - Create (initialBudget = null): Creates new budget with allocations
/// - Edit (initialBudget = existing): Updates existing budget with delete button
///
/// **Features**:
/// - Budget fields: name, amount, startDate, endDate
/// - Allocation management: add/edit/delete inline with category dropdowns
/// - Real-time validation: total allocations ≤ budget amount
/// - Atomic operations: budget + allocations saved together with rollback
/// - BlocProvider scopes BudgetFormCubit to modal lifecycle
/// - BlocListener handles navigation (close on success) and error display
///
/// **Usage**:
/// ```dart
/// showModalBottomSheetUtil(
///   context,
///   builder: (_) => BudgetFormModal(initialBudget: null), // Create
///   modalFractionalHeight: 0.78,
/// );
/// ```
class BudgetFormModal extends StatelessWidget {
  final BudgetModel? initialBudget; // null = create, non-null = edit

  const BudgetFormModal({super.key, this.initialBudget});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<BudgetFormCubit>();
        // Load existing allocations if editing
        if (initialBudget != null) {
          cubit.loadExistingAllocations(initialBudget!.id);
        }
        return cubit;
      },
      child: BlocListener<BudgetFormCubit, BudgetFormState>(
        listener: (context, state) {
          state.when(
            initial: (rebuildCounter) {},
            loading: () {
              // Loading state - could show loading indicator if needed
            },
            success: () {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    initialBudget != null
                        ? 'Budget updated successfully'
                        : 'Budget created successfully',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Close modal on success
              Navigator.of(context).pop();
            },
            error: (message) {
              // Show error snackbar but keep modal open (preserve form state)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  duration: const Duration(seconds: 4),
                ),
              );
            },
          );
        },
        child: SafeArea(
          child: _BudgetFormContent(initialBudget: initialBudget),
        ),
      ),
    );
  }
}

/// Internal form content widget.
///
/// Manages FormBuilder state and composes all field widgets.
/// Handles submit, cancel, and delete actions.
class _BudgetFormContent extends StatelessWidget {
  final BudgetModel? initialBudget;

  const _BudgetFormContent({this.initialBudget});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BudgetFormCubit>();
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;

    // Default dates: current month if creating new budget
    final now = DateTime.now();
    final defaultStartDate =
        initialBudget?.startDate ?? DateTime(now.year, now.month, 1);
    final defaultEndDate =
        initialBudget?.endDate ??
        DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 26, // v4 exact
        vertical: 12,
      ),
      child: FormBuilder(
        key: cubit.formKey,
        initialValue: {
          'name': initialBudget?.name ?? '',
          'amount': initialBudget?.amount.toStringAsFixed(2) ?? '',
          'startDate': defaultStartDate,
          'endDate': defaultEndDate,
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 22, // v4 exact
            children: [
              // Form Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      initialBudget != null ? 'Update Budget' : 'Create Budget',
                      style: TextStyle(
                        fontSize: 28, // v4's h2
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (initialBudget != null)
                    IconButton(
                      icon: Icon(
                        TablerIcons.trash,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Delete Budget',
                      onPressed: () =>
                          _handleDelete(context, initialBudget!.id),
                    ),
                ],
              ),

              // // Budget Details Section
              // Text(
              //   'Budget Details',
              //   style: theme.textTheme.titleMedium?.copyWith(
              //     fontWeight: FontWeight.w600,
              //     color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              //   ),
              // ),

              // Budget Name
              CustomTextInput(
                name: 'name',
                hintText: 'Budget name (e.g., December 2025)',
                validator: (value) =>
                    cubit.validateName(value, excludeId: initialBudget?.id),
              ),

              // Budget Amount
              FormBuilderTextField(
                name: 'amount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Total amount',
                  prefixText: '\$ ',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  fillColor: Colors.transparent,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 1,
                    ),
                  ),
                ),
                validator: cubit.validateAmount,
              ),

              // Date Range
              Row(
                spacing: 12,
                children: [
                  // Start Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          'Start Date',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        FormBuilderField<DateTime>(
                          name: 'startDate',
                          validator: FormBuilderValidators.required(
                            errorText: 'Start date is required',
                          ),
                          builder: (field) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: CupertinoCalendarPickerButton(
                                minimumDateTime: DateTime.now().subtract(
                                  const Duration(days: 365 * 10),
                                ),
                                maximumDateTime: DateTime.now().add(
                                  const Duration(days: 365 * 10),
                                ),
                                formatter: (dateTime) =>
                                    DateFormatter.formatHeaderDate(dateTime),
                                initialDateTime:
                                    field.value ?? defaultStartDate,
                                onDateTimeChanged: (dateTime) {
                                  field.didChange(dateTime);
                                },
                                mainColor: theme.colorScheme.secondary,
                                buttonDecoration: PickerButtonDecoration(
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                  backgroundColor: theme.colorScheme.surface,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // End Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          'End Date',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        FormBuilderField<DateTime>(
                          name: 'endDate',
                          validator: FormBuilderValidators.required(
                            errorText: 'End date is required',
                          ),
                          builder: (field) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: CupertinoCalendarPickerButton(
                                minimumDateTime: DateTime.now().subtract(
                                  const Duration(days: 365 * 10),
                                ),
                                maximumDateTime: DateTime.now().add(
                                  const Duration(days: 365 * 10),
                                ),
                                formatter: (dateTime) =>
                                    DateFormatter.formatHeaderDate(dateTime),
                                initialDateTime: field.value ?? defaultEndDate,
                                onDateTimeChanged: (dateTime) {
                                  field.didChange(dateTime);
                                },
                                mainColor: theme.colorScheme.secondary,
                                buttonDecoration: PickerButtonDecoration(
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                  backgroundColor: theme.colorScheme.surface,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              const Divider(),

              // Category Selection Section
              BlocBuilder<BudgetFormCubit, BudgetFormState>(
                buildWhen: (previous, current) => true,
                builder: (context, state) {
                  final cubit = context.read<BudgetFormCubit>();
                  final allocations = cubit.allocations;
                  final categories = cubit.categories;

                  // Filter out already-allocated categories
                  final availableCategories = categories
                      .where(
                        (cat) => !allocations
                            .map((a) => a.categoryId)
                            .contains(cat.id),
                      )
                      .toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Allocations',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                      const SizedBox(width: 36),
                      Expanded(
                        child: SelectDropdown<CategoryModel>(
                          items: availableCategories,
                          onItemTap: (category) {
                            if (category != null) {
                              cubit.addAllocation(category.id, 0.0);
                            }
                          },
                          // Conditional action widget based on category existence
                          actionWidget: cubit.categories.isEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      TablerIcons.plus,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    SizedBox(width: spacing.xs),
                                    Text(
                                      'Create your first category',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      TablerIcons.plus,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    SizedBox(width: spacing.xs),
                                    Text(
                                      'Create category',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                          onActionTap: () => _showCreateCategoryModal(context),
                          onItemLongPress: (category) {
                            if (category != null) {
                              _showEditCategoryModal(context, category);
                            }
                          },
                          buttonBuilder: (context, selected) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (selected != null) ...[
                                  Icon(
                                    TablerIcons.all[selected.iconName] ??
                                        TablerIcons.category,
                                    size: 18,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    availableCategories.isEmpty
                                        ? 'All categories allocated'
                                        : 'Add an allocation',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: availableCategories.isEmpty
                                          ? theme.colorScheme.onSurface
                                                .withValues(alpha: 0.4)
                                          : null,
                                    ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    TablerIcons.all[category.iconName] ??
                                        TablerIcons.category,
                                    size: 18,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      category.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
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
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Allocation List (reactive to cubit state changes)
              BlocBuilder<BudgetFormCubit, BudgetFormState>(
                buildWhen: (previous, current) => true, // Always rebuild
                builder: (context, state) {
                  final allocations = cubit.allocations;

                  // Empty state
                  if (allocations.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(spacing.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'No allocations yet. Tap "Add" to create one.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Allocation tiles
                  return Column(
                    spacing: spacing.sm,
                    children: allocations.map((allocation) {
                      return AllocationTile(
                        allocation: allocation,
                        categories: cubit.categories,
                        onAmountChanged: (amount) {
                          cubit.updateAllocation(
                            allocation.id,
                            allocation.categoryId,
                            amount,
                          );
                        },
                        onDelete: () => cubit.removeAllocation(allocation.id),
                      );
                    }).toList(),
                  );
                },
              ),

              // Validation Summary
              BlocBuilder<BudgetFormCubit, BudgetFormState>(
                buildWhen: (previous, current) => true, // Always rebuild
                builder: (context, state) {
                  final allocations = cubit.allocations;
                  final totalAllocated = allocations.fold<double>(
                    0.0,
                    (sum, alloc) => sum + alloc.amount,
                  );

                  final amountStr =
                      cubit.formKey.currentState?.fields['amount']?.value ??
                      '0';
                  final budgetAmount = double.tryParse(amountStr) ?? 0;
                  final unallocated = budgetAmount - totalAllocated;

                  return Container(
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ),
                    child: Column(
                      spacing: spacing.xs,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Budget:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            Text(
                              '\$${budgetAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Allocated:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            Text(
                              '\$${totalAllocated.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: totalAllocated > budgetAmount
                                    ? theme.colorScheme.error
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Unallocated:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${unallocated.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: unallocated < 0
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Form Actions
              FormActionsRow(
                actionWidget: Text(initialBudget != null ? 'Update' : 'Create'),
                actionHandler: () => _handleSubmit(context),
                onCancel: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle form submission (create or update).
  void _handleSubmit(BuildContext context) {
    // Capture cubit reference before async gap
    final cubit = context.read<BudgetFormCubit>();

    // Unfocus all fields to trigger pending debounced updates
    FocusScope.of(context).unfocus();

    // Delay submission slightly to allow debounced updates to complete
    Future.delayed(const Duration(milliseconds: 600), () {
      if (initialBudget != null) {
        cubit.updateBudget(initialBudget!.id);
      } else {
        cubit.createBudget();
      }
    });
  }

  /// Handle delete with confirmation dialog.
  void _handleDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Budget?'),
        content: const Text(
          'This will permanently delete the budget and all its allocations. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BudgetFormCubit>().deleteBudget(id);
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

  /// Show modal for creating a new category.
  void _showCreateCategoryModal(BuildContext context) {
    showModalBottomSheetUtil(
      context,
      builder: (_) => const CategoryFormModal(),
      modalFractionalHeight: 0.7,
    );
  }

  /// Show modal for editing an existing category.
  void _showEditCategoryModal(BuildContext context, CategoryModel category) {
    showModalBottomSheetUtil(
      context,
      builder: (_) => CategoryFormModal(initialValue: category),
      modalFractionalHeight: 0.7,
    );
  }
}
