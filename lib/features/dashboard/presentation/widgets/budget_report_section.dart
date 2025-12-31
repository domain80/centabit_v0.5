import 'package:centabit/core/localizations/app_localizations.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/data/models/transactions_chart_data.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_state.dart';
import 'package:centabit/features/dashboard/presentation/widgets/budget_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Budget report section displaying budget cards with BAR metric and charts.
///
/// Shows a PageView of budget cards, each displaying:
/// - Budget name (e.g., "Active Budget: December 2025")
/// - BAR (Budget Available Ratio) with info icon and animated value
/// - Animated progress bar (changes color when BAR > 1.2)
/// - Bar chart (allocations vs transactions per category)
/// - Page indicators (animated dots)
///
/// **Ported from v0.4**: `lib/ui/budget/budget_report_section.dart`
/// **Adaptations for v0.5**:
/// - Replaced `ValueListenableBuilder` with `BlocBuilder<DashboardCubit, DashboardState>`
/// - Removed `AppTextStyles` dependency (uses theme text styles)
/// - Removed `wrapperPadding` constant (uses EdgeInsets.symmetric directly)
/// - Uses Material 3 theme colors and v0.5 spacing system
/// - Maintains all animations and visual design
///
/// **Features**:
/// 1. **Multiple Budget Support**: PageView with indicators for swiping between budgets
/// 2. **BAR Animation**: TweenAnimationBuilder animates value from 0 to actual (600ms)
/// 3. **Color Animation**: Progress bar animates to error color when BAR > 1.2
/// 4. **Touch Response**: Prevents navbar hiding with NotificationListener
/// 5. **Info Dialog**: Tap "BAR ?" to show detailed explanation
/// 6. **Empty State**: Shows "No data" message when no budgets exist
///
/// **Layout**:
/// ```
/// ┌──────────────────────────────────┐
/// │ Active Budget: December 2025     │  <- Budget name
/// │                                  │
/// │ BAR ?           0.850            │  <- BAR metric (info icon + value)
/// │ [===============          ]      │  <- Animated progress bar
/// │                                  │
/// │ ┌────────────────────────────┐ │
/// │ │  ● Budget  ● Transactions  │ │  <- Chart legend
/// │ │   ││  ││  ││  ││           │ │  <- Bar chart
/// │ │   🛒  🍔  🚗  💊           │ │  <- Category icons
/// │ └────────────────────────────┘ │
/// │                                  │
/// │        ● ━━ ●                    │  <- Page indicators
/// └──────────────────────────────────┘
/// ```
///
/// **Usage**:
/// ```dart
/// BlocProvider(
///   create: (_) => getIt<DashboardCubit>(),
///   child: BudgetReportSection(),
/// )
/// ```
class BudgetReportSection extends StatefulWidget {
  const BudgetReportSection({super.key});

  @override
  State<BudgetReportSection> createState() => _BudgetReportSectionState();
}

