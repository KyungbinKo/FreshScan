import 'dart:async';
import 'package:flutter/material.dart';
import 'database_functions.dart';
import 'expiry_alert.dart';
import 'receipt_recognition_screen.dart';
import 'data_screen.dart'; // 외부 화면 파일 추가
import 'calendar_screen.dart';
import 'recipe_selection_screen.dart'; // 레시피 선택 화면

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 앱 실행 후 5초 뒤에 HomeScreen으로 이동하고 팝업을 띄운다.
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
      backgroundColor: Colors.lightBlue.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "FreshScan",
              style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownPopup = false;

  @override
  Widget build(BuildContext context) {
    // 앱 시작 후 첫 번째로만 팝업을 띄운다.
    if (!_hasShownPopup) {
      _hasShownPopup = true;
      Future.delayed(Duration.zero, () {
        showExpiryAlert(context);
      });
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: Text('FreshScan'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.center_focus_weak),
            onPressed: () {},
          ),
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
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
        centerTitle: false,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
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
            ListTile(
                leading: Icon(Icons.format_list_bulleted),
                title: Text('My Data'),
                onTap: () async {
                  List<Map<String, dynamic>> items = await fetchDataFromDatabase();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DataScreen(items: items),
                    ),
                  );
                }
            ),
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
            const Divider(height:50),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('설정'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('로그아웃'),
              onTap: () {
                // Logout을 눌렀을 때의 동작
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, "상품 등록", ReceiptRecognitionScreen()),
            const SizedBox(height: 20),
            _buildButton(context, "My Data", () async {
              List<Map<String, dynamic>> items = await fetchDataFromDatabase();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataScreen(items: items),
                ),
              );
            }),
            const SizedBox(height: 20),
            _buildButton(context, "레시피 추천", () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeSelectionScreen()),
              );
            }),
            const SizedBox(height: 20),
            _buildButton(context, "My 캘린더", () async {
              List<Map<String, dynamic>> items = await fetchDataFromDatabase();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(),
                ),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, dynamic screen) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
        onPressed: screen is Widget
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
            : screen,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.blueAccent,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }
}