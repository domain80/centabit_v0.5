import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'allocation_model.freezed.dart';
part 'allocation_model.g.dart';

@freezed
abstract class AllocationModel with _$AllocationModel {
  const factory AllocationModel({
    required String id,
    required String name,
    required String categoryId,
    required String budgetId,
    required double amount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AllocationModel;

  factory AllocationModel.fromJson(Map<String, dynamic> json) =>
      _$AllocationModelFromJson(json);

  factory AllocationModel.create({
    required String name,
    required String categoryId,
    required String budgetId,
    required double amount,
  }) {
    final now = DateTime.now();
    return AllocationModel(
      id: const Uuid().v4(),
      name: name,
      categoryId: categoryId,
      budgetId: budgetId,
      amount: amount,
      createdAt: now,
      updatedAt: now,
    );
  }
}
