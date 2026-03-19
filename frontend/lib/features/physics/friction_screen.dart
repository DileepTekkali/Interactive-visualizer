// FIXED: Fullscreen responsive layout with diagram labels

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'dart:math' as math;

class FrictionScreen extends StatefulWidget {
  const FrictionScreen({super.key});

  @override
  State<FrictionScreen> createState() => _FrictionScreenState();
}

class _FrictionScreenState extends State<FrictionScreen> {
  double _angle = 30.0;
  double _mass = 50.0;
  double _mu = 0.5;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    const double g = 9.81;
    final double rad = _angle * math.pi / 180;
    final double gravityParallel = _mass * g * math.sin(rad);
    final double normalForce = _mass * g * math.cos(rad);
    final double staticMax = _mu * normalForce;
    bool sliding = gravityParallel > staticMax;
    double frictionForce =
        sliding ? (_mu * 0.8 * normalForce) : gravityParallel;

    setState(() {
      _data = {
        'success': true,
        'normal_force': normalForce,
        'friction_force': frictionForce,
        'is_sliding': sliding,
        'will_slide': sliding,
        'gravity_component': gravityParallel,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 360.0 : screenWidth * 0.9;
    return MainLayout(
      title: 'Friction Simulator',
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls(controlWidth)])
          : SingleChildScrollView(
              child: Column(
                  children: [_buildVisual(), _buildControls(controlWidth)])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 900;
    final frictionForce = (_data['friction_force'] as num?)?.toDouble() ?? 0.0;
    final isSliding = _data['is_sliding'] == true;

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
                    'θ = ${_angle.toStringAsFixed(0)}°', Colors.blueAccent),
                const SizedBox(width: 8),
                _buildValueTag(
                    'μ = ${_mu.toStringAsFixed(2)}', Colors.orangeAccent),
                const SizedBox(width: 8),
                _buildValueTag(
                    'm = ${_mass.toStringAsFixed(0)}kg', Colors.greenAccent),
              ],
            ),
            Expanded(
              child: CustomPaint(
                painter: _FrictionPainter(
                  mass: _mass,
                  mu: _mu,
                  angle: _angle,
                  frictionForce: frictionForce,
                  isSliding: isSliding,
                  normalForce:
                      (_data['normal_force'] as num?)?.toDouble() ?? 0.0,
                  gravityComponent:
                      (_data['gravity_component'] as num?)?.toDouble() ?? 0.0,
                ),
                size: Size.infinite,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildValueBox(
                      'Friction',
                      '${frictionForce.toStringAsFixed(1)} N',
                      isSliding ? Colors.redAccent : Colors.greenAccent),
                  _buildValueBox('Status', isSliding ? 'SLIDING' : 'STATIC',
                      isSliding ? Colors.redAccent : Colors.greenAccent),
                ],
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
                fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      );

