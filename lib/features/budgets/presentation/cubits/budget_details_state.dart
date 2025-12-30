import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_details_vmodel.dart';

part 'budget_details_state.freezed.dart';

@freezed
class BudgetDetailsState with _$BudgetDetailsState {
  const factory BudgetDetailsState.initial() = _Initial;
  const factory BudgetDetailsState.loading() = _Loading;
  const factory BudgetDetailsState.success({
    required BudgetDetailsVModel details,
  }) = _Success;
  const factory BudgetDetailsState.error(String message) = _Error;
}
