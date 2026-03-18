import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'progressions_painter.dart';

class ProgressionsScreen extends StatefulWidget {
  const ProgressionsScreen({super.key});

  @override
  State<ProgressionsScreen> createState() => _ProgressionsScreenState();
}

class _ProgressionsScreenState extends State<ProgressionsScreen> with SingleTickerProviderStateMixin {
  // Mode: 0 = AP, 1 = GP
  int _mode = 0;

  // AP params
  double _a = 2.0;     // First Term
  double _d = 3.0;     // Common Difference
  // GP params
  double _gpA = 1.0;   // First Term
  double _gpR = 2.0;   // Common Ratio
  int _n = 8;          // Number of Terms (shared)

  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _a = 2.0; _d = 3.0; _gpA = 1.0; _gpR = 2.0; _n = 8;
    });
    _animController.reset();
    _animController.forward();
  }

  // AP calculations
  double get _apNthTerm => _a + (_n - 1) * _d;
  double get _apSum => (_n / 2) * (2 * _a + (_n - 1) * _d);

  // GP calculations
  double get _gpNthTerm => _gpA * math.pow(_gpR, _n - 1);
  double get _gpSum => _gpR == 1 ? _gpA * _n : _gpA * (math.pow(_gpR, _n) - 1) / (_gpR - 1);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return MainLayout(
      title: 'Progressions',
      actions: [
        IconButton(icon: const Icon(Icons.refresh, color: AppTheme.textSecondary), onPressed: _reset),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Text(
                    _mode == 0 ? 'Arithmetic Progression (A.P.)' : 'Geometric Progression (G.P.)',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  )),
                  // AP / GP Toggle Chips
                  _modeChip('AP', 0),
                  const SizedBox(width: 8),
                  _modeChip('GP', 1),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _mode == 0
                    ? 'Each term increases by a constant difference d.\nFormula: aₙ = a + (n-1)d'
                    : 'Each term is multiplied by a constant ratio r.\nFormula: aₙ = a × rⁿ⁻¹',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, height: 1.5),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) => CustomPaint(
                    painter: ProgressionsPainter(
                      a: _mode == 0 ? _a : _gpA,
                      d: _d,
                      r: _gpR,
                      n: _n,
                      isGP: _mode == 1,
                      animProgress: _anim.value,
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

    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: 420, child: content);
  }

  Widget _modeChip(String label, int idx) {
    final selected = _mode == idx;
    return GestureDetector(
      onTap: () {
        setState(() => _mode = idx);
        _animController.reset();
        _animController.forward();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : AppTheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.accent : AppTheme.accent.withOpacity(0.3)),
        ),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppTheme.background : AppTheme.accent,
        )),
      ),
    );
  }

  Widget _buildControls() {
    final isWide = MediaQuery.of(context).size.width > 800;
    return SizedBox(
      width: isWide ? 300 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Parameters', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              if (_mode == 0) ...[
                ParameterSlider(label: 'First Term (a)', value: _a, min: 0, max: 20, onChanged: (v) => setState(() => _a = v)),
                ParameterSlider(label: 'Common Difference (d)', value: _d, min: -10, max: 10, onChanged: (v) => setState(() => _d = v)),
              ] else ...[
                ParameterSlider(label: 'First Term (a)', value: _gpA, min: 1, max: 10, onChanged: (v) => setState(() => _gpA = v)),
                ParameterSlider(label: 'Common Ratio (r)', value: _gpR, min: 0.1, max: 5, onChanged: (v) => setState(() => _gpR = v)),
              ],
              ParameterSlider(label: 'Terms Count (n)', value: _n.toDouble(), min: 1, max: 15, onChanged: (v) => setState(() => _n = v.round())),
              const SizedBox(height: 20),
              _buildAnalysisBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withOpacity(0.1)),
      ),
      child: _mode == 0 ? Column(children: [
        _statRow('Last Term (aₙ)', _apNthTerm.toStringAsFixed(2)),
        _statRow('Sum (Sₙ)', _apSum.toStringAsFixed(2)),
      ]) : Column(children: [
        _statRow('Last Term (aₙ)', _gpNthTerm.toStringAsFixed(2)),
        _statRow('Sum (Sₙ)', _gpSum.toStringAsFixed(2)),
        if (_gpR.abs() < 1)
          _statRow('Sum to ∞ (S∞)', (_gpA / (1 - _gpR)).toStringAsFixed(2)),
      ]),
    );
  }

  Widget _statRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          Text(val, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent)),
        ],
      ),
    );
  }
}
