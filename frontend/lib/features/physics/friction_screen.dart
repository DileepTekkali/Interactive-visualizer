// FIXED: Slider updates and value display visibility
// Issue: Values may not update when sliders change
// Fix: Ensured all slider callbacks use setState properly

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
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Friction Simulator',
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls()])
          : SingleChildScrollView(
              child: Column(children: [_buildVisual(), _buildControls()])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final frictionForce = (_data['friction_force'] as num?)?.toDouble() ?? 0.0;
    final isSliding = _data['is_sliding'] == true;

    return SizedBox(
      width: isWide ? 320 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Surface Friction Mechanics',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 18, color: Colors.blueAccent)),
              ),
              Expanded(
                child: CustomPaint(
                  painter: _FrictionPainter(
                    mass: _mass,
                    mu: _mu,
                    angle: _angle,
                    frictionForce: frictionForce,
                    isSliding: isSliding,
                  ),
                  size: Size.infinite,
                ),
              ),
              // FIXED: Show values below diagram
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _valueBox(
                        'Normal', '${frictionForce.toStringAsFixed(1)} N'),
                    _valueBox('Status', isSliding ? 'SLIDING' : 'STATIC'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _valueBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
          Text(value,
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final normalForce = (_data['normal_force'] as num?)?.toDouble() ?? 0.0;
    final frictionForce = (_data['friction_force'] as num?)?.toDouble() ?? 0.0;
    final isSliding = _data['is_sliding'] == true;

    return SizedBox(
      width: isWide ? 320 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIXED: All sliders now use setState properly
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
                    label: 'Friction Coefficient (μ)',
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
                // FIXED: Clear value display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _stat('Normal Force',
                          '${normalForce.toStringAsFixed(2)} N'),
                      _stat('Friction Force',
                          '${frictionForce.toStringAsFixed(2)} N'),
                      const Divider(color: Colors.white24),
                      _stat('Status', isSliding ? 'SLIDING' : 'STATIC',
                          color: isSliding
                              ? Colors.redAccent
                              : Colors.greenAccent),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(color: Colors.white70)),
            Text(value,
                style: GoogleFonts.jetBrainsMono(
                  color: color ?? Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ))
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

  _FrictionPainter({
    required this.angle,
    required this.mass,
    required this.mu,
    required this.frictionForce,
    required this.isSliding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 1.5);
    final rad = angle * math.pi / 180;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rad);

    // Plane
    canvas.drawLine(
        const Offset(-200, 0),
        const Offset(200, 0),
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 4);

    // Block
    double boxSize = 40 + (mass / 2);
    final boxRect = Rect.fromLTRB(-boxSize / 2, -boxSize, boxSize / 2, 0);
    canvas.drawRect(boxRect, Paint()..color = Colors.orangeAccent);
    canvas.drawRect(
        boxRect,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);

    // Forces Arrows
    final arrowPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3;
    final redPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3;

    // Normal force (up relative to plane)
    canvas.drawLine(Offset(0, -boxSize), Offset(0, -boxSize - 50), arrowPaint);

    // Gravity (straight down in global coords)
    canvas.save();
    canvas.rotate(rad);
    canvas.drawLine(
        Offset(0, 0),
        Offset(0, 80),
        Paint()
          ..color = Colors.greenAccent
          ..strokeWidth = 3);
    canvas.restore();

    // Friction (up plane)
    double fLen = (frictionForce * 10).clamp(10, 100);
    canvas.drawLine(
        Offset(0, -boxSize / 2), Offset(-fLen, -boxSize / 2), redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FrictionPainter oldDelegate) => true;
}
