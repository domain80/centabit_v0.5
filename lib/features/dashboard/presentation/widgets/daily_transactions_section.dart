import 'package:centabit/core/localizations/app_localizations.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_state.dart';
import 'package:centabit/shared/widgets/custom_date_picker.dart';
import 'package:centabit/shared/widgets/infinite_date_scroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sticky header for the daily transactions section.
///
/// Contains:
/// - Header with "Transactions" title and calendar picker
/// - Divider
/// - Infinite date scroller for quick date selection
/// - Bottom divider
///
/// This widget is used as the sticky header in a SliverStickyHeader,
/// staying visible at the top while the transaction list scrolls underneath.
///
/// **Layout**:
/// ```
/// ┌──────────────────────────────────┐
/// │ Transactions            📅       │  <- Header with picker
/// ├──────────────────────────────────┤
/// │  Mon  Tue  Wed  Thu  Fri  Sat    │  <- Date scroller
/// │   19   20  [21]  22   23   24    │
/// ├──────────────────────────────────┤  <- Sticky boundary
/// ```
class DailyTransactionsStickyHeader extends StatelessWidget {
  const DailyTransactionsStickyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;
    final colorScheme = theme.colorScheme;

    return BlocBuilder<DateFilterCubit, DateFilterState>(
      builder: (context, state) {
        final cubit = context.read<DateFilterCubit>();

        return Container(
          color: colorScheme.surface,
          child: Column(
            children: [
              // HEADER with title and calendar picker
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.transactionsForDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Calendar picker icon
                    CustomDatePicker(
                      currentDate: state.selectedDate,
                      onDateChanged: (newDate) => cubit.changeDate(newDate),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Divider
              Divider(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                indent: 26,
                endIndent: 26,
              ),

              // INFINITE DATE SCROLLER
              Padding(
                padding: EdgeInsets.symmetric(vertical: spacing.xs),
                child: InfiniteDateScroller(
                  currentDate: state.selectedDate,
                  onDateChanged: (newDate) => cubit.changeDate(newDate),
                ),
              ),

              // Bottom divider
              Divider(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                indent: 26,
                endIndent: 26,
              ),
            ],
          ),
        );
      },
    );
  }
}
