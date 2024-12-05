// By 고경빈

// 필요한 Flutter 및 화면 관련 패키지 임포트
import 'package:flutter/material.dart';
import 'package:barcodescanner/breakfast_screen.dart'; // 아침 레시피 화면
import 'package:barcodescanner/lunch_screen.dart'; // 점심 레시피 화면
import 'package:barcodescanner/dinner_screen.dart'; // 저녁 레시피 화면
import 'package:barcodescanner/snack_screen.dart'; // 간식 레시피 화면

// 레시피 선택 화면 위젯 정의
class RecipeSelectionScreen extends StatelessWidget {
  const RecipeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 AppBar 설정
        appBar: AppBar(
          title: const Text('레시피 선택'), // 화면 제목
          backgroundColor: Colors.blueAccent, // AppBar 배경색 설정
        ),
        body: Center(
          // 화면 중앙에 콘텐츠 배치
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 세로 방향으로 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 가로 방향으로 중앙 정렬
            children: [
              // 첫 번째 행: 아침과 점심 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 행의 버튼들을 중앙에 배치
                children: [
                  _buildButton(context, "아침", BreakfastScreen()), // 아침 버튼
                  const SizedBox(width: 20), // 버튼 간 간격
                  _buildButton(context, "점심", LunchScreen()), // 점심 버튼
                ],
              ),
              const SizedBox(height: 20), // 행 간 간격
              // 두 번째 행: 저녁과 간식 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 행의 버튼들을 중앙에 배치
                children: [
                  _buildButton(context, "저녁", DinnerScreen()), // 저녁 버튼
                  const SizedBox(width: 20), // 버튼 간 간격
                  _buildButton(context, "간식", SnackScreen()), // 간식 버튼
                ],
              ),
            ],
          ),
        ));
  }

  // 버튼 생성 함수
  Widget _buildButton(BuildContext context, String text, Widget screen) {
    return ElevatedButton(
      // 버튼 클릭 시 화면 이동
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen), // 대상 화면으로 이동
        );
      },
      // 버튼 스타일 설정
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15), // 버튼 내부 여백
        backgroundColor: Colors.blueAccent, // 버튼 배경색
        fixedSize: Size(180, 180), // 버튼 고정 크기 설정
      ),
      // 버튼 텍스트 스타일
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, color: Colors.white), // 텍스트 크기 및 색상 설정
      ),
    );
  }
}
