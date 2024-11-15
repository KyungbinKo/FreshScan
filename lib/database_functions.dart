import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
  var database = await _initDB('items.db');
  return await database.query('items');
}

Future<Database> _initDB(String dbName) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, dbName);
  return openDatabase(path, version: 1, onCreate: _createDB);
}

Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      expirationDate TEXT,
      purchaseDate TEXT
    );
  ''');
}
