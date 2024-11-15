import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:barcodescanner/screens/scanner/QRscannerOverlay.dart';
import 'package:barcodescanner/screens/scanner/foundScreen.dart';

// QR 코드 스캐너 위젯
class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  MobileScannerController cameraController = MobileScannerController(); // 카메라 컨트롤러
  bool _screenOpened = false; // 스캔 결과 화면이 열렸는지 여부

  @override
  void initState() {
    super.initState();
    _screenWasClosed(); // 초기 상태 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // 반투명 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent, // 상단 바 색상
        title: Text("Scanner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          // MobileScanner 위젯을 사용해 QR 코드 인식
          MobileScanner(
            controller: cameraController,
            onDetect: _foundBarcode, // 바코드 감지 시 콜백
          ),
          // 스캔 오버레이 적용
          QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
        ],
      ),
    );
  }

  // 바코드를 감지했을 때 호출되는 함수
  void _foundBarcode(BarcodeCapture barcodeCapture) {
    // 감지된 모든 바코드를 콘솔에 출력
    for (var barcode in barcodeCapture.barcodes) {
      print("Detected barcode: ${barcode.rawValue}");
    }

    // 스캔 화면이 열리지 않았고 바코드가 감지되었을 때만 실행
    if (!_screenOpened && barcodeCapture.barcodes.isNotEmpty) {
      final String code = barcodeCapture.barcodes.first.rawValue ?? "___"; // 첫 번째 바코드 값
      _screenOpened = true; // 스크린 열림 상태 업데이트

      // FoundScreen으로 이동하여 감지된 바코드 표시
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FoundScreen(value: code, screenClose: _screenWasClosed)),
      ).then((value) {
        print(value); // FoundScreen에서 반환된 값 출력
        _screenWasClosed(); // 화면이 닫히면 상태 초기화
      });
    }
  }

  // 화면 닫힘 상태를 처리하는 함수
  void _screenWasClosed() {
    _screenOpened = false; // 스크린 열림 상태 초기화
  }
}
