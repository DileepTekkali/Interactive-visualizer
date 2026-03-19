// FIXED: Fullscreen responsive layout with improved visualization

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/chemistry_service_local.dart';

class EquilibriumScreen extends StatefulWidget {
  const EquilibriumScreen({super.key});

  @override
  State<EquilibriumScreen> createState() => _EquilibriumScreenState();
}

class _EquilibriumScreenState extends State<EquilibriumScreen>
    with SingleTickerProviderStateMixin {
  double _tempChange = 0;
  Map<String, dynamic> _result = {};
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1), value: 0.5);
    _calculate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _calculate() {
    final data = LocalChemistryService.equilibriumSimulator(_tempChange);
    setState(() => _result = data);

    if (data['success'] == true) {
      if (data['shift'] == 'Right (Products)') {
        _animController.animateTo(0.8, curve: Curves.easeInOut);
      } else if (data['shift'] == 'Left (Reactants)') {
        _animController.animateTo(0.2, curve: Curves.easeInOut);
      } else {
        _animController.animateTo(0.5, curve: Curves.easeInOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 360.0 : screenWidth * 0.9;

    return MainLayout(
      title: 'Le Chatelier Principle',
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls(controlWidth)])
          : SingleChildScrollView(
              child: Column(
                  children: [_buildVisual(), _buildControls(controlWidth)])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 900;
    final shift = _result['shift'] ?? 'No Change';
    final stimulus = _result['stimulus'] ?? '';

    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: AppTheme.glassCard,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Le Chatelier Principle Demo',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent)),
              child: Text('A + B ⇌ C + D + Heat',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 14, color: Colors.blueAccent)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => CustomPaint(
                  painter: _EquilibriumPainter(
                      shift: shift,
                      progress: _animController.value,
                      tempChange: _tempChange),
                  size: Size.infinite,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildStatusBadge(shift),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(height: 350, child: content);
  }

  Widget _buildStatusBadge(String shift) {
    Color color;
    String label;
    IconData icon;

    if (shift.contains('Right')) {
      color = Colors.greenAccent;
      label = 'Shifts RIGHT - More Products';
      icon = Icons.arrow_forward;
    } else if (shift.contains('Left')) {
      color = Colors.redAccent;
      label = 'Shifts LEFT - More Reactants';
      icon = Icons.arrow_back;
    } else {
      color = Colors.grey;
      label = 'No Change - Equilibrium';
      icon = Icons.balance;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

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
                Text('Adjust Temperature',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 16),
                ParameterSlider(
                  label: 'Temperature Change (°C)',
                  value: _tempChange,
                  min: -100,
                  max: 100,
                  onChanged: (v) {
                    setState(() => _tempChange = v);
                    _calculate();
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: _tempChange < 0
                          ? Colors.blueAccent.withValues(alpha: 0.2)
                          : Colors.redAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _tempChange < 0
                              ? Colors.blueAccent
                              : Colors.redAccent)),
                  child: Column(
                    children: [
                      Icon(
                          _tempChange < 0
                              ? Icons.ac_unit
                              : Icons.local_fire_department,
                          color: _tempChange < 0
                              ? Colors.blueAccent
                              : Colors.redAccent,
                          size: 32),
                      const SizedBox(height: 8),
                      Text(
                          _tempChange < 0
                              ? 'COOLING'
                              : (_tempChange > 0 ? 'HEATING' : 'NO CHANGE'),
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(
                          '${_tempChange > 0 ? '+' : ''}${_tempChange.toStringAsFixed(0)}°C',
                          style: GoogleFonts.jetBrainsMono(
                              color: _tempChange < 0
                                  ? Colors.blueAccent
                                  : Colors.redAccent,
                              fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb,
                              color: Colors.yellowAccent, size: 18),
                          const SizedBox(width: 8),
                          Text("Le Chatelier's Principle",
                              style: GoogleFonts.inter(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _tempChange < 0
                            ? 'Lower temperature favors the exothermic reaction (forward). System produces more heat by forming more products.'
                            : _tempChange > 0
                                ? 'Higher temperature favors the endothermic reaction (reverse). System absorbs heat by forming more reactants.'
                                : 'No temperature change means equilibrium is maintained.',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildExplanationCard(
                    'Exothermic Reaction',
                    'A + B → C + D + Heat\nReleases energy to surroundings',
                    Colors.greenAccent),
                _buildExplanationCard(
                    'Endothermic Reaction',
                    'A + B + Heat ← C + D\nAbsorbs energy from surroundings',
                    Colors.orangeAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(String title, String content, Color color) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(content,
                style: GoogleFonts.inter(
                    color: Colors.white70, fontSize: 10, height: 1.3)),
          ],
        ),
      );
}

class _EquilibriumPainter extends CustomPainter {
  final String shift;
  final double progress;
  final double tempChange;

  _EquilibriumPainter(
      {required this.shift, required this.progress, required this.tempChange});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 400;

    // Background containers
    final leftRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx - 80 * scale, center.dy),
            width: 120 * scale,
            height: 80 * scale),
        const Radius.circular(8));
    final rightRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx + 80 * scale, center.dy),
            width: 120 * scale,
            height: 80 * scale),
        const Radius.circular(8));

    canvas.drawRRect(
        leftRect, Paint()..color = Colors.redAccent.withValues(alpha: 0.2));
    canvas.drawRRect(
        leftRect,
        Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawRRect(
        rightRect, Paint()..color = Colors.greenAccent.withValues(alpha: 0.2));
    canvas.drawRRect(
        rightRect,
        Paint()
          ..color = Colors.greenAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Labels
    _drawText(
        canvas,
        'REACTANTS',
        Offset(center.dx - 80 * scale, center.dy - 50 * scale),
        Colors.redAccent,
        10 * scale);
    _drawText(
        canvas,
        'A + B',
        Offset(center.dx - 80 * scale, center.dy - 35 * scale),
        Colors.white,
        12 * scale);
    _drawText(
        canvas,
        'PRODUCTS',
        Offset(center.dx + 80 * scale, center.dy - 50 * scale),
        Colors.greenAccent,
        10 * scale);
    _drawText(
        canvas,
        'C + D',
        Offset(center.dx + 80 * scale, center.dy - 35 * scale),
        Colors.white,
        12 * scale);

    // Double arrow in center
    final arrowPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 3;
    canvas.drawLine(Offset(center.dx - 30 * scale, center.dy),
        Offset(center.dx + 30 * scale, center.dy), arrowPaint);
    canvas.drawLine(Offset(center.dx - 30 * scale, center.dy - 10 * scale),
        Offset(center.dx - 30 * scale, center.dy + 10 * scale), arrowPaint);
    canvas.drawLine(Offset(center.dx + 30 * scale, center.dy - 10 * scale),
        Offset(center.dx + 30 * scale, center.dy + 10 * scale), arrowPaint);

    // Heat symbol
    _drawText(canvas, '+ Heat', Offset(center.dx, center.dy + 55 * scale),
        tempChange < 0 ? Colors.blueAccent : Colors.redAccent, 10 * scale);

    // Animated particles
    final leftCount =
        shift.contains('Left') ? 8 : (shift.contains('Right') ? 4 : 6);
    final rightCount =
        shift.contains('Right') ? 8 : (shift.contains('Left') ? 4 : 6);

    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < leftCount; i++) {
      final angle = (i / leftCount) * 2 * 3.14159 + progress * 2 * 3.14159;
      final dist = 20 * scale + (i % 3) * 8 * scale;
      particlePaint.color = Colors.redAccent.withValues(alpha: 0.8);
      canvas.drawCircle(
          Offset(center.dx - 80 * scale + dist * math.cos(angle),
              center.dy + dist * math.sin(angle) * 0.5),
          6 * scale,
          particlePaint);
    }
    for (int i = 0; i < rightCount; i++) {
      final angle = (i / rightCount) * 2 * 3.14159 + progress * 2 * 3.14159;
      final dist = 20 * scale + (i % 3) * 8 * scale;
      particlePaint.color = Colors.greenAccent.withValues(alpha: 0.8);
      canvas.drawCircle(
          Offset(center.dx + 80 * scale + dist * math.cos(angle + 3.14159),
              center.dy + dist * math.sin(angle + 3.14159) * 0.5),
          6 * scale,
          particlePaint);
    }

    // Arrow indicators
    if (shift.contains('Left')) {
      _drawArrow(canvas, Offset(center.dx - 50 * scale, center.dy - 60 * scale),
          Offset(center.dx - 80 * scale, center.dy), Colors.redAccent);
    } else if (shift.contains('Right')) {
      _drawArrow(canvas, Offset(center.dx + 50 * scale, center.dy - 60 * scale),
          Offset(center.dx + 80 * scale, center.dy), Colors.greenAccent);
    }
  }

  void _drawText(
      Canvas canvas, String text, Offset pos, Color color, double fontSize) {
    final textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: GoogleFonts.inter(
                color: color, fontSize: fontSize, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr)
      ..layout();
    textPainter.paint(
        canvas,
        Offset(
            pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2));
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;
    canvas.drawLine(from, to, paint);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    canvas.drawLine(
        to,
        Offset(to.dx - 10 * math.cos(angle - 0.3),
            to.dy - 10 * math.sin(angle - 0.3)),
        paint);
    canvas.drawLine(
        to,
        Offset(to.dx - 10 * math.cos(angle + 0.3),
            to.dy - 10 * math.sin(angle + 0.3)),
        paint);
  }

  @override
  bool shouldRepaint(covariant _EquilibriumPainter oldDelegate) => true;
}
