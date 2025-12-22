import 'package:flutter_bloc/flutter_bloc.dart';

/// Enum for navigation action types based on current tab
enum NavActionType { none, addTransaction, addBudget }

/// Navigation state containing the selected tab index and action type
class NavState {
  /// Currently selected tab index (0: Dashboard, 1: Transactions, 2: Budgets)
  final int selectedIndex;

  /// Action type to display in FAB based on current tab
  final NavActionType actionType;

  const NavState({
    required this.selectedIndex,
    required this.actionType,
  });
}

/// Cubit for managing bottom navigation bar state
///
/// Handles tab selection and determines which action button to display
class NavCubit extends Cubit<NavState> {
  NavCubit()
      : super(const NavState(
          selectedIndex: 0,
          actionType: NavActionType.addTransaction,
        ));

  /// Update the selected tab and corresponding action type
  void updateTab(int index) {
    final actionType = switch (index) {
      0 => NavActionType.addTransaction, // Dashboard
      1 => NavActionType.addTransaction, // Transactions
      2 => NavActionType.addBudget, // Budgets
      _ => NavActionType.none,
    };

    emit(NavState(
      selectedIndex: index,
      actionType: actionType,
    ));
  }
}
