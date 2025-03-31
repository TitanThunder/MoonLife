import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lifestatistics/services/database/database_category.dart';
import 'package:lifestatistics/services/database/database_entry.dart';

typedef EntryCallback = void Function(DatabaseEntry entry);

class EntriesListView extends StatelessWidget {
  final DatabaseCategory category;
  final Iterable<DatabaseEntry> entries;
  final EntryCallback onTap;
  final EntryCallback onLongPress;

  const EntriesListView({
    super.key,
    required this.category,
    required this.entries,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(entry);
          },
          onLongPress: () {
            onLongPress(entry);
          },
          title: Text(entry.text ?? ""),
          trailing: Text(index.toString()),
        );
      },
    );
  }
}
