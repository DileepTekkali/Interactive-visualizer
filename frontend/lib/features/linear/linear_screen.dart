import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/widgets/preset_card.dart';
import '../../shared/widgets/main_layout.dart';
import 'linear_painter.dart';

class LinearScreen extends StatefulWidget {
  const LinearScreen({super.key});

  @override
  State<LinearScreen> createState() => _LinearScreenState();
}

class _LinearScreenState extends State<LinearScreen> with TickerProviderStateMixin {
  double _m = 1.0;
  double _c = 0.0;
  Offset? _hoverPoint;

  late AnimationController _lineAnimController;
  late Animation<double> _lineAnim;



  @override
  void initState() {
    super.initState();
    _lineAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lineAnim = CurvedAnimation(parent: _lineAnimController, curve: Curves.easeOut);
    _lineAnimController.forward();
  }

  @override
  void dispose() {
    _lineAnimController.dispose();
    super.dispose();
  }

  void _reset() {
    _lineAnimController.reset();
    setState(() {
      _m = 1.0;
      _c = 0.0;
      _hoverPoint = null;
    });
    _lineAnimController.forward();
  }

  void _applyPreset(double m, double c) {
    _lineAnimController.reset();
    setState(() {
      _m = m;
      _c = c;
    });
    _lineAnimController.forward();
  }



  String get _equation {
    final mStr = _m == _m.roundToDouble() ? _m.toInt().toString() : _m.toStringAsFixed(1);
    final cAbs = _c.abs();
    final cStr = cAbs == cAbs.roundToDouble() ? cAbs.toInt().toString() : cAbs.toStringAsFixed(1);
    if (_c == 0) return 'y = ${mStr}x';
    final sign = _c >= 0 ? '+' : '−';
    return 'y = ${mStr}x $sign $cStr';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Linear Graph',
      actions: [
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
          tooltip: 'Reset',
          onPressed: _reset,
        ),
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
                child: Text(
                  _equation,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGlow,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
                  child: MouseRegion(
                    onHover: (e) => setState(() => _hoverPoint = e.localPosition),
                    onExit: (_) => setState(() => _hoverPoint = null),
                    child: AnimatedBuilder(
                      animation: _lineAnim,
                      builder: (_, __) => CustomPaint(
                        painter: LinearPainter(
                          m: _m,
                          c: _c,
                          hoverPoint: _hoverPoint,
                          animProgress: _lineAnim.value,
                        ),
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

                _buildSectionTitle('Parameters'),
                ParameterSlider(label: 'Slope (m)', value: _m, min: -5, max: 5, onChanged: (v) {
                  setState(() => _m = v);
                }),
                ParameterSlider(label: 'Intercept (c)', value: _c, min: -8, max: 8, onChanged: (v) {
                  setState(() => _c = v);
                }),
                const SizedBox(height: 16),
                _buildInfoBox(),
                const SizedBox(height: 16),
                _buildSectionTitle('Presets'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PresetCard(label: 'Steep +', description: 'm=4, c=0', onTap: () => _applyPreset(4, 0)),
                    PresetCard(label: 'Steep −', description: 'm=−4, c=0', onTap: () => _applyPreset(-4, 0)),
                    PresetCard(label: 'Flat', description: 'm=0.5, c=2', onTap: () => _applyPreset(0.5, 2)),
                    PresetCard(label: 'Diagonal', description: 'm=1, c=−3', onTap: () => _applyPreset(1, -3)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.2)),
      );

  Widget _buildInfoBox() {
    final yInt = _c;
    final xInt = _m != 0 ? -_c / _m : double.infinity;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Y-intercept', yInt.toStringAsFixed(2)),
          const SizedBox(height: 4),
          _infoRow('X-intercept', xInt.isInfinite ? '∞' : xInt.toStringAsFixed(2)),
          const SizedBox(height: 4),
          _infoRow('Slope', _m > 0 ? 'Positive ↗' : _m < 0 ? 'Negative ↘' : 'Horizontal →'),
        ],
      ),
    );
  }

  Widget _infoRow(String key, String val) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          Text(val, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.accentGlow)),
        ],
      );


}
