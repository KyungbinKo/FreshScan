import 'package:flutter/material.dart';
import 'database_functions.dart';

class Item {
  final int id;
  final String name;
  final String purchaseDate;
  final String expirationDate;

  Item({
    required this.id,
    required this.name,
    required this.purchaseDate,
    required this.expirationDate,
  });
}

class DataScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const DataScreen({super.key, required this.items});

  @override
  _DataScreenState createState() => _DataScreenState();
}


class _DataScreenState extends State<DataScreen> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    items = widget.items;
  }

  // 목록 새로고침 함수
  Future<void> _loadItems() async {
    final data = await fetchDataFromDatabase(); // SQLite에서 데이터 가져오기
    setState(() {
      items = data; // 화면의 데이터 갱신
    });
  }

  // 수정 팝업 띄우기
  void _editItem(Map<String, dynamic> item) {
    TextEditingController nameController = TextEditingController(text: item['name']);
    TextEditingController expirationController = TextEditingController(text: item['expirationDate']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: expirationController,
                decoration: InputDecoration(labelText: 'Expiration Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // SQLite에 데이터 업데이트
                await updateItemInDatabase(
                  item['id'],
                  nameController.text,
                  expirationController.text,
                );

                Navigator.pop(context); // 팝업 닫기
                await _loadItems(); // 최신 데이터 불러오기
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 삭제 로직
  void _deleteItem(int id) async {
    await deleteItemFromDatabase(id); // SQLite에서 데이터 삭제
    await _loadItems(); // 최신 데이터 불러오기
  }

  @override
  Widget build(BuildContext context) {
    // 유통기한을 기준으로 오름차순 정렬
    List<Map<String, dynamic>> sortedItems = List.from(items); // 복사본 생성
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('상품명')),
              DataColumn(label: Text('구입 날짜')),
              DataColumn(label: Text('유통기한')),
              DataColumn(label: Text('')),
            ],
            rows: sortedItems.map((item) {
              return DataRow(cells: [
                DataCell(Text(item['name'] ?? 'N/A')),
                DataCell(Text(item['purchaseDate'] ?? DateTime.now())), // Null 방지
                DataCell(Text(item['expirationDate'] ?? DateTime.now())), // Null 방지
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editItem(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(item['id']),
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
