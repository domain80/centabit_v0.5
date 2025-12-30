import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_form_state.freezed.dart';

/// State for category form (create/edit/delete)
///
/// Union type with four states:
/// - initial: Form not yet interacted with
/// - loading: Creating/updating/deleting category
/// - success: Operation completed successfully (triggers modal close)
/// - error: Operation failed with error message
@freezed
class CategoryFormState with _$CategoryFormState {
  const factory CategoryFormState.initial() = _Initial;
  const factory CategoryFormState.loading() = _Loading;
  const factory CategoryFormState.success() = _Success;
  const factory CategoryFormState.error(String message) = _Error;
}
