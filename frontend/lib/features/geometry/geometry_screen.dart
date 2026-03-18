import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/widgets/main_layout.dart';

class GeometryScreen extends StatefulWidget {
  const GeometryScreen({super.key});

  @override
  State<GeometryScreen> createState() => _GeometryScreenState();
}

class _GeometryScreenState extends State<GeometryScreen> with TickerProviderStateMixin {
  bool _showCircle = true;

  String _selectedUnit = 'units';
  final List<String> _units = ['units', 'cm', 'm', 'in'];

  // Circle parameters
  double _radius = 4.0;

  // Triangle parameters
  double _base = 6.0;
  double _height = 4.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _switchController;
  late Animation<double> _switchAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _switchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _switchAnim = CurvedAnimation(parent: _switchController, curve: Curves.easeOut);
    _switchController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _switchController.dispose();
    super.dispose();
  }

  void _toggleShape() {
    _switchController.reset();
    setState(() => _showCircle = !_showCircle);
    _switchController.forward();
  }

  double get _circleArea => math.pi * _radius * _radius;
  double get _circleCircumference => 2 * math.pi * _radius;
  double get _triangleArea => 0.5 * _base * _height;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Basic Geometry',
      actions: [
        Row(
          children: [
            Text('Unit: ', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
            DropdownButton<String>(
              value: _selectedUnit,
              dropdownColor: AppTheme.surfaceLight,
              underline: const SizedBox(),
              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: GoogleFonts.inter(color: AppTheme.accentGlow, fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => _selectedUnit = v!),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
      child: isWide
          ? Row(children: [_buildCanvas(), _buildControls()])
          : SingleChildScrollView(child: Column(children: [_buildCanvas(), _buildControls()])),
    );
  }

  Widget _buildCanvas() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: AppTheme.glassCard,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _shapeToggle('Circle', true),
                  const SizedBox(width: 12),
                  _shapeToggle('Triangle', false),
                ]),
                Expanded(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_pulseAnim, _switchAnim]),
                    builder: (_, __) => CustomPaint(
                      painter: _showCircle
                          ? _CirclePainter(radius: _radius, unit: _selectedUnit, pulse: _pulseAnim.value, progress: _switchAnim.value)
                          : _TrianglePainter(base: _base, height: _height, unit: _selectedUnit, pulse: _pulseAnim.value, progress: _switchAnim.value),
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

  Widget _shapeToggle(String label, bool isCircle) {
    final active = _showCircle == isCircle;
    return GestureDetector(
      onTap: () { if (!active) _toggleShape(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: active ? AppTheme.accent : AppTheme.axisLine),
        ),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: active ? AppTheme.accentGlow : AppTheme.textSecondary,
        )),
      ),
    );
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
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Parameters'),
                if (_showCircle) ...[
                  ParameterSlider(label: 'Radius (r)', value: _radius, min: 0.5, max: 9, onChanged: (v) => setState(() => _radius = v)),
                  const SizedBox(height: 16),
                  _buildStatsBox([
                    _statRow('Area', '${_circleArea.toStringAsFixed(3)} $_selectedUnit²'),
                    _statRow('Circumference', '${_circleCircumference.toStringAsFixed(3)} $_selectedUnit'),
                    _statRow('Diameter', '${(_radius * 2).toStringAsFixed(2)} $_selectedUnit'),
                    _statRow('Formula', 'πr²'),
                  ], AppTheme.accent),
                ] else ...[
                  ParameterSlider(label: 'Base (b)', value: _base, min: 1, max: 12, onChanged: (v) => setState(() => _base = v)),
                  ParameterSlider(label: 'Height (h)', value: _height, min: 1, max: 10, onChanged: (v) => setState(() => _height = v)),
                  const SizedBox(height: 16),
                  _buildStatsBox([
                    _statRow('Area', '${_triangleArea.toStringAsFixed(3)} $_selectedUnit²'),
                    _statRow('Base', '${_base.toStringAsFixed(1)} $_selectedUnit'),
                    _statRow('Height', '${_height.toStringAsFixed(1)} $_selectedUnit'),
                    _statRow('Formula', '½ × b × h'),
                  ], AppTheme.success),
                ],
              ]),
            ),
          ),
        ),
      );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.2)),
      );

  Widget _buildStatsBox(List<Widget> rows, Color color) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(children: rows),
      );

  Widget _statRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.accentGlow, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _CirclePainter extends CustomPainter {
  final double radius;
  final String unit;
  final double pulse;
  final double progress;

  _CirclePainter({required this.radius, required this.unit, required this.pulse, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) * 0.38 * (radius / 9);
    final r = maxR * pulse * progress;

    // Glow
    canvas.drawCircle(center, r, Paint()
      ..color = AppTheme.accent.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));

    // Fill
    canvas.drawCircle(center, r, Paint()..color = AppTheme.accent.withOpacity(0.12));

    // Stroke
    canvas.drawCircle(center, r, Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke);

    // Radius line
    canvas.drawLine(center, center + Offset(r, 0), Paint()
      ..color = AppTheme.accentGlow.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round);

    _drawLabel(canvas, 'r = ${radius.toStringAsFixed(1)} $unit', center + Offset(r / 2, -14));
    _drawLabel(canvas, 'A = π·r²', center + const Offset(0, 20));
  }

  void _drawLabel(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: AppTheme.textPrimary.withOpacity(0.8), fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.radius != radius || old.unit != unit || old.pulse != pulse || old.progress != progress;
}

class _TrianglePainter extends CustomPainter {
  final double base;
  final double height;
  final String unit;
  final double pulse;
  final double progress;

  _TrianglePainter({required this.base, required this.height, required this.unit, required this.pulse, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final cx = size.width / 2;
    final bottom = size.height * 0.72;
    final scale = math.min(size.width / 14, size.height / 12) * progress;

    final bHalf = base / 2 * scale * pulse;
    final h = height * scale * pulse;

    final p1 = Offset(cx, bottom - h);
    final p2 = Offset(cx - bHalf, bottom);
    final p3 = Offset(cx + bHalf, bottom);

    final path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();

    canvas.drawPath(path, Paint()..color = AppTheme.success.withOpacity(0.12));
    canvas.drawPath(path, Paint()
      ..color = AppTheme.success
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke);

    // Height dashed line
    final dashPaint = Paint()..color = AppTheme.success.withOpacity(0.4)..strokeWidth = 1.5;
    canvas.drawLine(p1, Offset(cx, bottom), dashPaint);

    _drawLabel(canvas, 'h = ${height.toStringAsFixed(1)} $unit', Offset(cx + 6, (p1.dy + bottom) / 2));
    _drawLabel(canvas, 'b = ${base.toStringAsFixed(1)} $unit', Offset(cx, bottom + 12));
    _drawLabel(canvas, 'A = ½bh', Offset(cx, p1.dy - 18));
  }

  void _drawLabel(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: AppTheme.textPrimary.withOpacity(0.8), fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.base != base || old.height != height || old.unit != unit || old.pulse != pulse || old.progress != progress;
}
