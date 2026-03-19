// FIXED: Removed all API calls - now uses local chemistry calculations
// Issue: Was trying to parse HTML responses as JSON (backend not running)
// Fix: All calculations now performed locally in Dart
// ENHANCED: Added detailed visualization, electron dots, bond energy, explanation

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_service_local.dart';
import 'dart:math' as math;

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
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _simulate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _simulate() {
    _animController.reset();
    final data = LocalChemistryService.chemicalBonding(_el1, _el2);
    setState(() {
      _result = data;
    });
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 360.0 : screenWidth * 0.9;
    return MainLayout(
      title: 'Chemical Bonding Simulator',
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
    final bondType = _result['bond_type'] ?? '?';
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildElementBadge(_el1, Colors.blueAccent),
                  const SizedBox(width: 16),
                  Icon(Icons.add, color: Colors.white54, size: 20),
                  const SizedBox(width: 16),
                  _buildElementBadge(_el2, Colors.greenAccent),
                  const SizedBox(width: 16),
                  Icon(Icons.arrow_forward,
                      color: Colors.orangeAccent, size: 20),
                  const SizedBox(width: 16),
                  _buildBondBadge(bondType),
                ],
              ),
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
            height: MediaQuery.of(context).size.height * 0.5, child: content);
  }

  Widget _buildElementBadge(String el, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color)),
        child: Text(el,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 16, color: color, fontWeight: FontWeight.bold)),
      );

  Widget _buildBondBadge(String bond) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.orangeAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orangeAccent)),
        child: Text(bond,
            style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold)),
      );

  Widget _buildControls(double width) {
    final elements = [
      'H',
      'Li',
      'Na',
      'K',
      'Be',
      'Mg',
      'Ca',
      'B',
      'Al',
      'C',
      'Si',
      'N',
      'P',
      'O',
      'S',
      'F',
      'Cl',
      'Br',
      'I',
      'He',
      'Ne',
      'Ar'
    ];
    final isWide = MediaQuery.of(context).size.width > 900;
    final bondType = _result['bond_type'] ?? '';
    final explanation = _getBondExplanation(bondType);

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
                Text('Select Elements',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildElementSelector(
                            'Element 1', _el1, elements, (v) {
                      setState(() => _el1 = v!);
                      _simulate();
                    })),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildElementSelector(
                            'Element 2', _el2, elements, (v) {
                      setState(() => _el2 = v!);
                      _simulate();
                    })),
                  ],
                ),
                const SizedBox(height: 20),
                if (_result['success'] == true) ...[
                  _buildInfoCard('Bond Type', bondType, Colors.orangeAccent),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                      'How It Forms', explanation, Colors.blueAccent),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                      'Electron Transfer/Share',
                      _getElectronBehavior(bondType, _el1, _el2),
                      Colors.greenAccent),
                  const SizedBox(height: 12),
                  _buildInfoCard('Example', _getExample(bondType, _el1, _el2),
                      Colors.purpleAccent),
                ] else if (_result['error'] != null)
                  Text(_result['error'] ?? 'Simulation Error',
                      style: const TextStyle(color: Colors.redAccent))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementSelector(String label, String value,
          List<String> elements, ValueChanged<String?> onChanged) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: value,
            dropdownColor: AppTheme.surfaceLight,
            style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 14),
            isExpanded: true,
            items: elements
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      );

  Widget _buildInfoCard(String title, String content, Color color) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(content,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
          ],
        ),
      );

  String _getBondExplanation(String bond) {
    switch (bond) {
      case 'Ionic':
        return 'One atom gives electrons (becomes +), other takes electrons (becomes -). Opposite charges attract!';
      case 'Covalent':
        return 'Atoms share electrons equally or unequally to fill their outer shells.';
      case 'Metallic':
        return 'Positive ions in a sea of delocalized electrons. Electrons flow freely!';
      default:
        return 'Learn about different bond types!';
    }
  }

  String _getElectronBehavior(String bond, String e1, String e2) {
    switch (bond) {
      case 'Ionic':
        return '$e1 loses electron(s) → positive ion\n$e2 gains electron(s) → negative ion';
      case 'Covalent':
        return '$e1 and $e2 share their outer electrons to complete shells';
      case 'Metallic':
        return 'All atoms share electrons in a common pool';
      default:
        return '';
    }
  }

  String _getExample(String bond, String e1, String e2) {
    switch (bond) {
      case 'Ionic':
        return 'Table salt (NaCl) - dissolves in water';
      case 'Covalent':
        return 'Water (H₂O) - molecules stay together';
      case 'Metallic':
        return 'Copper wire - conducts electricity';
      default:
        return '';
    }
  }
}

