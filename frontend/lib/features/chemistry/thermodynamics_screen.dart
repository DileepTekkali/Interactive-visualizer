import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_api_service.dart';

class ThermodynamicsScreen extends StatefulWidget {
  const ThermodynamicsScreen({super.key});

  @override
  State<ThermodynamicsScreen> createState() => _ThermodynamicsScreenState();
}

class _ThermodynamicsScreenState extends State<ThermodynamicsScreen> {
  String _rxnType = 'exothermic';
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final data = await ChemistryApiService.thermodynamicsViz(_rxnType);
    if (mounted) setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Energy Diagram Visualizer',
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: _rxnType,
            dropdownColor: AppTheme.surfaceLight,
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'exothermic', child: Text('Exothermic (Releases Heat)')),
              DropdownMenuItem(value: 'endothermic', child: Text('Endothermic (Absorbs Heat)')),
            ],
            onChanged: (v) { setState(() => _rxnType = v!); _fetch(); },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _data == null || _data?['success'] == false
                ? Center(child: _data == null ? const CircularProgressIndicator() : Text(_data?['error'] ?? 'Simulation Error', style: const TextStyle(color: Colors.redAccent)))
                : _buildChart(),
          ),
        )
      ]),
    );
  }

  Widget _buildChart() {
    List<dynamic> pg = _data?['progress'] ?? [];
    List<dynamic> erg = _data?['energy'] ?? [];
    List<FlSpot> spots = [];
    if (pg.isEmpty || erg.isEmpty) return const Center(child: Text('Insufficient thermodynamic data', style: TextStyle(color: Colors.white54)));
    
    for (int i = 0; i < math.min(pg.length, erg.length); i++) {
        spots.add(FlSpot((pg[i] as num).toDouble(), (erg[i] as num).toDouble()));
    }
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 120,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(axisNameWidget: const Text('Reaction Progress', style: TextStyle(color: Colors.white))),
          leftTitles: AxisTitles(axisNameWidget: const Text('Energy (kJ)', style: TextStyle(color: Colors.white))),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white12)),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _rxnType == 'exothermic' ? Colors.redAccent : Colors.blueAccent,
            barWidth: 4,
            dotData: FlDotData(show: false)
          )
        ]
      )
    );
  }
}
