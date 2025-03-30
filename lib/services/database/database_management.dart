import 'dart:async';
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

  static final DatabaseManager _shared = DatabaseManager._sharedInstance();
  DatabaseManager._sharedInstance() {
    _categoriesStreamController =
        StreamController<List<DatabaseCategory>>.broadcast(onListen: () {
          _categoriesStreamController.sink.add(_categories);
        });
    _entriesStreamController =
        StreamController<List<DatabaseEntry>>.broadcast(onListen: () {
          _entriesStreamController.sink.add(_entries);
        });
  }
  factory DatabaseManager() => _shared;

  late final StreamController<List<DatabaseCategory>> _categoriesStreamController;
  late final StreamController<List<DatabaseEntry>> _entriesStreamController;

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

    final category = DatabaseCategory(id: id, name: name);
    _categories.add(category);
    _categoriesStreamController.add(_categories);
    return category;
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

  Future<Iterable<DatabaseCategory>> getAllCategories() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final categories = await db.query(categoryTable);
    return categories.map((categoryRow) => DatabaseCategory.fromRow(categoryRow));
  }

  Future<DatabaseCategory> updateCategory({
    required DatabaseCategory category,
    required String name,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getEntry(id: category.id);

    // update DB
    final updatesCount = await db.update(
      categoryTable,
      {
        categoryNameColumn: name,
      },
      where: "categoryid = ?",
      whereArgs: [category.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateCategoryException();
    } else {
      final updatedCategory = await getCategory(name: name);
      _categories.removeWhere((category) => category.id == updatedCategory.id);
      _categories.add(updatedCategory);
      _categoriesStreamController.add(_categories);
      return updatedCategory;
    }
  }

  Future<void> deleteCategory({required int id}) async {} // TODO: implement

  Future<DatabaseEntry> createEntry({
    required DatabaseCategory category,
    required String date,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure category exists in the database
    final dbCategory = getCategory(name: category.name);
    if (dbCategory != category) {
      throw new CouldNotFindCategoryException();
    }

    const text = "";
    const picture = "";
    // create the entry
    final int entid = await db.insert(entryTable, {
      categoryIDColumn: category.id,
      textColumn: text,
      dateColumn: date,
      pictureColumn: picture,
    });

    final entry = DatabaseEntry(entid: entid, catid: category.id, date: date);
    _entries.add(entry);
    _entriesStreamController.add(_entries);
    return entry;
  }

  Future<DatabaseEntry> getEntry({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final entries = await db.query(
      entryTable,
      limit: 1,
      where: "entryid = ?",
      whereArgs: [id],
    );

    if (entries.isEmpty) {
      throw CouldNotFindEntryException();
    } else {
      final entry = DatabaseEntry.fromRow(entries.first);
      _entries.removeWhere((entry) => entry.entid == id);
      _entries.add(entry);
      _entriesStreamController.add(_entries);
      return entry;
    }
  }

  Future<Iterable<DatabaseEntry>> getAllEntries() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final entries = await db.query(entryTable);
    return entries.map((entryRow) => DatabaseEntry.fromRow(entryRow));
  }

  Future<DatabaseEntry> updateEntry({
    required DatabaseEntry entry,
    String? text,
    String? picture,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getEntry(id: entry.entid);

    text = text ?? "";
    picture = picture ?? "";

    // update DB
    final updatesCount = await db.update(
      entryTable,
      {
        textColumn: text,
        pictureColumn: picture,
      },
      where: "entryid = ?",
      whereArgs: [entry.entid],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateEntryException();
    } else {
      final updatedEntry = await getEntry(id: entry.entid);
      _entries.removeWhere((entry) => entry.entid == updatedEntry.entid);
      _entries.add(updatedEntry);
      _entriesStreamController.add(_entries);
      return updatedEntry;
    }
  }

  Future<void> deleteNote({required int id}) async {} // TODO: implement
  Future<void> deleteallNotes() async {} // TODO: implement
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
