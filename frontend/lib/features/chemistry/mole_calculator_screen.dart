import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_api_service.dart';

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

  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _calculate() async {
    final v = double.tryParse(_valController.text);
    final m = double.tryParse(_molarController.text);
    if (v == null || m == null) return;

    setState(() => _isLoading = true);
    // Note: API service will need moleCalculator added. I'll add it in the next step.
    final data = await ChemistryApiService.moleCalculator(v, _mode, m);
    setState(() {
      _result = data;
      _isLoading = false;
    });
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
              initialValue: _mode,
              dropdownColor: AppTheme.surfaceLight,
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(
                    value: 'mass_to_moles', child: Text('Mass (g) to Moles')),
                DropdownMenuItem(
                    value: 'moles_to_mass', child: Text('Moles to Mass (g)')),
                DropdownMenuItem(
                    value: 'moles_to_particles',
                    child: Text('Moles to Particles')),
              ],
              onChanged: (v) {
                setState(() => _mode = v!);
                _calculate();
              },
            ),
            const SizedBox(height: 24),
            Text('Input Value:',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _valController,
              style: const TextStyle(color: Colors.white),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  filled: true, fillColor: Colors.black26),
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
              decoration: const InputDecoration(
                  filled: true, fillColor: Colors.black26),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _calculate,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.orangeAccent),
              child: const Text('Calculate',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            )
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
    return SizedBox(
      width: isWide ? 400 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: _result == null
              ? const Center(
                  child: Text('Press calculate',
                      style: TextStyle(color: Colors.white54)))
              : _result?['success'] == false
                  ? Center(
                      child: Text(_result?['error'] ?? 'Calculation failed',
                          style: const TextStyle(color: Colors.redAccent)))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Result:',
                            style: GoogleFonts.inter(
                                fontSize: 20, color: Colors.white70)),
                        const SizedBox(height: 20),
                        Text(
                          "${(_result?['result'] as num?)?.toStringAsExponential(3) ?? '0.000e0'}",
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent),
                        ),
                        Text(
                          _result?['unit'] ?? '',
                          style: GoogleFonts.inter(
                              fontSize: 24, color: Colors.white),
                        )
                      ],
                    ),
        ),
      ),
    );
  }
}
