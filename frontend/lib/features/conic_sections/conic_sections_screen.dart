import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'conic_sections_painter.dart';

class ConicSectionsScreen extends StatefulWidget {
  const ConicSectionsScreen({super.key});

  @override
  State<ConicSectionsScreen> createState() => _ConicSectionsScreenState();
}

class _ConicSectionsScreenState extends State<ConicSectionsScreen> with SingleTickerProviderStateMixin {
  double _a = 6.0;
  double _b = 4.0;
  String _mode = 'Ellipse';
  
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
      _a = 6.0;
      _b = 4.0;
      _mode = 'Ellipse';
    });
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return MainLayout(
      title: 'Conic Sections',
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
              child: Text('Section: $_mode', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) => CustomPaint(
                    painter: ConicSectionsPainter(a: _a, b: _b, mode: _mode, animProgress: _anim.value),
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
              Text('Curve Type', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Ellipse', 'Parabola', 'Hyperbola'].map((m) => ChoiceChip(
                  label: Text(m),
                  selected: _mode == m,
                  onSelected: (s) => setState(() => _mode = m),
                  selectedColor: AppTheme.secondary.withOpacity(0.2),
                )).toList(),
              ),
              const SizedBox(height: 24),
              Text('Equation Parameters', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              ParameterSlider(label: 'Major Axis (a)', value: _a, min: 1, max: 10, onChanged: (v) => setState(() => _a = v)),
              if (_mode != 'Parabola') 
                ParameterSlider(label: 'Minor Axis (b)', value: _b, min: 1, max: 10, onChanged: (v) => setState(() => _b = v)),
            ],
          ),
        ),
      ),
    );
  }
}
