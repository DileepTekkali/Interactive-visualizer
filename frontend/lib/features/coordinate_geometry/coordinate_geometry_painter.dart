import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CoordinateGeometryPainter extends CustomPainter {
  final Offset p1;
  final Offset p2;
  final double animProgress;

  CoordinateGeometryPainter({
    required this.p1,
    required this.p2,
    this.animProgress = 1.0,
  });

  static const double xMin = -12;
  static const double xMax = 12;
  static const double yMin = -12;
  static const double yMax = 12;

  Offset toCanvas(double x, double y, Size size) {
    final px = (x - xMin) / (xMax - xMin) * size.width;
    final py = (1 - (y - yMin) / (yMax - yMin)) * size.height;
    return Offset(px, py);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final gridPaint = Paint()
      ..color = AppTheme.axisLine.withOpacity(0.12)
      ..strokeWidth = 0.5;
    final axisPaint = Paint()
      ..color = AppTheme.axisLine
      ..strokeWidth = 1.5;
    final tickPaint = Paint()
      ..color = AppTheme.axisLine
      ..strokeWidth = 1;
    final labelStyle =
        TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 9);

    final origin = toCanvas(0, 0, size);

    // Grid
    for (int i = -12; i <= 12; i += 2) {
      final xLine = toCanvas(i.toDouble(), 0, size).dx;
      final yLine = toCanvas(0, i.toDouble(), size).dy;
      canvas.drawLine(Offset(xLine, 0), Offset(xLine, size.height), gridPaint);
      canvas.drawLine(Offset(0, yLine), Offset(size.width, yLine), gridPaint);
    }

    // Axes
    canvas.drawLine(
        Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    canvas.drawLine(
        Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);

    // Ticks + Labels
    for (int i = -10; i <= 10; i += 2) {
      if (i == 0) continue;
      final xPt = toCanvas(i.toDouble(), 0, size);
      final yPt = toCanvas(0, i.toDouble(), size);
      canvas.drawLine(Offset(xPt.dx, origin.dy - 4),
          Offset(xPt.dx, origin.dy + 4), tickPaint);
      canvas.drawLine(Offset(origin.dx - 4, yPt.dy),
          Offset(origin.dx + 4, yPt.dy), tickPaint);
      _drawText(canvas, '$i', Offset(xPt.dx - 6, origin.dy + 5), labelStyle);
      if (i != 0)
        _drawText(canvas, '$i', Offset(origin.dx + 4, yPt.dy - 6), labelStyle);
    }

    // Axis name labels
    _drawText(
        canvas,
        'x',
        Offset(size.width - 14, origin.dy + 5),
        TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontStyle: FontStyle.italic));
    _drawText(
        canvas,
        'y',
        Offset(origin.dx + 5, 4),
        TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontStyle: FontStyle.italic));

    // Points, line, labels
    final screenP1 = toCanvas(p1.dx, p1.dy, size);
    final screenP2 = toCanvas(p2.dx, p2.dy, size);
    final currentP2 = Offset.lerp(screenP1, screenP2, animProgress)!;

    // Line from A to B
    canvas.drawLine(
        screenP1,
        currentP2,
        Paint()
          ..color = AppTheme.secondary.withOpacity(0.7)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);

    // Midpoint dot
    final mid = Offset.lerp(screenP1, currentP2, 0.5)!;
    canvas.drawCircle(mid, 4, Paint()..color = AppTheme.success);

    // Dotted perpendicular helpers
    final dottedPaint = Paint()
      ..color = AppTheme.axisLine.withOpacity(0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(screenP1.dx, origin.dy), screenP1, dottedPaint);
    canvas.drawLine(Offset(origin.dx, screenP1.dy), screenP1, dottedPaint);
    canvas.drawLine(Offset(currentP2.dx, origin.dy), currentP2, dottedPaint);
    canvas.drawLine(Offset(origin.dx, currentP2.dy), currentP2, dottedPaint);

    // Points
    canvas.drawCircle(screenP1, 6, Paint()..color = AppTheme.accent);
    canvas.drawCircle(currentP2, 6, Paint()..color = AppTheme.secondary);

    // Labels
    _drawText(
        canvas,
        'A(${p1.dx.toInt()}, ${p1.dy.toInt()})',
        screenP1 + const Offset(10, -20),
        TextStyle(
            color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12));
    _drawText(
        canvas,
        'B(${p2.dx.toInt()}, ${p2.dy.toInt()})',
        currentP2 + const Offset(10, 10),
        TextStyle(
            color: AppTheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 12));
    _drawText(
        canvas,
        'M',
        mid + const Offset(8, -5),
        TextStyle(
            color: AppTheme.success,
            fontWeight: FontWeight.bold,
            fontSize: 11));
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(CoordinateGeometryPainter old) =>
      old.p1 != p1 || old.p2 != p2 || old.animProgress != animProgress;
}
