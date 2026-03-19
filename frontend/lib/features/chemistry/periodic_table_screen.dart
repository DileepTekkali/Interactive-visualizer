// ENHANCED: Full periodic table with all elements and detailed information on click

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
  Map<String, dynamic> _selectedData = {};
  String _selectedSymbol = '';

  final Map<String, Color> _categoryColors = {
    'alkali_metal': Colors.redAccent,
    'alkaline_earth': Colors.orangeAccent,
    'transition_metal': Colors.yellowAccent,
    'post_transition': Colors.greenAccent,
    'metalloid': Colors.tealAccent,
    'nonmetal': Colors.blueAccent,
    'halogen': Colors.indigoAccent,
    'noble_gas': Colors.purpleAccent,
    'lanthanide': Colors.pinkAccent,
    'actinide': Colors.deepOrangeAccent,
  };

  final List<List<String?>> _periodicTable = [
    [
      'H',
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      'He'
    ],
    [
      'Li',
      'Be',
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      'B',
      'C',
      'N',
      'O',
      'F',
      'Ne'
    ],
    [
      'Na',
      'Mg',
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      'Al',
      'Si',
      'P',
      'S',
      'Cl',
      'Ar'
    ],
    [
      'K',
      'Ca',
      'Sc',
      'Ti',
      'V',
      'Cr',
      'Mn',
      'Fe',
      'Co',
      'Ni',
      'Cu',
      'Zn',
      'Ga',
      'Ge',
      'As',
      'Se',
      'Br',
      'Kr'
    ],
    [
      'Rb',
      'Sr',
      'Y',
      'Zr',
      'Nb',
      'Mo',
      'Tc',
      'Ru',
      'Rh',
      'Pd',
      'Ag',
      'Cd',
      'In',
      'Sn',
      'Sb',
      'Te',
      'I',
      'Xe'
    ],
    [
      'Cs',
      'Ba',
      null,
      'Hf',
      'Ta',
      'W',
      'Re',
      'Os',
      'Ir',
      'Pt',
      'Au',
      'Hg',
      'Tl',
      'Pb',
      'Bi',
      'Po',
      'At',
      'Rn'
    ],
    [
      'Fr',
      'Ra',
      null,
      'Rf',
      'Db',
      'Sg',
      'Bh',
      'Hs',
      'Mt',
      'Ds',
      'Rg',
      'Cn',
      'Nh',
      'Fl',
      'Mc',
      'Lv',
      'Ts',
      'Og'
    ],
    [
      null,
      null,
      'La',
      'Ce',
      'Pr',
      'Nd',
      'Pm',
      'Sm',
      'Eu',
      'Gd',
      'Tb',
      'Dy',
      'Ho',
      'Er',
      'Tm',
      'Yb',
      'Lu',
      null
    ],
    [
      null,
      null,
      'Ac',
      'Th',
      'Pa',
      'U',
      'Np',
      'Pu',
      'Am',
      'Cm',
      'Bk',
      'Cf',
      'Es',
      'Fm',
      'Md',
      'No',
      'Lr',
      null
    ],
  ];

  String _getElementCategory(String symbol) {
    switch (symbol) {
      case 'Li':
      case 'Na':
      case 'K':
      case 'Rb':
      case 'Cs':
      case 'Fr':
        return 'alkali_metal';
      case 'Be':
      case 'Mg':
      case 'Ca':
      case 'Sr':
      case 'Ba':
      case 'Ra':
        return 'alkaline_earth';
      case 'Sc':
      case 'Ti':
      case 'V':
      case 'Cr':
      case 'Mn':
      case 'Fe':
      case 'Co':
      case 'Ni':
      case 'Cu':
      case 'Zn':
      case 'Y':
      case 'Zr':
      case 'Nb':
      case 'Mo':
      case 'Tc':
      case 'Ru':
      case 'Rh':
      case 'Pd':
      case 'Ag':
      case 'Cd':
      case 'Hf':
      case 'Ta':
      case 'W':
      case 'Re':
      case 'Os':
      case 'Ir':
      case 'Pt':
      case 'Au':
      case 'Hg':
      case 'Rf':
      case 'Db':
      case 'Sg':
      case 'Bh':
      case 'Hs':
      case 'Mt':
      case 'Ds':
      case 'Rg':
      case 'Cn':
        return 'transition_metal';
      case 'Al':
      case 'Ga':
      case 'In':
      case 'Sn':
      case 'Tl':
      case 'Pb':
      case 'Bi':
      case 'Po':
        return 'post_transition';
      case 'B':
      case 'Si':
      case 'Ge':
      case 'As':
      case 'Sb':
      case 'Te':
        return 'metalloid';
      case 'H':
      case 'C':
      case 'N':
      case 'O':
      case 'P':
      case 'S':
      case 'Se':
        return 'nonmetal';
      case 'F':
      case 'Cl':
      case 'Br':
      case 'I':
      case 'At':
        return 'halogen';
      case 'He':
      case 'Ne':
      case 'Ar':
      case 'Kr':
      case 'Xe':
      case 'Rn':
      case 'Og':
        return 'noble_gas';
      case 'La':
      case 'Ce':
      case 'Pr':
      case 'Nd':
      case 'Pm':
      case 'Sm':
      case 'Eu':
      case 'Gd':
      case 'Tb':
      case 'Dy':
      case 'Ho':
      case 'Er':
      case 'Tm':
      case 'Yb':
      case 'Lu':
        return 'lanthanide';
      case 'Ac':
      case 'Th':
      case 'Pa':
      case 'U':
      case 'Np':
      case 'Pu':
      case 'Am':
      case 'Cm':
      case 'Bk':
      case 'Cf':
      case 'Es':
      case 'Fm':
      case 'Md':
      case 'No':
      case 'Lr':
        return 'actinide';
      default:
        return 'transition_metal';
    }
  }

  void _selectElement(String symbol) {
    if (symbol == null || symbol.isEmpty) return;
    final data = LocalChemistryService.getAtomData(symbol);
    setState(() {
      _selectedData = data;
      _selectedSymbol = symbol;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectElement('H');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final controlWidth = isWide ? 360.0 : screenWidth * 0.9;

    return MainLayout(
      title: 'Periodic Table Explorer',
      child: isWide
          ? Row(children: [_buildGrid(), _buildDetails(controlWidth)])
          : SingleChildScrollView(
              child: Column(
                  children: [_buildGrid(), _buildDetails(controlWidth)])),
    );
  }

  Widget _buildGrid() {
    final isWide = MediaQuery.of(context).size.width > 900;
    final elementWidth = isWide ? 44.0 : 38.0;

    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend(),
                  const SizedBox(height: 12),
                  ...List.generate(_periodicTable.length, (rowIndex) {
                    if (rowIndex == 7) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryLabel('Lanthanides'),
                          _buildTableRow(
                              _periodicTable[rowIndex], elementWidth),
                        ],
                      );
                    } else if (rowIndex == 8) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryLabel('Actinides'),
                          _buildTableRow(
                              _periodicTable[rowIndex], elementWidth),
                        ],
                      );
                    }
                    return _buildTableRow(
                        _periodicTable[rowIndex], elementWidth);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: _categoryColors.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: e.value, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 4),
            Text(
              e.key
                  .replaceAll('_', ' ')
                  .split(' ')
                  .map((w) => w[0].toUpperCase() + w.substring(1))
                  .join(' '),
              style: GoogleFonts.inter(fontSize: 9, color: Colors.white70),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryLabel(String label) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
      );

  Widget _buildTableRow(List<String?> row, double elementWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: row.map((symbol) {
          if (symbol == null) {
            return SizedBox(width: elementWidth, height: elementWidth + 4);
          }
          return _buildElementTile(symbol, elementWidth);
        }).toList(),
      ),
    );
  }

  Widget _buildElementTile(String symbol, double width) {
    final isSelected = _selectedSymbol == symbol;
    final category = _getElementCategory(symbol);
    final color = _categoryColors[category] ?? Colors.grey;
    final data = LocalChemistryService.getAtomData(symbol);
    final atomicNum = data['atomic_number'] ?? 0;

    return GestureDetector(
      onTap: () => _selectElement(symbol),
      child: Container(
        width: width,
        height: width + 4,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.8)
              : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.white : color.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$atomicNum',
                style: GoogleFonts.inter(fontSize: 8, color: Colors.white70)),
            Text(symbol,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: width > 40 ? 14 : 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(double width) {
    final symbol = _selectedData['symbol'] ?? '';
    final name = _selectedData['name'] ?? '';
    final atomicNumber = _selectedData['atomic_number'] ?? 'N/A';
    final atomicMass =
        (_selectedData['atomic_mass'] as num?)?.toDouble() ?? 0.0;
    final valency = _selectedData['valency'] ?? 'N/A';
    final shells = _selectedData['shells'] as List? ?? [];
    final electronegativity =
        (_selectedData['electronegativity'] as num?)?.toDouble() ?? 0.0;
    final meltingPoint =
        (_selectedData['melting_point'] as num?)?.toDouble() ?? 0.0;
    final boilingPoint =
        (_selectedData['boiling_point'] as num?)?.toDouble() ?? 0.0;
    final density = (_selectedData['density'] as num?)?.toDouble() ?? 0.0;
    final description = _selectedData['description'] ?? '';

    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 12, 12, 12),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: _selectedData.isEmpty || _selectedData['success'] != true
                ? const Center(
                    child: Text('Select an element',
                        style: TextStyle(color: Colors.white)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Element symbol and name
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _categoryColors[_getElementCategory(symbol)]
                                ?.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _categoryColors[
                                        _getElementCategory(symbol)] ??
                                    Colors.grey,
                                width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$atomicNumber',
                                  style: GoogleFonts.inter(
                                      fontSize: 10, color: Colors.white70)),
                              Text(symbol,
                                  style: GoogleFonts.jetBrainsMono(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                          child: Text(name,
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      Center(
                          child: Text(
                              _getElementCategory(symbol)
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: _categoryColors[
                                          _getElementCategory(symbol)] ??
                                      Colors.grey))),
                      const SizedBox(height: 12),

                      // All element properties
                      _buildPropertyRow(
                          'Atomic Number', '$atomicNumber', Icons.tag),
                      _buildPropertyRow('Atomic Mass',
                          '${atomicMass.toStringAsFixed(3)} u', Icons.scale),
                      _buildPropertyRow('Valency', '$valency', Icons.share),
                      _buildPropertyRow('Electron Shells', shells.join(' - '),
                          Icons.blur_circular),
                      _buildPropertyRow(
                          'Electronegativity',
                          electronegativity > 0
                              ? electronegativity.toStringAsFixed(2)
                              : 'N/A',
                          Icons.flash_on),
                      _buildPropertyRow(
                          'Melting Point',
                          '${meltingPoint.toStringAsFixed(2)} °C',
                          Icons.ac_unit),
                      _buildPropertyRow(
                          'Boiling Point',
                          '${boilingPoint.toStringAsFixed(2)} °C',
                          Icons.local_fire_department),
                      _buildPropertyRow('Density',
                          '${density.toStringAsFixed(4)} g/cm³', Icons.layers),

                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('About',
                                  style: GoogleFonts.inter(
                                      color: Colors.blueAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(description,
                                  style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      height: 1.3)),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      _buildPropertyBar('Metal', _isMetal(symbol) ? 0.8 : 0.1,
                          Colors.blueAccent),
                      _buildPropertyBar('Non-metal',
                          _isNonMetal(symbol) ? 0.8 : 0.1, Colors.greenAccent),
                      _buildPropertyBar('Reactivity', _getReactivity(symbol),
                          Colors.orangeAccent),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'alkali_metal':
        return 'Highly reactive metals, soft, good conductors';
      case 'alkaline_earth':
        return 'Reactive metals, form alkaline solutions';
      case 'transition_metal':
        return 'Hard, shiny, good conductors of electricity';
      case 'post_transition':
        return 'Soft metals with low melting points';
      case 'metalloid':
        return 'Properties between metals and non-metals';
      case 'nonmetal':
        return 'Poor conductors, form acidic oxides';
      case 'halogen':
        return 'Highly reactive non-metals';
      case 'noble_gas':
        return 'Unreactive gases';
      case 'lanthanide':
        return 'Rare earth metals, similar properties';
      case 'actinide':
        return 'Radioactive heavy elements';
      default:
        return '';
    }
  }

  bool _isMetal(String symbol) {
    return [
      'alkali_metal',
      'alkaline_earth',
      'transition_metal',
      'post_transition',
      'lanthanide',
      'actinide'
    ].contains(_getElementCategory(symbol));
  }

  bool _isNonMetal(String symbol) {
    return ['nonmetal', 'halogen', 'noble_gas']
        .contains(_getElementCategory(symbol));
  }

  double _getReactivity(String symbol) {
    switch (_getElementCategory(symbol)) {
      case 'alkali_metal':
        return 0.9;
      case 'halogen':
        return 0.8;
      case 'alkaline_earth':
        return 0.6;
      case 'nonmetal':
        return 0.5;
      case 'transition_metal':
        return 0.3;
      case 'noble_gas':
        return 0.0;
      default:
        return 0.2;
    }
  }

  Widget _buildInfoCard(String label, String value, IconData icon) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 10, color: Colors.white54)),
                  Text(value,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildPropertyRow(String label, String value, IconData icon) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              Icon(icon, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style:
                        GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
              ),
              Text(value,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

  Widget _buildPropertyBar(String label, double value, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
                width: 70,
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: Colors.white70))),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4))),
                ),
              ),
            ),
          ],
        ),
      );
}
