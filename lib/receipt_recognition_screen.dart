// receipt_recognition_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ocr_service.dart';

class ReceiptRecognitionScreen extends StatefulWidget {
  @override
  _ReceiptRecognitionScreenState createState() => _ReceiptRecognitionScreenState();
}

class _ReceiptRecognitionScreenState extends State<ReceiptRecognitionScreen> {
  XFile? _image;
  String scannedText = "";
  final OCRService _ocrService = OCRService();

  Future<void> _getImageAndRecognizeText(ImageSource source) async {
    final XFile? pickedImage = await _ocrService.pickImage(source);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      String text = await _ocrService.getRecognizedText(pickedImage);
      setState(() {
        scannedText = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: Text("영수증 인식"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30, width: double.infinity),
          _buildPhotoArea(),
          _buildRecognizedText(),
          SizedBox(height: 20),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    return _image != null
        ? Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: FileImage(File(_image!.path)),
          fit: BoxFit.cover,
        ),
      ),
    )
        : Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          "이미지를 선택하세요",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildRecognizedText() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        scannedText,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _getImageAndRecognizeText(ImageSource.camera),
          child: Text("카메라",
            style: TextStyle(fontSize: 22, color: Colors.white), // 텍스트 색상과 폰트 크기 변경
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            backgroundColor: Colors.blueAccent,
          ),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: () => _getImageAndRecognizeText(ImageSource.gallery),
          child: Text("갤러리",
            style: TextStyle(fontSize: 22, color: Colors.white), // 텍스트 색상과 폰트 크기 변경
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            backgroundColor: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}
