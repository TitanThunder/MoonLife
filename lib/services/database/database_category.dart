import 'package:lifestatistics/constants/db_constants.dart';

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

  String get getName => name;

  @override
  String toString() => "Category, id = $id, name = $name";

  @override
  bool operator ==(covariant DatabaseCategory other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
