// FIXED: Removed all API calls - now uses local chemistry calculations
// Issue: Was trying to parse HTML responses as JSON (backend not running)
// Fix: All calculations now performed locally in Dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_service_local.dart';

class MoleCalculatorScreen extends StatefulWidget {
  const MoleCalculatorScreen({super.key});

  @override
  State<MoleCalculatorScreen> createState() => _MoleCalculatorScreenState();
}

class _MoleCalculatorScreenState extends State<MoleCalculatorScreen> {
  String _mode = 'mass_to_moles';
  final TextEditingController _valController =
      TextEditingController(text: '10.0');
  final TextEditingController _molarController =
      TextEditingController(text: '18.01'); // H2O default

  Map<String, dynamic> _result = {};
  bool _isLoading = false;

  void _calculate() {
    final v = double.tryParse(_valController.text);
    final m = double.tryParse(_molarController.text);
    if (v == null || m == null) {
      setState(() => _result = {'success': false, 'error': 'Invalid input'});
      return;
    }

    setState(() => _isLoading = true);
    // FIXED: Using local service instead of API call
    final data = LocalChemistryService.moleCalculator(v, _mode, m);
    setState(() {
      _result = data;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _valController.dispose();
    _molarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Mole & Mass Calculator',
      child: isWide
          ? Row(children: [_buildForm(), _buildResult()])
          : SingleChildScrollView(
              child: Column(children: [_buildForm(), _buildResult()])),
    );
  }

  Widget _buildForm() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final modeLabels = {
      'mass_to_moles': 'Mass (g) to Moles',
      'moles_to_mass': 'Moles to Mass (g)',
      'moles_to_particles': 'Moles to Particles',
    };
    final unitLabels = {
      'mass_to_moles': 'mol',
      'moles_to_mass': 'g',
      'moles_to_particles': 'particles',
    };

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calculation Mode:',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _mode,
              dropdownColor: AppTheme.surfaceLight,
              style: const TextStyle(color: Colors.white),
              items: modeLabels.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _mode = v);
                  _calculate();
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              _mode == 'mass_to_moles'
                  ? 'Mass (grams):'
                  : _mode == 'moles_to_mass'
                      ? 'Moles:'
                      : 'Moles:',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valController,
              style: const TextStyle(color: Colors.white),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                hintText: 'Enter value',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 24),
            Text('Molar Mass (g/mol):',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _molarController,
              style: const TextStyle(color: Colors.white),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                hintText: 'e.g. 18.01 for H2O',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _calculate,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.orangeAccent),
              child: Text('Calculate',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            // Formula hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Formula:',
                      style: GoogleFonts.inter(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _mode == 'mass_to_moles'
                        ? 'n = m / M'
                        : _mode == 'moles_to_mass'
                            ? 'm = n × M'
                            : 'N = n × NA',
                    style: GoogleFonts.jetBrainsMono(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(child: content);
  }

  Widget _buildResult() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final result = (_result['result'] as num?)?.toDouble() ?? 0.0;
    final unit = _result['unit'] ?? '';

    return SizedBox(
      width: isWide ? 400 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: _result.isEmpty
              ? const Center(
                  child: Text('Enter values and calculate',
                      style: TextStyle(color: Colors.white54)))
              : _result['success'] == false
                  ? Center(
                      child: Text(_result['error'] ?? 'Calculation failed',
                          style: const TextStyle(color: Colors.redAccent)))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Result:',
                            style: GoogleFonts.inter(
                                fontSize: 20, color: Colors.white70)),
                        const SizedBox(height: 20),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            result < 0.001 || result > 1000000
                                ? result.toStringAsExponential(4)
                                : result.toStringAsFixed(6),
                            style: GoogleFonts.jetBrainsMono(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent),
                          ),
                        ),
                        Text(
                          unit,
                          style: GoogleFonts.inter(
                              fontSize: 24, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        // Avogadro info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _mode == 'moles_to_particles'
                                ? 'NA = 6.022 × 10²³ mol⁻¹'
                                : 'Avogadro\'s number = 6.022 × 10²³',
                            style: GoogleFonts.inter(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
