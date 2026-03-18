// FIXED: Removed all API calls - now uses local chemistry calculations
// Issue: Was trying to parse HTML responses as JSON (backend not running)
// Fix: All calculations now performed locally in Dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_service_local.dart';

class ThermodynamicsScreen extends StatefulWidget {
  const ThermodynamicsScreen({super.key});

  @override
  State<ThermodynamicsScreen> createState() => _ThermodynamicsScreenState();
}

class _ThermodynamicsScreenState extends State<ThermodynamicsScreen> {
  String _rxnType = 'exothermic';
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    // FIXED: Using local service instead of API call
    final data = LocalChemistryService.thermodynamicsViz(_rxnType);
    setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Energy Diagram Visualizer',
      child: isWide
          ? Row(children: [_buildChart(), _buildControls()])
          : SingleChildScrollView(
              child: Column(children: [_buildChart(), _buildControls()])),
    );
  }

  Widget _buildChart() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final progress = (_data['progress'] as List<dynamic>?) ?? [];
    final energy = (_data['energy'] as List<dynamic>?) ?? [];

    List<FlSpot> spots = [];
    for (int i = 0; i < math.min(progress.length, energy.length); i++) {
      final p = (progress[i] as num?)?.toDouble();
      final e = (energy[i] as num?)?.toDouble();
      if (p != null && e != null) {
        spots.add(FlSpot(p, e));
      }
    }

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 16,
                    height: 4,
                    color: _rxnType == 'exothermic'
                        ? Colors.redAccent
                        : Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  _rxnType == 'exothermic'
                      ? 'Exothermic Reaction'
                      : 'Endothermic Reaction',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: spots.isEmpty
                  ? const Center(
                      child: Text('Insufficient data',
                          style: TextStyle(color: Colors.white54)))
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 120,
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('Reaction Progress',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (v, m) => Text(
                                  v.toStringAsFixed(0),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10)),
                            ),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text('Energy (kJ)',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (v, m) => Text(
                                  v.toStringAsFixed(0),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10)),
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (v) =>
                              FlLine(color: Colors.white12),
                        ),
                        borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.white24)),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: _rxnType == 'exothermic'
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            barWidth: 4,
                            dotData: FlDotData(show: true),
                          )
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(height: 400, child: content);
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
              Text('Reaction Type',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _rxnType,
                dropdownColor: AppTheme.surfaceLight,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(
                      value: 'exothermic',
                      child: Text('Exothermic (Releases Heat)')),
                  DropdownMenuItem(
                      value: 'endothermic',
                      child: Text('Endothermic (Absorbs Heat)')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _rxnType = v);
                    _fetch();
                  }
                },
              ),
              const SizedBox(height: 24),
              // Energy diagram explanation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                            width: 12, height: 12, color: Colors.yellowAccent),
                        const SizedBox(width: 8),
                        const Text('Activation Energy',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                            width: 12,
                            height: 12,
                            color: _rxnType == 'exothermic'
                                ? Colors.greenAccent
                                : Colors.orangeAccent),
                        const SizedBox(width: 8),
                        Text(
                          _rxnType == 'exothermic'
                              ? 'ΔH (negative)'
                              : 'ΔH (positive)',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _rxnType == 'exothermic'
                    ? 'Energy is released to surroundings. Products have lower energy than reactants.'
                    : 'Energy is absorbed from surroundings. Products have higher energy than reactants.',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
