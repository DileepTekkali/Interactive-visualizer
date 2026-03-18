import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class HeatTransferScreen extends StatefulWidget {
  const HeatTransferScreen({super.key});

  @override
  State<HeatTransferScreen> createState() => _HeatTransferScreenState();
}

class _HeatTransferScreenState extends State<HeatTransferScreen> {
  String _mode = 'conduction';
  double _deltaT = 50.0;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final double dt = _deltaT;
    final String mode = _mode;
    
    List<double> timeSteps = [];
    List<double> heatCurve = [];
    
    double k = mode == 'conduction' ? 0.5 : mode == 'convection' ? 0.8 : 1.2;
    
    for (int i = 0; i <= 20; i++) {
        double t = i.toDouble();
        double q = k * dt * (1 - math.exp(-t / 10.0));
        timeSteps.add(t);
        heatCurve.add(q);
    }

    if (mounted) {
      setState(() {
        _data = {
          'success': true,
          'heat_curve': heatCurve,
          'time_steps': timeSteps,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Heat Transfer Simulator',
      child: isWide
          ? Row(children: [_buildVisual(), _buildControls()])
          : SingleChildScrollView(child: Column(children: [_buildVisual(), _buildControls()])),
    );
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('${_mode.toUpperCase()} Heat Transfer', style: GoogleFonts.inter(fontSize: 18, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: _data == null || _data?['success'] == false
                  ? const Center(child: CircularProgressIndicator())
                  : _buildFlChart(),
            ),
          ],
        ),
      ),
    );
    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: 400, child: content);
  }

  Widget _buildFlChart() {
    List<dynamic> qList = _data?['heat_curve'] ?? [];
    List<dynamic> tList = _data?['time_steps'] ?? [];
    List<FlSpot> spots = [];
    if (qList.isEmpty || tList.isEmpty) return const Center(child: Text('No data points', style: TextStyle(color: Colors.white54)));

    for (int i = 0; i < math.min(tList.length, qList.length); i++) {
      spots.add(FlSpot((tList[i] as num).toDouble(), (qList[i] as num).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white12), getDrawingVerticalLine: (v) => FlLine(color: Colors.white12)),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(axisNameWidget: const Text('Time', style: TextStyle(color: Colors.white54))),
          leftTitles: AxisTitles(axisNameWidget: const Text('Heat Q', style: TextStyle(color: Colors.white54))),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.redAccent,
            barWidth: 4,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.3)),
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
              Text('Transfer Mode', style: GoogleFonts.inter(color: Colors.white)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _mode,
                dropdownColor: AppTheme.surfaceLight,
                style: const TextStyle(color: Colors.white),
                items: ['conduction', 'convection', 'radiation'].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
                onChanged: (v) { setState(() => _mode = v!); _calculate(); },
              ),
              const SizedBox(height: 24),
              ParameterSlider(label: 'Temp Difference (ΔT °C)', value: _deltaT, min: 10, max: 200, onChanged: (v) { setState(() => _deltaT = v); _calculate(); }),
              const Spacer(),
              if (_data != null && _data?['success'] == true) ...[
                Text('Mechanism:', style: GoogleFonts.inter(color: Colors.white54)),
                Text(
                  _mode == 'conduction' ? 'Heat flows through solid contact' : 
                  _mode == 'convection' ? 'Heat flows via fluid movement' : 'Heat radiates via EM waves',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                if ((_data?['heat_curve'] as List?)?.isNotEmpty == true)
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Final Heat', style: GoogleFonts.inter(color: Colors.white)),
                    Text("${((_data?['heat_curve'] as List).last as num).toStringAsFixed(1)} J", style: GoogleFonts.jetBrainsMono(color: Colors.orangeAccent))
                  ])
              ] else if (_data != null)
                Text(_data?['error'] ?? 'Simulation Error', style: const TextStyle(color: Colors.redAccent))
            ],
          ),
        ),
      ),
    );
  }
}
