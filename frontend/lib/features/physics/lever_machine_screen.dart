import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'dart:math' as math;

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
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Lever Simple Machine',
      child: isWide ? Row(children: [_buildVisual(), _buildControls()]) : SingleChildScrollView(child: Column(children: [_buildVisual(), _buildControls()])),
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
              child: Text(
                "Mechanical Advantage: ${_data?['mechanical_advantage']?.toStringAsFixed(2) ?? '0.00'}", 
                style: GoogleFonts.jetBrainsMono(fontSize: 20, color: Colors.blueAccent)
              )
            ),
            Expanded(
              child: CustomPaint(
                painter: _LeverPainter(
                  effortArm: _effortArm, 
                  loadArm: _loadArm, 
                  loadMass: _loadMass, 
                  effortRequired: (_data?['effort_required'] as num?)?.toDouble() ?? 0.0
                ),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: 400, child: content);
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
              ParameterSlider(label: 'Effort Arm (m)', value: _effortArm, min: 1, max: 10, onChanged: (v){ setState(()=>_effortArm=v); _calculate(); }),
              ParameterSlider(label: 'Load Arm (m)', value: _loadArm, min: 1, max: 10, onChanged: (v){ setState(()=>_loadArm=v); _calculate(); }),
              ParameterSlider(label: 'Load Mass (kg)', value: _loadMass, min: 10, max: 200, onChanged: (v){ setState(()=>_loadMass=v); _calculate(); }),
              const Spacer(),
              if (_data != null) ...[
                if (_data?['success'] == true) ...[
                  _stat('Load Force (Weight)', "${(_data?['load_force'] as num?)?.toDouble() ?? 0.0} N"),
                  _stat('Effort Required', "${(_data?['effort_required'] as num?)?.toDouble() ?? 0.0} N"),
                  const SizedBox(height: 16),
                  Text('A mechanical advantage > 1 means less effort is needed to lift the load.', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12))
                ] else
                  Text(_data?['error'] ?? 'Simulation Error', style: const TextStyle(color: Colors.redAccent))
              ]
            ]
          )
        )
      )
    );
  }
  
  Widget _stat(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: GoogleFonts.inter(color: Colors.white)), Text(v, style: GoogleFonts.jetBrainsMono(color: Colors.orangeAccent))])
  );
}

class _LeverPainter extends CustomPainter {
  final double effortArm;
  final double loadArm;
  final double loadMass;
  final double? effortRequired;
  _LeverPainter({required this.effortArm, required this.loadArm, required this.loadMass, this.effortRequired});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 1.5);
    // Draw fulcrum
    final fulcrumPath = Path()..moveTo(center.dx, center.dy)..lineTo(center.dx - 20, center.dy + 40)..lineTo(center.dx + 20, center.dy + 40)..close();
    canvas.drawPath(fulcrumPath, Paint()..color=Colors.blueAccent);

    // Scaling
    double totalArm = effortArm + loadArm;
    double scale = (size.width - 100) / totalArm;
    
    // Beam
    final leftX = center.dx - (loadArm * scale);
    final rightX = center.dx + (effortArm * scale);

    // Let's calculate balance angle. For simplicity, we just draw it perfectly balanced horizontal.
    canvas.drawLine(Offset(leftX, center.dy), Offset(rightX, center.dy), Paint()..color=Colors.white..strokeWidth=8);

    // Draw Load
    double boxSize = 30 + (loadMass / 5);
    canvas.drawRect(Rect.fromLTRB(leftX - 20, center.dy - boxSize, leftX + 20, center.dy), Paint()..color=Colors.redAccent);

    // Draw Effort Arrow
    final er = effortRequired;
    if (er != null) {
      double arrowLen = 30 + (er / 10).toDouble();
      _drawArrow(canvas, Offset(rightX, center.dy - arrowLen - 10), Offset(rightX, center.dy), Colors.greenAccent);
    }
  }

  void _drawArrow(Canvas canvas, Offset p1, Offset p2, Color color) {
    final paint = Paint()..color=color..strokeWidth=4;
    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p2, Offset(p2.dx - 10, p2.dy - 10), paint);
    canvas.drawLine(p2, Offset(p2.dx + 10, p2.dy - 10), paint);
  }

  @override bool shouldRepaint(covariant _LeverPainter oldDelegate) => true;
}
