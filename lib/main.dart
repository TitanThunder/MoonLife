import 'package:flutter/material.dart';
import 'package:lifestatistics/services/database/database_exceptions.dart';
import 'package:lifestatistics/services/database/database_management.dart';
import 'package:lifestatistics/views/categories_view.dart';
import 'package:lifestatistics/views/create_update_category_view.dart';
import 'package:lifestatistics/views/create_update_entry_view.dart';
import 'package:lifestatistics/views/entries_view.dart';
import 'package:lifestatistics/views/homepage_view.dart';
import 'package:path/path.dart';

import 'constants/routes.dart';

void main() {
  runApp(
    MaterialApp(
      title: "MoonLife",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Overview(),
      routes: {
        overviewRoute: (context) => const Overview(),
        homePageViewRoute: (context) => const HomepageView(),
        createUpdateCategoryRoute: (context) =>
            const CreateUpdateCategoryView(),
        entriesRoute: (context) => const EntriesView(),
      },
    ),
  );
}

class Overview extends StatelessWidget {
  const Overview({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseManager = DatabaseManager();
    try {
      databaseManager.open();
    } on DatabaseAlreadyOpenException {}
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("MoonLife"),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home_rounded)),
                Tab(icon: Icon(Icons.list_rounded)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Tab(
                child: HomepageView(),
              ),
              Tab(
                child: CategoriesView(),
              ),
            ],
          ),
          floatingActionButton: MenuAnchor(
            // TODO: Put buttons in external enum-file
            menuChildren: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        CreateUpdateCategoryView(),
                  );
                },
                child: const Text("Add category"),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => CreateUpdateEntryView(),
                  );
                },
                child: const Text("Add entry"),
              ),
            ],
            builder: (BuildContext context, MenuController controller,
                Widget? child) {
              return IconButton.filled(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.add_rounded),
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(
                    Size.fromRadius(28),
                  ),
                ),
              );
            },
            style: const MenuStyle(alignment: Alignment(-3, -5.5)),
          ),
        ),
      ),
    );
  }
}
