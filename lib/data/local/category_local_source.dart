import 'package:drift/drift.dart';
import 'package:centabit/data/local/database.dart';

/// Local data source for categories with userId filtering
///
/// All queries are automatically filtered by userId for security and multi-user support.
class CategoryLocalSource {
  final AppDatabase _db;
  final String userId; // CRITICAL: Injected userId for filtering

  CategoryLocalSource(this._db, this.userId);

  /// Reactive stream of all non-deleted categories FOR THIS USER
  Stream<List<Category>> watchAllCategories() {
    return (_db.select(_db.categories)
          ..where((c) =>
              c.userId.equals(userId) & // CRITICAL: Filter by userId
              c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Get single category FOR THIS USER
  Future<Category?> getCategoryById(String id) {
    return (_db.select(_db.categories)
          ..where((c) =>
              c.userId.equals(userId) & // CRITICAL: Filter by userId
              c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all categories (non-reactive) FOR THIS USER
  Future<List<Category>> getAllCategories() {
    return (_db.select(_db.categories)
          ..where((c) =>
              c.userId.equals(userId) & // CRITICAL: Filter by userId
              c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Create category (userId automatically added)
  Future<void> createCategory(CategoriesCompanion category) {
    // Ensure userId is set
    final withUser = category.copyWith(userId: Value(userId));
    return _db.into(_db.categories).insert(withUser);
  }

  /// Update category (userId check for security)
  Future<void> updateCategory(Category category) {
    if (category.userId != userId) {
      throw Exception('Cannot update category for different user');
    }
    return _db.update(_db.categories).replace(category);
  }

  /// Soft delete FOR THIS USER
  Future<void> deleteCategory(String id) {
    return (_db.update(_db.categories)
          ..where((c) =>
              c.userId.equals(userId) & // CRITICAL: Filter by userId
              c.id.equals(id)))
        .write(const CategoriesCompanion(isDeleted: Value(true)));
  }

  /// Get unsynced categories FOR THIS USER
  Future<List<Category>> getUnsyncedCategories() {
    return (_db.select(_db.categories)
          ..where((c) =>
              c.userId.equals(userId) & // CRITICAL: Filter by userId
              c.isSynced.equals(false)))
        .get();
  }

  /// Mark as synced FOR THIS USER
  Future<void> markAsSynced(String id) {
    return (_db.update(_db.categories)
          ..where((c) =>
              c.userId.equals(userId) & // CRITICAL: Filter by userId
              c.id.equals(id)))
        .write(CategoriesCompanion(
          isSynced: const Value(true),
          lastSyncedAt: Value(DateTime.now()),
        ));
  }
}
