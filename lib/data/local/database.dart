import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Transactions table
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // CRITICAL: Filter by userId
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get budgetId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync metadata
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, id}, // Composite unique constraint
  ];
}

// Categories table
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // CRITICAL: Filter by userId
  TextColumn get name => text()();
  TextColumn get iconName => text()();
  TextColumn get colorHex => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync metadata
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, id},
  ];
}

// Budgets table
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // CRITICAL: Filter by userId
  TextColumn get name => text()();
  RealColumn get amount => real()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync metadata
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, id},
  ];
}

// Allocations table
class Allocations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // CRITICAL: Filter by userId
  TextColumn get budgetId => text()();
  TextColumn get categoryId => text()();
  RealColumn get amount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync metadata
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, id},
  ];
}

// Sync queue for offline changes
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()(); // CRITICAL: Filter by userId
  TextColumn get entityType => text()(); // "transaction", "budget", etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()(); // JSON-encoded entity
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

// Database class
@DriftDatabase(
  tables: [Transactions, Categories, Budgets, Allocations, SyncQueue],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'centabit.sqlite'));
      return NativeDatabase(file);
    });
  }

  /// Clear all data from all tables (for development/testing)
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(categories).go();
      await delete(budgets).go();
      await delete(allocations).go();
      await delete(syncQueue).go();
    });
  }
}
