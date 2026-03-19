// ENHANCED: Added detailed steps for students, more visualization, better explanations

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

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
      _animController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 360.0 : screenWidth * 0.9;
    return MainLayout(
      title: 'Separation Process Simulator',
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls(controlWidth)])
          : SingleChildScrollView(
              child: Column(children: [
              _buildVisual(),
              _buildControls(screenWidth * 0.9)
            ])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 900;
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMethodBadge(),
                  const SizedBox(width: 12),
                  Text(_method.toUpperCase(),
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueAccent)),
                ],
              ),
            ),
            _buildProgressIndicator(),
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
            height: MediaQuery.of(context).size.height * 0.5, child: content);
  }

  Widget _buildMethodBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent)),
        child: Icon(_getMethodIcon(), color: Colors.blueAccent, size: 20),
      );

  IconData _getMethodIcon() {
    switch (_method) {
      case 'filtration':
        return Icons.filter_alt;
      case 'evaporation':
        return Icons.local_fire_department;
      case 'distillation':
        return Icons.water_drop;
      case 'magnetic':
        return Icons.filter_alt;
      default:
        return Icons.science;
    }
  }

  Widget _buildProgressIndicator() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: List.generate(
              _steps.length,
              (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _currentStepIndex
                            ? Colors.blueAccent
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
        ),
      );

  Widget _buildControls(double width) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 12, isWide ? 12 : 8, 12),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose Separation Method',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildMethodSelector(),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_steps.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.blueAccent.withValues(alpha: 0.3))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(14)),
                            child: Center(
                                child: Text('${_currentStepIndex + 1}',
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(width: 12),
                          Text(
                              'Step ${_currentStepIndex + 1} of ${_steps.length}',
                              style: GoogleFonts.inter(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                          _steps[_currentStepIndex]['desc'] ?? 'No description',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14, height: 1.4)),
                      const SizedBox(height: 8),
                      _buildStepExplanation(_currentStepIndex),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildKeyConcept(),
                const Spacer(),
                Row(
                  children: [
                    if (_currentStepIndex > 0)
                      Expanded(
                          child: ElevatedButton(
                              onPressed: _prevStep,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey),
                              child: const Text('Previous',
                                  style: TextStyle(color: Colors.white)))),
                    if (_currentStepIndex > 0) const SizedBox(width: 8),
                    if (_currentStepIndex < _steps.length - 1)
                      Expanded(
                          child: ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent),
                              child: const Text('Next Step',
                                  style: TextStyle(color: Colors.white))))
                    else
                      Expanded(
                          child: ElevatedButton(
                              onPressed: _fetchData,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text('Restart',
                                  style: TextStyle(color: Colors.white)))),
                  ],
                ),
              ] else if (!_isLoading && _method.isNotEmpty)
                const Center(
                    child: Text('Failed to load steps',
                        style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['filtration', 'evaporation', 'distillation', 'magnetic']
            .map((m) => _buildMethodChip(m))
            .toList(),
      );

  Widget _buildMethodChip(String method) => GestureDetector(
        onTap: () {
          setState(() => _method = method);
          _fetchData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _method == method
                ? Colors.blueAccent.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _method == method ? Colors.blueAccent : Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIconForMethod(method),
                  size: 16,
                  color:
                      _method == method ? Colors.blueAccent : Colors.white54),
              const SizedBox(width: 6),
              Text(method[0].toUpperCase() + method.substring(1),
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          _method == method ? Colors.white : Colors.white54)),
            ],
          ),
        ),
      );

  IconData _getIconForMethod(String method) {
    switch (method) {
      case 'filtration':
        return Icons.filter_alt;
      case 'evaporation':
        return Icons.local_fire_department;
      case 'distillation':
        return Icons.water_drop;
      case 'magnetic':
        return Icons.filter_alt;
      default:
        return Icons.science;
    }
  }

  Widget _buildStepExplanation(int stepIndex) {
    final explanations = _getStepExplanations();
    if (stepIndex < explanations.length) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 16),
            const SizedBox(width: 8),
            Expanded(
                child: Text(explanations[stepIndex],
                    style: GoogleFonts.inter(
                        color: Colors.yellowAccent, fontSize: 11))),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  List<String> _getStepExplanations() {
    switch (_method) {
      case 'filtration':
        return [
          'FILTRATION separates insoluble (doesn\'t dissolve) solids from liquids using a filter with tiny pores.',
          'The filter paper has holes small enough to block solid particles but let water through!',
          'The solid left on the filter is called RESIDUE. The liquid that passes through is called FILTRATE.',
        ];
      case 'evaporation':
        return [
          'EVAPORATION separates a solid dissolved in a liquid by heating to remove the liquid as vapor.',
          'Heat energy makes liquid molecules move faster until they escape into the air as gas!',
          'The solid that remains is called the RESIDUE or sometimes CRYSTALS when it forms a nice shape.',
        ];
      case 'distillation':
        return [
          'DISTILLATION separates liquids based on their different BOILING POINTS.',
          'Heating causes the liquid with the lower boiling point to evaporate first.',
          'The vapor is cooled and collected as pure liquid (DISTILLATE).',
        ];
      case 'magnetic':
        return [
          'MAGNETIC separation uses magnets to separate magnetic materials from non-magnetic ones.',
          'Only materials like iron, nickel, and cobalt are attracted to magnets!',
          'This is commonly used to remove metal scraps from recyclables.',
        ];
      default:
        return [];
    }
  }

  Widget _buildKeyConcept() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.purpleAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Concept',
                      style: GoogleFonts.inter(
                          color: Colors.purpleAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  Text(_getKeyConcept(),
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      );

  String _getKeyConcept() {
    switch (_method) {
      case 'filtration':
        return 'Particle size difference - big particles can\'t pass through filter';
      case 'evaporation':
        return 'State change - solid stays when liquid evaporates';
      case 'distillation':
        return 'Boiling point difference - liquids evaporate at different temperatures';
      case 'magnetic':
        return 'Magnetic property - some metals are attracted to magnets';
      default:
        return '';
    }
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
      ..color = Colors.orangeAccent;

    switch (method) {
      case 'filtration':
        _drawFiltration(canvas, size, center, paint, fillPaint, solidPaint);
        break;
      case 'evaporation':
        _drawEvaporation(canvas, size, center, paint, fillPaint, solidPaint);
        break;
      case 'distillation':
        _drawDistillation(canvas, size, center, paint, fillPaint, solidPaint);
        break;
      case 'magnetic':
        _drawMagnetic(canvas, size, center, paint, fillPaint, solidPaint);
        break;
    }
  }

  void _drawFiltration(Canvas canvas, Size size, Offset center, Paint paint,
      Paint fillPaint, Paint solidPaint) {
    // Beaker
    final beakerPath = Path()
      ..moveTo(center.dx - 60, center.dy - 80)
      ..lineTo(center.dx - 60, center.dy + 80)
      ..arcToPoint(Offset(center.dx + 60, center.dy + 80),
          radius: const Radius.circular(10), clockwise: false)
      ..lineTo(center.dx + 60, center.dy - 80);
    canvas.drawPath(beakerPath, paint);

    // Filter funnel
    final funnelPath = Path()
      ..moveTo(center.dx - 50, center.dy - 150)
      ..lineTo(center.dx + 50, center.dy - 150)
      ..lineTo(center.dx + 15, center.dy - 80)
      ..lineTo(center.dx - 15, center.dy - 80)
      ..close();
    canvas.drawPath(funnelPath, paint);

    if (stepIndex == 0) {
      // Pouring mixture
      _drawLabel(canvas, 'Pour mixture',
          Offset(center.dx - 80, center.dy - 100), Colors.blueAccent);
      canvas.drawCircle(
          Offset(center.dx, center.dy - 110), 8 * progress, solidPaint);
      canvas.drawCircle(
          Offset(center.dx - 10, center.dy - 120), 8 * progress, fillPaint);
      canvas.drawCircle(
          Offset(center.dx + 10, center.dy - 115), 6 * progress, solidPaint);
    } else if (stepIndex == 1) {
      // Filtering
      _drawLabel(canvas, 'Filter traps solids',
          Offset(center.dx + 80, center.dy - 100), Colors.orangeAccent);
      _drawLabel(canvas, 'Filtrate passes',
          Offset(center.dx + 80, center.dy + 60), Colors.greenAccent);
      canvas.drawCircle(Offset(center.dx, center.dy - 50), 12, solidPaint);
      canvas.drawCircle(Offset(center.dx + 15, center.dy - 40), 10, solidPaint);
      // Drip
      if (progress > 0.5) {
        canvas.drawCircle(
            Offset(center.dx, center.dy + 40), 5 * progress, fillPaint);
      }
    } else {
      // Result
      _drawLabel(canvas, 'RESIDUE (solid)', Offset(center.dx, center.dy - 110),
          Colors.orangeAccent);
      _drawLabel(canvas, 'FILTRATE (liquid)', Offset(center.dx, center.dy + 60),
          Colors.blueAccent);
      canvas.drawCircle(Offset(center.dx, center.dy - 50), 12, solidPaint);
      canvas.drawCircle(Offset(center.dx, center.dy + 40), 5, fillPaint);
    }
  }

  void _drawEvaporation(Canvas canvas, Size size, Offset center, Paint paint,
      Paint fillPaint, Paint solidPaint) {
    // Beaker
    final beakerPath = Path()
      ..moveTo(center.dx - 60, center.dy - 60)
      ..lineTo(center.dx - 60, center.dy + 80)
      ..arcToPoint(Offset(center.dx + 60, center.dy + 80),
          radius: const Radius.circular(10), clockwise: false)
      ..lineTo(center.dx + 60, center.dy - 60);
    canvas.drawPath(beakerPath, paint);

    // Heat source
    if (stepIndex < 2) {
      canvas.drawRect(
          Rect.fromLTRB(
              center.dx - 40, center.dy + 100, center.dx + 40, center.dy + 120),
          Paint()..color = Colors.redAccent);
      _drawLabel(canvas, 'Heat source', Offset(center.dx, center.dy + 130),
          Colors.redAccent);
    }

    if (stepIndex == 0) {
      // Solution
      _drawLabel(canvas, 'Salt dissolved in water',
          Offset(center.dx, center.dy), Colors.blueAccent);
      canvas.drawRect(
          Rect.fromLTRB(
              center.dx - 55, center.dy + 30, center.dx + 55, center.dy + 80),
          fillPaint);
      canvas.drawCircle(Offset(center.dx - 20, center.dy + 55), 5, solidPaint);
      canvas.drawCircle(Offset(center.dx + 10, center.dy + 60), 5, solidPaint);
      canvas.drawCircle(Offset(center.dx + 25, center.dy + 50), 5, solidPaint);
    } else if (stepIndex == 1) {
      // Evaporating
      _drawLabel(canvas, 'Water evaporating...',
          Offset(center.dx, center.dy - 90), Colors.blueAccent);
      canvas.drawRect(
          Rect.fromLTRB(
              center.dx - 55, center.dy + 50, center.dx + 55, center.dy + 80),
          fillPaint
            ..color = fillPaint.color!.withValues(alpha: 0.1 * (1 - progress)));
      // Steam
      for (int i = 0; i < 5; i++) {
        if (progress > i * 0.2) {
          canvas.drawCircle(
              Offset(center.dx - 40 + i * 20, center.dy - 50 - (20 * progress)),
              4,
              fillPaint);
        }
      }
      canvas.drawCircle(
          Offset(center.dx - 10, center.dy + 65), 6 * progress, solidPaint);
    } else {
      // Crystal left
      _drawLabel(canvas, 'Salt crystals remain!',
          Offset(center.dx, center.dy + 20), Colors.orangeAccent);
      canvas.drawCircle(Offset(center.dx, center.dy + 50), 8, solidPaint);
      canvas.drawCircle(Offset(center.dx - 15, center.dy + 55), 6, solidPaint);
      canvas.drawCircle(Offset(center.dx + 12, center.dy + 58), 5, solidPaint);
    }
  }

  void _drawDistillation(Canvas canvas, Size size, Offset center, Paint paint,
      Paint fillPaint, Paint solidPaint) {
    // Flask
    final flaskPath = Path()
      ..moveTo(center.dx - 50, center.dy + 40)
      ..lineTo(center.dx - 50, center.dy + 80)
      ..arcToPoint(Offset(center.dx + 50, center.dy + 80),
          radius: const Radius.circular(10), clockwise: false)
      ..lineTo(center.dx + 50, center.dy + 40)
      ..arcToPoint(Offset(center.dx - 50, center.dy + 40),
          radius: const Radius.circular(30), clockwise: false);
    canvas.drawPath(flaskPath, paint);

    // Condenser tube
    canvas.drawLine(Offset(center.dx + 50, center.dy),
        Offset(center.dx + 100, center.dy), paint);
    canvas.drawLine(Offset(center.dx + 100, center.dy),
        Offset(center.dx + 100, center.dy + 60), paint);
    canvas.drawLine(Offset(center.dx + 100, center.dy + 60),
        Offset(center.dx + 50, center.dy + 60), paint);

    // Collection flask
    canvas.drawCircle(Offset(center.dx + 75, center.dy + 100), 20, paint);

    if (stepIndex == 0) {
      _drawLabel(canvas, 'Heat mixture', Offset(center.dx, center.dy - 40),
          Colors.redAccent);
      canvas.drawRect(
          Rect.fromLTRB(
              center.dx - 45, center.dy + 50, center.dx + 45, center.dy + 80),
          fillPaint);
    } else if (stepIndex == 1) {
      _drawLabel(canvas, 'Vapor rises', Offset(center.dx + 60, center.dy - 20),
          Colors.blueAccent);
      _drawLabel(canvas, 'Condenser cools it',
          Offset(center.dx + 60, center.dy + 20), Colors.greenAccent);
    } else {
      _drawLabel(canvas, 'Pure liquid collected',
          Offset(center.dx + 75, center.dy + 140), Colors.greenAccent);
      canvas.drawCircle(Offset(center.dx + 75, center.dy + 100), 15, fillPaint);
    }
  }

  void _drawMagnetic(Canvas canvas, Size size, Offset center, Paint paint,
      Paint fillPaint, Paint solidPaint) {
    // Magnet
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(center.dx, center.dy - 60), width: 80, height: 30),
        Paint()..color = Colors.redAccent);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(center.dx, center.dy - 60), width: 40, height: 30),
        Paint()..color = Colors.blueAccent);
    _drawLabel(
        canvas, 'N', Offset(center.dx - 25, center.dy - 65), Colors.white);
    _drawLabel(
        canvas, 'S', Offset(center.dx + 25, center.dy - 65), Colors.white);

    // Mixture container
    final containerPath = Path()
      ..moveTo(center.dx - 50, center.dy - 20)
      ..lineTo(center.dx - 50, center.dy + 60)
      ..arcToPoint(Offset(center.dx + 50, center.dy + 60),
          radius: const Radius.circular(10), clockwise: false)
      ..lineTo(center.dx + 50, center.dy - 20)
      ..close();
    canvas.drawPath(containerPath, paint);

    if (stepIndex == 0) {
      _drawLabel(canvas, 'Iron + Sand mixture',
          Offset(center.dx, center.dy + 20), Colors.grey);
      canvas.drawCircle(
          Offset(center.dx - 20, center.dy + 30), 8, solidPaint); // iron
      canvas.drawCircle(Offset(center.dx + 10, center.dy + 25), 6,
          Paint()..color = Colors.orange); // sand
      canvas.drawCircle(Offset(center.dx, center.dy + 40), 5, solidPaint);
    } else if (stepIndex == 1) {
      _drawLabel(canvas, 'Magnet attracts iron!',
          Offset(center.dx + 80, center.dy - 20), Colors.redAccent);
      // Iron being pulled up
      canvas.drawCircle(Offset(center.dx - 20, center.dy - 10), 8, solidPaint);
      canvas.drawCircle(Offset(center.dx, center.dy - 25), 5, solidPaint);
      canvas.drawCircle(Offset(center.dx + 10, center.dy + 35), 6,
          Paint()..color = Colors.orange); // sand stays
    } else {
      _drawLabel(canvas, 'IRON (magnetic)', Offset(center.dx, center.dy - 90),
          Colors.redAccent);
      _drawLabel(canvas, 'SAND (non-magnetic)',
          Offset(center.dx + 80, center.dy + 30), Colors.orange);
      canvas.drawCircle(Offset(center.dx - 10, center.dy - 85), 8, solidPaint);
      canvas.drawCircle(Offset(center.dx + 10, center.dy + 40), 6,
          Paint()..color = Colors.orange);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: GoogleFonts.inter(
              color: color, fontSize: 10, fontWeight: FontWeight.w500)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
        canvas, Offset(position.dx - textPainter.width / 2, position.dy));
  }

  @override
  bool shouldRepaint(covariant _SeparationPainter oldDelegate) => true;
}
