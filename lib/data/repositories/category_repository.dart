import 'dart:async';
import 'package:centabit/core/logging/interceptors/repository_logger.dart';
import 'package:centabit/data/local/category_local_source.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/data/local/database.dart' as db;
import 'package:drift/drift.dart';

/// Repository for category data (local-only for now)
///
/// Responsibilities:
/// 1. Coordinate LocalSource (and future RemoteSource)
/// 2. Emit broadcast streams (like v0.5 services)
/// 3. Transform Drift entities ↔ Domain Models
/// 4. Manage sync queue (stub for now - no API yet)
class CategoryRepository with RepositoryLogger {
  @override
  String get repositoryName => 'CategoryRepository';
  final CategoryLocalSource _localSource;

  final _categoriesController =
      StreamController<List<CategoryModel>>.broadcast();
  StreamSubscription? _dbSubscription;

  CategoryRepository(this._localSource) {
    _subscribeToLocalChanges();
  }

  /// Public stream (like v0.5 services)
  Stream<List<CategoryModel>> get categoriesStream =>
      _categoriesController.stream;

  /// Synchronous getter for immediate access (like v0.5 services)
  List<CategoryModel> get categories => _latestCategories;

  List<CategoryModel> _latestCategories = [];

  /// Subscribe to Drift's reactive queries
  void _subscribeToLocalChanges() {
    _dbSubscription = _localSource.watchAllCategories().listen((dbCategories) {
      final models = dbCategories.map(_mapToModel).toList();
      _latestCategories = models; // Cache for synchronous getter
      _categoriesController.add(models);
    });
  }

  /// Map Drift entity → Domain model
  CategoryModel _mapToModel(db.Category dbCategory) {
    return CategoryModel(
      id: dbCategory.id,
      name: dbCategory.name,
      iconName: dbCategory.iconName,
      createdAt: dbCategory.createdAt,
      updatedAt: dbCategory.updatedAt,
    );
  }

  /// Map Domain model → Drift entity
  db.Category _mapToDbModel(CategoryModel model) {
    return db.Category(
      id: model.id,
      userId: _localSource.userId,
      name: model.name,
      iconName: model.iconName,
      colorHex: '#000000', // Default color - CategoryModel doesn't have this yet
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isSynced: false,
      isDeleted: false,
      lastSyncedAt: null,
    );
  }

  /// Create category (optimistic update - local only for now)
  Future<void> createCategory(CategoryModel model) async {
    return trackRepositoryOperation(
      operation: 'createCategory',
      execute: () async {
        await _localSource.createCategory(
          db.CategoriesCompanion.insert(
            id: model.id,
            userId: _localSource.userId,
            name: model.name,
            iconName: model.iconName,
            colorHex: '#000000', // Default color
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            isSynced: const Value(false), // Ready for future API sync
          ),
        );

        // TODO: When API is ready, trigger background sync in isolate
      },
      metadata: {'categoryId': model.id, 'name': model.name},
    );
  }

  /// Update category
  Future<void> updateCategory(CategoryModel model) async {
    return trackRepositoryOperation(
      operation: 'updateCategory',
      execute: () async {
        final updatedModel = model.copyWith(updatedAt: DateTime.now());
        await _localSource.updateCategory(_mapToDbModel(updatedModel));

        // TODO: When API is ready, trigger background sync in isolate
      },
      metadata: {'categoryId': model.id},
    );
  }

  /// Delete category (soft delete)
  Future<void> deleteCategory(String id) async {
    return trackRepositoryOperation(
      operation: 'deleteCategory',
      execute: () async {
        await _localSource.deleteCategory(id);

        // TODO: When API is ready, trigger background sync in isolate
      },
      metadata: {'categoryId': id},
    );
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    return trackRepositoryOperation(
      operation: 'getCategoryById',
      execute: () async {
        final dbCategory = await _localSource.getCategoryById(id);
        return dbCategory != null ? _mapToModel(dbCategory) : null;
      },
      metadata: {'categoryId': id},
    );
  }

  /// Get category by ID (synchronous - from cache)
  CategoryModel? getCategoryByIdSync(String id) {
    return trackRepositoryOperationSync(
      operation: 'getCategoryByIdSync',
      execute: () {
        try {
          return _latestCategories.firstWhere((cat) => cat.id == id);
        } catch (e) {
          return null;
        }
      },
      metadata: {'categoryId': id},
    );
  }

  /// Sync stub (ready for future API)
  Future<void> sync() async {
    return trackRepositoryOperation(
      operation: 'sync',
      execute: () async {
        // TODO: Implement API sync in isolate when backend is ready
        // For now, this is a stub
      },
    );
  }

  void dispose() {
    _dbSubscription?.cancel();
    _categoriesController.close();
  }
}
