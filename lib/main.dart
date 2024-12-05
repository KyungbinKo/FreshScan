// By 고경빈, 한창호

// 필수 Flutter 패키지와 프로젝트 관련 파일 임포트
import 'dart:async';
import 'package:flutter/material.dart';
import 'database_functions.dart';
import 'expiry_alert.dart';
import 'receipt_recognition_screen.dart';
import 'data_screen.dart'; // My Data 화면 추가
import 'calendar_screen.dart'; // 캘린더 화면 추가
import 'recipe_selection_screen.dart'; // 레시피 선택 화면 추가

// 앱의 진입점
void main() {
  runApp(const MyApp());
}

// 메인 앱 위젯
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueAccent, // 앱의 기본 테마 색상 설정
      ),
      home: const SplashScreen(), // 첫 화면으로 SplashScreen 지정
    );
  }
}

// 앱의 초기 로딩 화면
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// SplashScreen의 상태 관리 클래스
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 5초 후 홈 화면(HomeScreen)으로 이동
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100, // 배경색 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
          children: [
            // 앱 이름 표시
            const Text(
              "FreshScan",
              style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 20), // 간격 추가
            const CircularProgressIndicator(), // 로딩 인디케이터
          ],
        ),
      ),
    );
  }
}

// 홈 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// HomeScreen의 상태 관리 클래스
class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownPopup = false; // 팝업 표시 여부 상태 변수

  @override
  Widget build(BuildContext context) {
    // 앱 첫 실행 시 만료 경고 팝업 표시
    if (!_hasShownPopup) {
      _hasShownPopup = true; // 팝업을 한 번만 띄우기 위해 true로 설정
      Future.delayed(Duration.zero, () {
        showExpiryAlert(context); // 만료 경고 팝업 호출
        // 상단 알림 바 띄우기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('소비기한 임박 상품이 있습니다!'),
            duration: Duration(seconds: 10), // 알림이 5초 동안 표시됨
            backgroundColor: Colors.blueAccent, // 알림 색상
          ),
        );
        // showOverlayAlert(context); // 화면 상단 알림
      });
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50, // 배경색 설정
      appBar: AppBar(
        title: Text('FreshScan'), // 앱바 제목
        backgroundColor: Colors.blueAccent, // 앱바 색상
        actions: [
          // 바코드 스캔 버튼
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.center_focus_weak),
            onPressed: () {}, // 현재는 동작 없음
          ),
          // 캘린더 화면으로 이동
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarScreen()),
              );
            },
          ),
          // 사용자 계정 아이콘
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {}, // 현재는 동작 없음
          ),
        ],
        centerTitle: false, // 제목 정렬 설정
      ),
      drawer: Drawer( // 네비게이션 메뉴
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // 메뉴 헤더
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue, // 헤더 배경색
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // 상품 등록 메뉴
            ListTile(
              leading: Icon(Icons.center_focus_weak),
              title: Text('상품 등록'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReceiptRecognitionScreen()),
                );
              },
            ),
            // My Data 메뉴
            ListTile(
              leading: Icon(Icons.format_list_bulleted),
              title: Text('My Data'),
              onTap: () async {
                List<Map<String, dynamic>> items = await fetchDataFromDatabase(); // 데이터베이스에서 데이터 불러오기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DataScreen(items: items), // My Data 화면으로 이동
                  ),
                );
              },
            ),
            // 레시피 추천 메뉴
            ListTile(
              leading: Icon(Icons.recommend),
              title: Text('레시피 추천'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipeSelectionScreen()),
                );
              },
            ),
            // My 캘린더 메뉴
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('My 캘린더'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarScreen()),
                );
              },
            ),
            const Divider(height: 50), // 구분선
            // 설정 메뉴
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('설정'),
              onTap: () {}, // 현재는 동작 없음
            ),
            // 로그아웃 메뉴
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('로그아웃'),
              onTap: () {
                // 로그아웃 동작
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 버튼들 가운데 정렬
          children: [
            // 상품 등록 버튼
            _buildButton(context, "상품 등록", ReceiptRecognitionScreen()),
            const SizedBox(height: 20), // 버튼 간격
            // My Data 버튼
            _buildButton(context, "My Data", () async {
              List<Map<String, dynamic>> items = await fetchDataFromDatabase(); // 데이터베이스에서 데이터 불러오기
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataScreen(items: items), // My Data 화면으로 이동
                ),
              );
            }),
            const SizedBox(height: 20),
            // 레시피 추천 버튼
            _buildButton(context, "레시피 추천", () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeSelectionScreen()), // 레시피 추천 화면으로 이동
              );
            }),
            const SizedBox(height: 20),
            // My 캘린더 버튼
            _buildButton(context, "My 캘린더", () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarScreen()), // 캘린더 화면으로 이동
              );
            }),
          ],
        ),
      ),
    );
  }

  // 버튼 생성 메서드
  Widget _buildButton(BuildContext context, String text, dynamic screen) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8, // 버튼 너비 설정
      child: ElevatedButton(
        onPressed: screen is Widget
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen), // 특정 화면으로 이동
          );
        }
            : screen, // 비동기 작업 처리
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15), // 버튼 패딩
          backgroundColor: Colors.blueAccent, // 버튼 배경색
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 22, color: Colors.white), // 버튼 텍스트 스타일
        ),
      ),
    );
  }
}
