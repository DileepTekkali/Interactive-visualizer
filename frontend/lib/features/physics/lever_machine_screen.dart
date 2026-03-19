// FIXED: Fullscreen responsive layout with diagram labels

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';

class LeverScreen extends StatefulWidget {
  const LeverScreen({super.key});

  @override
  State<LeverScreen> createState() => _LeverScreenState();
}

class _LeverScreenState extends State<LeverScreen> {
  double _loadArm = 2.0;
  double _effortArm = 4.0;
  double _loadMass = 50.0;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    const double g = 9.81;
    final double loadForce = _loadMass * g;
    final double ma = _effortArm / _loadArm;
    final double effortRequired = loadForce / ma;

    if (mounted) {
      setState(() {
        _data = {
          'success': true,
          'mechanical_advantage': ma,
          'load_force': loadForce,
          'effort_required': effortRequired,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 360.0 : screenWidth * 0.9;
    return MainLayout(
      title: 'Lever Simple Machine',
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls(controlWidth)])
          : SingleChildScrollView(
              child: Column(
                  children: [_buildVisual(), _buildControls(controlWidth)])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 900;
    final ma = (_data?['mechanical_advantage'] as num?)?.toDouble() ?? 0.0;

    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: AppTheme.glassCard,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildValueTag(
                    'MA = ${ma.toStringAsFixed(2)}x', Colors.greenAccent),
                const SizedBox(width: 8),
                _buildValueTag('Effort: ${_effortArm.toStringAsFixed(0)}m',
                    Colors.blueAccent),
                const SizedBox(width: 8),
                _buildValueTag(
                    'Load: ${_loadArm.toStringAsFixed(0)}m', Colors.redAccent),
              ],
            ),
            const SizedBox(height: 4),
            Text('Mechanical Advantage: ${ma.toStringAsFixed(2)}x',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 16, color: Colors.greenAccent)),
            Expanded(
              child: CustomPaint(
                painter: _LeverPainter(
                  effortArm: _effortArm,
                  loadArm: _loadArm,
                  loadMass: _loadMass,
                  effortRequired:
                      (_data?['effort_required'] as num?)?.toDouble() ?? 0.0,
                  loadForce: (_data?['load_force'] as num?)?.toDouble() ?? 0.0,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color)),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      );

  Widget _buildControls(double width) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final ma = (_data?['mechanical_advantage'] as num?)?.toDouble() ?? 0.0;
    final loadForce = (_data?['load_force'] as num?)?.toDouble() ?? 0.0;
    final effortRequired =
        (_data?['effort_required'] as num?)?.toDouble() ?? 0.0;

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
                Text('Lever Parameters',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 16),
                ParameterSlider(
                    label: 'Effort Arm (m)',
                    value: _effortArm,
                    min: 1,
                    max: 10,
                    onChanged: (v) {
                      setState(() => _effortArm = v);
                      _calculate();
                    }),
                ParameterSlider(
                    label: 'Load Arm (m)',
                    value: _loadArm,
                    min: 1,
                    max: 10,
                    onChanged: (v) {
                      setState(() => _loadArm = v);
                      _calculate();
                    }),
                ParameterSlider(
                    label: 'Load Mass (kg)',
                    value: _loadMass,
                    min: 10,
                    max: 200,
                    onChanged: (v) {
                      setState(() => _loadMass = v);
                      _calculate();
                    }),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _stat('Mechanical Advantage', '${ma.toStringAsFixed(2)}x',
                          Colors.greenAccent),
                      _stat(
                          'Load Force (Weight)',
                          '${loadForce.toStringAsFixed(1)} N',
                          Colors.redAccent),
                      _stat(
                          'Effort Required',
                          '${effortRequired.toStringAsFixed(1)} N',
                          Colors.blueAccent),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blueAccent, size: 16),
                          const SizedBox(width: 8),
                          Text('How Levers Work',
                              style: GoogleFonts.inter(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ma > 1
                            ? 'MA > 1: Less effort needed to lift the load! This is a Class 1 or Class 2 lever.'
                            : 'MA < 1: More effort needed, but you gain speed/range of motion.',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoBox('Effort', 'The force you apply on the long arm',
                    Colors.blueAccent),
                _buildInfoBox(
                    'Load',
                    'The weight being lifted on the short arm',
                    Colors.redAccent),
                _buildInfoBox('Fulcrum', 'The pivot point of the lever',
                    Colors.greenAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
          Text(value,
              style: GoogleFonts.jetBrainsMono(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13))
        ]),
      );

