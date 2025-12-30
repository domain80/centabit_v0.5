import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_form_state.freezed.dart';

/// State for budget form management
///
/// Union type states:
/// - initial: Form not yet submitted
/// - loading: Submitting budget and allocations to repositories
/// - success: Budget created/updated/deleted successfully (triggers modal close)
/// - error: Submission failed with error message (keeps form open)
///
/// **State Flow**:
/// ```
/// initial → (user fills form) → (user taps Save)
///   ↓
/// loading → (validation + repository operations)
///   ↓
/// success (close modal) OR error (show message, keep form open)
/// ```
///
/// **Error Handling**:
/// When in error state, the form remains open so users can:
/// - See what went wrong
/// - Fix validation issues
/// - Retry submission
///
/// **Success Handling**:
/// When in success state, BlocListener:
/// - Shows success toast
/// - Closes modal
/// - BudgetListCubit auto-reloads via stream subscription
@freezed
class BudgetFormState with _$BudgetFormState {
  /// Initial state before form submission.
  ///
  /// Form is ready for user input.
  ///
  /// **rebuildCounter**: Incremented on each state emission to force UI rebuild
  /// (needed because this state has no other fields, so all instances would be equal)
  const factory BudgetFormState.initial({@Default(0) int rebuildCounter}) = _Initial;

  /// Loading state during form submission.
  ///
  /// Shown when:
  /// - Creating new budget with allocations
  /// - Updating existing budget and allocations
  /// - Deleting budget (cascades to allocations)
  ///
  /// **Atomic Operations**:
  /// - Create: budget first, then allocations (rollback on failure)
  /// - Update: budget and allocations together (diff and apply changes)
  /// - Delete: budget (cascades to allocations via repository)
  const factory BudgetFormState.loading() = _Loading;

  /// Success state after successful submission.
  ///
  /// Triggers modal close and success toast.
  ///
  /// **Post-Success Flow**:
  /// - BlocListener shows toast
  /// - Navigator.pop() closes modal
  /// - BudgetListCubit reloads via budgetsStream subscription
  /// - User sees updated list
  const factory BudgetFormState.success() = _Success;

  /// Error state when submission fails.
  ///
  /// Form stays open to allow correction and retry.
  ///
  /// **Common Error Scenarios**:
  /// - Validation failed (name empty, dates invalid, allocations over budget)
  /// - Repository operation failed
  /// - Rollback occurred (budget created but allocations failed)
  ///
  /// **Parameters**:
  /// - `message`: User-friendly error description
  const factory BudgetFormState.error(String message) = _Error;
}
