// By 고경빈, 한창호, 이의현

// 필요한 패키지 import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 관리하는 패키지
import 'package:sqflite/sqflite.dart'; // SQLite 데이터베이스 작업에 사용
import 'package:path/path.dart';

import 'main.dart'; // 데이터베이스 경로 생성에 사용

// 상품 목록 화면을 위한 StatefulWidget 정의
class ItemsScreen extends StatefulWidget {
  // 필요한 데이터를 생성자에서 전달받음
  final List<Map<String, dynamic>> items; // 상품 데이터 리스트
  final DateTime purchaseDate; // 구입 날짜
  final Function(int) onDeleteItem; // 아이템 삭제 콜백 함수
  final Function(int, String, dynamic) onUpdateItem; // 아이템 업데이트 콜백 함수
  final Function(DateTime) onUpdatePurchaseDate; // 구입 날짜 업데이트 콜백 함수

  // 생성자 정의
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

// ItemsScreen의 상태 관리 클래스
class _ItemsScreenState extends State<ItemsScreen> {
  late Database _database; // SQLite 데이터베이스 인스턴스

  @override
  void initState() {
    super.initState();
    _initDatabase(); // 데이터베이스 초기화
  }

  // SQLite 데이터베이스 초기화 함수
  Future<void> _initDatabase() async {
    // 데이터베이스 경로 생성
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'items.db');

    // 데이터베이스 열기 및 초기화
    _database = await openDatabase(
      path,
      version: 1, // 데이터베이스 버전
      onCreate: (db, version) async {
        // 데이터베이스 테이블 생성
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT, // 자동 증가 ID
            name TEXT, // 상품명
            expirationDate TEXT, // 소비기한
            purchaseDate TEXT // 구입 날짜
          )
        ''');
      },
    );
  }

  // SQLite에 데이터 저장 함수
  Future<void> _saveItemToDatabase(
      String name, DateTime expirationDate, DateTime purchaseDate) async {
    await _database.insert(
      'items',
      {
        'name': name,
        'expirationDate': DateFormat('yyyy-MM-dd').format(expirationDate), // 날짜 형식화
        'purchaseDate': DateFormat('yyyy-MM-dd').format(purchaseDate), // 날짜 형식화
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // 중복 시 기존 데이터를 덮어씀
    );
  }

  // 아이템 삭제 함수
  void _deleteItem(int index) {
    setState(() {
      widget.onDeleteItem(index); // 부모 위젯의 콜백 함수 호출
    });
  }

  // 소비기한 또는 구입 날짜를 선택하는 위젯 생성
  Widget _buildDatePicker(BuildContext context, DateTime? initialDate,
      String label, Function(DateTime) onDateChanged) {
    // 초기 날짜 값이 없을 경우 현재 날짜로 설정
    final safeInitialDate = initialDate ?? DateTime.now();

    return Row(
      children: [
        Text("$label: "), // 레이블 표시
        TextButton(
          onPressed: () async {
            // 날짜 선택 다이얼로그 호출
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: safeInitialDate, // 초기 날짜
              firstDate: DateTime(2000), // 선택 가능한 최소 날짜
              lastDate: DateTime(2101), // 선택 가능한 최대 날짜
            );
            if (pickedDate != null) {
              // 소비기한 또는 구입 날짜 업데이트 처리
              onDateChanged(pickedDate);

              setState(() {
                // 상태 갱신
              });
            }
          },
          child: Text(
            DateFormat('yyyy-MM-dd').format(safeInitialDate), // 선택된 날짜 표시
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("상품 목록"), // 앱바 타이틀
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 버튼
          onPressed: () => Navigator.pop(context, widget.items), // 업데이트된 아이템 리스트 반환
        ),
      ),
      body: Column(
        children: [
          // 구입 날짜 선택 위젯
          _buildDatePicker(
            context,
            widget.purchaseDate, // 구입 날짜
            "구입 날짜",
            widget.onUpdatePurchaseDate, // 부모 위젯의 콜백 함수 호출
          ),
          Expanded(
            // 상품 목록을 표시하는 ListView
            child: ListView.builder(
              shrinkWrap: true, // 목록 크기 축소
              itemCount: widget.items.length, // 아이템 개수
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    // 상품명 입력 필드
                    title: TextFormField(
                      initialValue: widget.items[index]['name'], // 초기 값 설정
                      onChanged: (value) =>
                          widget.onUpdateItem(index, 'name', value), // 이름 업데이트
                      decoration: InputDecoration(labelText: '상품명'), // 레이블
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 정렬
                      children: [
                        // 소비기한 선택 위젯
                        _buildDatePicker(
                          context,
                          widget.items[index]['expirationDate'], // 소비기한
                          "소비기한",
                              (date) =>
                              widget.onUpdateItem(index, 'expirationDate', date),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // "등록" 버튼
          Padding(
            padding: const EdgeInsets.all(8.0), // 여백
            child: ElevatedButton(
              onPressed: () {
                // 각 아이템을 데이터베이스에 저장
                for (var item in widget.items) {
                  _saveItemToDatabase(
                    item['name'], // 상품명
                    item['expirationDate'] ?? DateTime.now(), // 소비기한
                    widget.purchaseDate, // 구입 날짜
                  );
                }
                // 성공 메시지 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("상품이 등록되었습니다.")),
                );
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()) // 홈 화면으로 이동
                );
              },
              child: Text("등록"), // 버튼 텍스트
            ),
          ),
        ],
      ),
    );
  }
}
