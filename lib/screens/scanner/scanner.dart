import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:barcodescanner/screens/scanner/QRscannerOverlay.dart';
import 'package:barcodescanner/screens/scanner/foundScreen.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  void initState() {
    super.initState();
    _screenWasClosed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text("Scanner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _foundBarcode,
          ),
          QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
        ],
      ),
    );
  }

  void _foundBarcode(BarcodeCapture barcodeCapture) {
    // 모든 바코드를 반복하여 출력
    for (var barcode in barcodeCapture.barcodes) {
      print("Detected barcode: ${barcode.rawValue}");
    }

    if (!_screenOpened && barcodeCapture.barcodes.isNotEmpty) {
      // 첫 번째 바코드를 가져와서 화면을 여는 논리
      final String code = barcodeCapture.barcodes.first.rawValue ?? "___";
      _screenOpened = true;

      // Navigate to FoundScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FoundScreen(value: code, screenClose: _screenWasClosed)),
      ).then((value) {
        print(value);
        _screenWasClosed(); // Reset state when the screen is closed
      });
    }
  }

  void _screenWasClosed() {
    _screenOpened = false; // Reset the screen opened state
  }
}
