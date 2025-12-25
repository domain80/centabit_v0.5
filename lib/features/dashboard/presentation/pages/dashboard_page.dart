import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/localizations/app_localizations.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/data/services/transaction_service.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_state.dart';
import 'package:centabit/features/dashboard/presentation/widgets/budget_report_section.dart';
import 'package:centabit/features/dashboard/presentation/widgets/daily_transactions_section.dart';
import 'package:centabit/shared/widgets/shared_app_bar.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

/// Dashboard page - main screen displaying budget reports and daily transactions.
///
/// **Ported from v0.4 with complete feature set**:
/// - Budget Report Section: BAR metrics, charts, multiple budget support
/// - Daily Transactions Section: Date filtering with infinite scroller
/// - Pull-to-refresh functionality
/// - Waving hand animation in app bar
///
/// **Architecture**:
/// - Provides two cubits: DashboardCubit and DateFilterCubit
/// - DashboardCubit: Aggregates budget data from 4 services
/// - DateFilterCubit: Filters transactions by selected date
/// - Both cubits react to service changes via stream subscriptions
///
/// **Layout**:
/// ```
/// ┌──────────────────────────────────┐
/// │ 👋 Hi David                      │  <- App bar with waving hand
/// ├──────────────────────────────────┤
/// │ ┌────────────────────────────┐   │
/// │ │ Active Budget: Dec 2025    │   │  <- Budget Report Section
/// │ │ BAR ?            0.850     │   │     (330px height)
/// │ │ [===============      ]    │   │
/// │ │ 📊 Chart with bars         │   │
/// │ │        ● ━━ ●              │   │
/// │ └────────────────────────────┘   │
/// │                                  │
/// │ ┌────────────────────────────┐   │
/// │ │ Transactions         📅    │   │  <- Daily Transactions Section
/// │ ├────────────────────────────┤   │
/// │ │  Mon Tue Wed Thu Fri Sat   │   │     (Date scroller)
/// │ ├────────────────────────────┤   │
/// │ │ 🛒 Groceries    -$45.23    │   │     (Transaction tiles)
/// │ │ 🍔 Dining       -$28.50    │   │
/// │ └────────────────────────────┘   │
/// │                                  │
/// │              [120px bottom pad]  │  <- Space for nav bar
/// └──────────────────────────────────┘
/// ```
///
/// **Migration Notes**:
/// - v0.4 used Provider + Command pattern
/// - v0.5 uses BLoC + Cubit pattern
/// - All business logic ported from DashboardViewModel
/// - BAR calculation preserved exactly from v0.4
/// - Chart data building preserved from v0.4
/// - Date filtering logic follows TransactionListCubit pattern
///
/// **Usage**:
/// ```dart
/// // In router configuration
/// GoRoute(
///   path: '/',
///   builder: (context, state) => const DashboardPage(),
/// )
/// ```
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<DashboardCubit>()),
        BlocProvider(create: (_) => getIt<DateFilterCubit>()),
      ],
      child: const _DashboardView(),
    );
  }
}

