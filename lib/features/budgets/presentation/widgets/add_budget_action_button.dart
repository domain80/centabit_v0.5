import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/utils/show_modal.dart';
import 'package:centabit/features/budgets/presentation/widgets/budget_form_modal.dart';
import 'package:flutter/material.dart';

/// Action button for creating a new budget.
///
/// Displays a "+" icon button in the AppBar that opens the budget form modal
/// when tapped.
///
/// **Usage** (in AppBar actions):
/// ```dart
/// AppBar(
///   title: Text('Budgets'),
///   actions: [
///     AddBudgetActionButton(),
///   ],
/// )
/// ```
class AddBudgetActionButton extends StatelessWidget {
  const AddBudgetActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(TablerIcons.plus),
      tooltip: 'Create Budget',
      onPressed: () => _openBudgetForm(context),
    );
  }

  /// Opens budget form modal for creating a new budget.
  ///
  /// **Modal Config**:
  /// - Height: 78% of screen (0.78)
  /// - Draggable with handle
  /// - Dismissible by tapping outside
  /// - Contains BudgetFormModal with initialBudget = null (create mode)
  void _openBudgetForm(BuildContext context) {
    showModalBottomSheetUtil(
      context,
      builder: (_) => const BudgetFormModal(
        initialBudget: null, // null = create new budget
      ),
      modalFractionalHeight: 0.78, // Same height as transaction form
    );
  }
}
