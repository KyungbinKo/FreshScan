// By 고경빈
import 'dart:convert'; // JSON 변환에 필요한 라이브러리 가져오기
import 'package:flutter/material.dart'; // Flutter 위젯 사용을 위한 라이브러리
import 'package:http/http.dart' as http; // HTTP 요청을 위한 라이브러리

import 'database_functions.dart'; // 데이터베이스 관련 함수 가져오기

// 아침 레시피 화면을 나타내는 위젯 정의
class BreakfastScreen extends StatefulWidget {
  const BreakfastScreen({super.key}); // 생성자 선언

  @override
  _BreakfastScreenState createState() => _BreakfastScreenState(); // 상태 클래스 생성
}

// 상태 클래스 정의
class _BreakfastScreenState extends State<BreakfastScreen> {
  List<String> breakfastItems = []; // 아침 재료 목록을 저장하는 변수
  String recipeContent = ''; // GPT API에서 받은 레시피 내용을 저장하는 변수

  @override
  void initState() {
    super.initState(); // 초기화 시 부모 클래스의 initState 호출
    _loadBreakfastItems(); // 아침 재료 로드 함수 호출
  }

  // 데이터베이스에서 아침 재료를 불러오는 비동기 함수
  Future<void> _loadBreakfastItems() async {
    List<Map<String, dynamic>> items = await fetchNames(); // 데이터베이스에서 이름 목록 가져오기

    setState(() {
      breakfastItems = items.map((item) => item['name'] as String).toList(); // 이름만 추출하여 리스트에 저장
    });

    if (breakfastItems.isNotEmpty) { // 재료가 있을 경우
      await _fetchRecipeFromAPI(breakfastItems); // API를 호출하여 레시피 가져오기
    }
  }

  // GPT API를 통해 레시피를 요청하는 비동기 함수
  Future<void> _fetchRecipeFromAPI(List<String> productList) async {
    final String apiUrl = 'https://api.openai.com/v1/chat/completions'; // API URL
    final String apiKey = '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';
    // GPT 모델에 전달할 프롬프트 정의
    String prompt =
        "다음 재료들로 아침 레시피 3가지를 추천해 주세요: ${productList.join(", ")}. 간단한 조리법과 필요한 재료도 함께 출력해주세요. 출력은 한국어로 작성해주세요.";

    final Map<String, dynamic> requestBody = {
      "model": "gpt-4o-mini", // 사용할 GPT 모델 지정
      "messages": [
        {
          "role": "system",
          "content":
          "사용자가 입력한 재료 목록을 바탕으로 아침 레시피를 추천해주세요. 아침 메뉴는 만들기 쉽고, 가볍게 먹기 좋은 음식입니다. 모든 조미료는 자유롭게 사용할 수 있습니다. 출력은 한국어로, 레시피 이름과 재료, 조리법을 포함해야 합니다."
        },
        {
          "role": "user",
          "content": prompt // 사용자 입력
        }
      ],
      "temperature": 1.0, // 응답 다양성 설정
      "top_p": 0.9, // 확률 분포의 상위 비율 설정
      "frequency_penalty": 0.0 // 동일한 응답 빈도 제한
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl), // API URL로 POST 요청
        headers: {
          'Content-Type': 'application/json', // 요청 헤더 설정
          'Authorization': 'Bearer $apiKey', // 인증 헤더에 API 키 포함
        },
        body: json.encode(requestBody), // 요청 본문을 JSON으로 인코딩
      );

      if (response.statusCode == 200) { // 응답 코드가 200(성공)일 경우
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes)); // JSON 응답 디코딩

        print('API Response: $jsonResponse'); // 디버깅용 응답 출력

        if (jsonResponse.containsKey('choices') &&
            jsonResponse['choices'] is List &&
            jsonResponse['choices'].isNotEmpty) {
          // choices 필드 확인 및 첫 번째 선택 내용 가져오기
          final message = jsonResponse['choices'][0]['message'];
          if (message != null && message.containsKey('content')) {
            final String content = message['content']; // 메시지 내용 추출

            setState(() {
              recipeContent = content; // 레시피 내용을 상태에 저장
            });
          } else {
            setState(() {
              recipeContent = '메시지 내용이 없습니다.'; // 메시지 없음 처리
            });
          }
        } else {
          setState(() {
            recipeContent = '예상과 다른 응답 형식입니다: $jsonResponse'; // 응답 형식 오류 처리
          });
        }
      } else {
        setState(() {
          recipeContent = 'API 요청 실패: ${response.statusCode}'; // 실패 시 상태 업데이트
        });
      }
    } catch (e) {
      setState(() {
        recipeContent = '오류 발생: $e'; // 예외 발생 시 처리
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면 UI 빌드
    return Scaffold(
      appBar: AppBar(
        title: const Text('아침 레시피'), // 화면 제목
        backgroundColor: Colors.blueAccent, // 앱바 색상 설정
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 여백 설정
        child: Column(
          children: [
            if (recipeContent.isEmpty) // 레시피가 아직 없으면 로딩 표시
              Align(
                alignment: Alignment.center, // 좌우 중앙 정렬
                child: Padding(
                  padding: const EdgeInsets.only(top: 350), // 상단 여백 추가
                  child: const CircularProgressIndicator(), // 로딩 스피너 표시
                ),
              )
            else // 레시피가 있으면 출력
              Expanded(
                child: SingleChildScrollView(
                    child: Text(
                      '추천된 레시피:\n\n${recipeContent.replaceAll(RegExp(r'[#*]'), '')}', // 레시피 내용 표시
                      style: const TextStyle(fontSize: 16), // 텍스트 스타일 설정
                    )
                ),
              ),
          ],
        ),
      ),
    );
  }
}
