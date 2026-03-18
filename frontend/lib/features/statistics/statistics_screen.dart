import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/widgets/preset_card.dart';
import '../../shared/widgets/main_layout.dart';
import 'statistics_painter.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  double _mean = 0.0;
  double _stdDev = 1.0;
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
    setState(() { _mean = 0.0; _stdDev = 1.0; _hoverPoint = null; });
    _animController.forward();
  }

  void _applyPreset(double m, double s) {
    _animController.reset();
    setState(() { _mean = m; _stdDev = s; });
    _animController.forward();
  }



  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Statistics: Normal Distribution',
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
                  child: Text('N(μ=${_mean.toStringAsFixed(1)}, σ²=${(_stdDev * _stdDev).toStringAsFixed(2)})', 
                    style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.purpleAccent, letterSpacing: 1)),
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
                          painter: StatisticsPainter(mean: _mean, stdDev: _stdDev, hoverPoint: _hoverPoint, animProgress: _anim.value),
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
                  ParameterSlider(label: 'Mean (μ)', value: _mean, min: -6, max: 6, onChanged: (v) { setState(() => _mean = v); }),
                  ParameterSlider(label: 'Standard Deviation (σ)', value: _stdDev, min: 0.5, max: 4.0, onChanged: (v) { setState(() => _stdDev = v); }),
                  const SizedBox(height: 16),
                  _buildAnalysisBox(),
                  const SizedBox(height: 16),
                  _sectionTitle('Presets'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    PresetCard(label: 'Standard Normal', description: 'μ=0, σ=1', onTap: () => _applyPreset(0, 1)),
                    PresetCard(label: 'Wide Spread', description: 'μ=0, σ=3', onTap: () => _applyPreset(0, 3)),
                    PresetCard(label: 'Shifted Right', description: 'μ=4, σ=1.5', onTap: () => _applyPreset(4, 1.5)),
                    PresetCard(label: 'Tall & Narrow', description: 'μ=-2, σ=0.5', onTap: () => _applyPreset(-2, 0.5)),
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
          color: Colors.purpleAccent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            _statRow('Peak Probability', (1.0 / (_stdDev * math.sqrt(2 * math.pi))).toStringAsFixed(3)),
            _statRow('68% within', '[${(_mean - _stdDev).toStringAsFixed(1)}, ${(_mean + _stdDev).toStringAsFixed(1)}]'),
            _statRow('95% within', '[${(_mean - 2 * _stdDev).toStringAsFixed(1)}, ${(_mean + 2 * _stdDev).toStringAsFixed(1)}]'),
          ],
        ),
      );

  Widget _statRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.purpleAccent)),
        ]),
      );


}
