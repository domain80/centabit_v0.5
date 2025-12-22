import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

/*
  we want the model to have everything the view will need to render a component;
  i.e. the view must not make additional calls to other viewModels to render out a transaction
  - categoryIconName -- changes with the change of the categoryId
  - categoryId
  this will not work cause if the category itself changes,
  there will be no way to know to update the view

  so instead, we gotta make sure that the view-model supplies the view

*/

@freezed
abstract class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String name,
    required double amount,
    String? categoryId,
    String? budgetId,
    required DateTime transactionDate,
    required TransactionType type,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

  factory TransactionModel.create({
    required String name,
    required double amount,
    required TransactionType type,
    DateTime? transactionDate,
    String? categoryId,
    String? budgetId,
    String? notes,
  }) {
    final now = DateTime.now();
    return TransactionModel(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      transactionDate: transactionDate ?? now,
      categoryId: categoryId,
      type: type,
      budgetId: budgetId,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }
}

enum TransactionType { credit, debit }
