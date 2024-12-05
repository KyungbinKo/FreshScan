// By 고경빈

import 'dart:convert'; // JSON 변환을 위한 라이브러리 임포트
import 'package:flutter/material.dart'; // Flutter UI 구성용 라이브러리 임포트
import 'package:http/http.dart' as http; // HTTP 요청을 보내기 위한 라이브러리 임포트
import 'database_functions.dart'; // 데이터베이스에서 데이터를 불러오는 함수가 정의된 파일을 import

// SnackScreen 클래스 정의 (StatefulWidget을 상속받음)
class SnackScreen extends StatefulWidget {
  const SnackScreen({super.key});

  @override
  _SnackScreenState createState() => _SnackScreenState(); // 상태를 관리하는 _SnackScreenState 클래스 생성
}

// _SnackScreenState 클래스 정의
class _SnackScreenState extends State<SnackScreen> {
  List<String> snackItems = []; // 간식 리스트를 저장할 변수
  String recipeContent = ''; // GPT API에서 반환된 레시피 내용을 저장할 변수

  @override
  void initState() {
    super.initState();
    _loadSnackItems(); // 화면 초기화 시 간식 목록을 로드
  }

  // 데이터베이스에서 간식 아이템명만 불러오기
  Future<void> _loadSnackItems() async {
    // fetchNames 함수로 데이터베이스에서 상품명만 가져옴
    List<Map<String, dynamic>> items = await fetchNames();

    // 가져온 데이터를 snackItems 리스트에 할당
    setState(() {
      snackItems = items.map((item) => item['name'] as String).toList();
    });

    // snackItems가 비어 있지 않으면 API에서 레시피를 가져옴
    if (snackItems.isNotEmpty) {
      await _fetchRecipeFromAPI(snackItems);
    }
  }

  // GPT API를 통해 간식 레시피를 받아오기
  Future<void> _fetchRecipeFromAPI(List<String> productList) async {
    final String apiUrl = 'https://api.openai.com/v1/chat/completions'; // API URL
    final String apiKey = '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';
    // 사용자 입력으로 전달될 프롬프트 생성
    String prompt = "다음 재료들로 간식 레시피 3가지를 추천해 주세요: ${productList.join(", ")}. 간단한 조리법과 필요한 재료도 함께 출력해주세요. 출력은 한국어로 작성해주세요.";

    // API 요청을 위한 바디 설정
    final Map<String, dynamic> requestBody = {
      "model": "gpt-4", // 사용하려는 모델 설정
      "messages": [
        {
          "role": "system",
          "content": "사용자가 입력한 재료 목록을 바탕으로 간식 레시피를 추천해주세요. 간식 메뉴는 만들기 쉽고, 아이들이 좋아하는 핑거푸드입니다. 모든 조미료는 자유롭게 사용할 수 있습니다. 출력은 한국어로 레시피 이름, 재료, 조리법을 포함해야 합니다."
        },
        {
          "role": "user",
          "content": prompt // 사용자 프롬프트
        }
      ],
      "temperature": 1.0, // 응답의 창의성 정도
      "top_p": 0.9, // 확률 분포 설정
      "frequency_penalty": 0.0 // 반복을 방지하기 위한 패널티
    };

    try {
      // HTTP POST 요청을 보내 API 호출
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json', // JSON 형식으로 데이터 전송
          'Authorization': 'Bearer $apiKey', // Authorization 헤더에 API 키 포함
        },
        body: json.encode(requestBody), // 요청 본문을 JSON으로 인코딩
      );

      if (response.statusCode == 200) {
        // 응답이 성공적이면 JSON 응답을 디코딩
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));

        print('API Response: $jsonResponse'); // 디버깅을 위한 응답 출력

        if (jsonResponse.containsKey('choices') &&
            jsonResponse['choices'] is List &&
            jsonResponse['choices'].isNotEmpty) {
          final message = jsonResponse['choices'][0]['message']; // 첫 번째 선택지의 메시지 추출
          if (message != null && message.containsKey('content')) {
            final String content = message['content']; // 레시피 내용 추출

            // 레시피 내용을 화면에 표시
            setState(() {
              recipeContent = content;
            });
          } else {
            setState(() {
              recipeContent = '메시지 내용이 없습니다.'; // 메시지 내용이 없을 경우
            });
          }
        } else {
          setState(() {
            recipeContent = '예상과 다른 응답 형식입니다: $jsonResponse'; // 응답 형식이 예상과 다를 경우
          });
        }
      } else {
        setState(() {
          recipeContent = 'API 요청 실패: ${response.statusCode}'; // 요청 실패 시 오류 메시지 표시
        });
      }
    } catch (e) {
      setState(() {
        recipeContent = '오류 발생: $e'; // 예외 발생 시 오류 메시지 표시
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('간식 레시피'), // 상단 AppBar 제목
        backgroundColor: Colors.blueAccent, // AppBar 배경색
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 전체 여백 설정
        child: Column(
          children: [
            // 레시피가 로딩 중일 때 로딩 인디케이터 표시
            if (recipeContent.isEmpty)
              Align(
                alignment: Alignment.center, // 좌우 중앙 정렬
                child: Padding(
                  padding: const EdgeInsets.only(top: 350), // 상단 여백으로 위치 조정
                  child: const CircularProgressIndicator(), // 로딩 인디케이터
                ),
              )
            // 레시피가 로드된 후 화면에 표시
            else
              Expanded(
                child: SingleChildScrollView(
                    child: Text(
                      '추천된 레시피:\n\n${recipeContent.replaceAll(RegExp(r'[#*]'), '')}', // GPT에서 받은 레시피 내용 표시
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
