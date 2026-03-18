import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'coordinate_geometry_painter.dart';

class CoordinateGeometryScreen extends StatefulWidget {
  const CoordinateGeometryScreen({super.key});

  @override
  State<CoordinateGeometryScreen> createState() => _CoordinateGeometryScreenState();
}

class _CoordinateGeometryScreenState extends State<CoordinateGeometryScreen> with SingleTickerProviderStateMixin {
  Offset _p1 = const Offset(-3, 2);
  Offset _p2 = const Offset(4, 5);
  
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeInOutQuad);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _p1 = const Offset(-3, 2);
      _p2 = const Offset(4, 5);
    });
    _animController.reset();
    _animController.forward();
  }

  double get _distance => math.sqrt(math.pow(_p2.dx - _p1.dx, 2) + math.pow(_p2.dy - _p1.dy, 2));
  Offset get _midpoint => (_p1 + _p2) / 2;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return MainLayout(
      title: 'Coordinate Geometry',
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
              child: Text('Points & Distance', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) => CustomPaint(
                    painter: CoordinateGeometryPainter(p1: _p1, p2: _p2, animProgress: _anim.value),
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
              Text('Point A (x1, y1)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.accent)),
              const SizedBox(height: 8),
              ParameterSlider(label: 'x1', value: _p1.dx, min: -10, max: 10, onChanged: (v) => setState(() => _p1 = Offset(v, _p1.dy))),
              ParameterSlider(label: 'y1', value: _p1.dy, min: -10, max: 10, onChanged: (v) => setState(() => _p1 = Offset(_p1.dx, v))),
              const Divider(height: 32),
              Text('Point B (x2, y2)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.secondary)),
              const SizedBox(height: 8),
              ParameterSlider(label: 'x2', value: _p2.dx, min: -10, max: 10, onChanged: (v) => setState(() => _p2 = Offset(v, _p2.dy))),
              ParameterSlider(label: 'y2', value: _p2.dy, min: -10, max: 10, onChanged: (v) => setState(() => _p2 = Offset(_p2.dx, v))),
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
        color: AppTheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _statRow('Distance d = √Δx² + Δy²', _distance.toStringAsFixed(2)),
          _statRow('Midpoint M', '(${_midpoint.dx.toStringAsFixed(1)}, ${_midpoint.dy.toStringAsFixed(1)})'),
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
          Text(val, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
        ],
      ),
    );
  }
}
