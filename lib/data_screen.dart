// By 고경빈, 이의현

import 'package:flutter/material.dart'; // Flutter UI 라이브러리 임포트
import 'package:intl/intl.dart'; // 날짜 형식을 지정하기 위한 패키지
import 'database_functions.dart'; // 데이터베이스 관련 함수 임포트

// 상품 정보를 저장하는 모델 클래스 정의
class Item {
  final int id; // 상품 ID
  final String name; // 상품 이름
  final String purchaseDate; // 구매 날짜
  final String expirationDate; // 소비기한

  // Item 클래스 생성자
  Item({
    required this.id,
    required this.name,
    required this.purchaseDate,
    required this.expirationDate,
  });
}

// 데이터 관리 화면 위젯 정의
class DataScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items; // 초기 데이터로 전달받는 아이템 리스트

  const DataScreen({super.key, required this.items}); // 생성자 정의

  @override
  _DataScreenState createState() => _DataScreenState(); // 상태 클래스 생성
}

// 데이터 화면의 상태 클래스 정의
class _DataScreenState extends State<DataScreen> {
  List<Map<String, dynamic>> items = []; // 화면에서 사용할 데이터 리스트

  @override
  void initState() {
    super.initState(); // 부모 클래스의 초기화 호출
    items = widget.items; // 전달받은 초기 데이터를 화면 데이터로 설정
  }

  // 데이터 목록을 새로고침하는 함수
  Future<void> _loadItems() async {
    final data = await fetchDataFromDatabase(); // 데이터베이스에서 데이터 가져오기
    setState(() {
      items = data; // 가져온 데이터를 화면에 반영
    });
  }

  // 날짜 선택을 위한 DatePicker 위젯
  Future<void> _selectDate(BuildContext context, TextEditingController controller, String currentDate) async {
    DateTime initialDate = DateTime.parse(currentDate); // 현재 날짜를 기준으로 초기화
    DateTime? pickedDate = await showDatePicker( // DatePicker 띄우기
      context: context,
      initialDate: initialDate, // 초기 날짜 설정
      firstDate: DateTime(2000), // 선택 가능한 최소 날짜
      lastDate: DateTime(2101), // 선택 가능한 최대 날짜
    );
    if (pickedDate != null && pickedDate != initialDate) {
      // 새로운 날짜를 선택한 경우 텍스트 컨트롤러에 날짜를 업데이트
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  // 기존 아이템을 수정하기 위한 팝업 띄우기
  void _editItem(Map<String, dynamic> item) {
    TextEditingController nameController = TextEditingController(text: item['name']); // 상품명 텍스트 컨트롤러
    TextEditingController expirationController = TextEditingController(text: item['expirationDate']); // 소비기한 텍스트 컨트롤러

    showDialog( // 수정 팝업을 띄움
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item'), // 팝업 제목
          content: Column(
            mainAxisSize: MainAxisSize.min, // 팝업 크기를 내용에 맞게 설정
            children: [
              TextField(
                controller: nameController, // 상품명 입력 필드
                decoration: InputDecoration(labelText: '상품명'),
              ),
              TextField(
                controller: expirationController, // 소비기한 입력 필드
                decoration: InputDecoration(labelText: '소비기한'),
                onTap: () => _selectDate(context, expirationController, item['expirationDate']), // 날짜 선택 기능
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소 버튼 클릭 시 팝업 닫기
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // 데이터베이스에서 아이템 정보 업데이트
                await updateItemInDatabase(
                  item['id'], // 아이템 ID
                  nameController.text, // 수정된 상품명
                  expirationController.text, // 수정된 소비기한
                );

                Navigator.pop(context); // 팝업 닫기
                await _loadItems(); // 데이터 새로고침
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 새 아이템 추가를 위한 팝업 띄우기
  void _addItem() {
    TextEditingController nameController = TextEditingController(); // 상품명 텍스트 컨트롤러
    TextEditingController expirationController = TextEditingController(); // 소비기한 텍스트 컨트롤러

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('상품 추가'), // 팝업 제목
          content: Column(
            mainAxisSize: MainAxisSize.min, // 팝업 크기를 내용에 맞게 설정
            children: [
              TextField(
                controller: nameController, // 상품명 입력 필드
                decoration: InputDecoration(labelText: '상품명'),
              ),
              TextField(
                controller: expirationController, // 소비기한 입력 필드
                decoration: InputDecoration(labelText: '소비기한'),
                onTap: () => _selectDate(context, expirationController, DateTime.now().toString()), // 날짜 선택 기능
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소 버튼 클릭 시 팝업 닫기
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // 데이터베이스에 새 아이템 추가
                await addItemToDatabase(
                  nameController.text, // 입력된 상품명
                  expirationController.text, // 입력된 소비기한
                );

                Navigator.pop(context); // 팝업 닫기
                await _loadItems(); // 데이터 새로고침
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  // 아이템 삭제
  void _deleteItem(int id) async {
    await deleteItemFromDatabase(id); // 데이터베이스에서 아이템 삭제
    await _loadItems(); // 데이터 새로고침
  }

  @override
  Widget build(BuildContext context) {
    // 유통기한을 기준으로 오름차순 정렬된 아이템 리스트 생성
    List<Map<String, dynamic>> sortedItems = List.from(items); // 원본 데이터를 복사
    sortedItems.sort((a, b) {
      DateTime expirationA = DateTime.parse(a['expirationDate']); // 첫 번째 아이템 소비기한
      DateTime expirationB = DateTime.parse(b['expirationDate']); // 두 번째 아이템 소비기한
      return expirationA.compareTo(expirationB); // 오름차순으로 정렬
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Data"), // 화면 제목
        backgroundColor: Colors.blueAccent, // 앱바 배경색
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.5), // 전체 여백
        child: SingleChildScrollView( // 화면이 스크롤 가능하도록 설정
          child: LayoutBuilder(
            builder: (context, constraints) {
              double availableWidth = constraints.maxWidth; // 화면 너비 계산

              return DataTable(
                columns: const [ // 테이블 열 헤더 정의
                  DataColumn(label: Text('상품명')),
                  DataColumn(label: Text('소비기한')),
                  DataColumn(label: Text('')),
                ],
                rows: sortedItems.map((item) { // 각 아이템 데이터 행 생성
                  return DataRow(cells: [
                    DataCell(
                      Container( // 상품명 셀
                        width: availableWidth * 0.2, // 셀 너비 설정
                        child: Text(
                          item['name'] ?? 'N/A', // 상품명 표시
                          maxLines: 1, // 최대 1줄
                          overflow: TextOverflow.ellipsis, // 텍스트 넘침 처리
                        ),
                      ),
                    ),
                    DataCell(
                      Container( // 소비기한 셀
                        width: availableWidth * 0.2, // 셀 너비 설정
                        child: Text(item['expirationDate'] ?? DateTime.now().toString()), // 소비기한 표시
                      ),
                    ),
                    DataCell(
                      Container( // 수정/삭제 버튼 셀
                        width: availableWidth * 0.3, // 셀 너비 설정
                        child: Row( // 버튼을 가로로 배치
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit), // 수정 아이콘
                              onPressed: () => _editItem(item), // 수정 함수 호출
                            ),
                            IconButton(
                              icon: Icon(Icons.delete), // 삭제 아이콘
                              onPressed: () => _deleteItem(item['id']), // 삭제 함수 호출
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
      floatingActionButton: FloatingActionButton( // 하단 오른쪽 '+' 버튼
        onPressed: _addItem, // 새 아이템 추가 함수 호출
        child: Icon(Icons.add), // '+' 아이콘
      ),
    );
  }
}
