// FIXED: Fullscreen responsive layout with diagram labels

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';

class NewtonsLawsScreen extends StatefulWidget {
  const NewtonsLawsScreen({super.key});

  @override
  State<NewtonsLawsScreen> createState() => _NewtonsLawsScreenState();
}

class _NewtonsLawsScreenState extends State<NewtonsLawsScreen>
    with SingleTickerProviderStateMixin {
  double _force = 50.0;
  double _mass = 10.0;
  Map<String, dynamic>? _data;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _calculate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _calculate() {
    final accel = _mass == 0 ? 0.0 : _force / _mass;
    if (mounted) {
      setState(() {
        _data = {
          'success': true,
          'acceleration': accel,
          'law_statement':
              "F = ma → ${_force}N = ${_mass}kg × ${accel.toStringAsFixed(2)}m/s²",
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
      title: "Newton's 2nd Law",
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls(controlWidth)])
          : SingleChildScrollView(
              child: Column(
                  children: [_buildVisual(), _buildControls(controlWidth)])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 900;
    final accel = (_data?['acceleration'] as num?)?.toDouble() ?? 0.0;

    _animController.duration = Duration(
        milliseconds: accel == 0
            ? 999999
            : (2000 / accel.abs()).clamp(100.0, 5000.0).toInt());
    if (accel == 0)
      _animController.stop();
    else
      _animController.repeat();

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
                    'F = ${_force.toStringAsFixed(0)}N', Colors.redAccent),
                const SizedBox(width: 8),
                _buildValueTag(
                    'm = ${_mass.toStringAsFixed(0)}kg', Colors.blueAccent),
                const SizedBox(width: 8),
                _buildValueTag(
                    'a = ${accel.toStringAsFixed(2)}m/s²', Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 4),
            Text("F = ma",
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
            Expanded(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => CustomPaint(
                  painter: _NewtonPainter(
                      force: _force,
                      mass: _mass,
                      accel: accel,
                      progress: _animController.value),
                  size: Size.infinite,
                ),
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
                fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      );

  Widget _buildControls(double width) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final accel = (_data?['acceleration'] as num?)?.toDouble() ?? 0.0;

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
                Text("Newton's 2nd Law",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text('F = ma (Force = Mass × Acceleration)',
                    style:
                        GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 16),
                ParameterSlider(
                    label: 'Applied Force (N)',
                    value: _force,
                    min: -100,
                    max: 100,
                    onChanged: (v) {
                      setState(() => _force = v);
                      _calculate();
                    }),
                ParameterSlider(
                    label: 'Mass (kg)',
                    value: _mass,
                    min: 1,
                    max: 50,
                    onChanged: (v) {
                      setState(() => _mass = v);
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
                      _stat('Force (F)', '${_force.toStringAsFixed(1)} N',
                          Colors.redAccent),
                      _stat('Mass (m)', '${_mass.toStringAsFixed(1)} kg',
                          Colors.blueAccent),
                      _stat(
                          'Acceleration (a)',
                          '${accel.toStringAsFixed(2)} m/s²',
                          Colors.greenAccent),
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
                          Text('How it works',
                              style: GoogleFonts.inter(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _force > 0
                            ? 'Push the box from behind → Box accelerates forward. More force = More acceleration.'
                            : _force < 0
                                ? 'Push the box from front → Box accelerates backward. Negative force = Reverse direction.'
                                : 'No force applied → Box stays still or moves at constant speed.',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 11, height: 1.4),
                      ),
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
}

class _NewtonPainter extends CustomPainter {
  final double force;
  final double mass;
  final double accel;
  final double progress;

  _NewtonPainter(
      {required this.force,
      required this.mass,
      required this.accel,
      required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 1.8);
    final scale = size.width / 500;

    // Ground/Road
    canvas.drawLine(
        Offset(0, center.dy + 40 * scale),
        Offset(size.width, center.dy + 40 * scale),
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 4);

    // Direction markers
    for (int i = 0; i < 5; i++) {
      double x = 50 + i * 80;
      _drawDirectionMarker(
          canvas, Offset(x, center.dy + 50 * scale), Colors.white12);
    }

    // Box position
    double direction = accel >= 0 ? 1 : -1;
    double startX = direction > 0 ? -50 : size.width + 50;
    double distance = size.width + 100;
    double currentX = startX + (distance * progress * direction);
    if (accel == 0) currentX = center.dx;

    // Box
    double boxSize = 35 + (mass / 2);
    final rect = Rect.fromLTRB(
        currentX - boxSize / 2,
        center.dy + 40 * scale - boxSize,
        currentX + boxSize / 2,
        center.dy + 40 * scale);
    canvas.drawRect(rect, Paint()..color = Colors.blueAccent);
    canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);

    // Mass label
    _drawLabel(canvas, 'm=${mass.toStringAsFixed(0)}kg',
        Offset(currentX, rect.top - 15), Colors.blueAccent);

    // Force arrow
    if (force != 0) {
      double arrowLen = (50 + (force.abs() / 2)).clamp(30, 100) * scale;
      final p1 = Offset(currentX + (force > 0 ? boxSize / 2 : -boxSize / 2),
          center.dy + 40 * scale - boxSize / 2);
      final p2 = Offset(p1.dx + (force > 0 ? arrowLen : -arrowLen), p1.dy);

      final paint = Paint()
        ..color = Colors.redAccent
        ..strokeWidth = 4;
      canvas.drawLine(p1, p2, paint);
      _drawArrowHead(canvas, p2, Colors.redAccent, force > 0 ? 0 : math.pi);
      _drawLabel(canvas, 'F=${force.toStringAsFixed(0)}N',
          Offset((p1.dx + p2.dx) / 2, p1.dy - 20), Colors.redAccent);
    }

    // Acceleration arrow
    if (accel != 0) {
      double arrowLen = (30 + (accel.abs() * 10)).clamp(30, 80) * scale;
      final p1 = Offset(currentX, rect.bottom + 5);
      final p2 = Offset(p1.dx + (accel >= 0 ? arrowLen : -arrowLen), p1.dy);

      final paint = Paint()
        ..color = Colors.greenAccent
        ..strokeWidth = 3;
      canvas.drawLine(p1, p2, paint);
      _drawArrowHead(canvas, p2, Colors.greenAccent, accel >= 0 ? 0 : math.pi);
      _drawLabel(canvas, 'a=${accel.toStringAsFixed(1)}m/s²',
          Offset((p1.dx + p2.dx) / 2, p1.dy + 12), Colors.greenAccent);
    }

    // Velocity arrow (along the road)
    if (accel != 0) {
      double vLen = (20 + progress * 40) * scale;
      final p1 = Offset(currentX, center.dy + 40 * scale + 20 * scale);
      final p2 = Offset(p1.dx + (accel >= 0 ? vLen : -vLen), p1.dy);

      final paint = Paint()
        ..color = Colors.yellowAccent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(p1, p2, paint..strokeWidth = 3);
      _drawArrowHead(canvas, p2, Colors.yellowAccent, accel >= 0 ? 0 : math.pi);
      _drawLabel(canvas, 'v', Offset((p1.dx + p2.dx) / 2, p1.dy + 12),
          Colors.yellowAccent);
    }
  }

  void _drawDirectionMarker(Canvas canvas, Offset pos, Color color) {
    canvas.drawLine(
        pos,
        Offset(pos.dx - 10, pos.dy + 15),
        Paint()
          ..color = color
          ..strokeWidth = 2);
    canvas.drawLine(
        Offset(pos.dx - 10, pos.dy + 15),
        Offset(pos.dx + 10, pos.dy + 15),
        Paint()
          ..color = color
          ..strokeWidth = 2);
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Color color, double angle) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;
    canvas.drawLine(
        tip,
        Offset(tip.dx - 10 * math.cos(angle - 0.4),
            tip.dy - 10 * math.sin(angle - 0.4)),
        paint);
    canvas.drawLine(
        tip,
        Offset(tip.dx - 10 * math.cos(angle + 0.4),
            tip.dy - 10 * math.sin(angle + 0.4)),
        paint);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color) {
    final textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: GoogleFonts.inter(
                color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr)
      ..layout();
    textPainter.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _NewtonPainter oldDelegate) => true;
}
