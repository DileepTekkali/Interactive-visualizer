import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatisticsPainter extends CustomPainter {
  final double mean;
  final double stdDev;
  final Offset? hoverPoint;
  final double animProgress;

  StatisticsPainter({
    required this.mean,
    required this.stdDev,
    this.hoverPoint,
    this.animProgress = 1.0,
  });

  static const double xMin = -10;
  static const double xMax = 10;
  static const double yMin = 0;
  static const double yMax = 1.0;

  Offset toCanvas(double x, double y, Size size) {
    final px = (x - xMin) / (xMax - xMin) * size.width;
    final py = (1 - (y - yMin) / (yMax - yMin)) * size.height;
    return Offset(px, py);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = AppTheme.gridLine..strokeWidth = 0.5;
    for (int i = -10; i <= 10; i += 2) {
      final x = toCanvas(i.toDouble(), 0, size).dx;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double i = 0; i <= 1.0; i += 0.2) {
      final y = toCanvas(0, i, size).dy;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 1.5;
    final origin = toCanvas(0, 0, size);
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    // Y-axis usually at x=0
    final yAxis = toCanvas(0, 0, size);
    canvas.drawLine(Offset(yAxis.dx, 0), Offset(yAxis.dx, size.height), axisPaint);
  }

  void _drawAxisLabels(Canvas canvas, Size size) {
    final style = TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 9);
    for (int i = -10; i <= 10; i += 2) {
      if (i == 0) continue;
      _drawText(canvas, i.toString(), toCanvas(i.toDouble(), 0, size) + const Offset(0, 4), style);
    }
    for (double i = 0.2; i <= 1.0; i += 0.2) {
      _drawText(canvas, i.toStringAsFixed(1), toCanvas(0, i, size) + const Offset(4, 0), style);
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, pos);
  }

  void _drawDistribution(Canvas canvas, Size size) {
    if (stdDev <= 0) return;

    final glowPaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.2)
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.stroke;

    final curvePaint = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    bool started = false;
    final steps = 400;

    for (int i = 0; i <= steps; i++) {
      if (i / steps > animProgress) break;
      final x = xMin + (xMax - xMin) * (i / steps);
      
      // PDF formula
      final coefficient = 1.0 / (stdDev * math.sqrt(2 * math.pi));
      final exponent = -0.5 * math.pow((x - mean) / stdDev, 2);
      final y = coefficient * math.exp(exponent);

      final pt = toCanvas(x, y, size);

      if (!started) {
        path.moveTo(pt.dx, pt.dy);
        fillPath.moveTo(pt.dx, size.height);
        fillPath.lineTo(pt.dx, pt.dy);
        started = true;
      } else {
        path.lineTo(pt.dx, pt.dy);
        fillPath.lineTo(pt.dx, pt.dy);
      }
    }

    if (started) {
       final lastPt = toCanvas(xMin + (xMax - xMin) * animProgress, 0, size);
       fillPath.lineTo(lastPt.dx, size.height);
       fillPath.close();
       canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, curvePaint);

    // Draw Mean Line
    final meanY = (1.0 / (stdDev * math.sqrt(2 * math.pi)));
    final meanPt = toCanvas(mean, meanY, size);
    final meanBot = toCanvas(mean, 0, size);
    
    final dashPaint = Paint()..color = Colors.purpleAccent.withOpacity(0.5)..strokeWidth = 1;
    canvas.drawLine(meanPt, meanBot, dashPaint);
    
    _drawText(canvas, 'μ', toCanvas(mean, 0, size) + const Offset(-4, 12), TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold));
  }

  void _drawHover(Canvas canvas, Size size) {
    if (hoverPoint == null || stdDev <= 0) return;
    
    final x = xMin + (hoverPoint!.dx / size.width) * (xMax - xMin);
    final coefficient = 1.0 / (stdDev * math.sqrt(2 * math.pi));
    final exponent = -0.5 * math.pow((x - mean) / stdDev, 2);
    final y = coefficient * math.exp(exponent);

    final pt = toCanvas(x, y, size);
    canvas.drawCircle(pt, 6, Paint()..color = AppTheme.warning);

    _drawText(canvas, 'P(x) ≈ ${y.toStringAsFixed(3)}', pt + const Offset(8, -20),
        TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.bold));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    _drawGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawAxisLabels(canvas, size);
    _drawDistribution(canvas, size);
    _drawHover(canvas, size);
  }

  @override
  bool shouldRepaint(StatisticsPainter old) =>
      old.mean != mean || old.stdDev != stdDev || 
      old.hoverPoint != hoverPoint || old.animProgress != animProgress;
}
