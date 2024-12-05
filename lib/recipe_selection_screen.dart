// By 고경빈

import 'package:flutter/material.dart';
import 'package:barcodescanner/breakfast_screen.dart';
import 'package:barcodescanner/lunch_screen.dart';
import 'package:barcodescanner/dinner_screen.dart';
import 'package:barcodescanner/snack_screen.dart';

class RecipeSelectionScreen extends StatelessWidget {
  const RecipeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('레시피 선택'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 수직으로 가운데 정렬
                crossAxisAlignment: CrossAxisAlignment.center, // 버튼들을 수평으로 가운데 정렬
                children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                _buildButton(context, "아침", BreakfastScreen()),
        const SizedBox(width: 20),
        _buildButton(context, "점심", LunchScreen()),
    ],
    ),
    const SizedBox(height: 20),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    _buildButton(context, "저녁", DinnerScreen()),
    const SizedBox(width: 20),
    _buildButton(context, "간식", SnackScreen()),
    ],
    ),
    ],
    ),
    ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: Colors.blueAccent,
        fixedSize: Size(180, 180), // 버튼 크기 크게 설정
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}
