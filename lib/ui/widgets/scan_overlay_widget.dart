import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/quality_check_result.dart';

class ScanOverlayWidget extends StatelessWidget {
  final QualityCheckResult? qualityResult;

  const ScanOverlayWidget({this.qualityResult, super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const frameWidth = 280.0;
    const frameHeight = 200.0;
    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = (size.height - frameHeight) / 2 - 40;

    return CustomPaint(
      size: Size(size.width, size.height),
      painter: _ScanFramePainter(
        frameRect: Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final Rect frameRect;

  _ScanFramePainter({required this.frameRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;
    const radius = 4.0;

    final left = frameRect.left;
    final top = frameRect.top;
    final right = frameRect.right;
    final bottom = frameRect.bottom;

    canvas.drawLine(
      Offset(left + radius, top),
      Offset(left + cornerLength, top),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + radius),
      Offset(left, top + cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(right - cornerLength, top),
      Offset(right - radius, top),
      paint,
    );
    canvas.drawLine(
      Offset(right, top + radius),
      Offset(right, top + cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(left + radius, bottom),
      Offset(left + cornerLength, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(left, bottom - cornerLength),
      Offset(left, bottom - radius),
      paint,
    );

    canvas.drawLine(
      Offset(right - cornerLength, bottom),
      Offset(right - radius, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom - cornerLength),
      Offset(right, bottom - radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
