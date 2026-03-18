import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/chemistry_api_service.dart';

class AtomBuilderScreen extends StatefulWidget {
  const AtomBuilderScreen({super.key});

  @override
  State<AtomBuilderScreen> createState() => _AtomBuilderScreenState();
}

class _AtomBuilderScreenState extends State<AtomBuilderScreen> with SingleTickerProviderStateMixin {
  int _protons = 1;
  int _neutrons = 0;
  int _electrons = 1;

  Map<String, dynamic>? _atomData;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _fetchAtom();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchAtom() async {
    final data = await ChemistryApiService.atomBuilder(_protons, _neutrons, _electrons);
    if (mounted) setState(() => _atomData = data);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Atom Builder Simulator',
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls()])
          : SingleChildScrollView(child: Column(children: [_buildVisual(), _buildControls()])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            if (_atomData != null && _atomData?['success'] == true)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("\${_atomData?['element'] ?? ''} (\${_atomData?['symbol'] ?? ''})",
                    style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ),
            Expanded(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => CustomPaint(
                  painter: _AtomPainter(
                      protons: _protons,
                      neutrons: _neutrons,
                      electrons: _electrons,
                      animValue: _animController.value),
                  size: Size.infinite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: math.max(400.0, MediaQuery.of(context).size.height * 0.45), child: content);
  }

  Widget _buildControls() {
    final isWide = MediaQuery.of(context).size.width > 800;
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
              Text('Subatomic Particles', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              ParameterSlider(
                label: 'Protons (+)',
                value: _protons.toDouble(),
                min: 1,
                max: 20,
                onChanged: (v) {
                  setState(() => _protons = v.toInt());
                  _fetchAtom();
                },
              ),
              ParameterSlider(
                label: 'Neutrons (0)',
                value: _neutrons.toDouble(),
                min: 0,
                max: 25,
                onChanged: (v) {
                  setState(() => _neutrons = v.toInt());
                  _fetchAtom();
                },
              ),
              ParameterSlider(
                label: 'Electrons (-)',
                value: _electrons.toDouble(),
                min: 0,
                max: 20,
                onChanged: (v) {
                  setState(() => _electrons = v.toInt());
                  _fetchAtom();
                },
              ),
              const SizedBox(height: 32),
              if (_atomData != null && _atomData?['success'] == true) ...[
                _statRow('Net Charge', ((_atomData?['charge'] as num?) ?? 0) > 0 ? "+\${_atomData?['charge']}" : "\${_atomData?['charge']}", ((_atomData?['charge'] as num?) ?? 0) == 0 ? Colors.green : Colors.redAccent),
                _statRow('Mass Number', "\${_atomData?['mass'] ?? 0}", Colors.orangeAccent),
                _statRow('Stability', _atomData?['is_stable'] == true ? 'Stable' : 'Isotope/Unstable', _atomData?['is_stable'] == true ? Colors.green : Colors.yellow),
              ] else if (_atomData != null)
                Text(_atomData?['error'] ?? 'Simulation Error', style: const TextStyle(color: Colors.redAccent))
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white70)),
          Text(value, style: GoogleFonts.jetBrainsMono(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _AtomPainter extends CustomPainter {
  final int protons;
  final int neutrons;
  final int electrons;
  final double animValue;

  _AtomPainter({required this.protons, required this.neutrons, required this.electrons, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shellPaint = Paint()..style = PaintingStyle.stroke..color = Colors.white24..strokeWidth = 1;
    final pPaint = Paint()..style = PaintingStyle.fill..color = Colors.redAccent;
    final nPaint = Paint()..style = PaintingStyle.fill..color = Colors.grey;
    final ePaint = Paint()..style = PaintingStyle.fill..color = Colors.blueAccent;

    // Nucleus
    final random = math.Random(123);
    for (int i = 0; i < protons + neutrons; i++) {
      final isProton = i < protons;
      final angle = random.nextDouble() * 2 * math.pi;
      final rad = random.nextDouble() * 15;
      final offset = Offset(center.dx + rad * math.cos(angle), center.dy + rad * math.sin(angle));
      canvas.drawCircle(offset, 4, isProton ? pPaint : nPaint);
    }

    // Shells
    final shells = [2, 8, 8, 2];
    int remainingE = electrons;
    int shellIndex = 0;

    while (remainingE > 0 && shellIndex < shells.length) {
      int count = remainingE > shells[shellIndex] ? shells[shellIndex] : remainingE;
      double radius = 50.0 + shellIndex * 40.0;
      canvas.drawCircle(center, radius, shellPaint);

      for (int i = 0; i < count; i++) {
        double baseAngle = (2 * math.pi / count) * i;
        double currentAngle = baseAngle + (animValue * 2 * math.pi * (shellIndex % 2 == 0 ? 1 : -1));
        final offset = Offset(center.dx + radius * math.cos(currentAngle), center.dy + radius * math.sin(currentAngle));
        canvas.drawCircle(offset, 5, ePaint);
      }
      remainingE -= count;
      shellIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant _AtomPainter oldDelegate) => true;
}
