import 'dart:async';
import 'package:centabit/data/models/category_model.dart';

class CategoryService {
  final List<CategoryModel> _categories = [];
  final _categoriesController = StreamController<List<CategoryModel>>.broadcast();

  Stream<List<CategoryModel>> get categoriesStream => _categoriesController.stream;

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  CategoryService() {
    _initializeDefaultCategories();
  }

  void _initializeDefaultCategories() {
    final defaults = [
      CategoryModel.create(name: 'Groceries', iconName: 'basket'),
      CategoryModel.create(name: 'Entertainment', iconName: 'device_tv'),
      CategoryModel.create(name: 'Transport', iconName: 'car'),
      CategoryModel.create(name: 'Utilities', iconName: 'bolt'),
      CategoryModel.create(name: 'Healthcare', iconName: 'pill'),
      CategoryModel.create(name: 'Education', iconName: 'book'),
      CategoryModel.create(name: 'Dining', iconName: 'utensils'),
      CategoryModel.create(name: 'Shopping', iconName: 'shopping_bag'),
      CategoryModel.create(name: 'Coffee', iconName: 'coffee'),
      CategoryModel.create(name: 'Gas & Fuel', iconName: 'fuel'),
    ];
    _categories.addAll(defaults);
    _emitCategories();
  }

  Future<void> createCategory(CategoryModel category) async {
    _categories.add(category);
    _emitCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category.copyWith(updatedAt: DateTime.now());
      _emitCategories();
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    _emitCategories();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void _emitCategories() {
    _categoriesController.add(List.unmodifiable(_categories));
  }

  void dispose() {
    _categoriesController.close();
  }
}
