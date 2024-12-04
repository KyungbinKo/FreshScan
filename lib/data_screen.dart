import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class DataScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const DataScreen({super.key, required this.items});

  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  late Database _database;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _initDatabase().then((_) {
      _fetchItemsFromDatabase().then((_) {
        _deleteInvalidItems(); // 자동으로 잘못된 형식의 데이터 삭제
      });
    });
  }

  // SQLite 데이터베이스 초기화
  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'items.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            expirationDate TEXT,
            purchaseDate TEXT
          )
        '''
        );
      },
    );
  }

  // 데이터베이스에서 항목 가져오기
  Future<void> _fetchItemsFromDatabase() async {
    final List<Map<String, dynamic>> items = await _database.query('items');
    setState(() {
      _items = items;
    });
  }

  // 잘못된 형식의 데이터를 삭제하는 함수
  Future<void> _deleteInvalidItems() async {
    final List<Map<String, dynamic>> items = await _database.query('items');
    for (var item in items) {
      try {
        DateTime.parse(item['purchaseDate']);
        DateTime.parse(item['expirationDate']);
      } catch (e) {
        await _database.delete(
          'items',
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }
    _fetchItemsFromDatabase();
  }

  // 데이터 추가 함수
  void _addItem() async {
    if (_nameController.text.isNotEmpty &&
        _purchaseDateController.text.isNotEmpty &&
        _expirationDateController.text.isNotEmpty) {
      DateTime purchaseDate;
      DateTime expirationDate;
      try {
        purchaseDate = DateTime.parse(_purchaseDateController.text);
        expirationDate = DateTime.parse(_expirationDateController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('날짜 형식이 올바르지 않습니다. (YYYY-MM-DD)')),
        );
        return;
      }

      if (expirationDate.isBefore(purchaseDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유통기한은 구입 날짜 이후여야 합니다.')),
        );
        return;
      }

      await _saveItemToDatabase(
        _nameController.text,
        DateFormat('yyyy-MM-dd').format(purchaseDate),
        DateFormat('yyyy-MM-dd').format(expirationDate),
      );
      _fetchItemsFromDatabase();

      // 입력 필드 초기화
      _nameController.clear();
      _purchaseDateController.clear();
      _expirationDateController.clear();
    }
  }

  // 데이터베이스에 항목 저장 함수
  Future<void> _saveItemToDatabase(
      String name, String purchaseDate, String expirationDate) async {
    await _database.insert(
      'items',
      {
        'name': name,
        'purchaseDate': purchaseDate,
        'expirationDate': expirationDate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 유통기한을 기준으로 오름차순 정렬
    List<Map<String, dynamic>> sortedItems = List.from(_items);
    sortedItems.sort((a, b) {
      DateTime expirationA = DateTime.parse(a['expirationDate']);
      DateTime expirationB = DateTime.parse(b['expirationDate']);
      return expirationA.compareTo(expirationB); // 오름차순으로 정렬
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Data"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 입력 폼 추가
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '상품명'),
              ),
              TextField(
                controller: _purchaseDateController,
                decoration: const InputDecoration(labelText: '구입 날짜 (YYYY-MM-DD)'),
              ),
              TextField(
                controller: _expirationDateController,
                decoration: const InputDecoration(labelText: '유통기한 (YYYY-MM-DD)'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addItem,
                child: const Text('데이터 추가'),
              ),
              const SizedBox(height: 16.0),
              // 데이터 테이블
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('상품명')),
                    DataColumn(label: Text('구입 날짜')),
                    DataColumn(label: Text('유통기한')),
                  ],
                  rows: sortedItems.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(item['name'] ?? 'N/A')),
                      DataCell(Text(item['purchaseDate'] ?? 'N/A')),
                      DataCell(Text(item['expirationDate'] ?? 'N/A')),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
