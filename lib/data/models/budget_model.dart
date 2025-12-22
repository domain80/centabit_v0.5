import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'budget_model.freezed.dart';
part 'budget_model.g.dart';

@freezed
abstract class BudgetModel with _$BudgetModel {
  const factory BudgetModel({
    required String id,
    required String name,
    required double total,
    required List<String> allocationIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BudgetModel;

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  factory BudgetModel.create({
    required String name,
    required double total,
    List<String>? allocationIds,
  }) {
    final now = DateTime.now();
    return BudgetModel(
      id: const Uuid().v4(),
      name: name,
      total: total,
      allocationIds: allocationIds ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }
}
