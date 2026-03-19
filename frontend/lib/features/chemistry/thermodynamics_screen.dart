// FIXED: Removed all API calls - now uses local chemistry calculations
// Issue: Was trying to parse HTML responses as JSON (backend not running)
// Fix: All calculations now performed locally in Dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 360.0 : screenWidth * 0.9;
    return MainLayout(
      title: 'Energy Diagram Visualizer',
      child: isWide
          ? Row(children: [_buildChart(), _buildControls(controlWidth)])
          : SingleChildScrollView(
              child: Column(
                  children: [_buildChart(), _buildControls(controlWidth)])),
    );
  }

  Widget _buildChart() {
    final isWide = MediaQuery.of(context).size.width > 900;
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
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: AppTheme.glassCard,
        padding: const EdgeInsets.all(12),
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
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
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
                                        color: Colors.white, fontSize: 11))),
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (v, m) => Text(
                                    v.toStringAsFixed(0),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 9))),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Text('Energy',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11))),
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                getTitlesWidget: (v, m) => Text(
                                    v.toStringAsFixed(0),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 9))),
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
                                FlLine(color: Colors.white12)),
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
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          )
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            _buildLegend(),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(height: 350, child: content);
  }

  Widget _buildLegend() => Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _legendItem(Colors.yellowAccent, 'Activation Energy (Ea)'),
          _legendItem(
              _rxnType == 'exothermic'
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
              _rxnType == 'exothermic'
                  ? 'ΔH (Energy Released)'
                  : 'ΔH (Energy Absorbed)'),
        ],
      );

  Widget _legendItem(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
        ],
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Reaction Type',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 12),
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendItem(Colors.yellowAccent, 'Activation Energy'),
                      const SizedBox(height: 8),
                      _legendItem(
                          _rxnType == 'exothermic'
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          _rxnType == 'exothermic'
                              ? 'ΔH (negative)'
                              : 'ΔH (positive)'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: (_rxnType == 'exothermic'
                              ? Colors.redAccent
                              : Colors.blueAccent)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                              _rxnType == 'exothermic'
                                  ? Icons.local_fire_department
                                  : Icons.ac_unit,
                              color: _rxnType == 'exothermic'
                                  ? Colors.redAccent
                                  : Colors.blueAccent,
                              size: 20),
                          const SizedBox(width: 8),
                          Text(
                              _rxnType == 'exothermic'
                                  ? 'Exothermic Reaction'
                                  : 'Endothermic Reaction',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _rxnType == 'exothermic'
                            ? 'Energy is released to surroundings. Products have lower energy than reactants. Example: Burning, respiration.'
                            : 'Energy is absorbed from surroundings. Products have higher energy than reactants. Example: Photosynthesis, melting ice.',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoBox('Energy Profile',
                    'The graph shows how energy changes during the reaction. The peak represents the activation energy needed to start the reaction.'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String title, String content) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.purpleAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    color: Colors.purpleAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(content,
                style: GoogleFonts.inter(
                    color: Colors.white70, fontSize: 11, height: 1.3)),
          ],
        ),
      );
}
