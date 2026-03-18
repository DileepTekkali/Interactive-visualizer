import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VectorsPainter extends CustomPainter {
  final double mag1, angle1; // Angle in degrees
  final double mag2, angle2;
  final String unit;

  final double animProgress;

  VectorsPainter({
    required this.mag1,
    required this.angle1,
    required this.mag2,
    required this.angle2,
    required this.unit,
    this.animProgress = 1.0,
  });

  // Scale vectors to fit in a -15 to 15 grid roughly.
  static const double maxBounds = 15;

  Offset toCanvas(double x, double y, Size size) {
    final px = (x + maxBounds) / (2 * maxBounds) * size.width;
    final py = (1 - (y + maxBounds) / (2 * maxBounds)) * size.height;
    return Offset(px, py);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 0.5;
    for (int i = -15; i <= 15; i += 5) {
      final x = toCanvas(i.toDouble(), 0, size).dx;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      final y = toCanvas(0, i.toDouble(), size).dy;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = AppTheme.axisLine
      ..strokeWidth = 1.5;
    final origin = toCanvas(0, 0, size);
    canvas.drawLine(
        Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    canvas.drawLine(
        Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, pos);
  }

  void _drawVector(Canvas canvas, Size size, Offset start, double mag,
      double angleDeg, Color color, String label) {
    if (mag == 0) return;
    final rad = angleDeg * math.pi / 180;
    if (mag > 0) {
      // For magnitude calculation
    }

    final p1 = toCanvas(start.dx, start.dy, size);
    // Interpolate end position based on animProgress
    final interpMag = mag * animProgress;
    final p2 = toCanvas(start.dx + interpMag * math.cos(rad),
        start.dy + interpMag * math.sin(rad), size);

    canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = color
          ..strokeWidth = 2.5);

    // Draw arrow head
    if (animProgress > 0.9) {
      final arrowAngle = math.atan2(p1.dy - p2.dy, p1.dx - p2.dx);
      final headL = 12.0;
      final arrowP1 = Offset(p2.dx + headL * math.cos(arrowAngle - math.pi / 6),
          p2.dy + headL * math.sin(arrowAngle - math.pi / 6));
      final arrowP2 = Offset(p2.dx + headL * math.cos(arrowAngle + math.pi / 6),
          p2.dy + headL * math.sin(arrowAngle + math.pi / 6));

      final path = Path()
        ..moveTo(p2.dx, p2.dy)
        ..lineTo(arrowP1.dx, arrowP1.dy)
        ..lineTo(arrowP2.dx, arrowP2.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = color);

      // Label
      _drawText(
          canvas,
          '$label (${mag.toStringAsFixed(1)}$unit)',
          Offset(p2.dx + 5, p2.dy + 5),
          TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    _drawGrid(canvas, size);
    _drawAxes(canvas, size);

    final origin = const Offset(0, 0);
    // Vector 1 (Blue)
    _drawVector(canvas, size, origin, mag1, angle1, AppTheme.secondary, 'v₁');

    // Vector 2 starts at end of Vector 1
    final v1EndX = mag1 * math.cos(angle1 * math.pi / 180);
    final v1EndY = mag1 * math.sin(angle1 * math.pi / 180);
    final v1End = Offset(v1EndX, v1EndY);

    // Vector 2 (Orange)
    _drawVector(canvas, size, v1End, mag2, angle2, Colors.orangeAccent, 'v₂');

    // Resultant Vector starts at origin, goes to end of V2
    if (animProgress > 0.9 && (mag1 != 0 || mag2 != 0)) {
      final resX = v1EndX + mag2 * math.cos(angle2 * math.pi / 180);
      final resY = v1EndY + mag2 * math.sin(angle2 * math.pi / 180);
      final resMag = math.sqrt(resX * resX + resY * resY);
      // Draw dotted resultant
      final p1 = toCanvas(0, 0, size);
      final p2 = toCanvas(resX, resY, size);

      final dashPaint = Paint()
        ..color = AppTheme.success
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(p1, p2, dashPaint); // Simplified line for resultant

      _drawText(
          canvas,
          'R (${resMag.toStringAsFixed(1)}$unit)',
          Offset(p2.dx - 20, p2.dy - 25),
          TextStyle(
              color: AppTheme.success,
              fontSize: 12,
              fontWeight: FontWeight.bold));
    }
  }

  @override
  bool shouldRepaint(VectorsPainter old) =>
      old.mag1 != mag1 ||
      old.angle1 != angle1 ||
      old.mag2 != mag2 ||
      old.angle2 != angle2 ||
      old.animProgress != animProgress ||
      old.unit != unit;
}
