// FIXED: Removed all API calls - now uses local chemistry calculations
// Issue: Was trying to parse HTML responses as JSON (backend not running)
// Fix: All calculations now performed locally in Dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_service_local.dart';

class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  State<PeriodicTableScreen> createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen> {
  final List<String> _commonElements = [
    'H',
    'He',
    'Li',
    'Be',
    'B',
    'C',
    'N',
    'O',
    'F',
    'Ne',
    'Na',
    'Mg',
    'Al',
    'Si',
    'P',
    'S',
    'Cl',
    'Ar',
    'K',
    'Ca'
  ];

  Map<String, dynamic> _selectedData = {};
  bool _isLoading = false;

  void _fetchElement(String symbol) {
    setState(() => _isLoading = true);
    // FIXED: Using local service instead of API call
    final data = LocalChemistryService.getAtomData(symbol);
    setState(() {
      _selectedData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchElement('H');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Periodic Table Explorer',
      child: isWide
          ? Row(children: [_buildGrid(), _buildDetails()])
          : SingleChildScrollView(
              child: Column(children: [_buildGrid(), _buildDetails()])),
    );
  }

  Widget _buildGrid() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final selectedSymbol = _selectedData['symbol'] ?? '';

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonElements
              .map((e) => GestureDetector(
                    onTap: () => _fetchElement(e),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          color: selectedSymbol == e
                              ? Colors.orangeAccent.withValues(alpha: 0.5)
                              : Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedSymbol == e
                                ? Colors.orangeAccent
                                : Colors.white24,
                            width: selectedSymbol == e ? 2 : 1,
                          )),
                      child: Center(
                          child: Text(e,
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(child: content);
  }

  Widget _buildDetails() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final symbol = _selectedData['symbol'] ?? '';
    final name = _selectedData['name'] ?? '';
    final atomicNumber = _selectedData['atomic_number'] ?? 'N/A';
    final valency = _selectedData['valency'] ?? 'N/A';
    final shells = _selectedData['shells'] ?? [];

    return SizedBox(
      width: isWide ? 320 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _selectedData.isEmpty
                  ? const Center(
                      child: Text('Select an element',
                          style: TextStyle(color: Colors.white)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedData['success'] == true) ...[
                          Center(
                              child: Text(symbol,
                                  style: GoogleFonts.jetBrainsMono(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent))),
                          Center(
                              child: Text(name,
                                  style: GoogleFonts.inter(
                                      fontSize: 24, color: Colors.white))),
                          const SizedBox(height: 32),
                          _detailRow('Atomic Number', '$atomicNumber'),
                          _detailRow('Valency', '$valency'),
                          _detailRow('Shells', '${shells.join(', ')}'),
                        ] else
                          Center(
                              child: Text(
                                  _selectedData['error'] ??
                                      'Element data unavailable',
                                  style:
                                      const TextStyle(color: Colors.redAccent)))
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 16)),
          Text(value,
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }
}