  Widget _buildInfoBox(String title, String desc, Color color) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(
          children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  Text(desc,
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _LeverPainter extends CustomPainter {
  final double effortArm;
  final double loadArm;
  final double loadMass;
  final double effortRequired;
  final double loadForce;

  _LeverPainter(
      {required this.effortArm,
      required this.loadArm,
      required this.loadMass,
      required this.effortRequired,
      required this.loadForce});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 1.8);
    final scale = (size.width - 150) / (effortArm + loadArm);

    // Fulcrum triangle
    final fulcrumPath = Path()
      ..moveTo(center.dx, center.dy + 15)
      ..lineTo(center.dx - 30, center.dy + 60)
      ..lineTo(center.dx + 30, center.dy + 60)
      ..close();
    canvas.drawPath(fulcrumPath, Paint()..color = Colors.greenAccent);

    // Beam
    final leftX = center.dx - (loadArm * scale);
    final rightX = center.dx + (effortArm * scale);
    canvas.drawLine(
        Offset(leftX, center.dy),
        Offset(rightX, center.dy),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 12);
    canvas.drawLine(
        Offset(center.dx, center.dy),
        Offset(center.dx, center.dy + 15),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 6);

    // Labels with background - above diagram
    _drawLabel(canvas, 'Load Arm: ${loadArm.toStringAsFixed(1)}m',
        Offset(leftX, 30), Colors.redAccent);
    _drawLabel(canvas, 'Effort Arm: ${effortArm.toStringAsFixed(1)}m',
        Offset(rightX, 30), Colors.blueAccent);

    // Load box
    double boxSize = 35 + (loadMass / 4);
    final loadBoxTop = center.dy - boxSize;
    final loadBox =
        Rect.fromLTRB(leftX - 30, loadBoxTop, leftX + 30, center.dy);
    canvas.drawRect(loadBox, Paint()..color = Colors.redAccent);
    canvas.drawRect(
        loadBox,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);

    // Load labels - below box
    _drawLabel(canvas, 'LOAD', Offset(leftX, center.dy + 80), Colors.redAccent);
    _drawLabel(canvas, '${loadForce.toStringAsFixed(0)}N',
        Offset(leftX, center.dy + 95), Colors.redAccent);

    // Effort arrow
    double arrowLen = (40 + (effortRequired / 4)).clamp(40, 100);
    final arrowTop = center.dy - arrowLen;
    canvas.drawLine(
        Offset(rightX, center.dy - 5),
        Offset(rightX, arrowTop),
        Paint()
          ..color = Colors.blueAccent
          ..strokeWidth = 5);
    _drawArrowHead(
        canvas, Offset(rightX, arrowTop), Colors.blueAccent, math.pi / 2);

    // Effort labels - above arrow
    _drawLabel(
        canvas, 'EFFORT', Offset(rightX, arrowTop - 25), Colors.blueAccent);
    _drawLabel(canvas, '${effortRequired.toStringAsFixed(0)}N',
        Offset(rightX, arrowTop - 40), Colors.blueAccent);

    // Fulcrum label
    _drawLabel(canvas, 'FULCRUM', Offset(center.dx, center.dy + 75),
        Colors.greenAccent);

    // MA display - top right
    _drawLabel(
        canvas,
        'MA = ${(loadForce / effortRequired).toStringAsFixed(2)}x',
        Offset(size.width - 80, 30),
        Colors.greenAccent);
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Color color, double angle) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4;
    canvas.drawLine(
        tip,
        Offset(tip.dx - 12 * math.cos(angle - 0.4),
            tip.dy - 12 * math.sin(angle - 0.4)),
        paint);
    canvas.drawLine(
        tip,
        Offset(tip.dx - 12 * math.cos(angle + 0.4),
            tip.dy - 12 * math.sin(angle + 0.4)),
        paint);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color) {
    final textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: GoogleFonts.inter(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout();
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(pos.dx - textPainter.width / 2 - 4, pos.dy - 2,
                textPainter.width + 8, textPainter.height + 4),
            const Radius.circular(4)),
        bgPaint);
    textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, pos.dy));
  }

  @override
  bool shouldRepaint(covariant _LeverPainter oldDelegate) => true;
}
