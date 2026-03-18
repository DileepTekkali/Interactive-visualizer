import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/physics_api_service.dart';

class NewtonsLawsScreen extends StatefulWidget {
  const NewtonsLawsScreen({super.key});

  @override
  State<NewtonsLawsScreen> createState() => _NewtonsLawsScreenState();
}

class _NewtonsLawsScreenState extends State<NewtonsLawsScreen> with SingleTickerProviderStateMixin {
  double _force = 50.0;
  double _mass = 10.0;
  Map<String, dynamic>? _data;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _fetch();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final data = await PhysicsApiService.newtonsLaws(_force, _mass);
    if (mounted) setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: "Newton's 2nd Law",
      child: isWide ? Row(children: [_buildVisual(), _buildControls()]) : SingleChildScrollView(child: Column(children: [_buildVisual(), _buildControls()])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final accel = (_data?['acceleration'] as num?)?.toDouble() ?? 0.0;
    
    // Scale animation speed by acceleration
    _animController.duration = Duration(milliseconds: accel == 0 ? 999999 : (2000 / accel.abs()).clamp(100.0, 5000.0).toInt());
    if (accel == 0) _animController.stop(); else _animController.repeat();

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text('F = ma', style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent))),
            Expanded(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => CustomPaint(
                  painter: _NewtonPainter(force: _force, mass: _mass, accel: accel, progress: _animController.value),
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
              ParameterSlider(label: 'Applied Force (N)', value: _force, min: -100, max: 100, onChanged: (v){ setState(()=>_force=v); _fetch(); }),
              ParameterSlider(label: 'Mass (kg)', value: _mass, min: 1, max: 50, onChanged: (v){ setState(()=>_mass=v); _fetch(); }),
              const Spacer(),
              if (_data != null) ...[
                if (_data?['success'] == true) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Acceleration (m/s²)', style: GoogleFonts.inter(color: Colors.white)),
                      Text("${(_data?['acceleration'] as num?)?.toDouble() ?? 0.0}", style: GoogleFonts.jetBrainsMono(color: Colors.orangeAccent, fontSize: 18))
                  ]),
                  const SizedBox(height: 16),
                  Text(_data?['law_statement'] ?? '', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
                ] else
                   Text(_data?['error'] ?? 'Simulation Error', style: const TextStyle(color: Colors.redAccent))
              ]
            ]
          )
        )
      )
    );
  }
}

class _NewtonPainter extends CustomPainter {
  final double force;
  final double mass;
  final double accel;
  final double progress;

  _NewtonPainter({required this.force, required this.mass, required this.accel, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Road
    canvas.drawLine(Offset(0, center.dy + 40), Offset(size.width, center.dy + 40), Paint()..color=Colors.white24..strokeWidth=4);

    // Box offset
    // Just loop across screen
    double direction = accel >= 0 ? 1 : -1;
    double startX = direction > 0 ? -100 : size.width + 100;
    double distance = size.width + 200;
    double currentX = startX + (distance * progress * direction);
    
    if (accel == 0) currentX = center.dx;

    // Draw Box
    double boxSize = 40 + (mass); // Visual scaling
    final rect = Rect.fromLTRB(currentX - boxSize/2, center.dy + 40 - boxSize, currentX + boxSize/2, center.dy + 40);
    canvas.drawRect(rect, Paint()..color=Colors.blueAccent);

    // Force vector
    if (force != 0) {
      double arrowL = 40 + (force.abs() / 2);
      final p1 = Offset(currentX, center.dy - boxSize/2);
      final p2 = Offset(currentX + (force > 0 ? arrowL : -arrowL), center.dy - boxSize/2);
      
      final paint = Paint()..color=Colors.redAccent..strokeWidth=4;
      canvas.drawLine(p1, p2, paint);
      // arrowhead
      canvas.drawCircle(p2, 4, paint);
    }
  }

  @override bool shouldRepaint(covariant _NewtonPainter oldDelegate) => true;
}
