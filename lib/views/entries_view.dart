import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lifestatistics/constants/routes.dart';
import 'package:lifestatistics/extensions/list/get_argument.dart';
import 'package:lifestatistics/services/database/database_category.dart';
import 'package:lifestatistics/services/database/database_entry.dart';
import 'package:lifestatistics/services/database/database_management.dart';
import 'package:lifestatistics/views/entries_list_view.dart';

import 'create_update_entry_view.dart';

class EntriesView extends StatefulWidget {
  const EntriesView({
    super.key,
  });

  @override
  State<EntriesView> createState() => _EntriesViewState();
}

class _EntriesViewState extends State<EntriesView> {
  late final DatabaseManager _databaseManager;

  @override
  void initState() {
    _databaseManager = DatabaseManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.getArgument().getName),
      ),
      body: StreamBuilder(
        stream: _databaseManager.allEntries,
        builder: (context, snapshot) {
          Iterable<DatabaseEntry> allEntries;
          final category = context.getArgument<DatabaseCategory>() ??
              DatabaseCategory(id: -1, name: "");
          print(category);
          try {
            allEntries = snapshot.data as Iterable<DatabaseEntry>;
            allEntries =
                allEntries.where((entry) => entry.catid == category.id);
          } catch (e) {
            return Text("Keep track of your progress by adding an Entry");
          }
          return EntriesListView(
            category: category,
            entries: allEntries,
            onTap: (entry) {
              Navigator.of(context)
                  .pushNamed(detailedEntryRoute, arguments: entry);
            },
            onLongPress: (entry) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => CreateUpdateEntryView());
            },
          );
        },
      ),
    );
  }
}
