import 'package:flutter/widgets.dart';
import 'package:lifestatistics/constants/routes.dart';
import 'package:lifestatistics/extensions/list/get_argument.dart';
import 'package:lifestatistics/services/database/database_category.dart';
import 'package:lifestatistics/services/database/database_management.dart';
import 'package:lifestatistics/views/categories_list_view.dart';
import 'package:lifestatistics/views/entries_view.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  late final DatabaseManager _databaseManager;

  @override
  void initState() {
    _databaseManager = DatabaseManager();
    _databaseManager.getAllCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //WidgetsFlutterBinding.ensureInitialized();
    return StreamBuilder(
      stream: _databaseManager.allCategories,
      builder: (context, snapshot) {
        Iterable<DatabaseCategory> allCategories;
        try {
          allCategories = snapshot.data as Iterable<DatabaseCategory>;
        } catch (e) {
          return Text("Add a new category to get started.");
        } if (allCategories.isEmpty) {
          return Text("Add a new category to get started.");
        }
        return CategoriesListView(
          categories: allCategories,
          onDeleteCategory: (category) async {
            await _databaseManager.deleteCategory(id: category.id);
          },
          onTap: (category) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(
              entriesRoute,
              arguments: category,
            );
          },
        );
      },
    );
  }
}
