import 'package:centabit/features/budgets/presentation/cubits/budget_details_cubit.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_details_state.dart';
import 'package:centabit/features/budgets/presentation/cubits/chart_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Segmented button widget to toggle between bar and pie chart views
///
/// **Features**:
/// - Material 3 SegmentedButton component
/// - Icons for visual clarity (bar_chart, pie_chart)
/// - Updates BudgetDetailsCubit chart type state
/// - Highlighted background for selected option
///
/// **Usage**:
/// ```dart
/// const ChartTypeToggle()
/// ```
///
/// Requires BudgetDetailsCubit in widget tree context.
class ChartTypeToggle extends StatelessWidget {
  const ChartTypeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<BudgetDetailsCubit, BudgetDetailsState>(
      buildWhen: (previous, current) => true,
      builder: (context, state) {
        final cubit = context.read<BudgetDetailsCubit>();

        return SegmentedButton<ChartType>(
          segments: const [
            ButtonSegment(
              value: ChartType.bar,
              label: Text('Bar'),
              icon: Icon(Icons.bar_chart),
            ),
            ButtonSegment(
              value: ChartType.pie,
              label: Text('Pie'),
              icon: Icon(Icons.pie_chart),
            ),
          ],
          selected: {cubit.selectedChartType},
          onSelectionChanged: (Set<ChartType> newSelection) {
            cubit.setChartType(newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return theme.colorScheme.secondaryContainer;
              }
              return theme.colorScheme.surface;
            }),
          ),
        );
      },
    );
  }
}
