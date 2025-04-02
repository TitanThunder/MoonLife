import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lifestatistics/extensions/list/get_argument.dart';
import 'package:lifestatistics/services/database/database_category.dart';
import 'package:lifestatistics/services/database/database_entry.dart';
import 'package:lifestatistics/services/database/database_management.dart';

class CreateUpdateEntryView extends StatefulWidget {
  const CreateUpdateEntryView({super.key});

  @override
  State<CreateUpdateEntryView> createState() => _CreateUpdateEntryViewState();
}

class _CreateUpdateEntryViewState extends State<CreateUpdateEntryView> {
  DatabaseEntry? _entry;
  late final DatabaseManager _databaseManager;
  late final TextEditingController _textController;

  late final Iterable<DatabaseCategory> _categories;

  late DatabaseCategory _selectedCategory;
  late String? _text;
  late String _date;
  late String? _picture;

  @override
  void initState() {
    _databaseManager = DatabaseManager();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final entry = _entry;
    if (entry == null) {
      return;
    }
    final text = _textController.text;
    await _databaseManager.updateEntry(
      entry: entry,
      category: _selectedCategory,
      date: _date,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseEntry> createOrGetExistingCategory(
    BuildContext context,
  ) async {
    _categories = await _databaseManager.allCategories.first;
    print("createOrGetExistingEntry");
    final widgetCategory = context.getArgument<DatabaseEntry>();

    if (widgetCategory != null) {
      _entry = widgetCategory;
      _textController.text = widgetCategory.text ?? "";
      return widgetCategory;
    }

    final existingCategory = _entry;
    if (existingCategory != null) {
      return existingCategory;
    }

    print("createOrGetExistingEntry 1");
    final tempCategory = await _databaseManager.allCategories.first;
    _selectedCategory = tempCategory.first;
    _date = DateTime(0, 0, 0).toString();

    final newEntry = await _databaseManager.createEntry(
        category: _selectedCategory,
        date: _date
    );
    _entry = newEntry;
    return newEntry;
  }

  _deleteEntryIfEmpty() async {
    print("_deleteEntryIfEmpty");

    final entry = _entry;
    if (entry != null) {
      _databaseManager.deleteEntry(entid: entry.entid);
    }
  }

  void _saveEntryIfNotEmpty() async {
    print("_saveEntryIfNotEmpty");
    print("_entry.toString()");
  }


  @override
  Widget build(BuildContext context) {
    createOrGetExistingCategory(context);
    return StreamBuilder(
      stream: _databaseManager.allCategories,
      initialData: _databaseManager.getAllCategories(),
      builder: (context, snapshot) {
        Iterable<DatabaseCategory> allCategories;
        print(_databaseManager.allCategories.first.toString());
        try {
          allCategories = snapshot.data as Iterable<DatabaseCategory>;
        } catch (e) {
          return AlertDialog(
            title: Text("No category existent"),
            content: TextButton(onPressed: () {}, child: Text("Create a category first")),
          );
        } if (allCategories.isEmpty) {
          return AlertDialog(
            title: Text("No category existent"),
            content: TextButton(onPressed: () {}, child: Text("Create a category first")),
          );
        }
        return AlertDialog(
          title: Text("Create Entry"),
          content: Column(
            children: [
              DropdownMenu(dropdownMenuEntries: UnmodifiableListView(allCategories.map((cat) => DropdownMenuEntry(value: cat.id, label: cat.name))),),
            ],
          ),
        );
      },
    );
    /*return AlertDialog(
      title: Text("Create Entry"),
      content: Column(
        children: [
          DropdownMenu(dropdownMenuEntries: UnmodifiableListView(),),//_categories.map((DatabaseCategory cat) => DropdownMenuEntry(value: cat.id, label: cat.name))),),
        ],
      ),
    );*/
  }
}
