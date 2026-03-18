import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DataHandlingPainter extends CustomPainter {
  final List<double> values;
  final List<String> categories;
  final double animProgress;

  DataHandlingPainter({
    required this.values,
    required this.categories,
    this.animProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final axisPaint = Paint()
      ..color = AppTheme.axisLine
      ..strokeWidth = 2;

    final margin = 40.0;
    final chartWidth = size.width - 2 * margin;
    final chartHeight = size.height - 2 * margin;

    // Draw axes
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(size.width - margin, size.height - margin),
      axisPaint,
    );
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin, size.height - margin),
      axisPaint,
    );

    if (values.isEmpty) return;

    final barWidth = (chartWidth / values.length) * 0.6;
    final spacing = (chartWidth / values.length) * 0.4;
    final maxVal = 10.0;

    for (int i = 0; i < values.length; i++) {
      final val = values[i] * animProgress;
      final barHeight = (val / maxVal) * chartHeight;
      final x = margin + (i * (barWidth + spacing)) + spacing / 2;
      final y = size.height - margin - barHeight;

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.secondary,
          AppTheme.secondary.withOpacity(0.4),
        ],
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()..shader = gradient.createShader(rect),
      );

      // Draw value text
      _drawText(
        canvas,
        values[i].toStringAsFixed(1),
        Offset(x + barWidth / 2 - 10, y - 20),
        TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      );

      // Draw category text
      _drawText(
        canvas,
        categories[i],
        Offset(x + barWidth / 2 - 20, size.height - margin + 10),
        TextStyle(color: AppTheme.textSecondary, fontSize: 10),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(DataHandlingPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.animProgress != animProgress;
  }
}
