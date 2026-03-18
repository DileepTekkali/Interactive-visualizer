// FIXED: Slider updates and value display visibility
// Issue: Slider changes may not trigger UI rebuilds properly
// Fix: Ensured setState is called on slider changes and values are properly displayed

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';

class MotionGraphScreen extends StatefulWidget {
  const MotionGraphScreen({super.key});

  @override
  State<MotionGraphScreen> createState() => _MotionGraphScreenState();
}

class _MotionGraphScreenState extends State<MotionGraphScreen> {
  double _accel = 2.0;
  double _initialV = 0.0;
  double _time = 10.0;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _calculate() {
    final double a = _accel;
    final double u = _initialV;
    final double tMax = _time;

    List<double> timeSteps = [];
    List<double> positionSteps = [];
    List<double> velocitySteps = [];

    for (int i = 0; i <= 50; i++) {
      double t = (i / 50.0) * tMax;
      double s = (u * t) + (0.5 * a * t * t);
      double v = u + (a * t);

      timeSteps.add(t);
      positionSteps.add(s);
      velocitySteps.add(v);
    }

    setState(() {
      _data = {
        'success': true,
        'time': timeSteps,
        'position': positionSteps,
        'velocity': velocitySteps,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Kinematics Motion Graph',
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
                child: Text(
                  'Position & Velocity over Time',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )),
            Expanded(
              child: _data['success'] != true
                  ? Center(
                      child: Text(_data['error'] ?? 'Loading...',
                          style: const TextStyle(color: Colors.white54)))
                  : Padding(
                      padding: const EdgeInsets.all(16), child: _buildChart()),
            ),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(height: 500, child: content);
  }

  Widget _buildChart() {
    final timeList = (_data['time'] as List<dynamic>?)?.cast<num>() ?? [];
    final posList = (_data['position'] as List<dynamic>?)?.cast<num>() ?? [];
    final velList = (_data['velocity'] as List<dynamic>?)?.cast<num>() ?? [];

    if (timeList.isEmpty || posList.isEmpty || velList.isEmpty) {
      return const Center(
          child: Text('Insufficient data points',
              style: TextStyle(color: Colors.white54)));
    }

    // FIXED: Use LineChart from fl_chart with proper axis labels
    return LineChart(LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Time (s)',
                style: TextStyle(color: Colors.white, fontSize: 12)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, m) => Text(v.toInt().toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Value',
                style: TextStyle(color: Colors.white, fontSize: 12)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (v, m) => Text(v.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: Colors.white12)),
        borderData:
            FlBorderData(show: true, border: Border.all(color: Colors.white24)),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(timeList.length,
                (i) => FlSpot(timeList[i].toDouble(), posList[i].toDouble())),
            isCurved: true,
            color: Colors.redAccent,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: List.generate(timeList.length,
                (i) => FlSpot(timeList[i].toDouble(), velList[i].toDouble())),
            isCurved: false,
            color: Colors.blueAccent,
            barWidth: 3,
            dotData: FlDotData(show: false),
          )
        ]));
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
                      // FIXED: Added setState wrapper to ensure UI rebuilds
                      ParameterSlider(
                          label: 'Acceleration (m/s²)',
                          value: _accel,
                          min: -10,
                          max: 10,
                          onChanged: (v) {
                            setState(() => _accel = v);
                            _calculate();
                          }),
                      ParameterSlider(
                          label: 'Initial Velocity (m/s)',
                          value: _initialV,
                          min: -20,
                          max: 20,
                          onChanged: (v) {
                            setState(() => _initialV = v);
                            _calculate();
                          }),
                      ParameterSlider(
                          label: 'Total Time (s)',
                          value: _time,
                          min: 1,
                          max: 20,
                          onChanged: (v) {
                            setState(() => _time = v);
                            _calculate();
                          }),
                      const SizedBox(height: 16),
                      // FIXED: Added visible legend with proper colors
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _legendItem(Colors.redAccent, 'Position (m)'),
                            const SizedBox(height: 8),
                            _legendItem(Colors.blueAccent, 'Velocity (m/s)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // FIXED: Show current calculated values
                      _statRow('Final Position',
                          '${(_data['position'] as List?)?.last?.toStringAsFixed(1) ?? '0'} m'),
                      _statRow('Final Velocity',
                          '${(_data['velocity'] as List?)?.last?.toStringAsFixed(1) ?? '0'} m/s'),
                    ]))));
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 16,
            height: 4,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white70)),
          Text(value,
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
