import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Shared utility to paint a clean, labeled Cartesian axis on any canvas.
class AxisPainterHelper {
  final Canvas canvas;
  final Size size;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final double marginLeft;
  final double marginBottom;
  final double marginTop;
  final double marginRight;

  AxisPainterHelper({
    required this.canvas,
    required this.size,
    this.xMin = -10,
    this.xMax = 10,
    this.yMin = -10,
    this.yMax = 10,
    this.marginLeft = 44,
    this.marginBottom = 32,
    this.marginTop = 12,
    this.marginRight = 12,
  });

  double get chartW => size.width - marginLeft - marginRight;
  double get chartH => size.height - marginTop - marginBottom;
  double get originX => marginLeft + ((-xMin) / (xMax - xMin)) * chartW;
  double get originY => marginTop + ((yMax) / (yMax - yMin)) * chartH;

  /// Convert a math (x, y) to canvas (cx, cy)
  Offset toCanvas(double x, double y) => Offset(
        marginLeft + ((x - xMin) / (xMax - xMin)) * chartW,
        marginTop + ((yMax - y) / (yMax - yMin)) * chartH,
      );

  void drawAxesAndGrid() {
    final gridPaint = Paint()
      ..color = AppTheme.axisLine.withOpacity(0.12)
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = AppTheme.axisLine
      ..strokeWidth = 1.5;

    // Grid lines
    final xStep = _niceStep(xMax - xMin);
    final yStep = _niceStep(yMax - yMin);

    // Vertical grid lines + X labels
    for (double x = (xMin / xStep).ceil() * xStep; x <= xMax; x += xStep) {
      final cx = toCanvas(x, 0).dx;
      canvas.drawLine(Offset(cx, marginTop),
          Offset(cx, size.height - marginBottom), gridPaint);
      // Tick
      canvas.drawLine(
          Offset(cx, originY - 4), Offset(cx, originY + 4), axisPaint);
      // Label
      _drawLabel(x.toStringAsFixed(x == x.roundToDouble() ? 0 : 1),
          Offset(cx - 10, size.height - marginBottom + 4));
    }

    // Horizontal grid lines + Y labels
    for (double y = (yMin / yStep).ceil() * yStep; y <= yMax; y += yStep) {
      final cy = toCanvas(0, y).dy;
      canvas.drawLine(Offset(marginLeft, cy),
          Offset(size.width - marginRight, cy), gridPaint);
      // Tick
      canvas.drawLine(
          Offset(originX - 4, cy), Offset(originX + 4, cy), axisPaint);
      // Label (don't re-draw zero on both axes)
      if (y != 0) {
        _drawLabel(y.toStringAsFixed(y == y.roundToDouble() ? 0 : 1),
            Offset(2, cy - 8));
      }
    }

    // X axis line
    canvas.drawLine(Offset(marginLeft, originY),
        Offset(size.width - marginRight, originY), axisPaint);
    // Y axis line
    canvas.drawLine(Offset(originX, marginTop),
        Offset(originX, size.height - marginBottom), axisPaint);

    // Axis arrow caps
    final arrowPaint = Paint()
      ..color = AppTheme.axisLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // X arrow
    final xEnd = Offset(size.width - marginRight, originY);
    canvas.drawLine(xEnd, xEnd + const Offset(-8, -5), arrowPaint);
    canvas.drawLine(xEnd, xEnd + const Offset(-8, 5), arrowPaint);
    // Y arrow
    final yEnd = Offset(originX, marginTop);
    canvas.drawLine(yEnd, yEnd + const Offset(-5, 8), arrowPaint);
    canvas.drawLine(yEnd, yEnd + const Offset(5, 8), arrowPaint);

    // Axis name labels
    _drawLabel('x', Offset(size.width - marginRight - 10, originY + 10));
    _drawLabel('y', Offset(originX + 5, marginTop + 2));
  }

  void _drawLabel(String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  double _niceStep(double range) {
    final rough = range / 8;
    if (rough < 2) return 1;
    if (rough < 5) return 2;
    if (rough < 10) return 5;
    if (rough < 20) return 10;
    return 20;
  }
}
