// FIXED: Removed all API calls - now uses local chemistry calculations
// Issue: Was trying to parse HTML responses as JSON (backend not running)
// Fix: All calculations now performed locally in Dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_service_local.dart';
import 'dart:math' as math;

class SeparationScreen extends StatefulWidget {
  const SeparationScreen({super.key});

  @override
  State<SeparationScreen> createState() => _SeparationScreenState();
}

class _SeparationScreenState extends State<SeparationScreen>
    with SingleTickerProviderStateMixin {
  String _method = 'filtration';
  List<dynamic> _steps = [];
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _anim;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _fetchData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _fetchData() {
    setState(() {
      _isLoading = true;
      _currentStepIndex = 0;
    });
    // FIXED: Using local service instead of API call
    final data = LocalChemistryService.separationProcess(_method);
    if (data['success'] == true) {
      setState(() {
        _steps = data['steps'] as List<dynamic>;
      });
      _animController.forward(from: 0.0);
    }
    setState(() => _isLoading = false);
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() => _currentStepIndex++);
      _animController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Separation Process Simulator',
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls()])
          : SingleChildScrollView(
              child: Column(children: [_buildVisual(), _buildControls()])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_method.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueAccent,
                      letterSpacing: 1)),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => CustomPaint(
                  painter: _SeparationPainter(
                      method: _method,
                      stepIndex: _currentStepIndex,
                      progress: _anim.value),
                  size: Size.infinite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(
            height: math.max(400.0, MediaQuery.of(context).size.height * 0.45),
            child: content);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Method',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _method,
                dropdownColor: AppTheme.surfaceLight,
                style: GoogleFonts.inter(color: Colors.white),
                items: ['filtration', 'evaporation']
                    .map((e) => DropdownMenuItem(
                        value: e, child: Text(e.toUpperCase())))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _method = v);
                    _fetchData();
                  }
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_steps.isNotEmpty) ...[
                Text(
                    'Current Step: ${_currentStepIndex + 1} of ${_steps.length}',
                    style: GoogleFonts.inter(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                    _steps[_currentStepIndex]['desc'] ??
                        'No description available',
                    style:
                        GoogleFonts.inter(color: Colors.white, fontSize: 16)),
                const Spacer(),
                if (_currentStepIndex < _steps.length - 1)
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                    child: const Center(
                        child: Text('Next Step',
                            style: TextStyle(color: Colors.white))),
                  )
                else
                  ElevatedButton(
                    onPressed: _fetchData,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Center(
                        child: Text('Restart',
                            style: TextStyle(color: Colors.white))),
                  )
              ] else if (!_isLoading && _method.isNotEmpty)
                const Center(
                    child: Text('Failed to load steps',
                        style: TextStyle(color: Colors.redAccent)))
            ],
          ),
        ),
      ),
    );
  }
}

class _SeparationPainter extends CustomPainter {
  final String method;
  final int stepIndex;
  final double progress;

  _SeparationPainter(
      {required this.method, required this.stepIndex, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white54;
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueAccent.withValues(alpha: 0.3);
    final solidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.orangeAccent.withValues(alpha: 0.8);

    // Simple Beaker
    final path = Path()
      ..moveTo(center.dx - 60, center.dy - 60)
      ..lineTo(center.dx - 60, center.dy + 80)
      ..arcToPoint(Offset(center.dx + 60, center.dy + 80),
          radius: const Radius.circular(10), clockwise: false)
      ..lineTo(center.dx + 60, center.dy - 60);

    canvas.drawPath(path, paint);

    if (method == 'filtration') {
      if (stepIndex == 0) {
        canvas.drawPath(
            Path()
              ..moveTo(center.dx - 50, center.dy - 120)
              ..lineTo(center.dx + 50, center.dy - 120)
              ..lineTo(center.dx + 10, center.dy - 70)
              ..lineTo(center.dx - 10, center.dy - 70)
              ..close(),
            paint);
        canvas.drawCircle(
            Offset(center.dx, center.dy - 90), 20 * progress, fillPaint);
        canvas.drawCircle(
            Offset(center.dx, center.dy - 90), 10 * progress, solidPaint);
      } else if (stepIndex == 1) {
        canvas.drawPath(
            Path()
              ..moveTo(center.dx - 50, center.dy - 120)
              ..lineTo(center.dx + 50, center.dy - 120)
              ..lineTo(center.dx + 10, center.dy - 70)
              ..lineTo(center.dx - 10, center.dy - 70)
              ..close(),
            paint);
        canvas.drawLine(
            Offset(center.dx, center.dy - 70),
            Offset(center.dx, center.dy + 70),
            Paint()
              ..color = Colors.blueAccent
              ..strokeWidth = 4 * progress);
        canvas.drawRect(
            Rect.fromLTRB(center.dx - 58, center.dy + 80 - (50 * progress),
                center.dx + 58, center.dy + 80),
            fillPaint);
        canvas.drawCircle(Offset(center.dx, center.dy - 90), 10, solidPaint);
      } else {
        canvas.drawPath(
            Path()
              ..moveTo(center.dx - 50, center.dy - 120)
              ..lineTo(center.dx + 50, center.dy - 120)
              ..lineTo(center.dx + 10, center.dy - 70)
              ..lineTo(center.dx - 10, center.dy - 70)
              ..close(),
            paint);
        canvas.drawRect(
            Rect.fromLTRB(
                center.dx - 58, center.dy + 30, center.dx + 58, center.dy + 80),
            fillPaint);
        canvas.drawCircle(Offset(center.dx, center.dy - 90), 10, solidPaint);
      }
    } else {
      if (stepIndex == 0) {
        canvas.drawRect(
            Rect.fromLTRB(
                center.dx - 58, center.dy + 20, center.dx + 58, center.dy + 80),
            fillPaint);
        canvas.drawCircle(Offset(center.dx, center.dy + 60), 5, solidPaint);
        canvas.drawCircle(
            Offset(center.dx - 20, center.dy + 70), 5, solidPaint);
        canvas.drawCircle(
            Offset(center.dx + 20, center.dy + 50), 5, solidPaint);
      } else if (stepIndex == 1) {
        canvas.drawRect(
            Rect.fromLTRB(
                center.dx - 58,
                center.dy + 80 - (60 * (1 - progress)),
                center.dx + 58,
                center.dy + 80),
            fillPaint);
        for (int i = 0; i < 5; i++) {
          canvas.drawCircle(
              Offset(center.dx - 40 + i * 20, center.dy - 50 * progress),
              3,
              fillPaint);
        }
        canvas.drawCircle(Offset(center.dx, center.dy + 60), 5, solidPaint);
        canvas.drawCircle(
            Offset(center.dx - 20, center.dy + 70), 5, solidPaint);
        canvas.drawCircle(
            Offset(center.dx + 20, center.dy + 50), 5, solidPaint);
      } else {
        canvas.drawCircle(Offset(center.dx, center.dy + 60), 5, solidPaint);
        canvas.drawCircle(
            Offset(center.dx - 20, center.dy + 70), 5, solidPaint);
        canvas.drawCircle(
            Offset(center.dx + 20, center.dy + 50), 5, solidPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SeparationPainter oldDelegate) => true;
}
