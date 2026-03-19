import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'dart:math' as math;

class OpticsScreen extends StatefulWidget {
  const OpticsScreen({super.key});

  @override
  State<OpticsScreen> createState() => _OpticsScreenState();
}

class _OpticsScreenState extends State<OpticsScreen> {
  double _angle = 45.0;
  double _n1 = 1.0;
  double _n2 = 1.5;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final double theta1Deg = _angle;
    final double n1 = _n1;
    final double n2 = _n2;

    final double theta1Rad = theta1Deg * math.pi / 180;
    final double sinTheta2 = (n1 / n2) * math.sin(theta1Rad);

    bool tir = false;
    double theta2Deg = 0;

    if (sinTheta2.abs() > 1.0) {
      tir = true;
    } else {
      theta2Deg = math.asin(sinTheta2) * 180 / math.pi;
    }

    if (mounted) {
      setState(() {
        _data = {
          'success': true,
          'incident_angle_deg': theta1Deg,
          'refracted_angle_deg': theta2Deg,
          'total_internal_reflection': tir,
          'snell_n1': n1,
          'snell_n2': n2,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 320.0 : screenWidth * 0.9;
    return MainLayout(
      title: "Snell's Law (Optics)",
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls(controlWidth)])
          : SingleChildScrollView(
              child: Column(children: [
              _buildVisual(),
              _buildControls(screenWidth * 0.9)
            ])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 900;
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Refraction through Mediums',
                        style: GoogleFonts.inter(
                            fontSize: 16, color: Colors.blueAccent)),
                    if (_data?['success'] == true) ...[
                      _buildValueTag(
                          'n₁=${_data?['snell_n1']}', Colors.yellowAccent),
                      const SizedBox(width: 8),
                      _buildValueTag(
                          'n₂=${_data?['snell_n2']}', Colors.greenAccent),
                    ],
                  ],
                )),
            Expanded(
              child: CustomPaint(
                painter: _OpticsPainter(
                  incidentAngle: _angle,
                  refractedAngle:
                      (_data?['refracted_angle_deg'] as num?)?.toDouble() ??
                          0.0,
                  totalInternalRefl:
                      _data?['total_internal_reflection'] ?? false,
                  n1: _data?['snell_n1'] ?? 1.0,
                  n2: _data?['snell_n2'] ?? 1.5,
                ),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(height: 400, child: content);
  }

  Widget _buildValueTag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color)),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      );

  Widget _buildControls(double width) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return SizedBox(
        width: width,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 12, isWide ? 12 : 8, 12),
            child: Container(
                decoration: AppTheme.glassCard,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Text('Light Refraction Parameters',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 12),
                      ParameterSlider(
                          label: 'Incident Angle (θ₁)',
                          value: _angle,
                          min: 0,
                          max: 90,
                          onChanged: (v) {
                            setState(() => _angle = v);
                            _calculate();
                          }),
                      ParameterSlider(
                          label: 'Medium 1 Index (n₁)',
                          value: _n1,
                          min: 1.0,
                          max: 3.0,
                          onChanged: (v) {
                            setState(() => _n2 = v);
                            _calculate();
                          }),
                      ParameterSlider(
                          label: 'Medium 2 Index (n₂)',
                          value: _n2,
                          min: 1.0,
                          max: 3.0,
                          onChanged: (v) {
                            setState(() => _n2 = v);
                            _calculate();
                          }),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Snells Law',
                                style: GoogleFonts.inter(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('n₁sin(θ₁) = n₂sin(θ₂)',
                                style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_data != null) ...[
                        if (_data?['success'] == true) ...[
                          _stat('Incident Angle (θ₁)',
                              "${(_data?['incident_angle_deg'] as num?)?.toDouble()?.toStringAsFixed(1) ?? '0.0'}°"),
                          if (_data?['total_internal_reflection'] == true) ...[
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('TOTAL INTERNAL REFLECTION',
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                            Text('Critical angle exceeded!',
                                style: GoogleFonts.inter(
                                    color: Colors.white54, fontSize: 11)),
                          ] else
                            _stat('Refracted Angle (θ₂)',
                                "${(_data?['refracted_angle_deg'] as num?)?.toDouble()?.toStringAsFixed(1) ?? '0.0'}°"),
                        ] else
                          Text(_data?['error'] ?? 'Simulation Error',
                              style: const TextStyle(color: Colors.redAccent))
                      ]
                    ])))));
  }

  Widget _stat(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        Text(v,
            style: GoogleFonts.jetBrainsMono(
                color: Colors.orangeAccent, fontSize: 13))
      ]));
}

