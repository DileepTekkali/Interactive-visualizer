import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/chemistry_api_service.dart';
import 'dart:math' as math;

class KineticsScreen extends StatefulWidget {
  const KineticsScreen({super.key});

  @override
  State<KineticsScreen> createState() => _KineticsScreenState();
}

class _KineticsScreenState extends State<KineticsScreen> {
  double _c0 = 1.0;
  double _k = 0.1;
  int _order = 1;
  Map<String, dynamic>? _data;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    final data = await ChemistryApiService.kineticsGraph(_c0, _k, _order);
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Reaction Kinetics Simulator',
      child: isWide
          ? Row(children: [_buildChart(), _buildControls()])
          : SingleChildScrollView(
              child: Column(children: [_buildChart(), _buildControls()])),
    );
  }

  Widget _buildChart() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Concentration vs Time',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading || _data == null || _data?['success'] == false
                  ? const Center(child: CircularProgressIndicator())
                  : _buildFlChart(),
            ),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(height: 400, child: content);
  }

  Widget _buildFlChart() {
    List<dynamic> timeList = _data?['time'] ?? [];
    List<dynamic> cList = _data?['concentration'] ?? [];
    List<FlSpot> spots = [];
    if (timeList.isEmpty || cList.isEmpty)
      return const Center(
          child: Text('Insufficient kinetics data',
              style: TextStyle(color: Colors.white54)));

    for (int i = 0; i < math.min(timeList.length, cList.length); i++) {
      spots.add(FlSpot(
          (timeList[i] as num).toDouble(), (cList[i] as num).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: Colors.white12, strokeWidth: 1),
            getDrawingVerticalLine: (v) =>
                FlLine(color: Colors.white12, strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, m) => Text(v.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 10)))),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, m) => Text(v.toStringAsFixed(0),
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 10)))),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData:
            FlBorderData(show: true, border: Border.all(color: Colors.white24)),
        minX: 0,
        maxX: 50,
        minY: 0,
        maxY: math.max(_c0 * 1.2, 1.2),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orangeAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
                show: true, color: Colors.orangeAccent.withValues(alpha: 0.2)),
          ),
        ],
      ),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order of Reaction',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _order,
                  dropdownColor: AppTheme.surfaceLight,
                  style: const TextStyle(color: Colors.white),
                  items: [0, 1, 2]
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                              '\$e\${e == 0 ? " (Zero)" : e == 1 ? " (First)" : " (Second)"}')))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _order = v!);
                    _fetch();
                  },
                ),
                const SizedBox(height: 24),
                ParameterSlider(
                    label: 'Initial Concentration [A]₀',
                    value: _c0,
                    min: 0.1,
                    max: 5.0,
                    onChanged: (v) {
                      setState(() => _c0 = v);
                      _fetch();
                    }),
                ParameterSlider(
                    label: 'Rate Constant (k)',
                    value: _k,
                    min: 0.01,
                    max: 0.5,
                    onChanged: (v) {
                      setState(() => _k = v);
                      _fetch();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
