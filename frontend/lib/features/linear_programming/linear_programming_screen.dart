import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'linear_programming_painter.dart';

class LinearProgrammingScreen extends StatefulWidget {
  const LinearProgrammingScreen({super.key});

  @override
  State<LinearProgrammingScreen> createState() => _LinearProgrammingScreenState();
}

class _LinearProgrammingScreenState extends State<LinearProgrammingScreen> with SingleTickerProviderStateMixin {
  double _c1 = 8.0;
  double _c2 = 12.0;
  
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
      _c1 = 8.0;
      _c2 = 12.0;
    });
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return MainLayout(
      title: 'Linear Programming',
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
              child: Text('Feasible Region (First Quadrant)', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) => CustomPaint(
                    painter: LinearProgrammingPainter(c1: _c1, c2: _c2, animProgress: _anim.value),
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
              Text('Constraints', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              ParameterSlider(label: 'x + y ≤ C1', value: _c1, min: 2, max: 15, onChanged: (v) => setState(() => _c1 = v)),
              ParameterSlider(label: '2x + y ≤ C2', value: _c2, min: 2, max: 20, onChanged: (v) => setState(() => _c2 = v)),
              const SizedBox(height: 24),
              _buildInstructionBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success.withOpacity(0.1)),
      ),
      child: Text(
        'The shaded area represents the Feasible Region where all inequalities are satisfied simultaneously.',
        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, height: 1.4),
      ),
    );
  }
}
