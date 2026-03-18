import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LinearPainter extends CustomPainter {
  final double m;
  final double c;
  final Offset? hoverPoint;
  final double animProgress;

  LinearPainter({
    required this.m,
    required this.c,
    this.hoverPoint,
    this.animProgress = 1.0,
  });

  static const double xMin = -10;
  static const double xMax = 10;
  static const double yMin = -10;
  static const double yMax = 10;

  Offset toCanvas(double x, double y, Size size) {
    final px = (x - xMin) / (xMax - xMin) * size.width;
    final py = (1 - (y - yMin) / (yMax - yMin)) * size.height;
    return Offset(px, py);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 0.5;

    for (int i = -10; i <= 10; i++) {
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

    final xAxis = toCanvas(0, 0, size);
    final yAxis = toCanvas(0, 0, size);

    canvas.drawLine(Offset(0, xAxis.dy), Offset(size.width, xAxis.dy), axisPaint);
    canvas.drawLine(Offset(yAxis.dx, 0), Offset(yAxis.dx, size.height), axisPaint);
  }

  void _drawAxisLabels(Canvas canvas, Size size) {
    final xLabelStyle = TextStyle(
      color: AppTheme.textSecondary.withOpacity(0.8),
      fontSize: 10,
    );
    final yLabelStyle = TextStyle(
      color: AppTheme.textSecondary.withOpacity(0.8),
      fontSize: 10,
    );
    final axOrigin = toCanvas(0, 0, size);

    for (int i = -10; i <= 10; i += 2) {
      if (i == 0) continue;
      // X axis numbers below axis
      final xPt = toCanvas(i.toDouble(), 0, size);
      _drawLabel(canvas, '$i', Offset(xPt.dx - 6, axOrigin.dy + 5), xLabelStyle);
      // Y axis numbers left of axis
      final yPt = toCanvas(0, i.toDouble(), size);
      _drawLabel(canvas, '$i', Offset(axOrigin.dx + 4, yPt.dy - 7), yLabelStyle);
      // Tick marks
      final tickPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 1;
      canvas.drawLine(Offset(xPt.dx, axOrigin.dy - 4), Offset(xPt.dx, axOrigin.dy + 4), tickPaint);
      canvas.drawLine(Offset(axOrigin.dx - 4, yPt.dy), Offset(axOrigin.dx + 4, yPt.dy), tickPaint);
    }
    // Axis labels
    _drawLabel(canvas, 'x', Offset(size.width - 14, axOrigin.dy + 6), TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic));
    _drawLabel(canvas, 'y', Offset(axOrigin.dx + 6, 6), TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic));
  }

  void _drawLabel(Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  void _drawLine(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = AppTheme.accent.withOpacity(0.25)
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool started = false;

    final steps = 200;
    for (int i = 0; i <= steps; i++) {
      final progress = i / steps;
      if (progress > animProgress) break;

      final x = xMin + (xMax - xMin) * (i / steps);
      final y = m * x + c;
      final pt = toCanvas(x, y, size);

      if (!started) {
        path.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  void _drawIntercepts(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = AppTheme.secondary;

    // y-intercept
    final yIntercept = toCanvas(0, c, size);
    if (c >= yMin && c <= yMax) {
      canvas.drawCircle(yIntercept, 7, Paint()..color = AppTheme.secondary.withOpacity(0.3));
      canvas.drawCircle(yIntercept, 5, dotPaint);
      canvas.drawCircle(yIntercept, 2.5, Paint()..color = Colors.white);
      _drawLabelBox(canvas, '(0, ${c.toStringAsFixed(1)})', yIntercept + const Offset(8, -22), AppTheme.secondary);
    }

    // x-intercept
    if (m != 0) {
      final xInt = -c / m;
      if (xInt >= xMin && xInt <= xMax) {
        final xIntercept = toCanvas(xInt, 0, size);
        canvas.drawCircle(xIntercept, 7, Paint()..color = AppTheme.secondary.withOpacity(0.3));
        canvas.drawCircle(xIntercept, 5, dotPaint);
        canvas.drawCircle(xIntercept, 2.5, Paint()..color = Colors.white);
        _drawLabelBox(canvas, '(${xInt.toStringAsFixed(1)}, 0)', xIntercept + const Offset(8, -22), AppTheme.secondary);
      }
    }
  }

  void _drawLabelBox(Canvas canvas, String text, Offset pos, Color textColor) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    final bg = Rect.fromLTWH(pos.dx - 4, pos.dy - 2, tp.width + 8, tp.height + 4);
    canvas.drawRRect(RRect.fromRectAndRadius(bg, const Radius.circular(4)),
        Paint()..color = const Color(0xFF080D1C).withOpacity(0.82));
    tp.paint(canvas, pos);
  }

  void _drawHoverPoint(Canvas canvas, Size size) {
    if (hoverPoint == null) return;
    final x = xMin + (hoverPoint!.dx / size.width) * (xMax - xMin);
    final y = m * x + c;
    if (y < yMin || y > yMax) return;

    final pt = toCanvas(x, y, size);
    canvas.drawCircle(pt, 10, Paint()..color = AppTheme.warning.withOpacity(0.25));
    canvas.drawCircle(pt, 6, Paint()..color = AppTheme.warning);
    canvas.drawCircle(pt, 3, Paint()..color = Colors.white);

    final crosshairPaint = Paint()
      ..color = AppTheme.warning.withOpacity(0.4)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(pt.dx, 0), Offset(pt.dx, size.height), crosshairPaint);
    canvas.drawLine(Offset(0, pt.dy), Offset(size.width, pt.dy), crosshairPaint);

    _drawLabelBox(canvas, '(${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)})', pt + const Offset(10, -28), AppTheme.warning);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    _drawGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawAxisLabels(canvas, size);
    _drawLine(canvas, size);
    _drawIntercepts(canvas, size);
    _drawHoverPoint(canvas, size);
  }

  @override
  bool shouldRepaint(LinearPainter old) =>
      old.m != m || old.c != c || old.hoverPoint != hoverPoint || old.animProgress != animProgress;
}
