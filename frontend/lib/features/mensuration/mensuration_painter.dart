import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MensurationPainter extends CustomPainter {
  final double width;
  final double height;
  final double radius;
  final double depth;
  final String shape; 
  final String unit;
  final double rotX;
  final double rotY;
  final double animProgress;

  MensurationPainter({
    required this.width,
    required this.height,
    required this.radius,
    required this.depth,
    required this.shape,
    this.unit = 'cm',
    this.rotX = 0.0,
    this.rotY = 0.0,
    this.animProgress = 1.0,
  });

  static const _fillColor = Color(0xFF00E5FF);

  Offset _project(double x, double y, double z, double cx, double cy) {
    // Initial isometric-like tilt + user rotation
    final finalRx = -0.3 + rotX;
    final finalRy = -0.5 + rotY;

    // Rotate Y (around Y axis)
    double x1 = x * math.cos(finalRy) - z * math.sin(finalRy);
    double z1 = x * math.sin(finalRy) + z * math.cos(finalRy);

    // Rotate X (around X axis)
    double y1 = y * math.cos(finalRx) + z1 * math.sin(finalRx);
    double z2 = -y * math.sin(finalRx) + z1 * math.cos(finalRx);

    // Simple pseudo-perspective
    double fov = 600;
    double scale = fov / (fov + z2);

    return Offset(cx + x1 * scale, cy + y1 * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final p = animProgress;

    switch (shape) {
      case '2D Rect':
        _draw2DRect(canvas, size, cx, cy, p);
        break;
      case '2D Circle':
        _draw2DCircle(canvas, size, cx, cy, p);
        break;
      case '2D Triangle':
        _draw2DTriangle(canvas, size, cx, cy, p);
        break;
      case 'Cuboid':
        _drawCuboid(canvas, size, cx, cy, p);
        break;
      case 'Sphere':
        _drawSphere(canvas, size, cx, cy, p);
        break;
      case 'Cone':
        _drawCone(canvas, size, cx, cy, p);
        break;
      case 'Cylinder':
        _drawCylinder(canvas, size, cx, cy, p);
        break;
      case 'Pyramid':
        _drawPyramid(canvas, size, cx, cy, p);
        break;
    }
  }

  Paint _fillPaint(double opacity) => Paint()
    ..color = _fillColor.withOpacity(opacity)
    ..style = PaintingStyle.fill;

  Paint _strokePaint([double opacity = 1.0]) => Paint()
    ..color = _fillColor.withOpacity(opacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  // ── 2D Shapes (Do not use 3D projection) ──────────────────────
  void _draw2DRect(Canvas canvas, Size size, double cx, double cy, double p) {
    final w = width * 22 * p;
    final h = height * 22 * p;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    canvas.drawRect(rect, _fillPaint(0.25));
    canvas.drawRect(rect, _strokePaint());

    _drawDimLine(canvas, Offset(rect.left, rect.bottom + 24), Offset(rect.right, rect.bottom + 24),
        'w = ${width.toStringAsFixed(1)} $unit');
    _drawDimLine(canvas, Offset(rect.right + 24, rect.top), Offset(rect.right + 24, rect.bottom),
        'h = ${height.toStringAsFixed(1)} $unit', vertical: true);
  }

  void _draw2DCircle(Canvas canvas, Size size, double cx, double cy, double p) {
    final r = radius * 22 * p;
    canvas.drawCircle(Offset(cx, cy), r, _fillPaint(0.25));
    canvas.drawCircle(Offset(cx, cy), r, _strokePaint());
    canvas.drawLine(Offset(cx, cy), Offset(cx + r, cy), _strokePaint());
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = AppTheme.accent);
    _labelBox(canvas, 'r = ${radius.toStringAsFixed(1)} $unit', Offset(cx + r / 2 - 20, cy + 10));
  }

  void _draw2DTriangle(Canvas canvas, Size size, double cx, double cy, double p) {
    final w = width * 22 * p;
    final h = height * 22 * p;
    final top = Offset(cx, cy - h / 2);
    final bl = Offset(cx - w / 2, cy + h / 2);
    final br = Offset(cx + w / 2, cy + h / 2);

    final path = Path()..moveTo(top.dx, top.dy)..lineTo(br.dx, br.dy)..lineTo(bl.dx, bl.dy)..close();
    canvas.drawPath(path, _fillPaint(0.25));
    canvas.drawPath(path, _strokePaint());
    _drawDashed(canvas, top, Offset(cx, cy + h / 2), _strokePaint(0.5));
    
    _drawDimLine(canvas, Offset(bl.dx, bl.dy + 24), Offset(br.dx, br.dy + 24), 'b = ${width.toStringAsFixed(1)} $unit');
    _drawDimLine(canvas, Offset(br.dx + 24, top.dy), Offset(br.dx + 24, br.dy), 'h = ${height.toStringAsFixed(1)} $unit', vertical: true);
  }

  // ── 3D Shapes (Use 3D projection) ──────────────────────────────
  void _drawCuboid(Canvas canvas, Size size, double cx, double cy, double p) {
    final w = width * 14 * p;
    final h = height * 14 * p;
    final d = depth * 14 * p;

    // 8 Vertices (Centered)
    Offset proj(double x, double y, double z) => _project(x, y, z, cx, cy);
    
    final v0 = proj(-w/2, -h/2, -d/2);
    final v1 = proj(w/2, -h/2, -d/2);
    final v2 = proj(w/2, h/2, -d/2);
    final v3 = proj(-w/2, h/2, -d/2);
    final v4 = proj(-w/2, -h/2, d/2);
    final v5 = proj(w/2, -h/2, d/2);
    final v6 = proj(w/2, h/2, d/2);
    final v7 = proj(-w/2, h/2, d/2);

    // Faces
    _drawPolygon(canvas, [v0, v1, v2, v3], _strokePaint(0.5), fill: _fillPaint(0.08)); // Back
    _drawPolygon(canvas, [v0, v4, v7, v3], _strokePaint(0.5), fill: _fillPaint(0.12)); // Left
    _drawPolygon(canvas, [v1, v5, v6, v2], _strokePaint(0.5), fill: _fillPaint(0.12)); // Right
    _drawPolygon(canvas, [v0, v1, v5, v4], _strokePaint(0.5), fill: _fillPaint(0.18)); // Top
    _drawPolygon(canvas, [v3, v2, v6, v7], _strokePaint(0.5), fill: _fillPaint(0.18)); // Bot
    _drawPolygon(canvas, [v4, v5, v6, v7], _strokePaint(), fill: _fillPaint(0.2)); // Front

    // Floating dimension labels on an edge
    _labelBox(canvas, 'w = ${width.toStringAsFixed(1)} $unit', Offset((v4.dx + v5.dx)/2, (v4.dy + v5.dy)/2 - 20));
    _labelBox(canvas, 'h = ${height.toStringAsFixed(1)} $unit', Offset((v5.dx + v6.dx)/2 + 10, (v5.dy + v6.dy)/2));
    _labelBox(canvas, 'd = ${depth.toStringAsFixed(1)} $unit', Offset((v1.dx + v5.dx)/2 + 10, (v1.dy + v5.dy)/2));
  }

  void _drawPyramid(Canvas canvas, Size size, double cx, double cy, double p) {
    final w = width * 16 * p;
    final h = height * 16 * p;
    Offset proj(double x, double y, double z) => _project(x, y, z, cx, cy);

    final apex = proj(0, -h/2, 0);
    final v0 = proj(-w/2, h/2, -w/2);
    final v1 = proj(w/2, h/2, -w/2);
    final v2 = proj(w/2, h/2, w/2);
    final v3 = proj(-w/2, h/2, w/2);

    _drawPolygon(canvas, [v0, v1, v2, v3], _strokePaint(0.5), fill: _fillPaint(0.15)); // Base
    _drawPolygon(canvas, [apex, v0, v1], _strokePaint(0.5), fill: _fillPaint(0.1));
    _drawPolygon(canvas, [apex, v1, v2], _strokePaint(0.7), fill: _fillPaint(0.15));
    _drawPolygon(canvas, [apex, v2, v3], _strokePaint(), fill: _fillPaint(0.2));
    _drawPolygon(canvas, [apex, v3, v0], _strokePaint(), fill: _fillPaint(0.15));

    final baseCenter = proj(0, h/2, 0);
    _drawDashed(canvas, apex, baseCenter, _strokePaint(0.5));
    canvas.drawCircle(apex, 5, Paint()..color = AppTheme.accent);

    _labelBox(canvas, 'base = ${width.toStringAsFixed(1)} $unit', Offset(v3.dx - 30, v3.dy + 15));
    _labelBox(canvas, 'h = ${height.toStringAsFixed(1)} $unit', Offset((apex.dx + baseCenter.dx)/2 + 10, (apex.dy + baseCenter.dy)/2));
  }

  void _drawSphere(Canvas canvas, Size size, double cx, double cy, double p) {
    final r = radius * 16 * p;
    Offset proj(double x, double y, double z) => _project(x, y, z, cx, cy);

    // Outline sphere
    canvas.drawCircle(Offset(cx, cy), r, _fillPaint(0.15));
    final grad = RadialGradient(center: const Alignment(-0.35, -0.4), colors: [_fillColor.withOpacity(0.4), _fillColor.withOpacity(0.05)]);
    canvas.drawCircle(Offset(cx, cy), r, Paint()..shader = grad.createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    canvas.drawCircle(Offset(cx, cy), r, _strokePaint());

    // Rotating 3D equator (XZ plane)
    List<Offset> eq = [];
    for(int i=0; i<30; i++) {
       double a = i * 2 * math.pi / 30;
       eq.add(proj(r * math.cos(a), 0, r * math.sin(a)));
    }
    _drawPolygon(canvas, eq, _strokePaint(0.6));

    // Rotating 3D meridian (YZ plane)
    List<Offset> mer = [];
    for(int i=0; i<30; i++) {
       double a = i * 2 * math.pi / 30;
       mer.add(proj(0, r * math.cos(a), r * math.sin(a)));
    }
    _drawPolygon(canvas, mer, _strokePaint(0.4));

    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = AppTheme.accent);
    _labelBox(canvas, 'r = ${radius.toStringAsFixed(1)} $unit', Offset(cx + 20, cy + 10));
  }

  void _drawCylinder(Canvas canvas, Size size, double cx, double cy, double p) {
    final r = radius * 14 * p;
    final h = height * 12 * p;
    Offset proj(double x, double y, double z) => _project(x, y, z, cx, cy);

    List<Offset> topPts = [];
    List<Offset> botPts = [];
    for(int i=0; i<=30; i++) {
       double a = i * 2 * math.pi / 30;
       topPts.add(proj(r * math.cos(a), -h/2, r * math.sin(a)));
       botPts.add(proj(r * math.cos(a), h/2, r * math.sin(a)));
    }

    // Connect top and bot with translucent body
    for (int i=0; i<30; i+=2) {
      final path = Path()..moveTo(topPts[i].dx, topPts[i].dy)..lineTo(topPts[i+2].dx, topPts[i+2].dy)
          ..lineTo(botPts[i+2].dx, botPts[i+2].dy)..lineTo(botPts[i].dx, botPts[i].dy)..close();
      canvas.drawPath(path, _fillPaint(0.02));
    }

    _drawPolygon(canvas, botPts, _strokePaint(0.8), fill: _fillPaint(0.15));
    _drawPolygon(canvas, topPts, _strokePaint(), fill: _fillPaint(0.2));

    // Vertical bounding generator lines for visual framing
    for(int i=0; i<30; i+=6) {
      canvas.drawLine(topPts[i], botPts[i], _strokePaint(0.4));
    }

    final topCenter = proj(0, -h/2, 0);
    final botCenter = proj(0, h/2, 0);
    _drawDashed(canvas, topCenter, botCenter, _strokePaint(0.5));
    
    // Radius indicator on bottom base
    canvas.drawLine(botCenter, botPts[0], _strokePaint(0.8));

    _labelBox(canvas, 'r = ${radius.toStringAsFixed(1)} $unit', Offset(botCenter.dx + 4, botCenter.dy - 6));
    _labelBox(canvas, 'h = ${height.toStringAsFixed(1)} $unit', Offset((topCenter.dx + botCenter.dx)/2 + 20, (topCenter.dy + botCenter.dy)/2));
  }

  void _drawCone(Canvas canvas, Size size, double cx, double cy, double p) {
    final r = radius * 14 * p;
    final h = height * 14 * p;
    Offset proj(double x, double y, double z) => _project(x, y, z, cx, cy);

    final apex = proj(0, -h/2, 0);
    List<Offset> basePts = [];
    for(int i=0; i<=30; i++) {
       double a = i * 2 * math.pi / 30;
       basePts.add(proj(r * math.cos(a), h/2, r * math.sin(a)));
    }

    // Body fills
    for (int i=0; i<30; i+=2) {
      final path = Path()..moveTo(apex.dx, apex.dy)..lineTo(basePts[i].dx, basePts[i].dy)..lineTo(basePts[i+2].dx, basePts[i+2].dy)..close();
      canvas.drawPath(path, _fillPaint(0.03));
    }

    _drawPolygon(canvas, basePts, _strokePaint(), fill: _fillPaint(0.15));

    // Generator lines
    for(int i=0; i<30; i+=5) {
      canvas.drawLine(apex, basePts[i], _strokePaint(0.5));
    }

    final baseCenter = proj(0, h/2, 0);
    _drawDashed(canvas, apex, baseCenter, _strokePaint(0.5));
    canvas.drawLine(baseCenter, basePts[0], _strokePaint(0.8));
    canvas.drawCircle(apex, 5, Paint()..color = AppTheme.accent);

    _labelBox(canvas, 'r = ${radius.toStringAsFixed(1)} $unit', Offset(baseCenter.dx + 4, baseCenter.dy - 6));
    _labelBox(canvas, 'h = ${height.toStringAsFixed(1)} $unit', Offset((apex.dx + baseCenter.dx)/2 + 10, (apex.dy + baseCenter.dy)/2));
  }

  // ── Helpers ──────────────────────────────────────────────────
  void _drawPolygon(Canvas canvas, List<Offset> pts, Paint stroke, {Paint? fill}) {
    if (pts.isEmpty) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    if (fill != null) canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawDimLine(Canvas canvas, Offset a, Offset b, String label, {bool vertical = false}) {
    canvas.drawLine(a, b, _strokePaint(0.6));
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    _labelBox(canvas, label, vertical ? mid + const Offset(4, -8) : mid + const Offset(-30, 2));
  }

  void _drawDashed(Canvas canvas, Offset start, Offset end, Paint p) {
    const dash = 6.0;
    const gap = 4.0;
    final dir = (end - start) / (end - start).distance;
    double drawn = 0;
    final total = (end - start).distance;
    while (drawn < total) {
      final from = start + dir * drawn;
      final to = start + dir * (drawn + dash).clamp(0, total);
      canvas.drawLine(from, to, p);
      drawn += dash + gap;
    }
  }

  void _labelBox(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: _fillColor, fontSize: 12, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    final bg = Rect.fromLTWH(pos.dx - 4, pos.dy - 2, tp.width + 8, tp.height + 4);
    canvas.drawRRect(RRect.fromRectAndRadius(bg, const Radius.circular(4)), Paint()..color = const Color(0xFF0A0F1E).withOpacity(0.75));
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(MensurationPainter old) =>
      old.width != width || old.height != height || old.radius != radius ||
      old.depth != depth || old.shape != shape || old.unit != unit ||
      old.rotX != rotX || old.rotY != rotY || old.animProgress != animProgress;
}
