import 'package:centabit/shared/v_models/transaction_v_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_list_state.freezed.dart';

@freezed
abstract class TransactionListState with _$TransactionListState {
  const factory TransactionListState.initial() = _Initial;

  const factory TransactionListState.loading() = _Loading;

  const factory TransactionListState.success({
    required List<TransactionVModel> transactions,
    required int currentPage,
    required bool hasMore,
  }) = _Success;

  const factory TransactionListState.error(String message) = _Error;
}
