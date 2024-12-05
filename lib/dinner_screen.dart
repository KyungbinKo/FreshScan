// By 고경빈

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'database_functions.dart'; // 데이터베이스에서 데이터를 불러오는 함수가 정의된 파일을 import

// 저녁 레시피 화면을 나타내는 Stateful 위젯
class DinnerScreen extends StatefulWidget {
  const DinnerScreen({super.key});

  @override
  _DinnerScreenState createState() => _DinnerScreenState();
}

// DinnerScreen의 상태를 관리하는 클래스
class _DinnerScreenState extends State<DinnerScreen> {
  List<String> dinnerItems = []; // 저녁 재료 리스트
  String recipeContent = ''; // GPT API에서 반환된 레시피 내용

  @override
  void initState() {
    super.initState();
    _loadDinnerItems(); // 화면 초기화 시 데이터베이스에서 저녁 재료를 로드
  }

  // 데이터베이스에서 상품명을 불러와 dinnerItems 리스트를 초기화
  Future<void> _loadDinnerItems() async {
    // 데이터베이스에서 모든 상품 정보를 가져옴
    List<Map<String, dynamic>> items = await fetchNames();

    // 상태를 갱신하여 상품명을 dinnerItems 리스트에 추가
    setState(() {
      dinnerItems = items.map((item) => item['name'] as String).toList();
    });

    // 저녁 재료가 비어있지 않다면 API를 호출하여 레시피를 요청
    if (dinnerItems.isNotEmpty) {
      await _fetchRecipeFromAPI(dinnerItems);
    }
  }

  // OpenAI GPT API를 사용해 저녁 레시피를 받아오는 함수
  Future<void> _fetchRecipeFromAPI(List<String> productList) async {
    final String apiUrl = 'https://api.openai.com/v1/chat/completions'; // OpenAI API URL
    final String apiKey = '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';
    // 사용자에게 제공할 프롬프트 작성
    String prompt = "다음 재료들로 저녁 레시피 3가지를 추천해 주세요: ${productList.join(", ")}. 간단한 조리법과 필요한 재료도 함께 출력해주세요. 출력은 한국어로 작성해주세요.";

    // API 요청에 필요한 JSON 형태의 데이터 구성
    final Map<String, dynamic> requestBody = {
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content": "사용자가 입력한 재료 목록을 바탕으로 저녁 레시피를 추천해주세요. 저녁 메뉴는 가족과 함께 먹기 좋은 든든한 메뉴입니다. 모든 조미료는 자유롭게 사용할 수 있습니다. 출력은 한국어로 레시피 이름, 재료, 조리법을 포함해야 합니다."
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
      // API 요청 전송
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(requestBody),
      );

      // 요청 성공 시 응답 처리
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩

        print('API Response: $jsonResponse'); // 디버깅용 출력

        // 응답 데이터에서 레시피 내용 추출
        if (jsonResponse.containsKey('choices') &&
            jsonResponse['choices'] is List &&
            jsonResponse['choices'].isNotEmpty) {
          final message = jsonResponse['choices'][0]['message'];
          if (message != null && message.containsKey('content')) {
            final String content = message['content'];

            setState(() {
              recipeContent = content; // 레시피 내용을 상태에 저장
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
        // 요청 실패 시 상태에 에러 메시지 저장
        setState(() {
          recipeContent = 'API 요청 실패: ${response.statusCode}';
        });
      }
    } catch (e) {
      // 예외 발생 시 상태에 에러 메시지 저장
      setState(() {
        recipeContent = '오류 발생: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저녁 레시피'), // 화면 제목
        backgroundColor: Colors.blueAccent, // 앱바 배경색
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 여백 설정
        child: Column(
          children: [
            // 레시피 내용이 비어 있으면 로딩 표시
            if (recipeContent.isEmpty)
              Align(
                alignment: Alignment.center, // 로딩 아이콘 중앙 정렬
                child: Padding(
                  padding: const EdgeInsets.only(top: 350), // 상단 여백 추가
                  child: const CircularProgressIndicator(), // 로딩 아이콘
                ),
              )
            else
            // 레시피 내용을 스크롤 가능한 위젯으로 표시
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '추천된 레시피:\n\n${recipeContent.replaceAll(RegExp(r'[#*]'), '')}', // 불필요한 문자 제거 후 출력
                    style: const TextStyle(fontSize: 16), // 텍스트 스타일 설정
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
