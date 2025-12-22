import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Enum for navigation action types based on current tab
enum NavActionType { none, addTransaction, addBudget }

/// Navigation state containing the selected tab index, action type, and search state
class NavState {
  /// Currently selected tab index (0: Dashboard, 1: Transactions, 2: Budgets)
  final int selectedIndex;

  /// Action type to display in FAB based on current tab
  final NavActionType actionType;

  /// Whether search is enabled on the current page
  final bool searchEnabled;

  /// Whether search mode is currently active
  final bool isSearching;

  /// Current search query text
  final String searchQuery;

  /// Context for search placeholder (e.g., "transactions", "dashboard")
  final String searchScope;

  /// Whether the navigation bar is visible (for auto-hide on scroll)
  final bool isNavBarVisible;

  const NavState({
    required this.selectedIndex,
    required this.actionType,
    this.searchEnabled = false,
    this.isSearching = false,
    this.searchQuery = '',
    this.searchScope = '',
    this.isNavBarVisible = true,
  });

  /// Create a copy of this state with optional field replacements
  NavState copyWith({
    int? selectedIndex,
    NavActionType? actionType,
    bool? searchEnabled,
    bool? isSearching,
    String? searchQuery,
    String? searchScope,
    bool? isNavBarVisible,
  }) {
    return NavState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      actionType: actionType ?? this.actionType,
      searchEnabled: searchEnabled ?? this.searchEnabled,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchScope: searchScope ?? this.searchScope,
      isNavBarVisible: isNavBarVisible ?? this.isNavBarVisible,
    );
  }
}

/// Cubit for managing bottom navigation bar state and search functionality
///
/// Handles:
/// - Tab selection and corresponding action button display
/// - Search mode toggling with haptic feedback
/// - Search query management
/// - Page-level search capability control
class NavCubit extends Cubit<NavState> {
  NavCubit()
    : super(
        const NavState(
          selectedIndex: 0,
          actionType: NavActionType.addTransaction,
        ),
      );

  /// Update the selected tab and corresponding action type
  void updateTab(int index) {
    final actionType = switch (index) {
      0 => NavActionType.addTransaction, // Dashboard
      1 => NavActionType.addTransaction, // Transactions
      2 => NavActionType.addBudget, // Budgets
      _ => NavActionType.none,
    };

    // Determine search config based on tab
    final (searchEnabled, searchScope) = switch (index) {
      1 => (true, 'transactions'), // Transactions page has search
      _ => (false, ''), // Other pages don't have search
    };

    // Update all nav state when switching tabs
    emit(
      state.copyWith(
        selectedIndex: index,
        actionType: actionType,
        searchEnabled: searchEnabled,
        isSearching: false,
        searchQuery: '',
        searchScope: searchScope,
        isNavBarVisible: true, // Always show nav bar when changing tabs
      ),
    );
  }

  /// Enable or disable search capability for the current page
  void enableSearch(bool enabled, {String scope = ''}) {
    emit(state.copyWith(searchEnabled: enabled, searchScope: scope));
  }

  /// Toggle between search mode and navigation mode with haptic feedback
  void toggleSearchMode() {
    HapticFeedback.lightImpact();
    emit(state.copyWith(isSearching: !state.isSearching));
  }

  /// Update the current search query
  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Clear search and return to navigation mode
  void clearSearch() {
    emit(state.copyWith(isSearching: false, searchQuery: ''));
  }

  /// Set navigation bar visibility (for auto-hide on scroll)
  void setNavBarVisible(bool visible) {
    // Early return prevents unnecessary emissions
    if (state.isNavBarVisible == visible) return;
    emit(state.copyWith(isNavBarVisible: visible));
  }
}
