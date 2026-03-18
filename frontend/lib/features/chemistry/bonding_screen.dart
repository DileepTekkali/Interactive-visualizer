import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_api_service.dart';

class BondingSimulatorScreen extends StatefulWidget {
  const BondingSimulatorScreen({super.key});

  @override
  State<BondingSimulatorScreen> createState() => _BondingSimulatorScreenState();
}

class _BondingSimulatorScreenState extends State<BondingSimulatorScreen> with SingleTickerProviderStateMixin {
  String _el1 = 'Na';
  String _el2 = 'Cl';
  Map<String, dynamic>? _result;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _simulate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _simulate() async {
    _animController.reset();
    final data = await ChemistryApiService.chemicalBonding(_el1, _el2);
    setState(() => _result = data);
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Chemical Bonding Simulator',
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("\$_el1 + \$_el2 → \${_result?['success'] == true ? (_result?['bond_type'] ?? '?') : '?'}",
                  style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => CustomPaint(
                  painter: _BondingPainter(
                    el1: _el1,
                    el2: _el2,
                    bondType: _result?['bond_type'] ?? '',
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
    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: MediaQuery.of(context).size.height * 0.45, child: content);
  }

  Widget _buildControls() {
    final elements = ['Na', 'Mg', 'Ca', 'C', 'N', 'O', 'Cl', 'F', 'H'];
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
              Text('Reactants', style: GoogleFonts.inter(fontSize: 16, color: Colors.white)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _el1,
                dropdownColor: AppTheme.surfaceLight,
                style: const TextStyle(color: Colors.white),
                items: elements.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) { setState(() => _el1 = v!); _simulate(); },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _el2,
                dropdownColor: AppTheme.surfaceLight,
                style: const TextStyle(color: Colors.white),
                items: elements.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) { setState(() => _el2 = v!); _simulate(); },
              ),
              const SizedBox(height: 32),
              if (_result != null && _result?['success'] == true) ...[
                Text('Bond Formed:', style: GoogleFonts.inter(color: Colors.white54)),
                Text(_result?['bond_type'] ?? 'Unknown', style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                const SizedBox(height: 8),
                Text(
                  _result?['bond_type'] == 'Ionic' ? 'Transfer of electrons.' :
                  _result?['bond_type'] == 'Covalent' ? 'Sharing of electrons.' : 'Sea of delocalized electrons.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                )
              ] else if (_result != null)
                Text(_result?['error'] ?? 'Simulation Error', style: const TextStyle(color: Colors.redAccent))
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

  _BondingPainter({required this.el1, required this.el2, required this.bondType, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (bondType.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint1 = Paint()..style = PaintingStyle.fill..color = Colors.blueAccent;
    final paint2 = Paint()..style = PaintingStyle.fill..color = Colors.greenAccent;
    final bondPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = Colors.white54;

    // Start far apart, move closer based on progress
    double distance = 150 - (70 * progress);
    
    final pos1 = Offset(center.dx - distance, center.dy);
    final pos2 = Offset(center.dx + distance, center.dy);

    canvas.drawCircle(pos1, 30, paint1);
    canvas.drawCircle(pos2, 30, paint2);

    final textPainter1 = TextPainter(
      text: TextSpan(text: el1, style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter1.paint(canvas, Offset(pos1.dx - textPainter1.width/2, pos1.dy - textPainter1.height/2));

    final textPainter2 = TextPainter(
      text: TextSpan(text: el2, style: GoogleFonts.jetBrainsMono(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter2.paint(canvas, Offset(pos2.dx - textPainter2.width/2, pos2.dy - textPainter2.height/2));

    if (progress > 0.8) {
      if (bondType == 'Covalent') {
        // Shared overlap look
        canvas.drawOval(Rect.fromCenter(center: center, width: 80, height: 40), Paint()..color = Colors.white30);
      } else if (bondType == 'Ionic') {
        // Arrow from 1 to 2
        canvas.drawLine(Offset(pos1.dx + 40, pos1.dy), Offset(pos2.dx - 40, pos2.dy), bondPaint);
      } else if (bondType == 'Metallic') {
        // Cloud
        canvas.drawCircle(center, 60, Paint()..color = Colors.blue.withOpacity(0.2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BondingPainter oldDelegate) => true;
}
