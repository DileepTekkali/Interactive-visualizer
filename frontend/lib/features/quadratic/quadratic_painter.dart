import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QuadraticPainter extends CustomPainter {
  final double a;
  final double b;
  final double c;
  final Offset? hoverPoint;
  final double animProgress;

  QuadraticPainter({
    required this.a,
    required this.b,
    required this.c,
    this.hoverPoint,
    this.animProgress = 1.0,
  });

  static const double xMin = -10;
  static const double xMax = 10;
  static const double yMin = -12;
  static const double yMax = 12;

  Offset toCanvas(double x, double y, Size size) {
    final px = (x - xMin) / (xMax - xMin) * size.width;
    final py = (1 - (y - yMin) / (yMax - yMin)) * size.height;
    return Offset(px, py);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 0.5;

    for (int i = -12; i <= 12; i += 2) {
      final x = toCanvas(i.toDouble(), 0, size).dx;
      final y = toCanvas(0, i.toDouble(), size).dy;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = AppTheme.axisLine
      ..strokeWidth = 1.5;
    final origin = toCanvas(0, 0, size);
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);
  }

  void _drawAxisLabels(Canvas canvas, Size size) {
    final style = TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 10);
    final origin = toCanvas(0, 0, size);
    final tickPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 1;

    for (int i = -10; i <= 10; i += 2) {
      if (i == 0) continue;
      // X axis
      final xPt = toCanvas(i.toDouble(), 0, size);
      _drawText(canvas, '$i', Offset(xPt.dx - 6, origin.dy + 5), style);
      canvas.drawLine(Offset(xPt.dx, origin.dy - 4), Offset(xPt.dx, origin.dy + 4), tickPaint);
      // Y axis
      final yPt = toCanvas(0, i.toDouble(), size);
      _drawText(canvas, '$i', Offset(origin.dx + 4, yPt.dy - 7), style);
      canvas.drawLine(Offset(origin.dx - 4, yPt.dy), Offset(origin.dx + 4, yPt.dy), tickPaint);
    }
    _drawText(canvas, 'x', Offset(size.width - 14, origin.dy + 6), TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic));
    _drawText(canvas, 'y', Offset(origin.dx + 6, 6), TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic));
  }

  void _drawLabelBox(Canvas canvas, String text, Offset pos, Color textColor) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    // Dark background for readability
    final bg = Rect.fromLTWH(pos.dx - 4, pos.dy - 2, tp.width + 8, tp.height + 4);
    canvas.drawRRect(RRect.fromRectAndRadius(bg, const Radius.circular(4)),
        Paint()..color = const Color(0xFF080D1C).withOpacity(0.82));
    tp.paint(canvas, pos);
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, pos);
  }

  void _drawParabola(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = AppTheme.secondary.withOpacity(0.2)
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.stroke;

    final curvePaint = Paint()
      ..color = AppTheme.secondary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool started = false;
    final steps = 300;

    for (int i = 0; i <= steps; i++) {
      if (i / steps > animProgress) break;
      final x = xMin + (xMax - xMin) * (i / steps);
      final y = a * x * x + b * x + c;
      if (y < yMin - 2 || y > yMax + 2) {
        started = false;
        continue;
      }
      final pt = toCanvas(x, y, size);
      if (!started) {
        path.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, curvePaint);
  }

  void _drawVertex(Canvas canvas, Size size) {
    if (a == 0) return;
    final vx = -b / (2 * a);
    final vy = a * vx * vx + b * vx + c;
    if (vy < yMin || vy > yMax || vx < xMin || vx > xMax) return;

    final pt = toCanvas(vx, vy, size);

    // Glow ring
    canvas.drawCircle(pt, 10, Paint()..color = AppTheme.success.withOpacity(0.25));
    // Dot (drawn on top of curve)
    canvas.drawCircle(pt, 6, Paint()..color = AppTheme.success);
    canvas.drawCircle(pt, 3, Paint()..color = Colors.white);

    // Label with background
    final label = 'V(${vx.toStringAsFixed(1)}, ${vy.toStringAsFixed(1)})';
    _drawLabelBox(canvas, label, pt + const Offset(10, -26), AppTheme.success);
  }

  void _drawRoots(Canvas canvas, Size size) {
    if (a == 0) return;
    final disc = b * b - 4 * a * c;
    if (disc < 0) return;

    final roots = disc == 0
        ? [-b / (2 * a)]
        : [(-b + math.sqrt(disc)) / (2 * a), (-b - math.sqrt(disc)) / (2 * a)];

    for (final rx in roots) {
      if (rx < xMin || rx > xMax) continue;
      final pt = toCanvas(rx, 0, size);
      // Glow ring
      canvas.drawCircle(pt, 9, Paint()..color = AppTheme.warning.withOpacity(0.25));
      canvas.drawCircle(pt, 5, Paint()..color = AppTheme.warning);
      canvas.drawCircle(pt, 2.5, Paint()..color = Colors.white);
      _drawLabelBox(canvas, 'x=${rx.toStringAsFixed(2)}', pt + const Offset(6, -26), AppTheme.warning);
    }
  }

  void _drawHover(Canvas canvas, Size size) {
    if (hoverPoint == null) return;
    final x = xMin + (hoverPoint!.dx / size.width) * (xMax - xMin);
    final y = a * x * x + b * x + c;
    if (y < yMin || y > yMax) return;

    final pt = toCanvas(x, y, size);
    canvas.drawCircle(pt, 6, Paint()..color = AppTheme.warning);

    final crosshair = Paint()..color = AppTheme.warning.withOpacity(0.3)..strokeWidth = 1;
    canvas.drawLine(Offset(pt.dx, 0), Offset(pt.dx, size.height), crosshair);
    canvas.drawLine(Offset(0, pt.dy), Offset(size.width, pt.dy), crosshair);

    _drawText(canvas, '(${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)})', pt + const Offset(8, -16),
        TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.bold));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    _drawGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawAxisLabels(canvas, size);
    _drawParabola(canvas, size);
    _drawVertex(canvas, size);
    _drawRoots(canvas, size);
    _drawHover(canvas, size);
  }

  @override
  bool shouldRepaint(QuadraticPainter old) =>
      old.a != a || old.b != b || old.c != c ||
      old.hoverPoint != hoverPoint || old.animProgress != animProgress;
}
