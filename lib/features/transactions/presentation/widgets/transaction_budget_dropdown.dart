import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_form_cubit.dart';
import 'package:centabit/shared/widgets/select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Budget dropdown field for transaction form
///
/// Uses SelectDropdown widget with reactive updates from cubit's active budgets.
/// **Emphasized styling** with primary color to highlight budget importance.
///
/// Optional field - budget selection is not required.
/// Controlled mode - selected value managed by FormBuilder.
class TransactionBudgetDropdown extends StatelessWidget {
  const TransactionBudgetDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>()!;
    final cubit = context.watch<TransactionFormCubit>();

    return Row(
      spacing: 40, // v4 exact
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'Budget',
            style: TextStyle(
              fontSize: 18, // v4's large
              fontWeight: FontWeight.w400, // Regular, not semibold
              color: theme.colorScheme.primary, // Emphasized with primary color
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: FormBuilderField<String>(
            name: 'budgetId',
            validator: null, // Budget is optional
            builder: (field) {
              // Build items list with "No budget selected" option at top
              final dropdownItems = [
                BudgetModel(
                  id: '', // Empty string represents "No Budget"
                  name: 'No budget selected',
                  amount: 0,
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                ...cubit.activeBudgets,
              ];

              // Find selected budget (null or empty string is valid - means "No Budget")
              BudgetModel? selected;
              if (field.value != null && field.value!.isNotEmpty) {
                selected = cubit.activeBudgets.firstWhere(
                  (b) => b.id == field.value,
                  orElse: () => dropdownItems.first, // Fallback to "No budget selected"
                );
              }

              return SelectDropdown<BudgetModel>(
                items: dropdownItems,
                selected: selected,
                onItemTap: (budget) {
                  if (budget != null) {
                    // Empty string ID means "No Budget" → store as null
                    field.didChange(budget.id.isEmpty ? null : budget.id);
                  }
                },
                buttonBuilder: (context, selectedBudget) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedBudget?.name ?? 'No budget selected',
                          style: textTheme.bodyMedium?.copyWith(
                            fontStyle: selectedBudget == null ? FontStyle.italic : null,
                            color: selectedBudget == null
                                ? theme.colorScheme.onSurface.withValues(alpha: 150/255)
                                : theme.colorScheme.onSurface,
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
                itemBuilder: (context, budget, isSelected) {
                  final isNoneOption = budget.id.isEmpty;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.xs,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isNoneOption ? TablerIcons.x : TablerIcons.wallet,
                          size: 18,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isNoneOption
                                  ? theme.colorScheme.onSurface.withValues(alpha: 150/255)
                                  : theme.colorScheme.onSurface),
                        ),
                        SizedBox(width: spacing.xs),
                        Expanded(
                          child: Text(
                            budget.name,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              fontStyle: isNoneOption ? FontStyle.italic : null,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isNoneOption
                                      ? theme.colorScheme.onSurface.withValues(alpha: 150/255)
                                      : theme.colorScheme.onSurface),
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
}
