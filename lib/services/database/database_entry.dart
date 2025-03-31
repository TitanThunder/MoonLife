import 'package:lifestatistics/constants/db_constants.dart';

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