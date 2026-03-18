import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'complex_numbers_painter.dart';

class ComplexNumbersScreen extends StatefulWidget {
  const ComplexNumbersScreen({super.key});

  @override
  State<ComplexNumbersScreen> createState() => _ComplexNumbersScreenState();
}

class _ComplexNumbersScreenState extends State<ComplexNumbersScreen> with SingleTickerProviderStateMixin {
  double _real = 4.0;
  double _imag = 3.0;
  
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
    setState(() {
      _real = 4.0;
      _imag = 3.0;
    });
    _animController.reset();
    _animController.forward();
  }

  double get _modulus => math.sqrt(_real * _real + _imag * _imag);
  double get _argument => math.atan2(_imag, _real) * 180 / math.pi;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return MainLayout(
      title: 'Complex Numbers',
      actions: [
        IconButton(icon: const Icon(Icons.refresh, color: AppTheme.textSecondary), onPressed: _reset),
        const SizedBox(width: 8),
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
              padding: const EdgeInsets.all(16),
              child: Text('Argand Plane Visualization', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) => CustomPaint(
                    painter: ComplexNumbersPainter(real: _real, imag: _imag, animProgress: _anim.value),
                    size: Size.infinite,
                  ),
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
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Complex Part Values', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              ParameterSlider(label: 'Real Part (x)', value: _real, min: -10, max: 10, onChanged: (v) => setState(() => _real = v)),
              ParameterSlider(label: 'Imaginary Part (y)', value: _imag, min: -10, max: 10, onChanged: (v) => setState(() => _imag = v)),
              const SizedBox(height: 24),
              _buildAnalysisBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _statRow('Modulus |z|', _modulus.toStringAsFixed(2)),
          _statRow('Argument θ', '${_argument.toStringAsFixed(1)}°'),
          const Divider(),
          Text('Polar Form: z = |z|(cosθ + i sinθ)', style: GoogleFonts.inter(fontSize: 10, fontStyle: FontStyle.italic, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _statRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
