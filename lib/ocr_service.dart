// ocr_service.dart
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class OCRService {
  final ImagePicker _picker = ImagePicker();

  // 이미지 선택 함수
  Future<XFile?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    return image;
  }

  // OCR 인식 함수
  Future<String> getRecognizedText(XFile image) async {
    final InputImage inputImage = InputImage.fromFilePath(image.path);

    final textRecognizer =
    GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.korean);

    RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    String scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText += line.text + "\n";
      }
    }

    return scannedText;
  }
}
