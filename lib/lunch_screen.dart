// By 고경빈

import 'dart:convert'; // JSON 데이터를 처리하기 위한 모듈
import 'package:flutter/material.dart'; // Flutter UI 구성에 필요한 패키지
import 'package:http/http.dart' as http; // HTTP 요청을 보내기 위한 패키지

import 'database_functions.dart'; // 데이터베이스에서 데이터를 불러오는 함수가 정의된 파일을 import

// 점심 레시피 화면 클래스 정의
class LunchScreen extends StatefulWidget {
  const LunchScreen({super.key});

  @override
  _LunchScreenState createState() => _LunchScreenState();
}

// 상태를 관리하는 클래스
class _LunchScreenState extends State<LunchScreen> {
  List<String> lunchItems = []; // 데이터베이스에서 불러온 점심 레시피 재료 목록
  String recipeContent = ''; // GPT API에서 반환된 레시피 내용 저장

  @override
  void initState() {
    super.initState();
    _loadLunchItems(); // 초기화 시 데이터베이스에서 데이터 로드
  }

  // 데이터베이스에서 상품명만 불러오는 비동기 함수
  Future<void> _loadLunchItems() async {
    List<Map<String, dynamic>> items = await fetchNames(); // fetchNames()는 데이터베이스 함수 호출

    setState(() {
      lunchItems = items.map((item) => item['name'] as String).toList(); // 상품명 추출 및 리스트에 저장
    });

    if (lunchItems.isNotEmpty) {
      await _fetchRecipeFromAPI(lunchItems); // 상품명이 있으면 GPT API로 레시피 요청
    }
  }

  // GPT API를 통해 점심 레시피를 가져오는 비동기 함수
  Future<void> _fetchRecipeFromAPI(List<String> productList) async {
    final String apiUrl = 'https://api.openai.com/v1/chat/completions'; // OpenAI API URL
    final String apiKey = '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';

    // 사용자 입력과 함께 API 요청에 보낼 프롬프트 생성
    String prompt =
        "다음 재료들로 점심 레시피 3가지를 추천해 주세요: ${productList.join(", ")}. 간단한 조리법과 필요한 재료도 함께 출력해주세요. 출력은 한국어로 작성해주세요.";

    // API 요청에 필요한 데이터 구조 생성
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
      "temperature": 1.0, // 응답의 창의성을 조절하는 매개변수
      "top_p": 0.9, // 샘플링에 사용할 확률 분포 상위 비율
      "frequency_penalty": 0.0 // 단어 반복 페널티 설정
    };

    try {
      // API 요청 전송
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json', // JSON 형식 요청
          'Authorization': 'Bearer $apiKey', // 인증 키 포함
        },
        body: json.encode(requestBody), // 요청 데이터 JSON 변환 후 전송
      );

      if (response.statusCode == 200) {
        // 응답 성공 시 데이터 파싱
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes)); // 응답 UTF-8 디코딩

        print('API Response: $jsonResponse'); // 디버깅용 응답 출력

        if (jsonResponse.containsKey('choices') &&
            jsonResponse['choices'] is List &&
            jsonResponse['choices'].isNotEmpty) {
          final message = jsonResponse['choices'][0]['message'];
          if (message != null && message.containsKey('content')) {
            final String content = message['content'];

            setState(() {
              recipeContent = content.replaceAll(RegExp(r'[#*]'), ''); // 불필요한 기호 제거
            });
          } else {
            setState(() {
              recipeContent = '메시지 내용이 없습니다.'; // 메시지 오류 처리
            });
          }
        } else {
          setState(() {
            recipeContent = '예상과 다른 응답 형식입니다: $jsonResponse'; // 응답 형식 오류 처리
          });
        }
      } else {
        setState(() {
          recipeContent = 'API 요청 실패: ${response.statusCode}'; // HTTP 상태 코드 기반 오류 처리
        });
      }
    } catch (e) {
      setState(() {
        recipeContent = '오류 발생: $e'; // 네트워크 또는 기타 예외 처리
      });
    }
  }

  // UI 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('점심 레시피'), // 화면 상단 제목
        backgroundColor: Colors.blueAccent, // 제목 배경 색상
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 여백 설정
        child: Column(
          children: [
            if (recipeContent.isEmpty) // 레시피 데이터가 로드되지 않은 경우
              Align(
                alignment: Alignment.center, // 로딩 애니메이션 위치 중앙 정렬
                child: Padding(
                  padding: const EdgeInsets.only(top: 350), // 상단 여백 설정
                  child: const CircularProgressIndicator(), // 로딩 스피너 표시
                ),
              )
            else // 레시피 데이터가 로드된 경우
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '추천된 레시피:\n\n$recipeContent', // API로부터 반환된 레시피 출력
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
