import 'package:flutter/material.dart';

class DataScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const DataScreen({super.key, required this.items});

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
      ),
    );
  }
}
