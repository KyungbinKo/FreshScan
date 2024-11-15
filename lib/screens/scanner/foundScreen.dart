import 'package:flutter/material.dart';

// QR 코드 인식 후 결과를 보여주는 화면
class FoundScreen extends StatefulWidget {
  final String value; // 인식된 QR 코드 값
  final Function() screenClose; // 화면 닫기 콜백 함수

  const FoundScreen({super.key, required this.value, required this.screenClose});

  @override
  State<FoundScreen> createState() => _FoundScreenState();
}

class _FoundScreenState extends State<FoundScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return RotatedBox(
              quarterTurns: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: Colors.white), // 뒤로가기 버튼
                onPressed: () => Navigator.pop(context, false), // 화면 닫기
              ),
            );
          },
        ),
        title: Text("Result", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), // 화면 제목
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Result: ", style: TextStyle(fontSize: 20)), // 결과 제목
              SizedBox(height: 20),
              Text(widget.value, style: TextStyle(fontSize: 16)), // 인식된 QR 코드 값
            ],
          ),
        ),
      ),
    );
  }
}
