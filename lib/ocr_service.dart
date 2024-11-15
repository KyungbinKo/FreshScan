// ocr_service.dart
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

// OCR 서비스 클래스 정의
class OCRService {
  final ImagePicker _picker = ImagePicker(); // 이미지 선택을 위한 ImagePicker 인스턴스

  // 이미지 선택 함수
  // source에 따라 카메라 또는 갤러리에서 이미지를 선택하여 반환
  Future<XFile?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    return image;
  }

  // OCR 인식 함수
  // 선택된 이미지에서 텍스트를 추출하여 반환
  Future<String> getRecognizedText(XFile image) async {
    final InputImage inputImage = InputImage.fromFilePath(image.path); // 파일 경로에서 이미지 로드

    // 텍스트 인식기 초기화 (한글 인식을 위해 한국어 스크립트 사용)
    final textRecognizer = GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.korean);

    // 이미지에서 텍스트 인식
    RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close(); // 사용 후 인식기 리소스 해제

    List<String> koreanWords = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        // 한글만 추출하여 각 줄에 추가
        String lineText = _extractKoreanText(line.text);
        if (lineText.isNotEmpty) {
          koreanWords.add(lineText);
        }
      }
    }

    // 각 추출된 단어를 한 줄씩 반환
    return koreanWords.join("\n");
  }

  // 한글만 추출하여 반환하는 함수
  // 입력 텍스트에서 한글 문자만 필터링(숫자 X)
  String _extractKoreanText(String text) {
    RegExp regExp = RegExp(r'[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]+'); // 한글 패턴 정의
    Iterable<Match> matches = regExp.allMatches(text);

    // 한글 문자들을 이어 붙여서 반환
    return matches.map((match) => match.group(0)).join('');
  }
}
