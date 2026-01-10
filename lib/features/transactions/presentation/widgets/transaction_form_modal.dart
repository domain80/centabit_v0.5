import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_form_cubit.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_form_state.dart';
import 'package:centabit/features/transactions/presentation/widgets/transaction_amount_input.dart';
import 'package:centabit/features/transactions/presentation/widgets/transaction_budget_dropdown.dart';
import 'package:centabit/features/transactions/presentation/widgets/transaction_category_dropdown.dart';
import 'package:centabit/features/transactions/presentation/widgets/transaction_date_picker.dart';
import 'package:centabit/features/transactions/presentation/widgets/transaction_time_picker.dart';
import 'package:centabit/features/transactions/presentation/widgets/transaction_type_switch.dart';
import 'package:centabit/shared/widgets/form/custom_text_input.dart';
import 'package:centabit/shared/widgets/form/form_actions_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Main transaction form modal widget
///
/// Supports three modes:
/// - Create (initialValue = null, isCopy = false): Creates new transaction
/// - Edit (initialValue = existing, isCopy = false): Updates existing transaction with delete button
/// - Copy (initialValue = existing with new ID/date, isCopy = true): Duplicates transaction
///
/// Uses BlocProvider to scope TransactionFormCubit to modal lifecycle.
/// BlocListener handles navigation (close on success) and error display.
class TransactionFormModal extends StatelessWidget {
  final TransactionModel? initialValue; // null = create, non-null = edit/copy
  final bool isCopy; // true = copy mode (create with pre-filled data)

  const TransactionFormModal({
    super.key,
    this.initialValue,
    this.isCopy = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionFormCubit>(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocListener<TransactionFormCubit, TransactionFormState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {
                // Loading state - could show loading indicator if needed
              },
              success: () {
                // Show success message based on mode
                final message = isCopy || initialValue == null
                    ? 'Transaction created successfully'
                    : 'Transaction updated successfully';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
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
            child: _TransactionFormContent(
              initialValue: initialValue,
              isCopy: isCopy,
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
class _TransactionFormContent extends StatelessWidget {
  final TransactionModel? initialValue;
  final bool isCopy;

  const _TransactionFormContent({this.initialValue, this.isCopy = false});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionFormCubit>();
    final theme = Theme.of(context);

    // Budget ID logic:
    // - Edit/copy mode: preserve original budget (even if null)
    // - Create mode: auto-select first active budget (user can clear)
    final defaultBudgetId = initialValue?.budgetId ?? cubit.defaultBudgetId;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 26, // v4 exact
        vertical: 12,
      ),
      child: FormBuilder(
        key: cubit.formKey,
        initialValue: {
          'time': initialValue?.transactionDate != null
              ? TimeOfDay.fromDateTime(initialValue!.transactionDate)
              : TimeOfDay.now(),
          'date': initialValue?.transactionDate ?? DateTime.now(),
          'isDebit': (initialValue?.type == TransactionType.debit),
          'amount': initialValue?.amount.toStringAsFixed(2) ?? '',
          'budgetId': defaultBudgetId,
          'categoryId': initialValue?.categoryId ?? '',
          'transactionName': initialValue?.name ?? '',
          'notes': initialValue?.notes ?? '',
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 22, // v4 exact
            children: [
              // Form Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getFormTitle(),
                      style: TextStyle(
                        fontSize: 28, // v4's h2
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface, // Changed from primary for better contrast
                      ),
                    ),
                  ),
                  // Only show delete button in edit mode (not copy or create)
                  if (initialValue != null && !isCopy)
                    IconButton(
                      icon: Icon(
                        TablerIcons.trash,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () => _handleDelete(context, initialValue!.id),
                    ),
                ],
              ),
              const TransactionTimePicker(),
              const TransactionDatePicker(),
              const TransactionBudgetDropdown(), // Prominent placement
              const TransactionCategoryDropdown(),
              Row(
                spacing: 0, // v4 exact
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Expanded(flex: 4, child: TransactionAmountInput()),
                  Expanded(flex: 3, child: TransactionTypeSwitch()),
                ],
              ),
              CustomTextInput(
                name: 'transactionName',
                hintText: 'Transaction name',
                validator: FormBuilderValidators.required(
                  errorText: 'Transaction name is required',
                ),
              ),
              const CustomTextInput(
                name: 'notes',
                hintText: 'Notes (optional)',
              ),
              FormActionsRow(
                actionWidget: Text(
                  initialValue == null
                      ? "Add"
                      : isCopy
                      ? "Copy"
                      : "Update",
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

  /// Get form title based on mode
  String _getFormTitle() {
    if (isCopy) return 'Copy Transaction';
    if (initialValue != null) return 'Edit Transaction';
    return 'Add Transaction';
  }

  /// Handle form submission (create or update based on mode)
  void _handleSubmit(BuildContext context) {
    final cubit = context.read<TransactionFormCubit>();

    // Copy and Create modes both call createTransaction
    // Only Edit mode calls updateTransaction
    if (initialValue != null && !isCopy) {
      cubit.updateTransaction(initialValue!.id);
    } else {
      cubit.createTransaction();
    }
  }

  /// Handle delete with confirmation dialog
  void _handleDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TransactionFormCubit>().deleteTransaction(id);
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
}
