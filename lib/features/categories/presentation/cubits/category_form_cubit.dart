import 'dart:async';

import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/features/categories/presentation/cubits/category_form_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Cubit for category form (create/edit/delete)
///
/// Manages:
/// - Icon search functionality with tags and display names
/// - Category name validation (required, unique)
/// - Create/update/delete operations via CategoryRepository
/// - Reactive updates from repository's categoriesStream
class CategoryFormCubit extends Cubit<CategoryFormState> {
  final CategoryRepository _categoryRepository;
  final GlobalKey<FormBuilderState> formKey;

  StreamSubscription? _categorySubscription;
  List<CategoryModel> _categories = [];

  /// IconSearcher instance for searching ALL TablerIcons (5000+)
  late final IconSearcher _iconSearcher;

  /// Filtered icon names based on search query
  List<String> _filteredIcons = [];

  /// Common category icons shown by default (max 20)
  static const _defaultIcons = [
    'shoppingCart',
    'toolsKitchen2',
    'home',
    'car',
    'firstAidKit',
    'deviceTv',
    'wallet',
    'coffee',
    'shirt',
    'plane',
    'book',
    'dumbbell',
    'gift',
    'heart',
    'phone',
    'laptop',
    'music',
    'camera',
    'briefcase',
    'receipt',
  ];

  CategoryFormCubit(this._categoryRepository)
      : formKey = GlobalKey<FormBuilderState>(),
        super(const CategoryFormState.initial()) {
    _subscribeToCategories();
    _initializeIconSearcher();
  }

  // Public getters for UI
  List<String> get filteredIcons => _filteredIcons;
  List<CategoryModel> get categories => _categories;

  /// Subscribe to category repository stream for reactive updates
  void _subscribeToCategories() {
    // Initialize with current value IMMEDIATELY (don't wait for stream)
    _categories = _categoryRepository.categories;

    _categorySubscription =
        _categoryRepository.categoriesStream.listen((categories) {
      _categories = categories;
    });
  }

  /// Initialize IconSearcher with full TablerIcons
  ///
  /// Sets up IconSearcher with ALL 5000+ icons and comprehensive tagsMap.
  /// Starts with default common category icons.
  void _initializeIconSearcher() {
    // Initialize IconSearcher with full TablerIcons
    _iconSearcher = IconSearcher(
      all: TablerIcons.all,        // ALL 5000+ icons
      tagsMap: TablerIcons.tagsMap, // ALL tags
    );

    // Start with common category icons
    _filteredIcons = _defaultIcons;
  }

  /// Search icons using IconSearcher - NO FILTERING
  ///
  /// Returns ALL matching icons from the full 5000+ icon set.
  /// Shows default common icons when query is empty.
  void searchIcons(String query) {
    if (query.isEmpty) {
      // Show default common category icons
      _filteredIcons = _defaultIcons;
    } else {
      // Use IconSearcher - returns ALL matching icons from 5000+ set
      // No filtering - users can select any icon
      final searchResults = _iconSearcher.search(query);

      // Deduplicate (safety measure, though IconSearcher shouldn't produce duplicates)
      _filteredIcons = searchResults.toSet().toList();
    }
    // Re-emit current state to trigger rebuild
    emit(state);
  }

  /// Validate category name (required, unique)
  String? validateName(String? value, {String? excludeId}) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    // Check for duplicate names (case-insensitive), excluding current category if editing
    final isDuplicate = _categories.any((c) =>
        c.name.toLowerCase() == value.toLowerCase() && c.id != excludeId);

    if (isDuplicate) {
      return 'Category name already exists';
    }

    return null; // Valid
  }

  /// Create new category
  Future<void> createCategory(String name, String iconName) async {
    if (!formKey.currentState!.saveAndValidate()) {
      return; // Validation failed
    }

    emit(const CategoryFormState.loading());

    try {
      final category = CategoryModel.create(
        name: name,
        iconName: iconName,
      );
      await _categoryRepository.createCategory(category);
      emit(const CategoryFormState.success());
    } catch (e) {
      emit(CategoryFormState.error('Failed to create category: $e'));
    }
  }

  /// Update existing category
  Future<void> updateCategory(String id, String name, String iconName) async {
    if (!formKey.currentState!.saveAndValidate()) {
      return; // Validation failed
    }

    emit(const CategoryFormState.loading());

    try {
      final existing = _categories.firstWhere((c) => c.id == id);
      final updated = existing.copyWith(
        name: name,
        iconName: iconName,
        updatedAt: DateTime.now(),
      );
      await _categoryRepository.updateCategory(updated);
      emit(const CategoryFormState.success());
    } catch (e) {
      emit(CategoryFormState.error('Failed to update category: $e'));
    }
  }

  /// Delete category
  Future<void> deleteCategory(String id) async {
    emit(const CategoryFormState.loading());
    try {
      await _categoryRepository.deleteCategory(id);
      emit(const CategoryFormState.success());
    } catch (e) {
      emit(CategoryFormState.error('Failed to delete category: $e'));
    }
  }

  @override
  Future<void> close() {
    _categorySubscription?.cancel();
    return super.close();
  }
}
