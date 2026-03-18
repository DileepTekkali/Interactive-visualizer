import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CalculusPainter extends CustomPainter {
  final double m;
  final double x0;
  final bool showTangent;
  final bool showArea;
  final Offset? hoverPoint;
  final double animProgress;

  CalculusPainter({
    required this.m,
    required this.x0,
    required this.showTangent,
    required this.showArea,
    this.hoverPoint,
    this.animProgress = 1.0,
  });

  static const double xMin = -5;
  static const double xMax = 5;
  static const double yMin = -2;
  static const double yMax = 12;

  Offset toCanvas(double x, double y, Size size) {
    final px = (x - xMin) / (xMax - xMin) * size.width;
    final py = (1 - (y - yMin) / (yMax - yMin)) * size.height;
    return Offset(px, py);
  }

  void _drawGridAndAxes(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = AppTheme.gridLine..strokeWidth = 0.5;
    for (int i = -5; i <= 5; i++) {
        final x = toCanvas(i.toDouble(), 0, size).dx;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int i = -2; i <= 12; i += 2) {
        final y = toCanvas(0, i.toDouble(), size).dy;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final axisPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 1.5;
    final origin = toCanvas(0, 0, size);
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);

    // Axis value labels + ticks
    final labelStyle = TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 10);
    final tickPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 1;
    for (int i = -5; i <= 5; i++) {
      if (i == 0) continue;
      final xPt = toCanvas(i.toDouble(), 0, size);
      canvas.drawLine(Offset(xPt.dx, origin.dy - 4), Offset(xPt.dx, origin.dy + 4), tickPaint);
      _drawText(canvas, '$i', Offset(xPt.dx - 6, origin.dy + 5), labelStyle);
    }
    for (int i = 0; i <= 12; i += 2) {
      if (i == 0) continue;
      final yPt = toCanvas(0, i.toDouble(), size);
      canvas.drawLine(Offset(origin.dx - 4, yPt.dy), Offset(origin.dx + 4, yPt.dy), tickPaint);
      _drawText(canvas, '$i', Offset(origin.dx + 4, yPt.dy - 7), labelStyle);
    }
    _drawText(canvas, 'x', Offset(size.width - 14, origin.dy + 5), TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic));
    _drawText(canvas, 'y', Offset(origin.dx + 5, 4), TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic));
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, pos);
  }

  void _drawArea(Canvas canvas, Size size) {
    if (!showArea) return;
    final path = Path();
    final steps = 100;
    
    // Area limits: from 0 to x0
    final startX = 0.0;
    final endX = x0;
    
    // Handle both positive and negative x0
    final minX = startX < endX ? startX : endX;
    final maxX = startX > endX ? startX : endX;

    if (minX == maxX) return;

    final startPt = toCanvas(minX, 0, size);
    path.moveTo(startPt.dx, startPt.dy);

    for (int i = 0; i <= steps; i++) {
      final x = minX + (maxX - minX) * (i / steps);
      final y = m * x * x;
      final pt = toCanvas(x, y * animProgress, size);
      path.lineTo(pt.dx, pt.dy);
    }

    final endPt = toCanvas(maxX, 0, size);
    path.lineTo(endPt.dx, endPt.dy);
    path.close();

    canvas.drawPath(path, Paint()..color = Colors.orangeAccent.withOpacity(0.2)..style = PaintingStyle.fill);
  }

  void _drawCurve(Canvas canvas, Size size) {
    final path = Path();
    bool started = false;
    final steps = 200;

    for (int i = 0; i <= steps; i++) {
      if (i / steps > animProgress) break;
      final x = xMin + (xMax - xMin) * (i / steps);
      final y = m * x * x;
      
      if (y > yMax + 2) {
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

    canvas.drawPath(path, Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke);
  }

  void _drawTangent(Canvas canvas, Size size) {
    if (!showTangent) return;

    // Point of tangent
    final ptX = x0;
    final ptY = m * ptX * ptX;
    final slope = 2 * m * ptX;
    final intercept = ptY - slope * ptX;

    final x1 = xMin;
    final y1 = slope * x1 + intercept;
    final pt1 = toCanvas(x1, y1, size);

    final x2 = xMax;
    final y2 = slope * x2 + intercept;
    final pt2 = toCanvas(x2, y2, size);

    canvas.drawLine(pt1, pt2, Paint()
      ..color = AppTheme.secondary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    // Marker
    final pt = toCanvas(ptX, ptY, size);
    canvas.drawCircle(pt, 6, Paint()..color = AppTheme.secondary);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    _drawGridAndAxes(canvas, size);
    _drawArea(canvas, size);
    _drawCurve(canvas, size);
    _drawTangent(canvas, size);
  }

  @override
  bool shouldRepaint(CalculusPainter old) =>
      old.m != m || old.x0 != x0 || old.showTangent != showTangent || 
      old.showArea != showArea || old.hoverPoint != hoverPoint || 
      old.animProgress != animProgress;
}
