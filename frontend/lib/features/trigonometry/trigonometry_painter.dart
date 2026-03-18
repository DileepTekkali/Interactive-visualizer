import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TrigonometryPainter extends CustomPainter {
  final double amplitude;
  final double frequency;
  final double phase;
  final Offset? hoverPoint;
  final double animProgress;
  final bool isCosine;

  TrigonometryPainter({
    required this.amplitude,
    required this.frequency,
    required this.phase,
    this.hoverPoint,
    this.animProgress = 1.0,
    this.isCosine = false,
  });

  static const double xMin = -4 * math.pi;
  static const double xMax = 4 * math.pi;
  static const double yMin = -5;
  static const double yMax = 5;

  Offset toCanvas(double x, double y, Size size) {
    final px = (x - xMin) / (xMax - xMin) * size.width;
    final py = (1 - (y - yMin) / (yMax - yMin)) * size.height;
    return Offset(px, py);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 0.5;

    // Y-grid lines
    for (int i = -5; i <= 5; i++) {
      final y = toCanvas(0, i.toDouble(), size).dy;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // X-grid lines (Pi steps)
    final piStep = math.pi;
    for (int i = -4; i <= 4; i++) {
      final x = toCanvas(i * piStep, 0, size).dx;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
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

    // X-axis: π labels with ticks
    for (int i = -4; i <= 4; i++) {
      if (i == 0) continue;
      final String label = i == 1 ? 'π' : (i == -1 ? '-π' : '${i}π');
      final xPt = toCanvas(i * math.pi, 0, size);
      _drawText(canvas, label, Offset(xPt.dx - 8, origin.dy + 5), style);
      canvas.drawLine(Offset(xPt.dx, origin.dy - 4), Offset(xPt.dx, origin.dy + 4), tickPaint);
    }
    // Y-axis with ticks
    for (int i = -4; i <= 4; i += 2) {
      if (i == 0) continue;
      final yPt = toCanvas(0, i.toDouble(), size);
      _drawText(canvas, '$i', Offset(origin.dx + 4, yPt.dy - 7), style);
      canvas.drawLine(Offset(origin.dx - 4, yPt.dy), Offset(origin.dx + 4, yPt.dy), tickPaint);
    }
    // Axis name labels
    _drawText(canvas, 'x', Offset(size.width - 14, origin.dy + 5), TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic));
    _drawText(canvas, 'y', Offset(origin.dx + 5, 4), TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic));
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, pos);
  }

  void _drawWave(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.2)
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.stroke;

    final curvePaint = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool started = false;
    final steps = 400;

    for (int i = 0; i <= steps; i++) {
      if (i / steps > animProgress) break;
      final x = xMin + (xMax - xMin) * (i / steps);
      
      final value = isCosine ? math.cos(frequency * x + phase) : math.sin(frequency * x + phase);
      final y = amplitude * value;
      
      if (y < yMin - 1 || y > yMax + 1) {
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

  void _drawHover(Canvas canvas, Size size) {
    if (hoverPoint == null) return;
    final x = xMin + (hoverPoint!.dx / size.width) * (xMax - xMin);
    final value = isCosine ? math.cos(frequency * x + phase) : math.sin(frequency * x + phase);
    final y = amplitude * value;

    if (y < yMin || y > yMax) return;

    final pt = toCanvas(x, y, size);
    canvas.drawCircle(pt, 6, Paint()..color = AppTheme.warning);

    final crosshair = Paint()..color = AppTheme.warning.withOpacity(0.3)..strokeWidth = 1;
    canvas.drawLine(Offset(pt.dx, 0), Offset(pt.dx, size.height), crosshair);
    canvas.drawLine(Offset(0, pt.dy), Offset(size.width, pt.dy), crosshair);

    _drawText(canvas, '(${(x / math.pi).toStringAsFixed(2)}π, ${y.toStringAsFixed(1)})', pt + const Offset(8, -16),
        TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.bold));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    _drawGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawAxisLabels(canvas, size);
    _drawWave(canvas, size);
    _drawHover(canvas, size);
  }

  @override
  bool shouldRepaint(TrigonometryPainter old) =>
      old.amplitude != amplitude || old.frequency != frequency || 
      old.phase != phase || old.isCosine != isCosine ||
      old.hoverPoint != hoverPoint || old.animProgress != animProgress;
}
