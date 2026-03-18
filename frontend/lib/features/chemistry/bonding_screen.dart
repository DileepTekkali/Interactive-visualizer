// FIXED: Removed all API calls - now uses local chemistry calculations
// Issue: Was trying to parse HTML responses as JSON (backend not running)
// Fix: All calculations now performed locally in Dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_service_local.dart';

class BondingSimulatorScreen extends StatefulWidget {
  const BondingSimulatorScreen({super.key});

  @override
  State<BondingSimulatorScreen> createState() => _BondingSimulatorScreenState();
}

class _BondingSimulatorScreenState extends State<BondingSimulatorScreen>
    with SingleTickerProviderStateMixin {
  String _el1 = 'Na';
  String _el2 = 'Cl';
  Map<String, dynamic> _result = {};
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _simulate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _simulate() {
    _animController.reset();
    // FIXED: Using local service instead of API call
    final data = LocalChemistryService.chemicalBonding(_el1, _el2);
    setState(() {
      _result = data;
    });
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Chemical Bonding Simulator',
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls()])
          : SingleChildScrollView(
              child: Column(children: [_buildVisual(), _buildControls()])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final bondType = _result['bond_type'] ?? '?';
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('$_el1 + $_el2 → $bondType',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent)),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => CustomPaint(
                  painter: _BondingPainter(
                    el1: _el1,
                    el2: _el2,
                    bondType: bondType,
                    progress: _animController.value,
                  ),
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
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.45, child: content);
  }

  Widget _buildControls() {
    final elements = ['Na', 'Mg', 'Ca', 'C', 'N', 'O', 'Cl', 'F', 'H'];
    final isWide = MediaQuery.of(context).size.width > 800;
    final bondType = _result['bond_type'] ?? '';

    return SizedBox(
      width: isWide ? 320 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reactants',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _el1,
                dropdownColor: AppTheme.surfaceLight,
                style: const TextStyle(color: Colors.white),
                items: elements
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _el1 = v);
                    _simulate();
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _el2,
                dropdownColor: AppTheme.surfaceLight,
                style: const TextStyle(color: Colors.white),
                items: elements
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _el2 = v);
                    _simulate();
                  }
                },
              ),
              const SizedBox(height: 32),
              if (_result['success'] == true) ...[
                Text('Bond Formed:',
                    style: GoogleFonts.inter(color: Colors.white54)),
                Text(bondType,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent)),
                const SizedBox(height: 8),
                Text(
                  bondType == 'Ionic'
                      ? 'Transfer of electrons.'
                      : bondType == 'Covalent'
                          ? 'Sharing of electrons.'
                          : 'Sea of delocalized electrons.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                )
              ] else if (_result['error'] != null)
                Text(_result['error'] ?? 'Simulation Error',
                    style: const TextStyle(color: Colors.redAccent))
            ],
          ),
        ),
      ),
    );
  }
}

class _BondingPainter extends CustomPainter {
  final String el1;
  final String el2;
  final String bondType;
  final double progress;

  _BondingPainter({
    required this.el1,
    required this.el2,
    required this.bondType,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint1 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueAccent;
    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.greenAccent;
    final bondPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.white54;

    // Start far apart, move closer based on progress
    double distance = 150 - (70 * progress);

    final pos1 = Offset(center.dx - distance, center.dy);
    final pos2 = Offset(center.dx + distance, center.dy);

    canvas.drawCircle(pos1, 30, paint1);
    canvas.drawCircle(pos2, 30, paint2);

    // Draw element labels
    _drawText(canvas, el1, pos1, Colors.white);
    _drawText(canvas, el2, pos2, Colors.black);

    if (progress > 0.8) {
      if (bondType == 'Covalent') {
        canvas.drawOval(Rect.fromCenter(center: center, width: 80, height: 40),
            Paint()..color = Colors.white30);
      } else if (bondType == 'Ionic') {
        canvas.drawLine(Offset(pos1.dx + 40, pos1.dy),
            Offset(pos2.dx - 40, pos2.dy), bondPaint);
      } else if (bondType == 'Metallic') {
        canvas.drawCircle(
            center, 60, Paint()..color = Colors.blue.withValues(alpha: 0.2));
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: GoogleFonts.jetBrainsMono(
              color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
        canvas,
        Offset(position.dx - textPainter.width / 2,
            position.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BondingPainter oldDelegate) => true;
}
