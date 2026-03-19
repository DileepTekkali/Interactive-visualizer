import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';

class CircuitSimulatorScreen extends StatefulWidget {
  const CircuitSimulatorScreen({super.key});

  @override
  State<CircuitSimulatorScreen> createState() => _CircuitSimulatorScreenState();
}

class _CircuitSimulatorScreenState extends State<CircuitSimulatorScreen> {
  double _voltage = 12.0;
  List<double> _resistors = [10.0, 20.0];
  bool _isSeries = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double req = 0;
    if (_isSeries) {
      req = _resistors.fold(0, (sum, r) => sum + r);
    } else {
      double invSum = _resistors.fold(0, (sum, r) => sum + (1 / r));
      req = (invSum == 0) ? 0 : 1 / invSum;
    }

    double current = _voltage / (req == 0 ? 1 : req);
    double power = _voltage * current;

    if (mounted) {
      setState(() {
        _data = {
          'success': true,
          'equivalent_resistance': req,
          'total_current': current,
          'total_power': power,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 320.0 : screenWidth * 0.9;
    return MainLayout(
      title: "Ohm's Law & Circuits",
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
                child: Text(
                    'Circuit Builder (${_isSeries ? "Series" : "Parallel"})',
                    style: GoogleFonts.inter(
                        fontSize: 16, color: Colors.blueAccent))),
            Expanded(
              child: _data == null || _data?['success'] == false
                  ? Center(
                      child: Text(_data?['error'] ?? 'Loading...',
                          style: const TextStyle(color: Colors.redAccent)))
                  : CustomPaint(
                      painter: _CircuitPainter(
                          isSeries: _isSeries,
                          rCount: _resistors.length,
                          totalP: (_data?['total_power'] as num?)?.toDouble() ??
                              0.0),
                      size: Size.infinite,
                    ),
            ),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(height: 350, child: content);
  }

  Widget _buildControls(double width) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return SizedBox(
        width: width,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 12, isWide ? 12 : 8, 12),
            child: Container(
                decoration: AppTheme.glassCard,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Circuit Type',
                                  style: GoogleFonts.inter(
                                      color: Colors.white, fontSize: 14)),
                              Switch(
                                  value: _isSeries,
                                  onChanged: (v) {
                                    setState(() => _isSeries = v);
                                    _calculate();
                                  },
                                  activeColor: Colors.orangeAccent)
                            ]),
                        Text(_isSeries ? "Series Mode" : "Parallel Mode",
                            style: GoogleFonts.inter(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 12),
                        ParameterSlider(
                            label: 'Voltage (V)',
                            value: _voltage,
                            min: 1,
                            max: 220,
                            onChanged: (v) {
                              setState(() => _voltage = v);
                              _calculate();
                            }),
                        const SizedBox(height: 12),
                        Text('Resistors (Ω)',
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 8),
                        ...List.generate(
                            _resistors.length,
                            (i) => Row(children: [
                                  Expanded(
                                      child: ParameterSlider(
                                          label: 'R${i + 1}',
                                          value: _resistors[i],
                                          min: 1,
                                          max: 100,
                                          onChanged: (v) {
                                            setState(() => _resistors[i] = v);
                                            _calculate();
                                          })),
                                  IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        if (_resistors.length > 1) {
                                          setState(
                                              () => _resistors.removeAt(i));
                                          _calculate();
                                        }
                                      })
                                ])),
                        if (_resistors.length < 5)
                          TextButton.icon(
                              onPressed: () {
                                setState(() => _resistors.add(10.0));
                                _calculate();
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Resistor',
                                  style: TextStyle(fontSize: 12))),
                        const SizedBox(height: 16),
                        if (_data != null && _data?['success'] == true) ...[
                          _stat('Eq. Resistance',
                              "${(_data?['equivalent_resistance'] as num?)?.toDouble() ?? 0.0} Ω"),
                          _stat('Total Current',
                              "${(_data?['total_current'] as num?)?.toDouble() ?? 0.0} A"),
                          _stat('Total Power',
                              "${(_data?['total_power'] as num?)?.toDouble() ?? 0.0} W"),
                        ] else if (_data != null)
                          Text(_data?['error'] ?? 'Simulation Error',
                              style: const TextStyle(color: Colors.redAccent))
                      ]),
                ))));
  }

  Widget _stat(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: GoogleFonts.inter(color: Colors.white)),
        Text(v, style: GoogleFonts.jetBrainsMono(color: Colors.orangeAccent))
      ]));
}

class _CircuitPainter extends CustomPainter {
  final bool isSeries;
  final int rCount;
  final double? totalP;

  _CircuitPainter({required this.isSeries, required this.rCount, this.totalP});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final wirePaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Simple visual
    double w = 200;
    double h = 150;
    final rect = Rect.fromCenter(center: center, width: w, height: h);

    if (isSeries) {
      canvas.drawRect(rect, wirePaint);

      // Battery
      _drawBattery(canvas, Offset(center.dx - w / 2, center.dy));

      // Resistors on top wire
      double spacing = w / (rCount + 1);
      for (int i = 1; i <= rCount; i++) {
        _drawResistor(canvas,
            Offset((center.dx - w / 2) + spacing * i, center.dy - h / 2), true);
      }
    } else {
      // Parallel
      canvas.drawRect(rect, wirePaint);
      _drawBattery(canvas, Offset(center.dx - w / 2, center.dy));

      // Vertical branches
      double spacing = w / (rCount);
      for (int i = 1; i <= rCount; i++) {
        double x = (center.dx - w / 2) + spacing * i;
        canvas.drawLine(Offset(x, center.dy - h / 2),
            Offset(x, center.dy + h / 2), wirePaint);
        _drawResistor(canvas, Offset(x, center.dy), false);
      }
    }

    // "Light / power" effect
    final tp = totalP;
    if (tp != null && tp > 0) {
      canvas.drawCircle(
          Offset(center.dx + w / 2 + 30, center.dy),
          10 + (tp / 10).clamp(0, 30).toDouble(),
          Paint()
            ..color = Colors.yellowAccent.withOpacity(0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }
  }

  void _drawBattery(Canvas canvas, Offset pos) {
    canvas.drawRect(Rect.fromCenter(center: pos, width: 20, height: 40),
        Paint()..color = Colors.black);
    canvas.drawLine(
        Offset(pos.dx - 10, pos.dy - 10),
        Offset(pos.dx + 10, pos.dy - 10),
        Paint()
          ..color = Colors.greenAccent
          ..strokeWidth = 4);
    canvas.drawLine(
        Offset(pos.dx - 5, pos.dy + 10),
        Offset(pos.dx + 5, pos.dy + 10),
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 4);
  }

  void _drawResistor(Canvas canvas, Offset pos, bool horizontal) {
    canvas.drawRect(
        Rect.fromCenter(
            center: pos,
            width: horizontal ? 30 : 10,
            height: horizontal ? 10 : 30),
        Paint()..color = Colors.orangeAccent);
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) => true;
}
