import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/physics_api_service.dart';
import 'dart:math' as math;

class OpticsScreen extends StatefulWidget {
  const OpticsScreen({super.key});

  @override
  State<OpticsScreen> createState() => _OpticsScreenState();
}

class _OpticsScreenState extends State<OpticsScreen> {
  double _angle = 45.0;
  double _n1 = 1.0;
  double _n2 = 1.5;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final data = await PhysicsApiService.lightRaySimulator(_angle, _n1, _n2);
    if (mounted) setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: "Snell's Law (Optics)",
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
            Padding(padding: const EdgeInsets.all(16), child: Text('Refraction through Mediums', style: GoogleFonts.inter(fontSize: 18, color: Colors.blueAccent))),
            Expanded(
              child: CustomPaint(
                painter: _OpticsPainter(incidentAngle: _angle, refractedAngle: (_data?['refracted_angle_deg'] as num?)?.toDouble() ?? 0.0, totalInternalRefl: _data?['total_internal_reflection'] ?? false),
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
               ParameterSlider(label: 'Incident Angle (°)', value: _angle, min: 0, max: 90, onChanged: (v){ setState(()=>_angle=v); _fetch(); }),
               ParameterSlider(label: 'Medium 1 Index (n₁)', value: _n1, min: 1.0, max: 3.0, onChanged: (v){ setState(()=>_n1=v); _fetch(); }),
               ParameterSlider(label: 'Medium 2 Index (n₂)', value: _n2, min: 1.0, max: 3.0, onChanged: (v){ setState(()=>_n2=v); _fetch(); }),
               const Spacer(),
               if (_data != null) ...[
                if (_data?['success'] == true) ...[
                 _stat('Incident °', "${(_data?['incident_angle_deg'] as num?)?.toDouble() ?? 0.0}°"),
                 if (_data?['total_internal_reflection'] == true)
                   const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('TOTAL INTERNAL REFLECTION', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)))
                 else ...[
                   _stat('Refracted °', "${(_data?['refracted_angle_deg'] as num?)?.toDouble() ?? 0.0}°"),
                   const SizedBox(height: 16),
                   Text('n₁sin(θ₁) = n₂sin(θ₂)', style: GoogleFonts.inter(color: Colors.white54)),
                 ]
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

class _OpticsPainter extends CustomPainter {
  final double incidentAngle;
  final double refractedAngle;
  final bool totalInternalRefl;

  _OpticsPainter({required this.incidentAngle, required this.refractedAngle, required this.totalInternalRefl});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Mediums
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, center.dy), Paint()..color=Colors.black12);
    canvas.drawRect(Rect.fromLTRB(0, center.dy, size.width, size.height), Paint()..color=Colors.blueAccent.withOpacity(0.2));

    // Normal Line
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), Paint()..color=Colors.white30..strokeWidth=2..style=PaintingStyle.stroke); // dashed theoretically

    // Incident Ray
    double incRad = incidentAngle * math.pi / 180;
    // from top left towards center
    // angle is from normal
    final startX = center.dx - 200 * math.sin(incRad);
    final startY = center.dy - 200 * math.cos(incRad);
    canvas.drawLine(Offset(startX, startY), center, Paint()..color=Colors.yellowAccent..strokeWidth=4);

    // Refracted or Reflected
    if (totalInternalRefl) {
      // reflect over normal
      final refX = center.dx + 200 * math.sin(incRad);
      final refY = center.dy - 200 * math.cos(incRad);
      canvas.drawLine(center, Offset(refX, refY), Paint()..color=Colors.yellow..strokeWidth=4);
    } else {
      // refract into Medium 2
      double refRad = refractedAngle * math.pi / 180;
      final endX = center.dx + 200 * math.sin(refRad);
      final endY = center.dy + 200 * math.cos(refRad);
      canvas.drawLine(center, Offset(endX, endY), Paint()..color=Colors.redAccent..strokeWidth=4);
    }
  }

  @override bool shouldRepaint(covariant _OpticsPainter oldDelegate) => true;
}
