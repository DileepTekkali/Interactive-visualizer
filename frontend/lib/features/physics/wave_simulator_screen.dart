import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';

class WaveSimulatorScreen extends StatefulWidget {
  const WaveSimulatorScreen({super.key});

  @override
  State<WaveSimulatorScreen> createState() => _WaveSimulatorScreenState();
}

class _WaveSimulatorScreenState extends State<WaveSimulatorScreen> with SingleTickerProviderStateMixin {
  double _amplitude = 1.0;
  double _frequency = 2.0;
  double _phase = 0.0;
  Map<String, dynamic>? _data;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _animController.addListener(() {
      if (mounted) {
        setState(() {
          _phase = (_animController.value * 2 * math.pi);
          _calculateWave();
        });
      }
    });
  }

  void _calculateWave() {
    const int points = 100;
    List<double> xData = [];
    List<double> yData = [];
    
    for (int i = 0; i < points; i++) {
        double x = i * 0.2;
        xData.add(x);
        yData.add(_amplitude * math.sin(x - _phase * _frequency));
    }

    _data = {
      'success': true,
      'x': xData,
      'y': yData,
    };
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Removed API fetch. All calculations are local.

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Transverse Wave Simulator',
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
            Padding(padding: const EdgeInsets.all(16), child: Text('y(x,t) = A*sin(kx - ωt + φ)', style: GoogleFonts.inter(fontSize: 18, color: Colors.blueAccent))),
            Expanded(
              child: _data == null || _data?['success'] == false
                  ? Center(child: Text(_data?['error'] ?? 'Loading...', style: TextStyle(color: _data == null ? Colors.white54 : Colors.redAccent)))
                  : Padding(padding: const EdgeInsets.all(20), child: _buildChart()),
            ),
          ],
        ),
      ),
    );
    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: 400, child: content);
  }

  Widget _buildChart() {
    List<dynamic> x = _data?['x'] ?? [];
    List<dynamic> y = _data?['y'] ?? [];
    List<FlSpot> spots = [];
    
    if (x.isEmpty || y.isEmpty) return const Center(child: Text('Insufficient wave data', style: TextStyle(color: Colors.white54)));
    
    for (int i = 0; i < math.min(x.length, y.length); i++) {
        spots.add(FlSpot((x[i] as num?)?.toDouble() ?? 0.0, (y[i] as num?)?.toDouble() ?? 0.0));
    }
    return LineChart(
      LineChartData(
        minY: -5,
        maxY: 5,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(axisNameWidget: const Text('Position (x)', style: TextStyle(color: Colors.white))),
          leftTitles: AxisTitles(axisNameWidget: const Text('Displacement', style: TextStyle(color: Colors.white)), sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white12)),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.cyanAccent,
            barWidth: 4,
            dotData: FlDotData(show: false)
          )
        ]
      )
    );
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
               ParameterSlider(label: 'Amplitude (A)', value: _amplitude, min: 0.1, max: 4.0, onChanged: (v){ setState(()=>_amplitude=v); }),
               ParameterSlider(label: 'Frequency (f)', value: _frequency, min: 0.5, max: 5.0, onChanged: (v){ setState(()=>_frequency=v); }),
               const Spacer(),
               Icon(Icons.waves, size: 64, color: Colors.cyanAccent.withOpacity(0.5)),
               const SizedBox(height: 16),
               Text('Wave speed (v) = f * λ', style: GoogleFonts.inter(color: Colors.white54))
            ]
          )
        )
      )
    );
  }
}
