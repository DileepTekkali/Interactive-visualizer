import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/chemistry_api_service.dart';

class EquilibriumScreen extends StatefulWidget {
  const EquilibriumScreen({super.key});

  @override
  State<EquilibriumScreen> createState() => _EquilibriumScreenState();
}

class _EquilibriumScreenState extends State<EquilibriumScreen>
    with SingleTickerProviderStateMixin {
  double _tempChange = 0;
  Map<String, dynamic>? _result;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1), value: 0.5);
    _calculate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    final data = await ChemistryApiService.equilibriumSimulator(_tempChange);
    setState(() => _result = data);

    if (data['success'] == true) {
      if (data['shift'] == 'Right (Products)') {
        _animController.animateTo(0.8, curve: Curves.easeInOut);
      } else if (data['shift'] == 'Left (Reactants)') {
        _animController.animateTo(0.2, curve: Curves.easeInOut);
      } else {
        _animController.animateTo(0.5, curve: Curves.easeInOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        title: 'Le Chatelier Principle',
        child: Column(children: [
          Expanded(
              child: Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (_, __) => Transform.rotate(
                angle: (_animController.value - 0.5) * 0.5,
                child:
                    Container(width: 300, height: 10, color: Colors.blueAccent),
              ),
            ),
          )),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                  decoration: AppTheme.glassCard,
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Text('Exothermic Reaction: A + B ⇌ C + D + Heat',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 16),
                    ParameterSlider(
                        label: 'Temperature Change (°C)',
                        value: _tempChange,
                        min: -100,
                        max: 100,
                        onChanged: (v) {
                          setState(() => _tempChange = v);
                          _calculate();
                        }),
                    const SizedBox(height: 16),
                    if (_result != null) ...[
                      if (_result?['success'] == true)
                        Text("Shift: \${_result?['shift'] ?? 'None'}",
                            style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 24,
                                fontWeight: FontWeight.bold))
                      else
                        Text(_result?['error'] ?? 'Simulation Error',
                            style: const TextStyle(color: Colors.redAccent))
                    ]
                  ])))
        ]));
  }
}
