import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lifestatistics/extensions/list/get_argument.dart';
import 'package:lifestatistics/services/database/database_category.dart';
import 'package:lifestatistics/services/database/database_management.dart';

class CreateUpdateCategoryView extends StatefulWidget {
  const CreateUpdateCategoryView({super.key});

  @override
  State<CreateUpdateCategoryView> createState() =>
      _CreateUpdateCategoryViewState();
}

class _CreateUpdateCategoryViewState extends State<CreateUpdateCategoryView> {
  DatabaseCategory? _category;
  late final DatabaseManager _databaseManager;
  late final TextEditingController _textController;

  @override
  void initState() {
    _databaseManager = DatabaseManager();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final category = _category;
    if (category == null) {
      return;
    }
    final name = _textController.text;
    await _databaseManager.updateCategory(
      category: category,
      name: name,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseCategory> createOrGetExistingCategory(
      BuildContext context) async {
    print("createOrGetExistingCategory");
    final widgetCategory = context.getArgument<DatabaseCategory>();

    if (widgetCategory != null) {
      _category = widgetCategory;
      _textController.text = widgetCategory.name;
      return widgetCategory;
    }

    final existingCategory = _category;
    if (existingCategory != null) {
      return existingCategory;
    }

    print("createOrGetExistingCategory 1");
    var name = "";
    final newCategory = await _databaseManager.createCategory(name: name);
    _category = newCategory;
    return newCategory;
  }

  void _deleteCategoryIfNameIsEmpty() {
    // TODO: Existing entries might be deleted if name is empty => fix
    print("_deleteCategoryIfNameIsEmpty()");

    final category = _category;
    if (_textController.text.isEmpty && category != null) {
      _databaseManager.deleteCategory(id: category.id);
    }
  }

  void _saveCategoryIfNameNotEmpty() async {
    print("_saveCategoryIfNameNotEmpty()");
    print(_category.toString());

    final category = _category;
    final name = _textController.text;
    if (category != null && name.isNotEmpty) {
      print("_saveCategoryIfNameNotEmpty() 1");
      await _databaseManager.updateCategory(
        category: category,
        name: name,
      );
    }
  }

  @override
  void dispose() {
    _deleteCategoryIfNameIsEmpty();
    _saveCategoryIfNameNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createOrGetExistingCategory(context);
    return AlertDialog(
      title: Text("Create Category"),
      content: TextField(
        controller: _textController,
        autofocus: true,
        keyboardType: TextInputType.name,
        maxLines: 1,
        decoration: InputDecoration(hintText: "Enter the category's name..."),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              _saveCategoryIfNameNotEmpty();
              Navigator.of(context).pop();
            } else {
              //TODO: look for error handling
            }
          },
          child: Text("Save"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
      ],
    );

    /*return Scaffold(
      appBar: AppBar(
        title: const Text("New Category"),
      ),
      body: FutureBuilder(future: createOrGetExistingCategory(context), builder: (context, snapshot) {
        _setupTextControllerListener();
        return TextField(
          controller: _textController,
          autofocus: true,
          keyboardType: TextInputType.name,
          maxLines: 1,
          decoration: InputDecoration(hintText: "Enter the category's name..."),
        );
      },),
    );*/
  }
}
