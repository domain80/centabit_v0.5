// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AllocationModel _$AllocationModelFromJson(Map<String, dynamic> json) =>
    _AllocationModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      budgetId: json['budgetId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AllocationModelToJson(_AllocationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'categoryId': instance.categoryId,
      'budgetId': instance.budgetId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
