import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/physics_api_service.dart';

class MotionGraphScreen extends StatefulWidget {
  const MotionGraphScreen({super.key});

  @override
  State<MotionGraphScreen> createState() => _MotionGraphScreenState();
}

class _MotionGraphScreenState extends State<MotionGraphScreen> {
  double _accel = 2.0;
  double _initialV = 0.0;
  double _time = 10.0;
  Map<String, dynamic>? _data;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    final data = await PhysicsApiService.motionGraph(_accel, _initialV, _time);
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Kinematics Motion Graph',
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
            Padding(padding: const EdgeInsets.all(16), child: Text('Position & Velocity over Time', style: GoogleFonts.inter(fontSize: 18, color: Colors.blueAccent))),
            Expanded(
              child: _isLoading || _data == null || _data?['success'] == false
                  ? Center(child: _isLoading ? const CircularProgressIndicator() : Text(_data?['error'] ?? 'Data unavailable', style: const TextStyle(color: Colors.redAccent)))
                  : Padding(padding: const EdgeInsets.all(32), child: _buildChart()),
            ),
          ],
        ),
      ),
    );
    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: 500, child: content);
  }

  Widget _buildChart() {
    List<dynamic> pg = _data?['position'] ?? [];
    List<dynamic> vg = _data?['velocity'] ?? [];
    List<dynamic> t = _data?['time'] ?? [];
    List<FlSpot> posSpots = [];
    List<FlSpot> velSpots = [];
    
    if (pg.isEmpty || vg.isEmpty || t.isEmpty) return const Center(child: Text('Insufficient data points', style: TextStyle(color: Colors.white54)));
        posSpots.add(FlSpot((t[i] as num).toDouble(), (pg[i] as num).toDouble()));
        velSpots.add(FlSpot((t[i] as num).toDouble(), (vg[i] as num).toDouble()));
    }
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(axisNameWidget: const Text('Time (s)', style: TextStyle(color: Colors.white))),
          leftTitles: AxisTitles(axisNameWidget: const Text('Magnitude', style: TextStyle(color: Colors.white)), sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white12)),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
        lineBarsData: [
          LineChartBarData(
            spots: posSpots,
            isCurved: true,
            color: Colors.redAccent,
            barWidth: 3,
            dotData: FlDotData(show: false)
          ),
          LineChartBarData(
            spots: velSpots,
            isCurved: false,
            color: Colors.blueAccent,
            barWidth: 3,
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
               ParameterSlider(label: 'Acceleration (m/s²)', value: _accel, min: -10, max: 10, onChanged: (v){ setState(()=>_accel=v); _fetch(); }),
               ParameterSlider(label: 'Init Velocity (m/s)', value: _initialV, min: -20, max: 20, onChanged: (v){ setState(()=>_initialV=v); _fetch(); }),
               ParameterSlider(label: 'Total Time (s)', value: _time, min: 1, max: 20, onChanged: (v){ setState(()=>_time=v); _fetch(); }),
               const Spacer(),
               Row(children: [Container(width: 12, height:12, color: Colors.redAccent), const SizedBox(width: 8), Text('Position (m)', style: TextStyle(color: Colors.white))]),
               const SizedBox(height: 8),
               Row(children: [Container(width: 12, height:12, color: Colors.blueAccent), const SizedBox(width: 8), Text('Velocity (m/s)', style: TextStyle(color: Colors.white))]),
            ]
          )
        )
      )
    );
  }
}
