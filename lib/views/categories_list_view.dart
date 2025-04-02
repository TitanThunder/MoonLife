import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lifestatistics/extensions/list/get_argument.dart';
import 'package:lifestatistics/services/database/database_category.dart';
import 'package:lifestatistics/services/database/database_management.dart';

typedef CategoryCallback = void Function(DatabaseCategory category);

class CategoriesListView extends StatelessWidget {
  final Iterable<DatabaseCategory> categories;
  final CategoryCallback onDeleteCategory; // TODO: Maybe delete?
  final CategoryCallback onTap;

  const CategoriesListView({
    super.key,
    required this.categories,
    required this.onDeleteCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(category);
          },
          title: Text(category.name),
          trailing: Text(context
                  .getArgument<DatabaseManager>()
                  ?.allEntries
                  .length
                  .toString() ??
              "0"),
        );
      },
    );
  }
}
