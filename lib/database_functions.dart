// By 고경빈

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 데이터베이스에서 모든 데이터 가져오기
Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
  var database = await _initDB('items.db');
  return await database.query('items');
}

// 데이터베이스 초기화
Future<Database> _initDB(String dbName) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, dbName);
  return openDatabase(path, version: 1, onCreate: _createDB);
}

// 테이블 생성
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

// 유통기한 정보만 가져오기
Future<List<Map<String, dynamic>>> fetchExpirationDates() async {
  var data = await fetchDataFromDatabase();  // 기존 fetchDataFromDatabase 함수 호출
  return data.where((item) => item['expirationDate'] != null).toList();  // 유통기한이 있는 항목만 반환
}

// 아침 레시피 상품명만 가져오기
Future<List<Map<String, dynamic>>> fetchNames() async {
  var data = await fetchDataFromDatabase();  // 기존 fetchDataFromDatabase 함수 호출
  return data.map((item) => {'name': item['name']}).toList();  // 상품명만 반환
}

// 데이터베이스에 새로운 아이템 추가
Future<void> addItemToDatabase(String name, String expirationDate) async {
  final db = await _initDB('items.db');
  await db.insert(
    'items',
    {
      'name': name,
      'expirationDate': expirationDate
    },
    conflictAlgorithm: ConflictAlgorithm.replace, // 충돌 시 기존 데이터를 덮어씀
  );
}

// 데이터 업데이트 함수
Future<void> updateItemInDatabase(int id, String name, String expirationDate) async {
  final db = await _initDB('items.db');
  await db.update(
    'items',
    {'name': name, 'expirationDate': expirationDate},
    where: 'id = ?',
    whereArgs: [id],
  );
}

// 데이터 삭제 함수
Future<void> deleteItemFromDatabase(int id) async {
  final db = await _initDB('items.db');
  await db.delete(
    'items',
    where: 'id = ?',
    whereArgs: [id],
  );
}
