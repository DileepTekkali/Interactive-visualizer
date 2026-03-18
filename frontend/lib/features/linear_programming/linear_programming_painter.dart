import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LinearProgrammingPainter extends CustomPainter {
  final double c1; // Constraint 1: x + y <= c1
  final double c2; // Constraint 2: 2x + y <= c2
  final double animProgress;

  LinearProgrammingPainter({
    required this.c1,
    required this.c2,
    this.animProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    
    final centerX = 40.0; // Origin at bottom left for LPP
    final centerY = size.height - 40.0;
    final scale = 30.0;

    final axisPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 2;
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), axisPaint);
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), axisPaint);

    final line1Paint = Paint()..color = AppTheme.secondary..strokeWidth = 2;
    final line2Paint = Paint()..color = AppTheme.accent..strokeWidth = 2;

    // Line 1: x + y = c1 -> (c1, 0) and (0, c1)
    final p1a = Offset(centerX + c1 * scale, centerY);
    final p1b = Offset(centerX, centerY - c1 * scale);
    canvas.drawLine(p1a, p1b, line1Paint);

    // Line 2: 2x + y = c2 -> (c2/2, 0) and (0, c2)
    final p2a = Offset(centerX + (c2/2) * scale, centerY);
    final p2b = Offset(centerX, centerY - c2 * scale);
    canvas.drawLine(p2a, p2b, line2Paint);

    // Feasible Region Shading (x >= 0, y >= 0, and constraints)
    // Intersection of x+y=c1 and 2x+y=c2 => x = c2-c1, y = 2c1-c2
    final ix = (c2 - c1).clamp(0.0, 20.0);
    final iy = (2 * c1 - c2).clamp(0.0, 20.0);

    final path = Path()
      ..moveTo(centerX, centerY)
      ..lineTo(centerX + math.min(c1, c2/2) * scale, centerY);
      
    if (c2/2 < c1 && c2 > c1) { // They intersect in the first quadrant
       path.lineTo(centerX + ix * scale, centerY - iy * scale);
    }
    
    path.lineTo(centerX, centerY - math.min(c1, c2) * scale);
    path.close();

    canvas.drawPath(path, Paint()..color = AppTheme.success.withOpacity(0.2 * animProgress));

    _drawText(canvas, 'x + y = ${c1.toInt()}', p1a, TextStyle(color: AppTheme.secondary, fontSize: 10));
    _drawText(canvas, '2x + y = ${c2.toInt()}', p2a, TextStyle(color: AppTheme.accent, fontSize: 10));
    _drawText(canvas, 'Feasible Region', Offset(centerX + 10, centerY - 20), TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12));
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(LinearProgrammingPainter oldDelegate) {
    return oldDelegate.c1 != c1 || oldDelegate.c2 != c2 || oldDelegate.animProgress != animProgress;
  }
}