/// Internal dashboard view with scaffold and content.
///
/// **Responsibilities**:
/// - App bar with waving hand animation
/// - Pull-to-refresh wrapper
/// - ScrollView with budget and transaction sections
/// - Bottom padding for navigation bar clearance
/// - Scroll position management (resets to top on date change)
class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  late final ScrollController _scrollController;
  DateTime? _previousDate;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Scaffold(
      appBar: sharedAppBar(
        context,
        title: Row(
          children: [
            _buildWavingHand(),
            SizedBox(width: spacing.sm),
            const Text('Hi David'), // TODO: User name from settings
          ],
        ),
      ),
      body: BlocListener<DateFilterCubit, DateFilterState>(
        listenWhen: (previous, current) =>
            previous.selectedDate != current.selectedDate,
        listener: (context, state) {
          // Reset scroll position to top when date changes
          if (_previousDate != null && _previousDate != state.selectedDate) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
          _previousDate = state.selectedDate;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh both cubits
            context.read<DashboardCubit>().refresh();
            // DateFilterCubit refreshes automatically via service streams
            await Future<void>.delayed(const Duration(milliseconds: 300));
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
            // Budget Report Section with BAR and charts
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const BudgetReportSection(),
                  SizedBox(height: spacing.lg),
                ],
              ),
            ),

            // Daily Transactions Section with sticky header
            BlocBuilder<DateFilterCubit, DateFilterState>(
              builder: (context, state) {
                final screenHeight = MediaQuery.of(context).size.height * 1.3;

                return SliverStickyHeader(
                  header: const DailyTransactionsStickyHeader(),
                  sliver: _buildTransactionSliver(context, state, screenHeight),
                );
              },
            ),

            // Bottom padding for navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        ),
      ),
    );
  }

  /// Builds the transaction list sliver with minimum height.
  ///
  /// **Empty State**: Shows centered message when no transactions exist
  /// **Transaction List**: Shows list of TransactionTile widgets
  ///
  /// **Min Height**: Ensures the section takes at least screen height to prevent
  /// layout shifts when switching between dates with different transaction counts
  ///
  /// **Delete Behavior**:
  /// - Swipe transaction tile left to reveal delete
  /// - Calls TransactionService.deleteTransaction()
  /// - DateFilterCubit automatically reacts to service change
  ///
  /// **Parameters**:
  /// - `context`: Build context
  /// - `state`: Current date filter state
  /// - `screenHeight`: Screen height for minimum constraint
  ///
  /// **Returns**: Sliver widget showing transactions or empty state
  Widget _buildTransactionSliver(
    BuildContext context,
    DateFilterState state,
    double screenHeight,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;

    // Calculate minimum height (screen height minus some space for header/navbar)
    final minContentHeight = screenHeight - 400;

    // Empty state: no transactions for selected date
    if (state.filteredTransactions.isEmpty) {
      return SliverToBoxAdapter(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minContentHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.xl,
              vertical: spacing.lg,
            ),
            child: Center(
              child: Text(
                l10n.noTransactionsForDate,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Transaction list
    final transactionService = getIt<TransactionService>();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
      sliver: SliverConstrainedCrossAxis(
        maxExtent: double.infinity,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            // Add minimum height constraint to the list
            if (index == 0) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: minContentHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.filteredTransactions
                      .map(
                        (transaction) => TransactionTile(
                          transaction: transaction,
                          onDelete: () {
                            transactionService.deleteTransaction(
                              transaction.id,
                            );
                          },
                          onEdit: null, // TODO: Navigate to edit form
                          onCopy: null, // TODO: Duplicate transaction
                        ),
                      )
                      .toList(),
                ),
              );
            }
            return const SizedBox.shrink();
          }, childCount: 1),
        ),
      ),
    );
  }

  /// Builds animated waving hand emoji.
  ///
  /// **Animation**:
  /// - Duration: 2 seconds (2 complete waves)
  /// - Motion: Back-forth-back-forth rotation
  /// - Angle: 0 to 0.3 radians (~17 degrees)
  /// - Origin: Offset(12, 0) for natural wrist pivot
  ///
  /// **Ported from v0.4**: Original dashboard waving hand animation
  ///
  /// **Pattern**: TweenAnimationBuilder for one-time animation on load
  ///
  /// **Returns**: Animated Text widget with waving hand emoji
  static TweenAnimationBuilder<double> _buildWavingHand() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2), // 2 waves total
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // Creates back-forth-back-forth motion
        // value goes 0 -> 1 over 2 seconds
        // wave: 0 -> 4 (represents 4 half-waves = 2 complete waves)
        final wave = (value * 4);

        // Convert to triangle wave (0 -> 1 -> 0 -> 1 -> 0)
        final t = wave <= 2
            ? (wave <= 1 ? wave : 2 - wave) // First wave: 0 -> 1 -> 0
            : (wave <= 3 ? wave - 2 : 4 - wave); // Second wave: 0 -> 1 -> 0

        return Transform.rotate(
          angle: 0.3 * t, // Max rotation: ~17 degrees
          origin: const Offset(12, 0), // Pivot point (wrist)
          child: child,
        );
      },
      child: const Text("👋"),
    );
  }
}
