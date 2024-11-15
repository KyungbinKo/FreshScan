import 'package:flutter/material.dart';

// QR 코드 스캐너 오버레이 위젯 클래스 정의
class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay({super.key, required this.overlayColour});

  final Color overlayColour; // 오버레이 색상

  @override
  Widget build(BuildContext context) {
    // 스캔 영역 크기를 디바이스 화면 크기에 따라 조정
    double scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 330.0;

    // 오버레이 디자인 설정
    return Stack(children: [
      // 배경색을 적용하여 스캔 영역 이외의 부분을 어둡게 처리
      ColorFiltered(
        colorFilter: ColorFilter.mode(
            overlayColour, BlendMode.srcOut), // 컬러 필터를 사용하여 스캔 영역 강조
        child: Stack(
          children: [
            // 스캔 영역 이외의 배경 설정
            Container(
              decoration: const BoxDecoration(
                  color: Colors.red,
                  backgroundBlendMode: BlendMode.dstOut),
            ),
            Align(
              alignment: Alignment.center,
              // 스캔 영역 크기를 정하고 모서리를 둥글게 처리
              child: Container(
                height: scanArea,
                width: scanArea,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
      // 스캔 영역 중앙에 흰색 테두리를 추가
      Align(
        alignment: Alignment.center,
        child: CustomPaint(
          foregroundPainter: BorderPainter(),
          child: SizedBox(
            width: scanArea + 25,
            height: scanArea + 25,
          ),
        ),
      ),
    ]);
  }
}

// 스캔 영역 테두리를 그리는 페인터 클래스
class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const width = 4.0; // 테두리 두께
    const radius = 20.0; // 모서리 반경
    const tRadius = 3 * radius;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));

    // 사각형의 네 모서리 클리핑 설정
    const clippingRect0 = Rect.fromLTWH(0, 0, tRadius, tRadius);
    final clippingRect1 = Rect.fromLTWH(size.width - tRadius, 0, tRadius, tRadius);
    final clippingRect2 = Rect.fromLTWH(0, size.height - tRadius, tRadius, tRadius);
    final clippingRect3 = Rect.fromLTWH(size.width - tRadius, size.height - tRadius, tRadius, tRadius);

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    // 캔버스에 테두리 그리기
    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // 재페인팅이 필요 없는 경우 false 반환
  }
}

// 스캐너 바 크기 정의 클래스
class BarReaderSize {
  static double width = 200;
  static double height = 200;
}

// 투명한 원형 구멍이 있는 오버레이를 생성하는 페인터 클래스
class OverlayWithHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54; // 배경을 반투명 검은색으로 설정
    // 전체 화면에서 원형 구멍 부분을 빼서 그리는 경로 생성
    canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()
            ..addOval(Rect.fromCircle(
                center: Offset(size.width - 44, size.height - 44), radius: 40))
            ..close(),
        ),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // 재페인팅이 필요 없는 경우 false 반환
  }
}

@override
bool shouldRepaint(CustomPainter oldDelegate) {
  return false;
}
