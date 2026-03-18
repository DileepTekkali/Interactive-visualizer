import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';

class EnergySimulatorScreen extends StatefulWidget {
  const EnergySimulatorScreen({super.key});

  @override
  State<EnergySimulatorScreen> createState() => _EnergySimulatorScreenState();
}

class _EnergySimulatorScreenState extends State<EnergySimulatorScreen> {
  double _mass = 10.0;
  double _height = 50.0;
  double _velocity = 10.0;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    const double g = 9.81;
    final pe = _mass * g * _height;
    final ke = 0.5 * _mass * _velocity * _velocity;
    final te = pe + ke;

    if (mounted) {
      setState(() {
        _data = {
          'success': true,
          'potential_energy': pe,
          'kinetic_energy': ke,
          'total_energy': te,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Work & Energy Simulator',
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
            Padding(padding: const EdgeInsets.all(16), child: Text('Conservation of Energy', style: GoogleFonts.inter(fontSize: 18, color: Colors.blueAccent))),
            Expanded(
              child: _data == null || _data?['success'] == false
                  ? Center(child: _data == null ? const CircularProgressIndicator() : Text(_data?['error'] ?? 'Error', style: const TextStyle(color: Colors.redAccent)))
                  : _buildBarCharts(),
            ),
          ],
        ),
      ),
    );
    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: 400, child: content);
  }

  Widget _buildBarCharts() {
    final pe = (_data?['potential_energy'] as num?)?.toDouble() ?? 0.0;
    final ke = (_data?['kinetic_energy'] as num?)?.toDouble() ?? 0.0;
    final te = (_data?['total_energy'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
           _bar('Potential', pe, te, Colors.blueAccent),
           _bar('Kinetic', ke, te, Colors.redAccent),
           _bar('Total', te, te, Colors.orangeAccent),
        ],
      )
    );
  }

  Widget _bar(String label, double val, double maxVal, Color c) {
    if (maxVal == 0) maxVal = 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${val.toInt()} J', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 200 * (val / maxVal).clamp(0.0, 1.0),
          decoration: BoxDecoration(color: c, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
      ]
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
               ParameterSlider(label: 'Mass (kg)', value: _mass, min: 1, max: 100, onChanged: (v){ setState(()=>_mass=v); _calculate(); }),
               ParameterSlider(label: 'Height (m)', value: _height, min: 0, max: 200, onChanged: (v){ setState(()=>_height=v); _calculate(); }),
               ParameterSlider(label: 'Velocity (m/s)', value: _velocity, min: 0, max: 100, onChanged: (v){ setState(()=>_velocity=v); _calculate(); }),
               const Spacer(),
               Text('Equations', style: GoogleFonts.inter(color: Colors.white54)),
               const SizedBox(height: 8),
               Text('PE = mgh', style: GoogleFonts.jetBrainsMono(color: Colors.blueAccent)),
               Text('KE = ½mv²', style: GoogleFonts.jetBrainsMono(color: Colors.redAccent)),
               Text('Total = PE + KE', style: GoogleFonts.jetBrainsMono(color: Colors.orangeAccent)),
            ]
          )
        )
      )
    );
  }
}
