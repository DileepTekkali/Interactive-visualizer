// FIXED: Removed all API calls - now uses local chemistry calculations
// Issue: Was trying to parse HTML responses as JSON (backend not running)
// Fix: All calculations now performed locally in Dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import '../../shared/services/chemistry_service_local.dart';

class EquilibriumScreen extends StatefulWidget {
  const EquilibriumScreen({super.key});

  @override
  State<EquilibriumScreen> createState() => _EquilibriumScreenState();
}

class _EquilibriumScreenState extends State<EquilibriumScreen>
    with SingleTickerProviderStateMixin {
  double _tempChange = 0;
  Map<String, dynamic> _result = {};
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

  void _calculate() {
    // FIXED: Using local service instead of API call
    final data = LocalChemistryService.equilibriumSimulator(_tempChange);
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
    final isWide = MediaQuery.of(context).size.width > 800;

    return MainLayout(
        title: 'Le Chatelier Principle',
        child: isWide
            ? Row(children: [_buildVisual(), _buildControls()])
            : SingleChildScrollView(
                child: Column(children: [_buildVisual(), _buildControls()])));
  }

  Widget _buildVisual() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final shift = _result['shift'] ?? 'No Change';
    final stimulus = _result['stimulus'] ?? '';

    return SizedBox(
      width: isWide ? 320 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Equilibrium Balance',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Animated balance indicator
              AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => Transform.rotate(
                  angle: (_animController.value - 0.5) * 0.5,
                  child: Container(
                    width: 300,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_result['success'] == true) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: shift.contains('Right')
                        ? Colors.greenAccent.withValues(alpha: 0.2)
                        : shift.contains('Left')
                            ? Colors.redAccent.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Shift Direction:',
                        style: GoogleFonts.inter(color: Colors.white54),
                      ),
                      Text(
                        shift,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: shift.contains('Right')
                              ? Colors.greenAccent
                              : shift.contains('Left')
                                  ? Colors.redAccent
                                  : Colors.white,
                        ),
                      ),
                      if (stimulus.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          stimulus,
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else if (_result['error'] != null)
                Text(_result['error'] ?? 'Simulation Error',
                    style: const TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exothermic Reaction: A + B ⇌ C + D + Heat',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ParameterSlider(
                label: 'Temperature Change (°C)',
                value: _tempChange,
                min: -100,
                max: 100,
                onChanged: (v) {
                  setState(() => _tempChange = v);
                  _calculate();
                },
              ),
              const SizedBox(height: 24),
              // Explanation box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Le Chatelier\'s Principle:',
                        style: GoogleFonts.inter(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _tempChange < 0
                          ? 'Lower temperature favors exothermic reaction → products'
                          : _tempChange > 0
                              ? 'Higher temperature favors endothermic direction → reactants'
                              : 'No temperature change → equilibrium maintained',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
