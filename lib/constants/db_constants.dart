const dbName = "statistics.db";
const categoryTable = "category";
const entryTable = "entry";
const categoryIDColumn = "categoryid";
const entryIDColumn = "entryid";
const categoryNameColumn = "categoryname";
const numberColumn = "number";
const textColumn = "text";
const dateColumn = "column";
const pictureColumn = "picture";
const createCategoryTable = '''CREATE TABLE IF NOT EXISTS "category" (
                               "categoryid"	INTEGER NOT NULL UNIQUE,
                               "categoryname"	TEXT NOT NULL,
                               PRIMARY KEY("categoryid" AUTOINCREMENT)
                               );''';
const createEntryTable = '''CREATE TABLE "entry" (
	                          "entryid"	INTEGER NOT NULL UNIQUE,
		                        "categoryid"	INTEGER NOT NULL,
		                        "text"	TEXT,
	                         	"date"	TEXT NOT NULL,
		                        "picture"	BLOB,
		                        PRIMARY KEY("entryid"),
		                        FOREIGN KEY("categoryid") REFERENCES ""
	                          );''';
