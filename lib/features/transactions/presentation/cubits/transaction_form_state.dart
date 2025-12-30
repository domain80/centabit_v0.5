import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_form_state.freezed.dart';

/// State for transaction form management
///
/// Union type states:
/// - initial: Form not yet submitted
/// - loading: Submitting transaction to repository
/// - success: Transaction created/updated/deleted successfully
/// - error: Submission failed with error message
@freezed
class TransactionFormState with _$TransactionFormState {
  const factory TransactionFormState.initial() = _Initial;
  const factory TransactionFormState.loading() = _Loading;
  const factory TransactionFormState.success() = _Success;
  const factory TransactionFormState.error(String message) = _Error;
}
