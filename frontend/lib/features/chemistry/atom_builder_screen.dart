// ENHANCED: Added periodic table element selector, more particle visualization
// IMPROVED: Better responsiveness, more educational content

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/chemistry_service_local.dart';

class AtomBuilderScreen extends StatefulWidget {
  const AtomBuilderScreen({super.key});

  @override
  State<AtomBuilderScreen> createState() => _AtomBuilderScreenState();
}

class _AtomBuilderScreenState extends State<AtomBuilderScreen>
    with SingleTickerProviderStateMixin {
  int _protons = 1;
  int _neutrons = 0;
  int _electrons = 1;
  Map<String, dynamic> _atomData = {};
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    _fetchAtom();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _fetchAtom() {
    final data =
        LocalChemistryService.atomBuilder(_protons, _neutrons, _electrons);
    setState(() => _atomData = data);
  }

  void _selectElement(String symbol) {
    final data = LocalChemistryService.getAtomData(symbol);
    if (data['success'] == true) {
      setState(() {
        _protons = data['atomic_number'] as int;
        _electrons = data['atomic_number'] as int;
        _neutrons = (data['atomic_number'] as int) - 1;
      });
      _fetchAtom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 360.0 : screenWidth * 0.9;
    return MainLayout(
      title: 'Atom Builder Simulator',
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
    final element = _atomData['element'] ?? 'Unknown';
    final symbol = _atomData['symbol'] ?? '?';

    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            if (_atomData['success'] == true)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatBadge('p: $_protons', Colors.redAccent),
                    const SizedBox(width: 8),
                    _buildStatBadge('n: $_neutrons', Colors.grey),
                    const SizedBox(width: 8),
                    _buildStatBadge('e: $_electrons', Colors.blueAccent),
                    const SizedBox(width: 16),
                    Text('$element ($symbol)',
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent)),
                  ],
                ),
              ),
            Expanded(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => CustomPaint(
                  painter: _AtomPainter(
                    protons: _protons,
                    neutrons: _neutrons,
                    electrons: _electrons,
                    animValue: _animController.value,
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

  Widget _buildStatBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color)),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      );

  Widget _buildControls(double width) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final charge = (_atomData['charge'] as num?)?.toInt() ?? 0;
    final mass = (_atomData['mass'] as num?)?.toInt() ?? 0;
    final isStable = _atomData['is_stable'] == true;

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
                Text('Quick Select Element',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 8),
                _buildPeriodicTableGrid(),
                const SizedBox(height: 16),
                Text('Or Adjust Particles Manually',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 12),
                ParameterSlider(
                    label: 'Protons (+) - Atomic Number',
                    value: _protons.toDouble(),
                    min: 1,
                    max: 20,
                    onChanged: (v) {
                      setState(() => _protons = v.toInt());
                      _fetchAtom();
                    }),
                ParameterSlider(
                    label: 'Neutrons (0) - Mass Variation',
                    value: _neutrons.toDouble(),
                    min: 0,
                    max: 25,
                    onChanged: (v) {
                      setState(() => _neutrons = v.toInt());
                      _fetchAtom();
                    }),
                ParameterSlider(
                    label: 'Electrons (-)',
                    value: _electrons.toDouble(),
                    min: 0,
                    max: 20,
                    onChanged: (v) {
                      setState(() => _electrons = v.toInt());
                      _fetchAtom();
                    }),
                const SizedBox(height: 16),
                if (_atomData['success'] == true) ...[
                  _buildInfoRow(
                      'Net Charge',
                      charge > 0 ? '+$charge' : '$charge',
                      charge == 0 ? Colors.green : Colors.redAccent),
                  _buildInfoRow('Mass Number', '$mass', Colors.orangeAccent),
                  _buildInfoRow(
                      'Stability',
                      isStable ? 'Stable Isotope' : 'Unstable/Isotope',
                      isStable ? Colors.green : Colors.yellow),
                  _buildInfoRow(
                      'Ion Type',
                      charge > 0
                          ? 'Cation (+)'
                          : (charge < 0 ? 'Anion (-)' : 'Neutral'),
                      Colors.purpleAccent),
                ] else if (_atomData['error'] != null)
                  Text(_atomData['error'] ?? 'Simulation Error',
                      style: const TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodicTableGrid() {
    final elements = [
      ['H', 'He'],
      ['Li', 'Be', 'B', 'C', 'N', 'O', 'F', 'Ne'],
      ['Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'Ar'],
      ['K', 'Ca'],
    ];
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: elements
          .expand((row) => row)
          .map((el) => _buildElementButton(el))
          .toList(),
    );
  }

  Widget _buildElementButton(String el) {
    final data = LocalChemistryService.getAtomData(el);
    final isSelected = _atomData['symbol'] == el;
    final color = data['valency'] == 0
        ? Colors.grey
        : (data['valency'] as int) <= 2
            ? Colors.blueAccent
            : Colors.greenAccent;
    return GestureDetector(
      onTap: () => _selectElement(el),
      child: Container(
        width: 32,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: isSelected ? Colors.white : color.withValues(alpha: 0.5)),
        ),
        child: Center(
            child: Text(el,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
            Text(value,
                style: GoogleFonts.jetBrainsMono(
                    color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      );
}

class _AtomPainter extends CustomPainter {
  final int protons;
  final int neutrons;
  final int electrons;
  final double animValue;

  _AtomPainter(
      {required this.protons,
      required this.neutrons,
      required this.electrons,
      required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shellPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white24
      ..strokeWidth = 1.5;
    final pPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.redAccent;
    final nPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey.shade600;
    final ePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueAccent;

    final nucleusRadius = (protons + neutrons) * 1.5;
    final random = math.Random(123);
    for (int i = 0; i < protons + neutrons; i++) {
      final isProton = i < protons;
      final angle = random.nextDouble() * 2 * math.pi;
      final rad = random.nextDouble() * nucleusRadius;
      final offset = Offset(
          center.dx + rad * math.cos(angle), center.dy + rad * math.sin(angle));
      canvas.drawCircle(offset, 6, isProton ? pPaint : nPaint);
    }

    final shells = [2, 8, 18, 32, 50];
    int remainingE = electrons;
    int shellIndex = 0;

    while (remainingE > 0 && shellIndex < shells.length) {
      int count =
          remainingE > shells[shellIndex] ? shells[shellIndex] : remainingE;
      double radius = 50.0 + shellIndex * 35.0;
      canvas.drawCircle(center, radius, shellPaint);

      for (int i = 0; i < count; i++) {
        double baseAngle = (2 * math.pi / count) * i;
        double currentAngle = baseAngle +
            (animValue * 2 * math.pi * (shellIndex % 2 == 0 ? 1 : -1));
        final offset = Offset(center.dx + radius * math.cos(currentAngle),
            center.dy + radius * math.sin(currentAngle));
        canvas.drawCircle(offset, 6, ePaint);
        canvas.drawCircle(offset, 3, Paint()..color = Colors.white);
      }
      remainingE -= count;
      shellIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant _AtomPainter oldDelegate) => true;
}
