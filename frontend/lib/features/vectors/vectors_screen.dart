import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/widgets/main_layout.dart';
import 'vectors_painter.dart';

class VectorsScreen extends StatefulWidget {
  const VectorsScreen({super.key});

  @override
  State<VectorsScreen> createState() => _VectorsScreenState();
}

class _VectorsScreenState extends State<VectorsScreen> with TickerProviderStateMixin {
  double _mag1 = 5.0, _angle1 = 45.0;
  double _mag2 = 4.0, _angle2 = 0.0;
  
  String _selectedUnit = 'm/s';
  final List<String> _units = ['m', 'm/s', 'N', 'km/h'];

  late AnimationController _animController;
  late Animation<double> _anim;



  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _reset() {
    _animController.reset();
    setState(() { _mag1 = 5; _angle1 = 45; _mag2 = 4; _angle2 = 0; });
    _animController.forward();
  }



  double get _resMag {
    final rX = _mag1 * math.cos(_angle1 * math.pi / 180) + _mag2 * math.cos(_angle2 * math.pi / 180);
    final rY = _mag1 * math.sin(_angle1 * math.pi / 180) + _mag2 * math.sin(_angle2 * math.pi / 180);
    return math.sqrt(rX*rX + rY*rY);
  }

  double get _resAngle {
    final rX = _mag1 * math.cos(_angle1 * math.pi / 180) + _mag2 * math.cos(_angle2 * math.pi / 180);
    final rY = _mag1 * math.sin(_angle1 * math.pi / 180) + _mag2 * math.sin(_angle2 * math.pi / 180);
    return math.atan2(rY, rX) * 180 / math.pi;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Vectors: Addition & Resultants',
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
        IconButton(icon: const Icon(Icons.refresh, color: AppTheme.textSecondary), onPressed: _reset),
        const SizedBox(width: 8),
      ],
      child: isWide
          ? Row(children: [_buildGraph(), _buildControls()])
          : SingleChildScrollView(child: Column(children: [_buildGraph(), _buildControls()])),
    );
  }

  Widget _buildGraph() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: AppTheme.glassCard,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('R = v₁ + v₂', style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.success, letterSpacing: 1)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) => CustomPaint(
                        painter: VectorsPainter(
                          mag1: _mag1, angle1: _angle1, mag2: _mag2, angle2: _angle2,
                          unit: _selectedUnit, animProgress: _anim.value,
                        ),
                        size: Size.infinite,
                      ),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _sectionTitle('Vector 1 (v₁)'),
                  ParameterSlider(label: 'Magnitude', value: _mag1, min: 0, max: 10, onChanged: (v) { setState(() => _mag1 = v); }),
                  ParameterSlider(label: 'Angle (°)', value: _angle1, min: -180, max: 180, divisions: 144, onChanged: (v) { setState(() => _angle1 = v); }),
                  const SizedBox(height: 16),
                  _sectionTitle('Vector 2 (v₂)'),
                  ParameterSlider(label: 'Magnitude', value: _mag2, min: 0, max: 10, onChanged: (v) { setState(() => _mag2 = v); }),
                  ParameterSlider(label: 'Angle (°)', value: _angle2, min: -180, max: 180, divisions: 144, onChanged: (v) { setState(() => _angle2 = v); }),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.success.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _statRow('Resultant Magnitude', '${_resMag.toStringAsFixed(2)} $_selectedUnit'),
                        _statRow('Resultant Angle', '${_resAngle.toStringAsFixed(1)}°'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.2)),
      );

  Widget _statRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.success)),
        ]),
      );
}