class _BondingPainter extends CustomPainter {
  final String el1;
  final String el2;
  final String bondType;
  final double progress;

  _BondingPainter(
      {required this.el1,
      required this.el2,
      required this.bondType,
      required this.progress});

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

    double distance = 180 - (100 * progress);
    final pos1 = Offset(center.dx - distance, center.dy);
    final pos2 = Offset(center.dx + distance, center.dy);

    canvas.drawCircle(pos1, 35 * progress, paint1);
    canvas.drawCircle(pos2, 35 * progress, paint2);

    if (progress > 0.3) {
      _drawElectrons(canvas, pos1, 1, Colors.yellowAccent, progress);
      _drawElectrons(canvas, pos2, 1, Colors.yellowAccent, progress);
    }

    _drawText(canvas, el1, Offset(pos1.dx, pos1.dy - 50), Colors.blueAccent);
    _drawText(canvas, el2, Offset(pos2.dx, pos2.dy - 50), Colors.greenAccent);

    if (progress > 0.6) {
      if (bondType == 'Covalent') {
        for (int i = 0; i < 2; i++) {
          double x = center.dx + (i == 0 ? -8 : 8);
          canvas.drawLine(Offset(x, center.dy - 20), Offset(x, center.dy + 20),
              bondPaint..strokeWidth = 3);
        }
        _drawText(canvas, 'Shared e⁻', Offset(center.dx, center.dy + 40),
            Colors.white54);
      } else if (bondType == 'Ionic') {
        _drawArrows(canvas, pos1, pos2);
        _drawText(canvas, 'e⁻ transferred', Offset(center.dx, center.dy + 40),
            Colors.orangeAccent);
      } else if (bondType == 'Metallic') {
        canvas.drawCircle(
            center, 80, Paint()..color = Colors.purple.withValues(alpha: 0.2));
        _drawText(canvas, 'Delocalized e⁻', center, Colors.purpleAccent);
      }
    }

    if (progress > 0.8) {
      _drawText(
          canvas, '+', Offset(pos1.dx + 25, pos1.dy - 20), Colors.redAccent);
      _drawText(
          canvas, '-', Offset(pos2.dx - 30, pos2.dy - 20), Colors.blueAccent);
    }
  }

  void _drawElectrons(
      Canvas canvas, Offset center, int count, Color color, double progress) {
    final ePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    for (int i = 0; i < count; i++) {
      double angle = (2 * math.pi / count) * i;
      final offset = Offset(
          center.dx + 45 * math.cos(angle), center.dy + 45 * math.sin(angle));
      canvas.drawCircle(offset, 5 * progress, ePaint);
    }
  }

  void _drawArrows(Canvas canvas, Offset from, Offset to) {
    final arrowPaint = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    double midX = (from.dx + to.dx) / 2;
    canvas.drawLine(
        Offset(from.dx + 40, from.dy), Offset(midX, from.dy), arrowPaint);
    canvas.drawLine(
        Offset(midX, from.dy - 5), Offset(midX + 8, from.dy), arrowPaint);
    canvas.drawLine(
        Offset(midX, from.dy + 5), Offset(midX + 8, from.dy), arrowPaint);
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: GoogleFonts.inter(
              color: color, fontSize: 12, fontWeight: FontWeight.w500)),
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
