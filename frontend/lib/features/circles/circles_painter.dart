import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CirclesPainter extends CustomPainter {
  final double radius;
  final double angle; // Tangent angle in degrees
  final double animProgress;

  CirclesPainter({
    required this.radius,
    required this.angle,
    this.animProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final r = radius * 20 * animProgress;

    final circlePaint = Paint()
      ..color = AppTheme.secondary.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = AppTheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw Circle
    canvas.drawCircle(Offset(centerX, centerY), r, circlePaint);
    canvas.drawCircle(Offset(centerX, centerY), r, strokePaint);

    // Draw Radius
    final rad = angle * math.pi / 180;
    final contactPoint = Offset(centerX + r * math.cos(rad), centerY - r * math.sin(rad));
    canvas.drawLine(Offset(centerX, centerY), contactPoint, Paint()..color = AppTheme.textSecondary..strokeWidth = 1);

    // Draw Tangent
    final tangentLen = 150.0;
    final tDir = Offset(math.cos(rad + math.pi/2), -math.sin(rad + math.pi/2));
    final tStart = contactPoint - tDir * tangentLen;
    final tEnd = contactPoint + tDir * tangentLen;

    final tangentPaint = Paint()..color = AppTheme.accent..strokeWidth = 3;
    canvas.drawLine(tStart, tEnd, tangentPaint);

    // Draw Normal (perpendicular to tangent, which is the radius extension)
    canvas.drawCircle(contactPoint, 4, Paint()..color = AppTheme.accent);

    _drawText(canvas, 'O', Offset(centerX - 15, centerY - 15), TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold));
    _drawText(canvas, 'P', contactPoint + const Offset(10, 10), TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold));
    _drawText(canvas, 'Tangent line', tEnd + const Offset(5, 5), TextStyle(color: AppTheme.accent, fontSize: 10));
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(CirclesPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.angle != angle || oldDelegate.animProgress != animProgress;
  }
}
