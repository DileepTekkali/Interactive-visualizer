import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ConicSectionsPainter extends CustomPainter {
  final double a; // Semi-major axis
  final double b; // Semi-minor axis
  final String mode; // 'Ellipse', 'Parabola', 'Hyperbola'
  final double animProgress;

  ConicSectionsPainter({
    required this.a,
    required this.b,
    required this.mode,
    this.animProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = 20.0;

    final axisPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 2;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), axisPaint);
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), axisPaint);

    final curvePaint = Paint()
      ..color = AppTheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (mode == 'Ellipse') {
      _drawEllipse(canvas, size, centerX, centerY, a * scale * animProgress, b * scale * animProgress, curvePaint);
    } else if (mode == 'Hyperbola') {
      _drawHyperbola(canvas, size, centerX, centerY, a * scale, b * scale, curvePaint);
    } else {
      _drawParabola(canvas, size, centerX, centerY, a * scale, curvePaint);
    }
  }

  void _drawEllipse(Canvas canvas, Size size, double cx, double cy, double sa, double sb, Paint paint) {
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: sa * 2, height: sb * 2), paint);
    
    // Draw Foci
    final c = math.sqrt((sa*sa - sb*sb).abs());
    final focusPaint = Paint()..color = AppTheme.accent;
    canvas.drawCircle(Offset(cx + c, cy), 4, focusPaint);
    canvas.drawCircle(Offset(cx - c, cy), 4, focusPaint);
  }

  void _drawHyperbola(Canvas canvas, Size size, double cx, double cy, double sa, double sb, Paint paint) {
    final path1 = Path();
    final path2 = Path();
    
    for (double t = -2.0; t <= 2.0; t += 0.05) {
      final x = sa * _cosh(t);
      final y = sb * _sinh(t);
      
      if (t == -2.0) {
        path1.moveTo(cx + x, cy - y);
        path2.moveTo(cx - x, cy - y);
      } else {
        path1.lineTo(cx + x, cy - y);
        path2.lineTo(cx - x, cy - y);
      }
    }
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  void _drawParabola(Canvas canvas, Size size, double cx, double cy, double a, Paint paint) {
    final path = Path();
    for (double y = -size.height/2; y <= size.height/2; y += 5) {
      final x = (y * y) / (4 * a.clamp(0.1, 100.0));
      if (y == -size.height/2) path.moveTo(cx + x, cy + y);
      else path.lineTo(cx + x, cy + y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConicSectionsPainter oldDelegate) {
    return oldDelegate.a != a || oldDelegate.b != b || oldDelegate.mode != mode || oldDelegate.animProgress != animProgress;
  }
}

// Fixing cosh/sinh scope for Dart
double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
