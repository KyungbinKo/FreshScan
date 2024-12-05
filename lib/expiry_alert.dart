import 'package:flutter/material.dart';
import 'database_functions.dart'; // 데이터베이스에서 유통기한 임박 상품을 가져오는 함수

// 유통기한 임박 상품을 확인하고 팝업을 띄우는 함수
Future<void> showExpiryAlert(BuildContext context) async {
  // 유통기한이 임박한 상품 데이터 가져오기
  List<Map<String, dynamic>> items = await fetchDataFromDatabase();

  // 데이터베이스에서 가져온 데이터를 로그로 출력하여 확인
  print('Fetched items from database: $items');

  // 유통기한이 임박한 항목을 모두 출력하기 위해 모든 항목을 확인
  DateTime currentDate = DateTime.now();
  List<Map<String, dynamic>> expiringItems = []; // 유통기한이 임박한 상품을 저장할 리스트

  for (var item in items) {
    // 소비기한 정보 가져오기
    String? expirationDateString = item['expirationDate']; // 'expirationDate'로 수정

    if (expirationDateString == null || expirationDateString.isEmpty) {
      // 소비기한 정보가 없거나 비어있는 경우 건너뜀
      continue;
    }

    DateTime expirationDate;
    try {
      expirationDate = DateTime.parse(expirationDateString);
    } catch (e) {
      // 유효하지 않은 날짜 형식일 경우 처리
      continue;
    }

    // 유통기한이 3일 이내인 상품이 있으면 리스트에 추가
    if (expirationDate.isBefore(currentDate.add(const Duration(days: 3)))) {
      // 남은 일수를 계산
      int remainingDays = expirationDate.difference(currentDate).inDays;

      // 유통기한 임박 상품 추가
      expiringItems.add({
        'name': item['name'],
        'remainingDays': remainingDays,
        'expirationDate': expirationDate
      });
    }
  }

  // 유통기한이 임박한 상품이 있으면 알림을 띄움
  if (expiringItems.isNotEmpty) {
    // 유통기한 임박 상품을 유통기한이 가까운 순으로 정렬
    expiringItems.sort((a, b) => a['expirationDate'].compareTo(b['expirationDate']));

    // 모든 유통기한 임박 상품을 하나의 알림 창에 출력
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('소비기한 임박'),
          content: SingleChildScrollView( // 내용이 많으면 스크롤 가능하도록 설정
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: expiringItems
                  .map((item) => Text('${item['name']}의 소비기한이 ${item['remainingDays']}일 남았습니다.'))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
