import 'dart:async';
import 'dart:core';
import 'package:lifestatistics/constants/db_constants.dart';
import 'package:lifestatistics/extensions/list/filter.dart';
import 'package:lifestatistics/services/database/database_exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

import 'database_category.dart';
import 'database_entry.dart';

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

  late final StreamController<List<DatabaseCategory>>
      _categoriesStreamController;
  late final StreamController<List<DatabaseEntry>> _entriesStreamController;

  Stream<List<DatabaseCategory>> get allCategories =>
      _categoriesStreamController.stream;

  Stream<List<DatabaseEntry>> get allEntries => _entriesStreamController.stream;

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
    } on DatabaseAlreadyOpenException {
      return;
    }
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

  Future<void> _cacheCategories() async {
    print("_cacheCategories()");
    final allCategories = await getAllCategories();
    _categories = allCategories.toList();
    _categoriesStreamController.add(_categories);
  }

  // replaced because of possible arising consistency issues
  /* Future<DatabaseCategory> getCategory({required String name}) async {
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
  }*/

  Future<DatabaseCategory> getCategory({required int id}) async {
    print("getCategory");
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      categoryTable,
      limit: 1,
      where: "categoryid = ?",
      whereArgs: [id],
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
    print(categories.toString());
    return categories
        .map((categoryRow) => DatabaseCategory.fromRow(categoryRow));
  }

  Future<DatabaseCategory> updateCategory({
    required DatabaseCategory category,
    required String name,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getCategory(id: category.id);

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
      final updatedCategory = await getCategory(id: category.id);
      _categories.removeWhere((category) => category.id == updatedCategory.id);
      _categories.add(updatedCategory);
      _categoriesStreamController.add(_categories);
      return updatedCategory;
    }
  }

  Future<void> deleteCategory({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // delete category
    final deletedCount = await db.delete(
      categoryTable,
      where: "categoryid = ?",
      whereArgs: [id],
    );
    //delete entries of category
    await db.delete(
      entryTable,
      where: "categoryid = ?",
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteCategoryException();
    } else {
      _categories.removeWhere((category) => category.id == id);
      _categoriesStreamController.add(_categories);
      _entries.removeWhere((entry) => entry.catid == id);
      _entriesStreamController.add(_entries);
    }
  }

  Future<DatabaseEntry> createEntry({
    required DatabaseCategory category,
    required String date,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure category exists in the database
    final dbCategory = await getCategory(id: category.id);
    if (dbCategory != category) {
      throw CouldNotFindCategoryException();
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

  Future<void> _cacheEntries() async {
    final allEntries = await getAllEntries();
    _entries = allEntries.toList();
    _entriesStreamController.add(_entries);
  }

  Future<DatabaseEntry> getEntry({required int entid}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final entries = await db.query(
      entryTable,
      limit: 1,
      where: "entryid = ?",
      whereArgs: [entid],
    );

    if (entries.isEmpty) {
      throw CouldNotFindEntryException();
    } else {
      final entry = DatabaseEntry.fromRow(entries.first);
      _entries.removeWhere((entry) => entry.entid == entid);
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
    await getEntry(entid: entry.entid);

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
      final updatedEntry = await getEntry(entid: entry.entid);
      _entries.removeWhere((entry) => entry.entid == updatedEntry.entid);
      _entries.add(updatedEntry);
      _entriesStreamController.add(_entries);
      return updatedEntry;
    }
  }

  Future<void> deleteEntry({required int entid}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      entryTable,
      where: "entryid = ?",
      whereArgs: [entid],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteEntryException();
    } else {
      _entries.removeWhere((entry) => entry.entid == entid);
      _entriesStreamController.add(_entries);
    }
  }

  Future<int> deleteAllEntriesOfCategory(
      {required DatabaseCategory category}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      entryTable,
      where: "categoryid = ?",
      whereArgs: [category.id],
    );
    _entries.removeWhere((entry) => entry.catid == category.id);
    _entriesStreamController.add(_entries);
    return deletedCount;
  }
}
