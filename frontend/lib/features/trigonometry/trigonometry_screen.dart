import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/widgets/preset_card.dart';
import '../../shared/widgets/main_layout.dart';
import 'trigonometry_painter.dart';

class TrigonometryScreen extends StatefulWidget {
  const TrigonometryScreen({super.key});

  @override
  State<TrigonometryScreen> createState() => _TrigonometryScreenState();
}

class _TrigonometryScreenState extends State<TrigonometryScreen> with TickerProviderStateMixin {
  double _amplitude = 1.0;
  double _frequency = 1.0;
  double _phase = 0.0;
  bool _isCosine = false;
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
    setState(() { _amplitude = 1; _frequency = 1; _phase = 0; _hoverPoint = null; });
    _animController.forward();
  }

  void _applyPreset(double a, double f, double p) {
    _animController.reset();
    setState(() { _amplitude = a; _frequency = f; _phase = p; });
    _animController.forward();
  }



  String get _equation {
    final func = _isCosine ? 'cos' : 'sin';
    final pStr = _phase == 0 ? '' : _phase > 0 ? ' + ${_phase.toStringAsFixed(1)}' : ' - ${_phase.abs().toStringAsFixed(1)}';
    return 'y = ${_amplitude.toStringAsFixed(1)}$func(${_frequency.toStringAsFixed(1)}x$pStr)';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Trigonometry Graph',
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
                  child: Text(_equation, style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.pinkAccent, letterSpacing: 1)),
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
                          painter: TrigonometryPainter(amplitude: _amplitude, frequency: _frequency, phase: _phase, isCosine: _isCosine, hoverPoint: _hoverPoint, animProgress: _anim.value),
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

                  _sectionTitle('Wave Type'),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _toggleBtn('Sine', !_isCosine),
                    _toggleBtn('Cosine', _isCosine),
                  ]),
                  const SizedBox(height: 16),
                  _sectionTitle('Parameters'),
                  ParameterSlider(label: 'Amplitude (A)', value: _amplitude, min: -4, max: 4, onChanged: (v) { setState(() => _amplitude = v); }),
                  ParameterSlider(label: 'Frequency (B)', value: _frequency, min: 0.1, max: 4, onChanged: (v) { setState(() => _frequency = v); }),
                  ParameterSlider(label: 'Phase (C)', value: _phase, min: -math.pi, max: math.pi, onChanged: (v) { setState(() => _phase = v); }),
                  const SizedBox(height: 16),
                  _sectionTitle('Presets'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    PresetCard(label: 'Standard Sine', description: 'A=1, B=1', onTap: () => _applyPreset(1, 1, 0)),
                    PresetCard(label: 'High Freq', description: 'A=1, B=3', onTap: () => _applyPreset(1, 3, 0)),
                    PresetCard(label: 'Tall Wave', description: 'A=3, B=1', onTap: () => _applyPreset(3, 1, 0)),
                    PresetCard(label: 'Shifted', description: 'Phase = π/2', onTap: () => _applyPreset(1, 1, math.pi / 2)),
                  ]),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _toggleBtn(String label, bool active) => GestureDetector(
        onTap: () {
          setState(() => _isCosine = label == 'Cosine');
          _animController.reset();
          _animController.forward();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.pinkAccent.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? Colors.pinkAccent : AppTheme.axisLine),
          ),
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: active ? Colors.pinkAccent : AppTheme.textSecondary)),
        ),
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.2)),
      );


}
