// main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'receipt_recognition_screen.dart';

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
      home: SplashScreen(),
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
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
            Text(
              "FreshScan",
              style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: Text(
            "FreshScan",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, "영수증 인식", ReceiptRecognitionScreen()),
            SizedBox(height: 20),
            _buildButton(context, "My Data", null),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget? screen) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
        onPressed: screen != null
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
            : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.blueAccent,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 22, color: Colors.white), // 텍스트 색상과 폰트 크기 변경
        ),
      ),
    );
  }
}
