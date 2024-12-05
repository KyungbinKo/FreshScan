// By 고경빈

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'database_functions.dart'; // 데이터베이스에서 데이터를 불러오는 함수가 정의된 파일을 import

class LunchScreen extends StatefulWidget {
  const LunchScreen({super.key});

  @override
  _LunchScreenState createState() => _LunchScreenState();
}

class _LunchScreenState extends State<LunchScreen> {
  // 점심 레시피 리스트
  List<String> lunchItems = [];
  String recipeContent = ''; // GPT API에서 반환된 레시피 내용

  @override
  void initState() {
    super.initState();
    _loadLunchItems();
  }

  // 데이터베이스에서 상품명만 불러오기
  Future<void> _loadLunchItems() async {
    List<Map<String, dynamic>> items = await fetchNames();

    setState(() {
      lunchItems = items.map((item) => item['name'] as String).toList();
    });

    if (lunchItems.isNotEmpty) {
      await _fetchRecipeFromAPI(lunchItems);
    }
  }

  // GPT API에서 점심 레시피 가져오기
  Future<void> _fetchRecipeFromAPI(List<String> productList) async {
    final String apiUrl = 'https://api.openai.com/v1/chat/completions';
    final String apiKey = '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';

    String prompt = "다음 재료들로 점심 레시피 3가지를 추천해 주세요: ${productList.join(", ")}. 간단한 조리법과 필요한 재료도 함께 출력해주세요. 출력은 한국어로 작성해주세요.";

    final Map<String, dynamic> requestBody = {
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content": "사용자가 입력한 재료 목록을 바탕으로 점심 레시피를 추천해주세요. 점심 메뉴는 칼로리가 높고 든든하게 먹을 수 있는 음식을 제시해주세요. 모든 조미료는 자유롭게 사용할 수 있습니다. 출력은 한국어로, 레시피 이름과 재료, 조리법을 포함해야 합니다."
        },
        {
          "role": "user",
          "content": prompt
        }
      ],
      "temperature": 1.0,
      "top_p": 0.9,
      "frequency_penalty": 0.0
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));  // 응답을 UTF-8로 디코딩

        print('API Response: $jsonResponse');

        if (jsonResponse.containsKey('choices') &&
            jsonResponse['choices'] is List &&
            jsonResponse['choices'].isNotEmpty) {

          final message = jsonResponse['choices'][0]['message'];
          if (message != null && message.containsKey('content')) {
            final String content = message['content'];

            setState(() {
              recipeContent = content.replaceAll(RegExp(r'[#*]'), ''); // #, * 기호 제거
            });
          } else {
            setState(() {
              recipeContent = '메시지 내용이 없습니다.';
            });
          }
        } else {
          setState(() {
            recipeContent = '예상과 다른 응답 형식입니다: $jsonResponse';
          });
        }
      } else {
        setState(() {
          recipeContent = 'API 요청 실패: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        recipeContent = '오류 발생: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('점심 레시피'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (recipeContent.isEmpty)
              Align(
                alignment: Alignment.center, // 좌우 중앙
                child: Padding(
                  padding: const EdgeInsets.only(top: 350), // 상단 여백으로 아래로 위치 조정
                  child: const CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '추천된 레시피:\n\n$recipeContent',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
