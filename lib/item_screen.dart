// By 고경빈, 한창호, 이의현

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ItemsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final DateTime purchaseDate;
  final Function(int) onDeleteItem;
  final Function(int, String, dynamic) onUpdateItem;
  final Function(DateTime) onUpdatePurchaseDate;

  ItemsScreen({
    required this.items,
    required this.purchaseDate,
    required this.onDeleteItem,
    required this.onUpdateItem,
    required this.onUpdatePurchaseDate,
  });

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // SQLite 데이터베이스 초기화
  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'items.db');

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
        ''');
      },
    );
  }

  // "등록" 버튼 클릭 시 데이터베이스에 저장하는 함수
  Future<void> _saveItemToDatabase(
      String name, DateTime expirationDate, DateTime purchaseDate) async {
    await _database.insert(
      'items',
      {
        'name': name,
        'expirationDate': DateFormat('yyyy-MM-dd').format(expirationDate),
        'purchaseDate': DateFormat('yyyy-MM-dd').format(purchaseDate),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void _deleteItem(int index) {
    setState(() {
      widget.onDeleteItem(index);
    });
  }

  // Widget _buildQuantityField(int index) {
  //   return Row(
  //     children: [
  //       Text("수량: "),
  //       SizedBox(
  //         width: 40,
  //         child: TextFormField(
  //           initialValue: widget.items[index]['quantity'].toString(),
  //           keyboardType: TextInputType.number,
  //           onChanged: (value) =>
  //               widget.onUpdateItem(index, 'quantity', int.tryParse(value) ?? 1),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDatePicker(
      BuildContext context, DateTime? initialDate, String label, Function(DateTime) onDateChanged) {
    // 기본값을 설정해 null 방지
    final safeInitialDate = initialDate ?? DateTime.now();

    return Row(
      children: [
        Text("$label: "),
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: safeInitialDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              onDateChanged(pickedDate);
            }
          },
          child: Text(
            DateFormat('yyyy-MM-dd').format(safeInitialDate),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("상품 목록"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, widget.items), // 업데이트된 리스트 반환
        ),
      ),
      body: Column(
        children: [
          _buildDatePicker(
            context,
            widget.purchaseDate, // nullable로 변경 후 null 처리
            "구입 날짜",
            widget.onUpdatePurchaseDate,
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: TextFormField(
                      initialValue: widget.items[index]['name'],
                      onChanged: (value) => widget.onUpdateItem(index, 'name', value),
                      decoration: InputDecoration(labelText: '상품명'),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildQuantityField(index),
                        _buildDatePicker(
                          context,
                          widget.items[index]['expirationDate'], // nullable로 변경 후 null 처리
                          "소비기한",
                              (date) => widget.onUpdateItem(
                            index,
                            'expirationDate',
                            date,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // "등록" 버튼 추가
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                for (var item in widget.items) {
                  _saveItemToDatabase(
                    item['name'],
                    item['expirationDate'] ?? DateTime.now(), // null 방지
                    widget.purchaseDate,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("상품이 등록되었습니다.")),
                );
                Navigator.pop(context); // 버튼 클릭 후 홈화면으로 이동
                Navigator.pop(context);
              },
              child: Text("등록"),
            ),
          ),
        ],
      ),
    );
  }
}