class _OpticsPainter extends CustomPainter {
  final double incidentAngle;
  final double refractedAngle;
  final bool totalInternalRefl;
  final double n1;
  final double n2;

  _OpticsPainter(
      {required this.incidentAngle,
      required this.refractedAngle,
      required this.totalInternalRefl,
      required this.n1,
      required this.n2});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Medium labels with values
    _drawText(canvas, 'Medium 1 (n=${n1.toStringAsFixed(1)})', Offset(20, 10),
        Colors.yellowAccent, 11);
    _drawText(canvas, 'Medium 2 (n=${n2.toStringAsFixed(1)})',
        Offset(20, center.dy + 10), Colors.greenAccent, 11);

    // Mediums
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, center.dy),
        Paint()..color = Colors.yellowAccent.withValues(alpha: 0.1));
    canvas.drawRect(Rect.fromLTRB(0, center.dy, size.width, size.height),
        Paint()..color = Colors.greenAccent.withValues(alpha: 0.1));

    // Interface line
    canvas.drawLine(
        Offset(0, center.dy),
        Offset(size.width, center.dy),
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 2);

    // Normal Line (dashed)
    _drawDashedLine(
        canvas,
        Offset(center.dx, 0),
        Offset(center.dx, size.height),
        Paint()
          ..color = Colors.white38
          ..strokeWidth = 1);
    _drawText(canvas, 'Normal', Offset(center.dx + 5, 30), Colors.white54, 9);

    // Incident Ray
    double incRad = incidentAngle * math.pi / 180;
    final startX = center.dx - 180 * math.sin(incRad);
    final startY = center.dy - 180 * math.cos(incRad);
    canvas.drawLine(
        Offset(startX, startY),
        center,
        Paint()
          ..color = Colors.yellowAccent
          ..strokeWidth = 4);
    _drawText(canvas, 'Incident Ray', Offset(startX + 5, startY),
        Colors.yellowAccent, 9);

    // Angle arc for incident
    _drawAngleArc(canvas, center, incRad, true);

    // Refracted or Reflected
    if (totalInternalRefl) {
      final refX = center.dx + 180 * math.sin(incRad);
      final refY = center.dy - 180 * math.cos(incRad);
      canvas.drawLine(
          center,
          Offset(refX, refY),
          Paint()
            ..color = Colors.orange
            ..strokeWidth = 4);
      _drawText(canvas, 'Reflected Ray', Offset(refX - 80, refY - 10),
          Colors.orange, 9);
    } else {
      double refRad = refractedAngle * math.pi / 180;
      final endX = center.dx + 180 * math.sin(refRad);
      final endY = center.dy + 180 * math.cos(refRad);
      canvas.drawLine(
          center,
          Offset(endX, endY),
          Paint()
            ..color = Colors.greenAccent
            ..strokeWidth = 4);
      _drawText(canvas, 'Refracted Ray', Offset(endX + 5, endY - 20),
          Colors.greenAccent, 9);
      _drawAngleArc(canvas, center, refRad, false);
    }

    // Angle labels on diagram
    _drawText(canvas, 'θ₁=${incidentAngle.toStringAsFixed(0)}°',
        Offset(center.dx + 40, center.dy - 50), Colors.yellowAccent, 10);
    if (!totalInternalRefl) {
      _drawText(canvas, 'θ₂=${refractedAngle.toStringAsFixed(0)}°',
          Offset(center.dx + 40, center.dy + 20), Colors.greenAccent, 10);
    }
  }

  void _drawAngleArc(Canvas canvas, Offset center, double angle, bool isTop) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isTop ? Colors.yellowAccent : Colors.greenAccent;
    final rect = Rect.fromCenter(center: center, width: 40, height: 40);
    if (isTop) {
      canvas.drawArc(rect, -math.pi / 2 - angle, angle, false, paint);
    } else {
      canvas.drawArc(rect, math.pi / 2, angle, false, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final distance = (end - start).distance;
    final dx = (end.dx - start.dx) / distance;
    final dy = (end.dy - start.dy) / distance;
    var currentX = start.dx;
    var currentY = start.dy;
    for (var i = 0.0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(Offset(currentX, currentY),
          Offset(currentX + dx * dashWidth, currentY + dy * dashWidth), paint);
      currentX += dx * (dashWidth + dashSpace);
      currentY += dy * (dashWidth + dashSpace);
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color,
      double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: GoogleFonts.inter(
              color: color, fontSize: fontSize, fontWeight: FontWeight.w500)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _OpticsPainter oldDelegate) => true;
}
