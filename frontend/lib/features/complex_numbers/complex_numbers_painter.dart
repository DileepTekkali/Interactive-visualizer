import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ComplexNumbersPainter extends CustomPainter {
  final double real;
  final double imag;
  final double animProgress;

  ComplexNumbersPainter({
    required this.real,
    required this.imag,
    this.animProgress = 1.0,
  });

  static const double min = -12;
  static const double max = 12;

  Offset toCanvas(double x, double y, Size size) {
    final cx = (x - min) / (max - min) * size.width;
    final cy = (1 - (y - min) / (max - min)) * size.height;
    return Offset(cx, cy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final gridPaint = Paint()..color = AppTheme.axisLine.withOpacity(0.12)..strokeWidth = 0.5;
    final axisPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 1.5;
    final tickPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 1;
    final labelStyle = TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 9);

    final origin = toCanvas(0, 0, size);

    // Grid
    for (int i = -12; i <= 12; i += 2) {
      final xLine = toCanvas(i.toDouble(), 0, size).dx;
      final yLine = toCanvas(0, i.toDouble(), size).dy;
      canvas.drawLine(Offset(xLine, 0), Offset(xLine, size.height), gridPaint);
      canvas.drawLine(Offset(0, yLine), Offset(size.width, yLine), gridPaint);
    }

    // Axes
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);

    // Ticks + Labels
    for (int i = -10; i <= 10; i += 2) {
      if (i == 0) continue;
      final xPt = toCanvas(i.toDouble(), 0, size);
      final yPt = toCanvas(0, i.toDouble(), size);
      canvas.drawLine(Offset(xPt.dx, origin.dy - 4), Offset(xPt.dx, origin.dy + 4), tickPaint);
      canvas.drawLine(Offset(origin.dx - 4, yPt.dy), Offset(origin.dx + 4, yPt.dy), tickPaint);
      _drawText(canvas, '$i', Offset(xPt.dx - 6, origin.dy + 5), labelStyle);
      _drawText(canvas, '$i', Offset(origin.dx + 4, yPt.dy - 6), labelStyle);
    }

    // Axis name labels
    _drawText(canvas, 'Re', Offset(size.width - 22, origin.dy + 5), TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontStyle: FontStyle.italic));
    _drawText(canvas, 'Im', Offset(origin.dx + 5, 4), TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontStyle: FontStyle.italic));

    // Complex number vector
    final r = real * animProgress;
    final im = imag * animProgress;
    final target = toCanvas(r, im, size);

    // Shaded rectangle helper
    final refX = toCanvas(r, 0, size);
    final refY = toCanvas(0, im, size);
    final helperPaint = Paint()..color = AppTheme.accent.withOpacity(0.07)..style = PaintingStyle.fill;
    final helperPath = Path()
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(refX.dx, refX.dy)
      ..lineTo(target.dx, target.dy)
      ..lineTo(refY.dx, refY.dy)
      ..close();
    canvas.drawPath(helperPath, helperPaint);

    // Helper dashed lines
    canvas.drawLine(origin, refX, Paint()..color = AppTheme.accent.withOpacity(0.25)..strokeWidth = 1);
    canvas.drawLine(refX, target, Paint()..color = AppTheme.accent.withOpacity(0.25)..strokeWidth = 1);

    // Vector line
    canvas.drawLine(origin, target, Paint()..color = AppTheme.accent..strokeWidth = 2.5..strokeCap = StrokeCap.round);

    // Angle arc
    final modulus = math.sqrt(real * real + imag * imag);
    if (modulus > 0) {
      final arcRadius = 28.0;
      final arcPath = Path();
      arcPath.moveTo(origin.dx + arcRadius, origin.dy);
      arcPath.arcTo(
        Rect.fromCircle(center: origin, radius: arcRadius),
        0,
        -math.atan2(imag, real),
        false,
      );
      canvas.drawPath(arcPath, Paint()..color = AppTheme.success.withOpacity(0.6)..strokeWidth = 1.5..style = PaintingStyle.stroke);
      _drawText(canvas, 'θ', Offset(origin.dx + arcRadius + 4, origin.dy - 16),
          TextStyle(color: AppTheme.success, fontSize: 10, fontStyle: FontStyle.italic));
    }

    // Point
    canvas.drawCircle(target, 7, Paint()..color = AppTheme.accent);

    // z label
    _drawText(canvas, 'z = ${real.toStringAsFixed(1)} + ${imag.toStringAsFixed(1)}i',
        target + const Offset(10, -20),
        TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12));
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(ComplexNumbersPainter old) =>
      old.real != real || old.imag != imag || old.animProgress != animProgress;
}
