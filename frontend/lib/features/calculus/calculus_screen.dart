import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/widgets/main_layout.dart';
import 'calculus_painter.dart';

class CalculusScreen extends StatefulWidget {
  const CalculusScreen({super.key});

  @override
  State<CalculusScreen> createState() => _CalculusScreenState();
}

class _CalculusScreenState extends State<CalculusScreen> with TickerProviderStateMixin {
  double _m = 1.0;
  double _x0 = 2.0;
  bool _showTangent = true;
  bool _showArea = true;

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
    setState(() { _m = 1.0; _x0 = 2.0; _showTangent = true; _showArea = true; });
    _animController.forward();
  }



  double get _currentArea => (_m * math.pow(_x0, 3)) / 3.0;
  double get _currentDerivative => 2 * _m * _x0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Calculus: Limits & Derivatives',
      actions: [
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
                  child: Text('y = ${_m.toStringAsFixed(1)}x²', style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.orangeAccent, letterSpacing: 1)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) => CustomPaint(
                        painter: CalculusPainter(m: _m, x0: _x0, showTangent: _showTangent, showArea: _showArea, animProgress: _anim.value),
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
                  _sectionTitle('Function: y = mx²'),
                  ParameterSlider(label: 'Multiplier (m)', value: _m, min: 0.2, max: 4, onChanged: (v) { setState(() => _m = v); }),
                  ParameterSlider(label: 'Point of Interest (x₀)', value: _x0, min: -4, max: 4, onChanged: (v) { setState(() => _x0 = v); }),
                  const SizedBox(height: 16),
                  _sectionTitle('Concepts'),
                  _toggleRow('Show Tangent (Derivative)', _showTangent, (v) => setState(() => _showTangent = v)),
                  _toggleRow('Show Area (Integral from 0)', _showArea, (v) => setState(() => _showArea = v)),
                  const SizedBox(height: 16),
                  if (_showTangent || _showArea) _buildAnalysisBox(),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.orangeAccent),
        ],
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.2)),
      );

  Widget _buildAnalysisBox() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            if (_showTangent) _statRow('Derivative dy/dx', _currentDerivative.toStringAsFixed(2)),
            if (_showTangent) _statRow('Slope meaning', 'Rate of change at x₀'),
            if (_showTangent && _showArea) const SizedBox(height: 8),
            if (_showArea) _statRow('Integral ∫y dx', _currentArea.abs().toStringAsFixed(2)),
            if (_showArea) _statRow('Area meaning', 'Accumulated area from 0 to x₀'),
          ],
        ),
      );

  Widget _statRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 2,
            child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.orangeAccent),
            ),
          ),
        ]),
      );


}
