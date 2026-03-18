import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ProgressionsPainter extends CustomPainter {
  final double a;
  final double d;    // AP: common difference
  final double r;    // GP: common ratio
  final int n;
  final bool isGP;
  final double animProgress;

  ProgressionsPainter({
    required this.a,
    required this.d,
    required this.r,
    required this.n,
    this.isGP = false,
    this.animProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    const marginL = 52.0;
    const marginB = 36.0;
    const marginT = 20.0;
    const marginR = 16.0;

    final chartH = size.height - marginT - marginB;
    final chartW = size.width - marginL - marginR;

    if (n <= 0) return;

    // Build term values
    final List<double> terms = List.generate(n, (i) {
      if (isGP) return a * math.pow(r, i).toDouble();
      return a + i * d;
    });

    final maxVal = terms.map((v) => v.abs()).reduce(math.max).clamp(1.0, 1e9);
    final minVal = terms.reduce(math.min);
    final hasNeg = minVal < 0;
    final yMin = hasNeg ? minVal - 1 : 0.0;
    final yMax = maxVal + maxVal * 0.1;

    final baselineY = size.height - marginB - ((0 - yMin) / (yMax - yMin)) * chartH;

    // === Draw Y axis grid + labels ===
    final axisPaint = Paint()..color = AppTheme.axisLine..strokeWidth = 1.5;
    final gridPaint = Paint()..color = AppTheme.axisLine.withOpacity(0.15)..strokeWidth = 1;
    final double yStep = _niceStep(yMax - yMin);

    for (double y = (yMin / yStep).ceil() * yStep; y <= yMax; y += yStep) {
      final cy = size.height - marginB - ((y - yMin) / (yMax - yMin)) * chartH;
      canvas.drawLine(Offset(marginL, cy), Offset(size.width - marginR, cy), gridPaint);
      canvas.drawLine(Offset(marginL - 4, cy), Offset(marginL, cy), axisPaint);
      _drawText(canvas, y.toStringAsFixed(y == y.roundToDouble() ? 0 : 1),
          Offset(0, cy - 7), const TextStyle(color: AppTheme.textSecondary, fontSize: 9));
    }

    // Y axis line
    canvas.drawLine(Offset(marginL, marginT), Offset(marginL, size.height - marginB), axisPaint);
    // X axis baseline
    canvas.drawLine(Offset(marginL, baselineY), Offset(size.width - marginR, baselineY), axisPaint);

    // Y axis label
    _drawText(canvas, 'Term Value', Offset(2, marginT),
        const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontStyle: FontStyle.italic));

    // === Draw Bars ===
    final barW = (chartW / n) * 0.6;
    final gap = (chartW / n) * 0.4;

    for (int i = 0; i < n; i++) {
      final termVal = terms[i] * animProgress;
      final barH = ((termVal - yMin) / (yMax - yMin)) * chartH;
      final x = marginL + i * (barW + gap) + gap / 2;
      final barTop = size.height - marginB - barH;

      final rect = Rect.fromLTWH(x, barTop, barW, barH);
      final isGPStyle = isGP;
      final barColor = isGPStyle ? AppTheme.secondary : AppTheme.accent;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [barColor, barColor.withOpacity(0.5)],
          ).createShader(rect),
      );

      // X axis label: n=1, n=2...
      _drawText(canvas, 'n=${i + 1}',
          Offset(x, size.height - marginB + 5),
          const TextStyle(color: AppTheme.textSecondary, fontSize: 8));

      // Value on top of bar
      if (barH > 16) {
        _drawText(canvas, terms[i].toStringAsFixed(1),
            Offset(x, barTop - 14),
            TextStyle(color: barColor, fontSize: 9, fontWeight: FontWeight.bold));
      }
    }

    // X axis label
    _drawText(canvas, 'n  (Term Number)',
        Offset(size.width - marginR - 80, size.height - marginB + 5),
        const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontStyle: FontStyle.italic));
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  double _niceStep(double range) {
    if (range < 5) return 1;
    if (range < 20) return 5;
    if (range < 50) return 10;
    if (range < 200) return 50;
    if (range < 1000) return 100;
    return 500;
  }

  @override
  bool shouldRepaint(ProgressionsPainter old) =>
      old.a != a || old.d != d || old.r != r || old.n != n || old.isGP != isGP || old.animProgress != animProgress;
}