  Widget _buildValueBox(String label, String value, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color)),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
            Text(value,
                style: GoogleFonts.jetBrainsMono(
                    color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildControls(double width) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final normalForce = (_data['normal_force'] as num?)?.toDouble() ?? 0.0;
    final frictionForce = (_data['friction_force'] as num?)?.toDouble() ?? 0.0;
    final isSliding = _data['is_sliding'] == true;

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
                Text('Parameters',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 12),
                ParameterSlider(
                    label: 'Mass (kg)',
                    value: _mass,
                    min: 1,
                    max: 100,
                    onChanged: (v) {
                      setState(() => _mass = v);
                      _calculate();
                    }),
                ParameterSlider(
                    label: 'Friction Coeff (μ)',
                    value: _mu,
                    min: 0.1,
                    max: 1.0,
                    onChanged: (v) {
                      setState(() => _mu = v);
                      _calculate();
                    }),
                ParameterSlider(
                    label: 'Incline Angle (°)',
                    value: _angle,
                    min: 0,
                    max: 90,
                    onChanged: (v) {
                      setState(() => _angle = v);
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
                      _stat('Normal Force (N)',
                          '${normalForce.toStringAsFixed(2)} N'),
                      _stat('Friction Force',
                          '${frictionForce.toStringAsFixed(2)} N'),
                      _stat('Status', isSliding ? 'SLIDING' : 'STATIC',
                          color: isSliding
                              ? Colors.redAccent
                              : Colors.greenAccent),
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
                      Text('Forces on Inclined Plane',
                          style: GoogleFonts.inter(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      const SizedBox(height: 8),
                      _forceLegend(Colors.greenAccent, 'Weight (W = mg)'),
                      _forceLegend(Colors.blueAccent, 'Normal Force (N)'),
                      _forceLegend(Colors.redAccent, 'Friction Force (f)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
          Text(value,
              style: GoogleFonts.jetBrainsMono(
                  color: color ?? Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13))
        ]),
      );

  Widget _forceLegend(Color color, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
          ],
        ),
      );
}

class _FrictionPainter extends CustomPainter {
  final double angle;
  final double mass;
  final double mu;
  final double frictionForce;
  final bool isSliding;
  final double normalForce;
  final double gravityComponent;

  _FrictionPainter(
      {required this.angle,
      required this.mass,
      required this.mu,
      required this.frictionForce,
      required this.isSliding,
      required this.normalForce,
      required this.gravityComponent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 1.8);
    final rad = angle * math.pi / 180;
    final scale = size.width / 500;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rad);

    // Ground/Plane
    canvas.drawLine(
        Offset(-200 * scale, 0),
        Offset(200 * scale, 0),
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 4);
    canvas.drawLine(
        Offset(-200 * scale, 0),
        Offset(-180 * scale, -20 * scale),
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 2);

    // Block
    double boxSize = 40 + (mass / 3);
    final boxRect = Rect.fromLTRB(-boxSize / 2, -boxSize, boxSize / 2, 0);
    canvas.drawRect(boxRect, Paint()..color = Colors.orangeAccent);
    canvas.drawRect(
        boxRect,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);

    canvas.restore();

    // Labels and arrows in world coordinates
    final arrowPaint = Paint()..strokeWidth = 3;

    // Normal force arrow (perpendicular to plane)
    arrowPaint.color = Colors.blueAccent;
    canvas.drawLine(Offset(center.dx, center.dy - boxSize - 20 * scale),
        Offset(center.dx, center.dy - boxSize - 60 * scale), arrowPaint);
    _drawArrowHead(canvas, Offset(center.dx, center.dy - boxSize - 60 * scale),
        Colors.blueAccent, -math.pi / 2);
    _drawLabel(
        canvas,
        'N = ${normalForce.toStringAsFixed(0)}N',
        Offset(center.dx + 10, center.dy - boxSize - 70 * scale),
        Colors.blueAccent);

    // Gravity arrow (straight down)
    arrowPaint.color = Colors.greenAccent;
    double gdx = (center.dy) * math.tan(rad);
    canvas.drawLine(
        Offset(center.dx, center.dy - boxSize / 2),
        Offset(center.dx + gdx, center.dy - boxSize / 2 + 80 * scale),
        arrowPaint);
    _drawArrowHead(
        canvas,
        Offset(center.dx + gdx, center.dy - boxSize / 2 + 80 * scale),
        Colors.greenAccent,
        math.pi / 2 - rad);
    _drawLabel(
        canvas,
        'W = ${(mass * 9.81).toStringAsFixed(0)}N',
        Offset(center.dx + gdx + 10, center.dy - boxSize / 2 + 40),
        Colors.greenAccent);

    // Friction arrow (opposite to motion)
    arrowPaint.color = Colors.redAccent;
    double frictionLen = (frictionForce * 2).clamp(20, 80) * scale;
    canvas.drawLine(
        Offset(center.dx + 20 * scale, center.dy - boxSize / 2),
        Offset(center.dx + 20 * scale - frictionLen, center.dy - boxSize / 2),
        arrowPaint);
    _drawArrowHead(
        canvas,
        Offset(center.dx + 20 * scale - frictionLen, center.dy - boxSize / 2),
        Colors.redAccent,
        rad > 0 ? 0 : math.pi);
    _drawLabel(
        canvas,
        'f = ${frictionForce.toStringAsFixed(0)}N',
        Offset(center.dx + 20 * scale - frictionLen - 50,
            center.dy - boxSize / 2 - 15),
        Colors.redAccent);

    // Angle label
    _drawLabel(canvas, 'θ = ${angle.toStringAsFixed(0)}°',
        Offset(center.dx + 60 * scale, center.dy + 30 * scale), Colors.white54);
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Color color, double angle) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;
    canvas.drawLine(
        tip,
        Offset(tip.dx - 8 * math.cos(angle - 0.4),
            tip.dy - 8 * math.sin(angle - 0.4)),
        paint);
    canvas.drawLine(
        tip,
        Offset(tip.dx - 8 * math.cos(angle + 0.4),
            tip.dy - 8 * math.sin(angle + 0.4)),
        paint);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color) {
    final textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: GoogleFonts.inter(
                color: color, fontSize: 10, fontWeight: FontWeight.w500)),
        textDirection: TextDirection.ltr)
      ..layout();
    textPainter.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _FrictionPainter oldDelegate) => true;
}
