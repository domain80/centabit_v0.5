import 'dart:async';

import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';
import 'package:centabit/shared/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Search bar with filter button
///
/// Layout:
/// - Pill-shaped search input (white background)
///   - "Search" placeholder on left
///   - X clear button on right (inside the pill)
/// - Circular dark calendar/filter button (separate, on far right)
class NavSearchBar extends StatefulWidget {
  const NavSearchBar({super.key, required this.focusNode});
  final FocusNode focusNode;

  @override
  State<NavSearchBar> createState() => _NavSearchBarState();
}

class _NavSearchBarState extends State<NavSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    context.read<NavCubit>().updateSearchQuery('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    return BlocBuilder<NavCubit, NavState>(
      builder: (context, navState) {
        return Row(
          spacing: spacing.md,
          children: [
            // Search input (white pill with X button inside)
            Flexible(
              child: SizedBox(
                height: spacing.xl4,
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(
                      const Duration(milliseconds: 300),
                      () {
                        context.read<NavCubit>().updateSearchQuery(value);
                      },
                    );
                    setState(() {});
                  },
                  // textAlignVertical: TextAlignVertical.center,
                  expands: true,
                  maxLines: null,
                  focusNode: widget.focusNode,
                  decoration: InputDecoration(
                    hintText: navState.searchScope.isNotEmpty
                        ? 'Search ${navState.searchScope}'
                        : 'Search',
                    hintStyle: .new(fontSize: 14, fontWeight: FontWeight.w400),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius.xl3),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius.xl3),
                      borderSide: BorderSide(
                        color: colorScheme.primary.withAlpha(70),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius.xl3),
                      borderSide: BorderSide(
                        color: colorScheme.primary.withAlpha(70),
                        width: 1,
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: _clearSearch,
                      icon: Icon(
                        TablerIcons.x,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                ),
              ),
            ),
            // Calendar filter button (dark circle)
            IconButton(
              style: .new(
                backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (bottomSheetContext) {
                    return CustomDatePicker(
                      currentDate: DateTime.now(),
                      onDateChanged: (date) {
                        Navigator.pop(bottomSheetContext);

                        // Try to access TransactionListCubit (only works on transactions page)
                        try {
                          final cubit = context.read<TransactionListCubit>();
                          cubit.setSelectedDate(date);
                        } catch (e) {
                          // Not on transactions page, ignore
                        }
                      },
                    );
                  },
                );
              },
              icon: Icon(TablerIcons.calendarCode),
            ),
          ],
        );
      },
    );
  }
}
