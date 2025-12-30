import 'dart:async';

import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/features/categories/presentation/cubits/category_form_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Searchable icon with tags and display name
class SearchableIcon {
  final String name;
  final String displayName;
  final List<String> tags;

  const SearchableIcon({
    required this.name,
    required this.displayName,
    required this.tags,
  });
}

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
  List<SearchableIcon> _availableIcons = [];
  List<String> _filteredIcons = [];

  CategoryFormCubit(this._categoryRepository)
      : formKey = GlobalKey<FormBuilderState>(),
        super(const CategoryFormState.initial()) {
    _subscribeToCategories();
    _initializeIcons();
  }

  // Public getters for UI
  List<String> get filteredIcons => _filteredIcons;
  List<CategoryModel> get categories => _categories;

  /// Subscribe to category repository stream for reactive updates
  void _subscribeToCategories() {
    // Initialize with current value IMMEDIATELY (don't wait for stream)
    _categories = _categoryRepository.categories;
    print('🟢 CategoryFormCubit initialized with ${_categories.length} categories');

    _categorySubscription =
        _categoryRepository.categoriesStream.listen((categories) {
      _categories = categories;
      print('🟢 CategoryFormCubit updated via stream: ${_categories.length} categories');
    });
  }

  /// Initialize available icons with searchable tags
  void _initializeIcons() {
    _availableIcons = [
      const SearchableIcon(name: 'shoppingCart', displayName: 'Shopping Cart', tags: ['shopping', 'cart', 'groceries', 'store', 'retail', 'supermarket', 'buy']),
      const SearchableIcon(name: 'toolsKitchen2', displayName: 'Kitchen', tags: ['kitchen', 'food', 'cooking', 'dining', 'restaurant', 'meal', 'eat']),
      const SearchableIcon(name: 'home', displayName: 'Home', tags: ['home', 'house', 'rent', 'mortgage', 'property', 'utilities']),
      const SearchableIcon(name: 'car', displayName: 'Car', tags: ['car', 'transport', 'vehicle', 'gas', 'fuel', 'auto', 'drive', 'parking']),
      const SearchableIcon(name: 'firstAidKit', displayName: 'Medical', tags: ['medical', 'health', 'doctor', 'hospital', 'medicine', 'healthcare', 'pharmacy']),
      const SearchableIcon(name: 'deviceTv', displayName: 'Entertainment', tags: ['entertainment', 'tv', 'movies', 'streaming', 'netflix', 'fun', 'leisure']),
      const SearchableIcon(name: 'category', displayName: 'Category', tags: ['category', 'general', 'other', 'misc', 'miscellaneous']),
      const SearchableIcon(name: 'wallet', displayName: 'Wallet', tags: ['wallet', 'money', 'cash', 'finance', 'bank', 'savings', 'budget']),
      const SearchableIcon(name: 'coffee', displayName: 'Coffee', tags: ['coffee', 'cafe', 'drink', 'beverage', 'tea', 'breakfast']),
      const SearchableIcon(name: 'gas', displayName: 'Gas Station', tags: ['gas', 'fuel', 'petrol', 'station', 'car', 'transport']),
      const SearchableIcon(name: 'shirt', displayName: 'Clothing', tags: ['clothing', 'clothes', 'fashion', 'apparel', 'shopping', 'wardrobe', 'outfit']),
      const SearchableIcon(name: 'plane', displayName: 'Travel', tags: ['travel', 'flight', 'vacation', 'trip', 'holiday', 'tourism', 'airplane']),
      const SearchableIcon(name: 'book', displayName: 'Education', tags: ['education', 'book', 'study', 'school', 'learning', 'reading', 'course']),
      const SearchableIcon(name: 'dumbbell', displayName: 'Fitness', tags: ['fitness', 'gym', 'exercise', 'workout', 'health', 'sport', 'training']),
      const SearchableIcon(name: 'gift', displayName: 'Gifts', tags: ['gift', 'present', 'celebration', 'birthday', 'party', 'surprise']),
      const SearchableIcon(name: 'heart', displayName: 'Personal Care', tags: ['personal', 'care', 'beauty', 'health', 'wellness', 'self-care']),
      const SearchableIcon(name: 'phone', displayName: 'Phone', tags: ['phone', 'mobile', 'cell', 'communication', 'bills', 'subscription']),
      const SearchableIcon(name: 'laptop', displayName: 'Electronics', tags: ['electronics', 'computer', 'tech', 'technology', 'gadgets', 'devices']),
      const SearchableIcon(name: 'music', displayName: 'Music', tags: ['music', 'audio', 'streaming', 'spotify', 'entertainment', 'concert']),
      const SearchableIcon(name: 'camera', displayName: 'Photography', tags: ['photography', 'camera', 'photo', 'pictures', 'hobby']),
      const SearchableIcon(name: 'briefcase', displayName: 'Business', tags: ['business', 'work', 'office', 'professional', 'job', 'career']),
      const SearchableIcon(name: 'creditCard', displayName: 'Credit Card', tags: ['credit', 'card', 'payment', 'finance', 'banking', 'debt']),
      const SearchableIcon(name: 'piggyBank', displayName: 'Savings', tags: ['savings', 'save', 'piggy', 'bank', 'money', 'invest', 'future']),
      const SearchableIcon(name: 'receipt', displayName: 'Bills', tags: ['bills', 'receipt', 'invoice', 'expenses', 'payment', 'utilities']),
    ];
    _filteredIcons = _availableIcons.map((icon) => icon.name).toList();
  }

  /// Search/filter icons by query (searches name, displayName, and tags)
  void searchIcons(String query) {
    if (query.isEmpty) {
      _filteredIcons = _availableIcons.map((icon) => icon.name).toList();
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredIcons = _availableIcons
          .where((icon) {
            // Search in technical name
            if (icon.name.toLowerCase().contains(lowerQuery)) return true;
            // Search in display name
            if (icon.displayName.toLowerCase().contains(lowerQuery)) return true;
            // Search in tags
            if (icon.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))) {
              return true;
            }
            return false;
          })
          .map((icon) => icon.name)
          .toList();
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
    print('🟢 CategoryFormCubit.createCategory called');
    print('🟢 Name: "$name", Icon: "$iconName"');

    if (!formKey.currentState!.saveAndValidate()) {
      print('🔴 Form validation FAILED in cubit');
      return; // Validation failed
    }
    print('🟢 Form validation PASSED in cubit');

    print('🟢 Emitting loading state');
    emit(const CategoryFormState.loading());

    try {
      print('🟢 Creating category model');
      final category = CategoryModel.create(
        name: name,
        iconName: iconName,
      );
      print('🟢 Category model created: $category');

      print('🟢 Calling repository.createCategory');
      await _categoryRepository.createCategory(category);

      print('🟢 Repository call successful, emitting success state');
      emit(const CategoryFormState.success());
    } catch (e, stackTrace) {
      print('🔴 Error creating category: $e');
      print('🔴 Stack trace: $stackTrace');
      emit(CategoryFormState.error('Failed to create category: $e'));
    }
  }

  /// Update existing category
  Future<void> updateCategory(String id, String name, String iconName) async {
    print('🟢 CategoryFormCubit.updateCategory called');
    print('🟢 ID: "$id", Name: "$name", Icon: "$iconName"');

    if (!formKey.currentState!.saveAndValidate()) {
      print('🔴 Form validation FAILED in updateCategory');
      return; // Validation failed
    }

    print('🟢 Emitting loading state');
    emit(const CategoryFormState.loading());

    try {
      print('🟢 Finding existing category with ID: $id');
      print('🟢 Available categories: ${_categories.map((c) => c.id).toList()}');

      final existing = _categories.firstWhere((c) => c.id == id);
      print('🟢 Found existing category: ${existing.name}');

      final updated = existing.copyWith(
        name: name,
        iconName: iconName,
        updatedAt: DateTime.now(),
      );
      print('🟢 Calling repository.updateCategory');
      await _categoryRepository.updateCategory(updated);

      print('🟢 Repository call successful, emitting success state');
      emit(const CategoryFormState.success());
    } catch (e, stackTrace) {
      print('🔴 Error updating category: $e');
      print('🔴 Stack trace: $stackTrace');
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
