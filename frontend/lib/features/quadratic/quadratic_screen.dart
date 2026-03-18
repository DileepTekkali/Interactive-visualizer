import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/widgets/preset_card.dart';
import '../../shared/widgets/main_layout.dart';
import 'quadratic_painter.dart';

class QuadraticScreen extends StatefulWidget {
  const QuadraticScreen({super.key});

  @override
  State<QuadraticScreen> createState() => _QuadraticScreenState();
}

class _QuadraticScreenState extends State<QuadraticScreen> with TickerProviderStateMixin {
  double _a = 1.0;
  double _b = 0.0;
  double _c = 0.0;
  Offset? _hoverPoint;

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
    setState(() { _a = 1; _b = 0; _c = 0; _hoverPoint = null; });
    _animController.forward();
  }

  void _applyPreset(double a, double b, double c) {
    _animController.reset();
    setState(() { _a = a; _b = b; _c = c; });
    _animController.forward();
  }



  String get _equation {
    final parts = <String>[];
    if (_a != 0) parts.add('${_a.toStringAsFixed(1)}x²');
    if (_b != 0) parts.add('${_b >= 0 ? '+ ' : '− '}${_b.abs().toStringAsFixed(1)}x');
    if (_c != 0) parts.add('${_c >= 0 ? '+ ' : '− '}${_c.abs().toStringAsFixed(1)}');
    return 'y = ${parts.isEmpty ? '0' : parts.join(' ')}';
  }

  Map<String, String> get _analysisData {
    final disc = _b * _b - 4 * _a * _c;
    String roots;
    if (_a == 0) {
      roots = 'Linear';
    } else if (disc < 0) {
      roots = 'None (imaginary)';
    } else if (disc == 0) {
      roots = '${(-_b / (2 * _a)).toStringAsFixed(2)}';
    } else {
      final r1 = (-_b + math.sqrt(disc)) / (2 * _a);
      final r2 = (-_b - math.sqrt(disc)) / (2 * _a);
      roots = '${r1.toStringAsFixed(1)}, ${r2.toStringAsFixed(1)}';
    }
    final vertex = _a != 0
        ? '(${(-_b / (2 * _a)).toStringAsFixed(2)}, ${(_c - _b * _b / (4 * _a)).toStringAsFixed(2)})'
        : 'N/A';
    return {
      'Roots': roots,
      'Vertex': vertex,
      'Opens': _a > 0 ? 'Upward ↑' : _a < 0 ? 'Downward ↓' : 'N/A',
      'Y-intercept': _c.toStringAsFixed(2),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Quadratic Graph',
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
                  child: Text(_equation, style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.secondary, letterSpacing: 1)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
                    child: MouseRegion(
                      onHover: (e) => setState(() => _hoverPoint = e.localPosition),
                      onExit: (_) => setState(() => _hoverPoint = null),
                      child: AnimatedBuilder(
                        animation: _anim,
                        builder: (_, __) => CustomPaint(
                          painter: QuadraticPainter(a: _a, b: _b, c: _c, hoverPoint: _hoverPoint, animProgress: _anim.value),
                          size: Size.infinite,
                        ),
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

                  _sectionTitle('Parameters'),
                  ParameterSlider(label: 'a (x² coefficient)', value: _a, min: -3, max: 3, onChanged: (v) { setState(() => _a = v); }),
                  ParameterSlider(label: 'b (x coefficient)', value: _b, min: -5, max: 5, onChanged: (v) { setState(() => _b = v); }),
                  ParameterSlider(label: 'c (constant)', value: _c, min: -8, max: 8, onChanged: (v) { setState(() => _c = v); }),
                  const SizedBox(height: 16),
                  _buildAnalysisBox(),
                  const SizedBox(height: 16),
                  _sectionTitle('Presets'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    PresetCard(label: 'Standard', description: 'a=1, b=0, c=0', onTap: () => _applyPreset(1, 0, 0)),
                    PresetCard(label: 'Wide', description: 'a=0.3, b=0, c=0', onTap: () => _applyPreset(0.3, 0, 0)),
                    PresetCard(label: 'Inverted', description: 'a=−1, b=0, c=4', onTap: () => _applyPreset(-1, 0, 4)),
                    PresetCard(label: 'Shifted', description: 'a=1, b=−4, c=3', onTap: () => _applyPreset(1, -4, 3)),
                  ]),
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

  Widget _buildAnalysisBox() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
        ),
        child: Column(
          children: _analysisData.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(e.key, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              Text(e.value, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.secondary)),
            ]),
          )).toList(),
        ),
      );


}