class _BudgetReportSectionState extends State<BudgetReportSection> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    _pageController.addListener(() {
      final next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() => _currentPage = next);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Builds page indicator dots for PageView navigation.
  ///
  /// **Visual Design**:
  /// - Active dot: 24x8px, higher opacity (110)
  /// - Inactive dot: 8x8px, lower opacity (60)
  /// - 4px spacing between dots
  /// - Animated width transition (200ms)
  ///
  /// **Parameters**:
  /// - `index`: Current active page index
  /// - `pageCount`: Total number of pages
  ///
  /// **Returns**: Row of animated indicators, or empty if single page
  Widget _buildPageIndicator(int index, int pageCount) {
    if (pageCount <= 1) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: isActive ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.onSurface.withValues(alpha: 0.43)
                : colorScheme.onSurface.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return state.when(
          // Initial state: show nothing
          initial: () => const SizedBox.shrink(),

          // Loading state: show loading indicator
          loading: () => Container(
            width: double.infinity,
            height: 330.0,
            padding: EdgeInsets.symmetric(horizontal: spacing.sm),
            child: const Center(child: CircularProgressIndicator()),
          ),

          // Success state: show budget cards
          success: (budgetPages, monthlyOverview) {
            const height = 300.0;

            // Empty state: no budgets or no chart data
            if (budgetPages.isEmpty || budgetPages.first.chartData.isEmpty) {
              return Container(
                width: double.infinity,
                height: height,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                ),
                child: Center(
                  child: Text(
                    l10n.noData,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            }

            // Budget cards with PageView
            return NotificationListener(
              onNotification: (notification) {
                // Prevent navbar from hiding when scrolling budget pages
                return true;
              },
              child: Container(
                width: double.infinity,
                height: height,
                padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: budgetPages.length,
                        itemBuilder: (context, index) {
                          final page = budgetPages[index];
                          return _BudgetPageContent(
                            monthTitle: l10n.activeBudget(page.budget.name),
                            barIndexValue: page.barIndexValue,
                            data: page.chartData,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPageIndicator(_currentPage, budgetPages.length),
                  ],
                ),
              ),
            );
          },

          // Error state: show error message
          error: (message) => Container(
            width: double.infinity,
            height: 330.0,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              child: Text(
                'Error: $message',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colorScheme.error),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Content for a single budget page in the PageView.
///
/// Displays:
/// - Budget name heading
/// - BAR metric with info icon
/// - Animated BAR value
/// - Animated progress bar (color changes at threshold)
/// - Bar chart with allocations vs transactions
///
/// **Ported from v0.4**: Internal `_BudgetPageContent` class
class _BudgetPageContent extends StatelessWidget {
  /// Budget name heading (e.g., "Active Budget: December 2025").
  final String monthTitle;

  /// BAR (Budget Available Ratio) value.
  ///
  /// Animates from 0 to this value over 600ms.
  final double barIndexValue;

  /// Chart data for all categories.
  final List<TransactionsChartData> data;

  const _BudgetPageContent({
    required this.monthTitle,
    required this.barIndexValue,
    required this.data,
  });

  /// Shows BAR info dialog with detailed explanation.
  ///
  /// **Dialog Content**:
  /// - Title: "Budget Available Ratio (BAR)"
  /// - BAR definition
  /// - Usage explanation
  /// - Key rule: "Stay below 1.0"
  /// - Higher/lower explanation
  /// - Update frequency note
  /// - "GOT IT" button to close
  ///
  /// **Localized**: All strings from AppLocalizations
  void _showBarInfoDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            l10n.barFull,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BAR definition
                Text(l10n.barDefinition, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),

                // Usage explanation
                Text(l10n.barUsageExplanation, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),

                // Key Rule
                Text(
                  l10n.barKeyRule,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Higher/Lower explanation
                Text(
                  l10n.barHigherLowerExplanation,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),

                // Update frequency
                Text(l10n.barUpdateFrequency, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.gotIt),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Budget name heading
        Text(
          monthTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // BAR INDEX ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // BAR label with info icon
            InkWell(
              onTap: () => _showBarInfoDialog(context),
              child: Row(
                children: [
                  Text(l10n.bar, style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 4),
                  const Icon(TablerIcons.questionMark, size: 18),
                ],
              ),
            ),

            // Animated BAR value
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: barIndexValue),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Text(
                  value.toStringAsFixed(3),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),

        // ANIMATED PROGRESS BAR
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: barIndexValue),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            // Clamp width to max 1.0, but keep raw value for color logic
            final double widthFactor = value.clamp(0.0, 1.0);

            // Animate color: error if > 1.2, else onSurface
            final Color targetColor = value > 1.2
                ? colorScheme.error
                : colorScheme.onSurface;

            return TweenAnimationBuilder<Color?>(
              tween: ColorTween(begin: colorScheme.onSurface, end: targetColor),
              duration: const Duration(milliseconds: 400),
              builder: (context, color, _) {
                return Container(
                  width: double.infinity,
                  height: 24,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.31),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [color!, color],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 16),

        // BAR CHART
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.5),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.04),
                  spreadRadius: 2,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: BudgetBarChart(data: data),
          ),
        ),
      ],
    );
  }
}
