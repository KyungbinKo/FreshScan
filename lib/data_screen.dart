// By 고경빈, 이의현

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식 지정
import 'database_functions.dart'; // 데이터베이스 관련 함수 임포트

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

  // 날짜 선택을 위한 DatePicker 위젯
  Future<void> _selectDate(BuildContext context, TextEditingController controller, String currentDate) async {
    DateTime initialDate = DateTime.parse(currentDate);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != initialDate) {
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
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
                decoration: InputDecoration(labelText: '상품명'),
              ),
              TextField(
                controller: expirationController,
                decoration: InputDecoration(labelText: '소비기한'),
                onTap: () => _selectDate(context, expirationController, item['expirationDate']), // 소비기한 날짜 선택
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // SQLite에 데이터 업데이트
                await updateItemInDatabase(
                  item['id'],
                  nameController.text,
                  expirationController.text, // 소비기한 날짜 업데이트
                );

                Navigator.pop(context); // 팝업 닫기
                await _loadItems(); // 최신 데이터 불러오기
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 상품 추가 팝업 띄우기
  void _addItem() {
    TextEditingController nameController = TextEditingController();
    TextEditingController expirationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('상품 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '상품명'),
              ),
              TextField(
                controller: expirationController,
                decoration: InputDecoration(labelText: '소비기한'),
                onTap: () => _selectDate(context, expirationController, DateTime.now().toString()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // 새로운 상품 데이터 추가
                await addItemToDatabase(
                    nameController.text,
                    expirationController.text
                );

                Navigator.pop(context); // 팝업 닫기
                await _loadItems(); // 최신 데이터 불러오기
              },
              child: Text('추가'),
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
        padding: const EdgeInsets.all(0.5),
        child: SingleChildScrollView( // 여기에 추가
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 화면의 가로 길이에 맞게 최대 너비 계산
              double availableWidth = constraints.maxWidth;

              return DataTable(
                columns: const [
                  DataColumn(label: Text('상품명')),
                  DataColumn(label: Text('소비기한')),
                  DataColumn(label: Text('')),
                ],
                rows: sortedItems.map((item) {
                  return DataRow(cells: [
                    DataCell(
                      // 상품명 텍스트 너비를 화면의 크기에 맞게 조정
                      Container(
                        width: availableWidth * 0.2, // 5글자만 표시(0.05 당 글자 수 +2)
                        child: Text(
                          item['name'] ?? 'N/A',
                          maxLines: 1, // 한 줄로 표시
                          overflow: TextOverflow.ellipsis, // 넘치는 텍스트 잘림 처리
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: availableWidth * 0.2, // 소비기한도 화면 크기에 맞게 조정
                        child: Text(item['expirationDate'] ?? DateTime.now().toString()),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: availableWidth * 0.3,
                        child: Row(
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
                    ),
                  ]);
                }).toList(),
              );
            },
          ),
        ),
      ),
      // 하단에 '+' 버튼 추가
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
