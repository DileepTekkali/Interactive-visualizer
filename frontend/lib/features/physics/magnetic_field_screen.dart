import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'dart:math' as math;

class MagneticFieldScreen extends StatefulWidget {
  const MagneticFieldScreen({super.key});

  @override
  State<MagneticFieldScreen> createState() => _MagneticFieldScreenState();
}

class _MagneticFieldScreenState extends State<MagneticFieldScreen> with SingleTickerProviderStateMixin {
  double _strength = 5.0;
  Map<String, dynamic>? _data;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _calculate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _calculate() {
    // Dipole Field Approximation local data
    // Grid: -5 to 5
    List<List<double>> grid = [];
    double maxB = 0;
    final s = _strength;

    for (int y = -3; y <= 3; y++) {
      for (int x = -3; x <= 3; x++) {
        double r = math.sqrt(x * x + y * y) + 1.0;
        double B = s / (r * r);
        if (B > maxB) maxB = B;
        grid.add([x.toDouble(), y.toDouble(), B]);
      }
    }

    if (mounted) {
      setState(() {
        _data = {
          'success': true,
          'grid': grid,
          'max_b_field': maxB,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Magnetic Field Visualizer',
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
            Padding(padding: const EdgeInsets.all(16), child: Text('Dipole Magnet Field Lines', style: GoogleFonts.inter(fontSize: 18, color: Colors.blueAccent))),
            Expanded(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => CustomPaint(
                  painter: _MagnetPainter(strength: _strength, animValue: _animController.value),
                  size: Size.infinite,
                ),
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
               ParameterSlider(label: 'Magnet Strength', value: _strength, min: 1, max: 20, onChanged: (v){ setState(()=>_strength=v); _calculate(); }),
               const Spacer(),
               if (_data != null) ...[
                 if (_data?['success'] == true) ...[
                   _stat('Grid Points', "${(_data?['grid'] as List?)?.length ?? 0}"),
                   _stat('Max B-Field', "${(_data?['max_b_field'] as num?)?.toDouble() ?? 0.0} T"),
                   const SizedBox(height: 16),
                   Text('Magnetic field loops from North (Red) to South (Blue). Field is strongest at the poles.', style: GoogleFonts.inter(color: Colors.white54, fontSize: 13))
                 ] else
                    Text(_data?['error'] ?? 'Simulation Error', style: const TextStyle(color: Colors.redAccent))
               ]
            ]
          )
        )
      )
    );
  }

  Widget _stat(String l, String v) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: GoogleFonts.inter(color: Colors.white)), Text(v, style: GoogleFonts.jetBrainsMono(color: Colors.orangeAccent))]);
}

class _MagnetPainter extends CustomPainter {
  final double strength;
  final double animValue;

  _MagnetPainter({required this.strength, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Magnet
    final rect = Rect.fromCenter(center: center, width: 140, height: 40);
    final rectN = Rect.fromLTRB(rect.left, rect.top, center.dx, rect.bottom);
    final rectS = Rect.fromLTRB(center.dx, rect.top, rect.right, rect.bottom);
    
    canvas.drawRect(rectN, Paint()..color=Colors.redAccent);
    canvas.drawRect(rectS, Paint()..color=Colors.blueAccent);

    TextPainter(text: TextSpan(text: 'N', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 20)), textDirection: TextDirection.ltr)
      ..layout()..paint(canvas, Offset(center.dx - 40, center.dy - 10));
    TextPainter(text: TextSpan(text: 'S', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 20)), textDirection: TextDirection.ltr)
      ..layout()..paint(canvas, Offset(center.dx + 25, center.dy - 10));

    // Field Lines
    final paint = Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=Colors.white30;
    
    for (int i = 1; i <= 4; i++) {
       double a = 60.0 + (i * 30);
       double b = 40.0 + (i * 25);
       
       // Draw elliptical arcs approximation
       canvas.drawOval(Rect.fromCenter(center: center, width: 140 + a, height: b * 2), paint);
       
       // Animating particles along the path (approximate)
       double t = (animValue + (i * 0.25)) % 1.0;
       double angle = t * 2 * math.pi;
       if (t > 0.5) { // bottom half goes S -> N (wrong for outside magnet, actually N->S always outside)
       }
       
       // Proper ellipse parametric: x = a*cos(t), y = b*sin(t)
       // N is left, S is right. Field goes left -> right on top and bottom OUTSIDE magnet.
       double partAngle = (animValue * math.pi + (i * 0.1));
       double pxTop = center.dx - ((140+a)/2) * math.cos(partAngle); // Moves left to right
       double pyTop = center.dy - b * math.sin(partAngle);
       
       double pxBot = center.dx - ((140+a)/2) * math.cos(partAngle); // Moves left to right
       double pyBot = center.dy + b * math.sin(partAngle);

       canvas.drawCircle(Offset(pxTop, pyTop), 3, Paint()..color=Colors.white);
       canvas.drawCircle(Offset(pxBot, pyBot), 3, Paint()..color=Colors.white);
    }
  }

  @override bool shouldRepaint(covariant _MagnetPainter oldDelegate) => true;
}
