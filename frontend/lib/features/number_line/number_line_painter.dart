import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NumberLinePainter extends CustomPainter {
  final double value;
  final double scale;
  final double animProgress;

  NumberLinePainter({
    required this.value,
    required this.scale,
    this.animProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    
    final linePaint = Paint()
      ..color = AppTheme.axisLine
      ..strokeWidth = 2;

    final centerY = size.height / 2;
    final centerX = size.width / 2;

    // Draw main line
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), linePaint);

    final tickSpacing = 50.0 * scale;
    final startOffset = centerX % tickSpacing;

    final textStyle = TextStyle(color: AppTheme.textSecondary, fontSize: 10);

    // Draw ticks and labels
    for (double x = startOffset; x < size.width; x += tickSpacing) {
      final val = (x - centerX) / tickSpacing;
      
      canvas.drawLine(Offset(x, centerY - 10), Offset(x, centerY + 10), linePaint);
      
      _drawText(canvas, val.round().toString(), Offset(x - 5, centerY + 15), textStyle);
    }

    // Draw the point
    final pointX = centerX + (value * tickSpacing) * animProgress;
    final pointPaint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(pointX, centerY), 8, pointPaint);
    
    // Draw label for the point
    _drawText(
      canvas,
      value.toStringAsFixed(2),
      Offset(pointX - 15, centerY - 30),
      TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(NumberLinePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.scale != scale || oldDelegate.animProgress != animProgress;
  }
}
