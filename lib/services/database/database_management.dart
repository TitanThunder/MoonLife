import 'dart:core';
import 'dart:ui';
import 'package:lifestatistics/constants/db_constants.dart';
import 'package:lifestatistics/services/database/database_exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class DatabaseManager {
  Database? _db;
  List<DatabaseCategory> _categories = [];
  List<DatabaseEntry> _entries = [];
  late Map<DatabaseCategory, List<DatabaseEntry>> _mappedEntries;

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create category table
      await db.execute(createCategoryTable);
      // create entry table
      await db.execute(createEntryTable);
      await _cacheCategories();
      await _cacheEntries();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {}
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<DatabaseCategory> createCategory({required String name}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      categoryTable,
      limit: 1,
      where: "categoryname = ?",
      whereArgs: [name],
    );
    if (results.isNotEmpty) {
      throw CategoryAlreadyExistsException();
    }

    final id = await db.insert(categoryTable, {categoryNameColumn: name});

    return DatabaseCategory(id: id, name: name);
  }

  Future<DatabaseCategory> getCategory({required String name}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      categoryTable,
      limit: 1,
      where: "categoryname = ?",
      whereArgs: [name],
    );

    if (results.isEmpty) {
      throw CouldNotFindCategoryException();
    } else {
      return DatabaseCategory.fromRow(results.first);
    }
  }

  Future<void> deleteCategory({required int id}) async {} // TODO: implement
}

class DatabaseCategory {
  final int id;
  final String name;

  DatabaseCategory({
    required this.id,
    required this.name,
  });

  DatabaseCategory.fromRow(Map<String, Object?> map)
      : id = map[categoryIDColumn] as int,
        name = map[categoryNameColumn] as String;

  @override
  String toString() => "Category, id = $id, name = $name";

  @override
  bool operator ==(covariant DatabaseCategory other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseEntry {
  final int entid;
  final int catid;
  final String? text;
  final String date;
  final String? picture;

  DatabaseEntry({
    required this.entid,
    required this.catid,
    this.text,
    required this.date,
    this.picture,
  });

  DatabaseEntry.fromRow(Map<String, Object?> map)
      : entid = map[entryIDColumn] as int,
        catid = map[categoryIDColumn] as int,
        text = map[textColumn] as String,
        date = map[dateColumn] as String,
        picture = map[pictureColumn] as String;

  @override
  String toString() =>
      "Entry, entry id = $entid, category id = $catid, text = $text, date = $date";

  @override
  bool operator ==(covariant DatabaseEntry other) =>
      entid == other.entid && catid == other.catid;

  @override
  int get hashCode => catid.hashCode;
}
