import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:centabit/data/models/transaction_model.dart';

part 'transaction_v_model.freezed.dart';

@freezed
abstract class TransactionVModel with _$TransactionVModel {
  const factory TransactionVModel({
    required String id,
    required String name,
    required double amount,
    required TransactionType type,
    required DateTime transactionDate,
    required String formattedDate,
    String? categoryId,
    String? categoryName,
    String? categoryIconName,
    String? notes,
  }) = _TransactionVModel;
}
