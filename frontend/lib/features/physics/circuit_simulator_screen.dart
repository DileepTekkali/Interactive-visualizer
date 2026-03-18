import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/physics_api_service.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    final data = await PhysicsApiService.circuitSimulator(_resistors, _voltage, _isSeries);
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: "Ohm's Law & Circuits",
      child: isWide ? Row(children: [_buildVisual(), _buildControls()]) : SingleChildScrollView(child: Column(children: [_buildVisual(), _buildControls()])),
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
            Padding(padding: const EdgeInsets.all(16), child: Text('Circuit Builder (\${_isSeries ? "Series" : "Parallel"})', style: GoogleFonts.inter(fontSize: 18, color: Colors.blueAccent))),
            Expanded(
              child: _isLoading || _data == null || _data?['success'] == false
                  ? Center(child: _isLoading ? const CircularProgressIndicator() : Text(_data?['error'] ?? 'Data unavailable', style: const TextStyle(color: Colors.redAccent)))
                  : CustomPaint(
                      painter: _CircuitPainter(isSeries: _isSeries, rCount: _resistors.length, totalP: (_data?['total_power'] as num?)?.toDouble()),
                      size: Size.infinite,
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
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text('Circuit Type', style: GoogleFonts.inter(color: Colors.white)),
                     Switch(value: _isSeries, onChanged: (v){ setState(()=>_isSeries=v); _fetch(); }, activeColor: Colors.orangeAccent)
                   ]
                 ),
                 Text(_isSeries ? "Series Mode" : "Parallel Mode", style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                 const SizedBox(height: 16),
                 ParameterSlider(label: 'Voltage (V)', value: _voltage, min: 1, max: 220, onChanged: (v){ setState(()=>_voltage=v); _fetch(); }),
                 const SizedBox(height: 16),
                 Text('Resistors (Ω)', style: GoogleFonts.inter(color: Colors.white)),
                 ...List.generate(_resistors.length, (i) => Row(
                   children: [
                     Expanded(child: ParameterSlider(label: 'R\${i+1}', value: _resistors[i], min: 1, max: 100, onChanged: (v){ setState(()=>_resistors[i]=v); _fetch(); })),
                     IconButton(icon: const Icon(Icons.remove_circle, color: Colors.redAccent), onPressed: () {
                       if (_resistors.length > 1) { setState(()=>_resistors.removeAt(i)); _fetch(); }
                     })
                   ]
                 )),
                 if (_resistors.length < 5)
                   TextButton.icon(onPressed: (){ setState(()=>_resistors.add(10.0)); _fetch(); }, icon: const Icon(Icons.add), label: const Text('Add Resistor')),
                 const SizedBox(height: 24),
                  if (_data != null && _data?['success'] == true) ...[
                    _stat('Eq. Resistance', "${(_data?['equivalent_resistance'] as num?)?.toDouble() ?? 0.0} Ω"),
                    _stat('Total Current', "${(_data?['total_current'] as num?)?.toDouble() ?? 0.0} A"),
                    _stat('Total Power', "${(_data?['total_power'] as num?)?.toDouble() ?? 0.0} W"),
                  ] else if (_data != null)
                    Text(_data?['error'] ?? 'Simulation Error', style: const TextStyle(color: Colors.redAccent))
              ]
            ),
          )
        )
      )
    );
  }

  Widget _stat(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: GoogleFonts.inter(color: Colors.white)), Text(v, style: GoogleFonts.jetBrainsMono(color: Colors.orangeAccent))])
  );
}

class _CircuitPainter extends CustomPainter {
  final bool isSeries;
  final int rCount;
  final double? totalP;

  _CircuitPainter({required this.isSeries, required this.rCount, this.totalP});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final wirePaint = Paint()..color=Colors.white54..strokeWidth=3..style=PaintingStyle.stroke;
    
    // Simple visual
    double w = 200;
    double h = 150;
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    
    if (isSeries) {
      canvas.drawRect(rect, wirePaint);
      
      // Battery
      _drawBattery(canvas, Offset(center.dx - w/2, center.dy));
      
      // Resistors on top wire
      double spacing = w / (rCount + 1);
      for(int i=1; i<=rCount; i++) {
        _drawResistor(canvas, Offset((center.dx - w/2) + spacing*i, center.dy - h/2), true);
      }
    } else {
      // Parallel
      canvas.drawRect(rect, wirePaint);
      _drawBattery(canvas, Offset(center.dx - w/2, center.dy));
      
      // Vertical branches
      double spacing = w / (rCount);
      for(int i=1; i<=rCount; i++) {
        double x = (center.dx - w/2) + spacing*i;
        canvas.drawLine(Offset(x, center.dy - h/2), Offset(x, center.dy + h/2), wirePaint);
        _drawResistor(canvas, Offset(x, center.dy), false);
      }
    }

    // "Light / power" effect
    if (totalP != null && totalP > 0) {
      canvas.drawCircle(Offset(center.dx + w/2 + 30, center.dy), 10 + (totalP / 10).clamp(0, 30).toDouble(), Paint()..color=Colors.yellowAccent.withOpacity(0.5)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 10));
    }
  }

  void _drawBattery(Canvas canvas, Offset pos) {
    canvas.drawRect(Rect.fromCenter(center: pos, width: 20, height: 40), Paint()..color=Colors.black);
    canvas.drawLine(Offset(pos.dx-10, pos.dy-10), Offset(pos.dx+10, pos.dy-10), Paint()..color=Colors.greenAccent..strokeWidth=4);
    canvas.drawLine(Offset(pos.dx-5, pos.dy+10), Offset(pos.dx+5, pos.dy+10), Paint()..color=Colors.redAccent..strokeWidth=4);
  }

  void _drawResistor(Canvas canvas, Offset pos, bool horizontal) {
    canvas.drawRect(Rect.fromCenter(center: pos, width: horizontal ? 30 : 10, height: horizontal ? 10 : 30), Paint()..color=Colors.orangeAccent);
  }

  @override bool shouldRepaint(covariant _CircuitPainter oldDelegate) => true;
}
