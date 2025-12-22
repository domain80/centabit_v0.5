import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String iconName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.create({
    required String name,
    required String iconName,
  }) {
    final now = DateTime.now();
    return CategoryModel(
      id: const Uuid().v4(),
      name: name,
      iconName: iconName,
      createdAt: now,
      updatedAt: now,
    );
  }
}
