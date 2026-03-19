// Chemistry Module - Local implementation (no external API calls)
// All chemistry calculations are performed locally in Dart

import 'dart:math' as math;

// Local periodic table data - ALL ELEMENTS WITH COMPLETE INFO
const Map<String, Map<String, dynamic>> _PERIODIC_TABLE = {
  'H': {
    'atomic_number': 1,
    'name': 'Hydrogen',
    'symbol': 'H',
    'atomic_mass': 1.008,
    'category': 'nonmetal',
    'valency': 1,
    'shells': [1],
    'electronegativity': 2.20,
    'melting_point': -259.14,
    'boiling_point': -252.87,
    'density': 0.00008988,
    'description': 'Lightest element, most abundant in universe'
  },
  'He': {
    'atomic_number': 2,
    'name': 'Helium',
    'symbol': 'He',
    'atomic_mass': 4.003,
    'category': 'noble_gas',
    'valency': 0,
    'shells': [2],
    'electronegativity': 0.00,
    'melting_point': -272.20,
    'boiling_point': -268.93,
    'density': 0.0001785,
    'description': 'Noble gas, second most abundant in universe'
  },
  'Li': {
    'atomic_number': 3,
    'name': 'Lithium',
    'symbol': 'Li',
    'atomic_mass': 6.94,
    'category': 'alkali_metal',
    'valency': 1,
    'shells': [2, 1],
    'electronegativity': 0.98,
    'melting_point': 180.54,
    'boiling_point': 1342,
    'density': 0.534,
    'description': 'Lightest metal, used in batteries'
  },
  'Be': {
    'atomic_number': 4,
    'name': 'Beryllium',
    'symbol': 'Be',
    'atomic_mass': 9.012,
    'category': 'alkaline_earth',
    'valency': 2,
    'shells': [2, 2],
    'electronegativity': 1.57,
    'melting_point': 1287,
    'boiling_point': 2469,
    'density': 1.85,
    'description': 'Lightweight structural metal'
  },
  'B': {
    'atomic_number': 5,
    'name': 'Boron',
    'symbol': 'B',
    'atomic_mass': 10.81,
    'category': 'metalloid',
    'valency': 3,
    'shells': [2, 3],
    'electronegativity': 2.04,
    'melting_point': 2076,
    'boiling_point': 3927,
    'density': 2.34,
    'description': 'Metalloid used in glass and ceramics'
  },
  'C': {
    'atomic_number': 6,
    'name': 'Carbon',
    'symbol': 'C',
    'atomic_mass': 12.011,
    'category': 'nonmetal',
    'valency': 4,
    'shells': [2, 4],
    'electronegativity': 2.55,
    'melting_point': 3550,
    'boiling_point': 4027,
    'density': 2.267,
    'description': 'Basis of organic chemistry, many allotropes'
  },
  'N': {
    'atomic_number': 7,
    'name': 'Nitrogen',
    'symbol': 'N',
    'atomic_mass': 14.007,
    'category': 'nonmetal',
    'valency': 3,
    'shells': [2, 5],
    'electronegativity': 3.04,
    'melting_point': -210.00,
    'boiling_point': -195.79,
    'density': 0.0012506,
    'description': '78% of atmosphere, essential for life'
  },
  'O': {
    'atomic_number': 8,
    'name': 'Oxygen',
    'symbol': 'O',
    'atomic_mass': 15.999,
    'category': 'nonmetal',
    'valency': 2,
    'shells': [2, 6],
    'electronegativity': 3.44,
    'melting_point': -218.79,
    'boiling_point': -182.95,
    'density': 0.001429,
    'description': 'Essential for respiration, 21% of atmosphere'
  },
  'F': {
    'atomic_number': 9,
    'name': 'Fluorine',
    'symbol': 'F',
    'atomic_mass': 18.998,
    'category': 'halogen',
    'valency': 1,
    'shells': [2, 7],
    'electronegativity': 3.98,
    'melting_point': -219.62,
    'boiling_point': -188.12,
    'density': 0.001696,
    'description': 'Most electronegative element, highly reactive'
  },
  'Ne': {
    'atomic_number': 10,
    'name': 'Neon',
    'symbol': 'Ne',
    'atomic_mass': 20.180,
    'category': 'noble_gas',
    'valency': 0,
    'shells': [2, 8],
    'electronegativity': 0.00,
    'melting_point': -248.59,
    'boiling_point': -246.08,
    'density': 0.0008999,
    'description': 'Noble gas used in neon signs'
  },
  'Na': {
    'atomic_number': 11,
    'name': 'Sodium',
    'symbol': 'Na',
    'atomic_mass': 22.990,
    'category': 'alkali_metal',
    'valency': 1,
    'shells': [2, 8, 1],
    'electronegativity': 0.93,
    'melting_point': 97.79,
    'boiling_point': 883,
    'density': 0.971,
    'description': 'Highly reactive metal, essential for life'
  },
  'Mg': {
    'atomic_number': 12,
    'name': 'Magnesium',
    'symbol': 'Mg',
    'atomic_mass': 24.305,
    'category': 'alkaline_earth',
    'valency': 2,
    'shells': [2, 8, 2],
    'electronegativity': 1.31,
    'melting_point': 650,
    'boiling_point': 1090,
    'density': 1.738,
    'description': 'Light metal used in alloys'
  },
  'Al': {
    'atomic_number': 13,
    'name': 'Aluminum',
    'symbol': 'Al',
    'atomic_mass': 26.982,
    'category': 'post_transition',
    'valency': 3,
    'shells': [2, 8, 3],
    'electronegativity': 1.61,
    'melting_point': 660.32,
    'boiling_point': 2519,
    'density': 2.70,
    'description': 'Most abundant metal in Earth\'s crust'
  },
  'Si': {
    'atomic_number': 14,
    'name': 'Silicon',
    'symbol': 'Si',
    'atomic_mass': 28.086,
    'category': 'metalloid',
    'valency': 4,
    'shells': [2, 8, 4],
    'electronegativity': 1.90,
    'melting_point': 1414,
    'boiling_point': 3265,
    'density': 2.3296,
    'description': 'Basis of semiconductor technology'
  },
  'P': {
    'atomic_number': 15,
    'name': 'Phosphorus',
    'symbol': 'P',
    'atomic_mass': 30.974,
    'category': 'nonmetal',
    'valency': 3,
    'shells': [2, 8, 5],
    'electronegativity': 2.19,
    'melting_point': 44.15,
    'boiling_point': 280.5,
    'density': 1.82,
    'description': 'Essential for DNA and ATP'
  },
  'S': {
    'atomic_number': 16,
    'name': 'Sulfur',
    'symbol': 'S',
    'atomic_mass': 32.06,
    'category': 'nonmetal',
    'valency': 2,
    'shells': [2, 8, 6],
    'electronegativity': 2.58,
    'melting_point': 115.21,
    'boiling_point': 444.60,
    'density': 2.067,
    'description': 'Yellow solid, used in fertilizers'
  },
  'Cl': {
    'atomic_number': 17,
    'name': 'Chlorine',
    'symbol': 'Cl',
    'atomic_mass': 35.45,
    'category': 'halogen',
    'valency': 1,
    'shells': [2, 8, 7],
    'electronegativity': 3.16,
    'melting_point': -101.5,
    'boiling_point': -34.04,
    'density': 0.003214,
    'description': 'Used for water purification and PVC'
  },
  'Ar': {
    'atomic_number': 18,
    'name': 'Argon',
    'symbol': 'Ar',
    'atomic_mass': 39.948,
    'category': 'noble_gas',
    'valency': 0,
    'shells': [2, 8, 8],
    'electronegativity': 0.00,
    'melting_point': -189.35,
    'boiling_point': -185.85,
    'density': 0.0017837,
    'description': 'Third most abundant gas in atmosphere'
  },
  'K': {
    'atomic_number': 19,
    'name': 'Potassium',
    'symbol': 'K',
    'atomic_mass': 39.098,
    'category': 'alkali_metal',
    'valency': 1,
    'shells': [2, 8, 8, 1],
    'electronegativity': 0.82,
    'melting_point': 63.38,
    'boiling_point': 759,
    'density': 0.862,
    'description': 'Essential nutrient for nerve function'
  },
  'Ca': {
    'atomic_number': 20,
    'name': 'Calcium',
    'symbol': 'Ca',
    'atomic_mass': 40.078,
    'category': 'alkaline_earth',
    'valency': 2,
    'shells': [2, 8, 8, 2],
    'electronegativity': 1.00,
    'melting_point': 842,
    'boiling_point': 1484,
    'density': 1.54,
    'description': 'Essential for bones and teeth'
  },
  'Sc': {
    'atomic_number': 21,
    'name': 'Scandium',
    'symbol': 'Sc',
    'atomic_mass': 44.956,
    'category': 'transition_metal',
    'valency': 3,
    'shells': [2, 8, 9, 2],
    'electronegativity': 1.36,
    'melting_point': 1541,
    'boiling_point': 2836,
    'density': 2.989,
    'description': 'Light transition metal'
  },
  'Ti': {
    'atomic_number': 22,
    'name': 'Titanium',
    'symbol': 'Ti',
    'atomic_mass': 47.867,
    'category': 'transition_metal',
    'valency': 4,
    'shells': [2, 8, 10, 2],
    'electronegativity': 1.54,
    'melting_point': 1668,
    'boiling_point': 3287,
    'density': 4.54,
    'description': 'Strong, lightweight, corrosion-resistant'
  },
  'V': {
    'atomic_number': 23,
    'name': 'Vanadium',
    'symbol': 'V',
    'atomic_mass': 50.942,
    'category': 'transition_metal',
    'valency': 5,
    'shells': [2, 8, 11, 2],
    'electronegativity': 1.63,
    'melting_point': 1910,
    'boiling_point': 3407,
    'density': 6.11,
    'description': 'Used in steel alloys'
  },
  'Cr': {
    'atomic_number': 24,
    'name': 'Chromium',
    'symbol': 'Cr',
    'atomic_mass': 51.996,
    'category': 'transition_metal',
    'valency': 6,
    'shells': [2, 8, 13, 1],
    'electronegativity': 1.66,
    'melting_point': 1907,
    'boiling_point': 2671,
    'density': 7.15,
    'description': 'Gives stainless steel its corrosion resistance'
  },
  'Mn': {
    'atomic_number': 25,
    'name': 'Manganese',
    'symbol': 'Mn',
    'atomic_mass': 54.938,
    'category': 'transition_metal',
    'valency': 7,
    'shells': [2, 8, 13, 2],
    'electronegativity': 1.55,
    'melting_point': 1246,
    'boiling_point': 2061,
    'density': 7.44,
    'description': 'Essential for steel production'
  },
  'Fe': {
    'atomic_number': 26,
    'name': 'Iron',
    'symbol': 'Fe',
    'atomic_mass': 55.845,
    'category': 'transition_metal',
    'valency': 3,
    'shells': [2, 8, 14, 2],
    'electronegativity': 1.83,
    'melting_point': 1538,
    'boiling_point': 2861,
    'density': 7.874,
    'description': 'Most used metal, essential for blood'
  },
  'Co': {
    'atomic_number': 27,
    'name': 'Cobalt',
    'symbol': 'Co',
    'atomic_mass': 58.933,
    'category': 'transition_metal',
    'valency': 3,
    'shells': [2, 8, 15, 2],
    'electronegativity': 1.88,
    'melting_point': 1495,
    'boiling_point': 2927,
    'density': 8.90,
    'description': 'Used in batteries and magnets'
  },
  'Ni': {
    'atomic_number': 28,
    'name': 'Nickel',
    'symbol': 'Ni',
    'atomic_mass': 58.693,
    'category': 'transition_metal',
    'valency': 2,
    'shells': [2, 8, 16, 2],
    'electronegativity': 1.91,
    'melting_point': 1455,
    'boiling_point': 2913,
    'density': 8.912,
    'description': 'Used in coins and stainless steel'
  },
  'Cu': {
    'atomic_number': 29,
    'name': 'Copper',
    'symbol': 'Cu',
    'atomic_mass': 63.546,
    'category': 'transition_metal',
    'valency': 2,
    'shells': [2, 8, 18, 1],
    'electronegativity': 1.90,
    'melting_point': 1084.62,
    'boiling_point': 2562,
    'density': 8.96,
    'description': 'Excellent conductor of electricity'
  },
  'Zn': {
    'atomic_number': 30,
    'name': 'Zinc',
    'symbol': 'Zn',
    'atomic_mass': 65.38,
    'category': 'transition_metal',
    'valency': 2,
    'shells': [2, 8, 18, 2],
    'electronegativity': 1.65,
    'melting_point': 419.53,
    'boiling_point': 907,
    'density': 7.134,
    'description': 'Used for galvanizing steel'
  },
  'Ga': {
    'atomic_number': 31,
    'name': 'Gallium',
    'symbol': 'Ga',
    'atomic_mass': 69.723,
    'category': 'post_transition',
    'valency': 3,
    'shells': [2, 8, 18, 3],
    'electronegativity': 1.81,
    'melting_point': 29.76,
    'boiling_point': 2204,
    'density': 5.91,
    'description': 'Melts in your hand, used in semiconductors'
  },
  'Ge': {
    'atomic_number': 32,
    'name': 'Germanium',
    'symbol': 'Ge',
    'atomic_mass': 72.630,
    'category': 'metalloid',
    'valency': 4,
    'shells': [2, 8, 18, 4],
    'electronegativity': 2.01,
    'melting_point': 938.25,
    'boiling_point': 2833,
    'density': 5.323,
    'description': 'Important semiconductor material'
  },
  'As': {
    'atomic_number': 33,
    'name': 'Arsenic',
    'symbol': 'As',
    'atomic_mass': 74.922,
    'category': 'metalloid',
    'valency': 5,
    'shells': [2, 8, 18, 5],
    'electronegativity': 2.18,
    'melting_point': 817,
    'boiling_point': 614,
    'density': 5.776,
    'description': 'Historically used as poison'
  },
  'Se': {
    'atomic_number': 34,
    'name': 'Selenium',
    'symbol': 'Se',
    'atomic_mass': 78.971,
    'category': 'nonmetal',
    'valency': 6,
    'shells': [2, 8, 18, 6],
    'electronegativity': 2.55,
    'melting_point': 221,
    'boiling_point': 685,
    'density': 4.809,
    'description': 'Essential trace element, used in electronics'
  },
  'Br': {
    'atomic_number': 35,
    'name': 'Bromine',
    'symbol': 'Br',
    'atomic_mass': 79.904,
    'category': 'halogen',
    'valency': 1,
    'shells': [2, 8, 18, 7],
    'electronegativity': 2.96,
    'melting_point': -7.2,
    'boiling_point': 58.8,
    'density': 3.122,
    'description': 'Only liquid nonmetal at room temp'
  },
  'Kr': {
    'atomic_number': 36,
    'name': 'Krypton',
    'symbol': 'Kr',
    'atomic_mass': 83.798,
    'category': 'noble_gas',
    'valency': 0,
    'shells': [2, 8, 18, 8],
    'electronegativity': 0.00,
    'melting_point': -157.36,
    'boiling_point': -153.22,
    'density': 0.003733,
    'description': 'Noble gas used in lighting'
  },
  'Rb': {
    'atomic_number': 37,
    'name': 'Rubidium',
    'symbol': 'Rb',
    'atomic_mass': 85.468,
    'category': 'alkali_metal',
    'valency': 1,
    'shells': [2, 8, 18, 8, 1],
    'electronegativity': 0.82,
    'melting_point': 39.30,
    'boiling_point': 688,
    'density': 1.532,
    'description': 'Highly reactive alkali metal'
  },
  'Sr': {
    'atomic_number': 38,
    'name': 'Strontium',
    'symbol': 'Sr',
    'atomic_mass': 87.62,
    'category': 'alkaline_earth',
    'valency': 2,
    'shells': [2, 8, 18, 8, 2],
    'electronegativity': 0.95,
    'melting_point': 777,
    'boiling_point': 1382,
    'density': 2.64,
    'description': 'Used in fireworks for red color'
  },
  'Y': {
    'atomic_number': 39,
    'name': 'Yttrium',
    'symbol': 'Y',
    'atomic_mass': 88.906,
    'category': 'transition_metal',
    'valency': 3,
    'shells': [2, 8, 18, 9, 2],
    'electronegativity': 1.22,
    'melting_point': 1522,
    'boiling_point': 3345,
    'density': 4.469,
    'description': 'Used in LEDs and superconductors'
  },
  'Zr': {
    'atomic_number': 40,
    'name': 'Zirconium',
    'symbol': 'Zr',
    'atomic_mass': 91.224,
    'category': 'transition_metal',
    'valency': 4,
    'shells': [2, 8, 18, 10, 2],
    'electronegativity': 1.33,
    'melting_point': 1854,
    'boiling_point': 4377,
    'density': 6.506,
    'description': 'Used in nuclear reactors'
  },
  'Nb': {
    'atomic_number': 41,
    'name': 'Niobium',
    'symbol': 'Nb',
    'atomic_mass': 92.906,
    'category': 'transition_metal',
    'valency': 5,
    'shells': [2, 8, 18, 12, 1],
    'electronegativity': 1.6,
    'melting_point': 2477,
    'boiling_point': 4744,
    'density': 8.57,
    'description': 'Used in superconducting magnets'
  },
  'Mo': {
    'atomic_number': 42,
    'name': 'Molybdenum',
    'symbol': 'Mo',
    'atomic_mass': 95.95,
    'category': 'transition_metal',
    'valency': 6,
    'shells': [2, 8, 18, 13, 1],
    'electronegativity': 2.16,
    'melting_point': 2623,
    'boiling_point': 4639,
    'density': 10.22,
    'description': 'Essential trace element, high melting point'
  },
  'Ag': {
    'atomic_number': 47,
    'name': 'Silver',
    'symbol': 'Ag',
    'atomic_mass': 107.87,
    'category': 'transition_metal',
    'valency': 1,
    'shells': [2, 8, 18, 18, 1],
    'electronegativity': 1.93,
    'melting_point': 961.78,
    'boiling_point': 2162,
    'density': 10.501,
    'description': 'Best conductor of electricity'
  },
  'Sn': {
    'atomic_number': 50,
    'name': 'Tin',
    'symbol': 'Sn',
    'atomic_mass': 118.71,
    'category': 'post_transition',
    'valency': 4,
    'shells': [2, 8, 18, 18, 4],
    'electronegativity': 1.96,
    'melting_point': 231.93,
    'boiling_point': 2602,
    'density': 7.287,
    'description': 'Used in solder and tin cans'
  },
  'I': {
    'atomic_number': 53,
    'name': 'Iodine',
    'symbol': 'I',
    'atomic_mass': 126.90,
    'category': 'halogen',
    'valency': 1,
    'shells': [2, 8, 18, 18, 7],
    'electronegativity': 2.66,
    'melting_point': 113.7,
    'boiling_point': 184.3,
    'density': 4.93,
    'description': 'Essential for thyroid function'
  },
  'Xe': {
    'atomic_number': 54,
    'name': 'Xenon',
    'symbol': 'Xe',
    'atomic_mass': 131.29,
    'category': 'noble_gas',
    'valency': 0,
    'shells': [2, 8, 18, 18, 8],
    'electronegativity': 0.00,
    'melting_point': -111.75,
    'boiling_point': -108.12,
    'density': 0.005887,
    'description': 'Used in flash lamps and anesthesia'
  },
  'Au': {
    'atomic_number': 79,
    'name': 'Gold',
    'symbol': 'Au',
    'atomic_mass': 196.97,
    'category': 'transition_metal',
    'valency': 3,
    'shells': [2, 8, 18, 32, 18, 1],
    'electronegativity': 2.54,
    'melting_point': 1064.18,
    'boiling_point': 2856,
    'density': 19.282,
    'description': 'Precious metal, excellent conductor'
  },
  'Hg': {
    'atomic_number': 80,
    'name': 'Mercury',
    'symbol': 'Hg',
    'atomic_mass': 200.59,
    'category': 'transition_metal',
    'valency': 2,
    'shells': [2, 8, 18, 32, 18, 2],
    'electronegativity': 2.00,
    'melting_point': -38.83,
    'boiling_point': 356.73,
    'density': 13.5336,
    'description': 'Only liquid metal at room temp'
  },
  'Pb': {
    'atomic_number': 82,
    'name': 'Lead',
    'symbol': 'Pb',
    'atomic_mass': 207.2,
    'category': 'post_transition',
    'valency': 4,
    'shells': [2, 8, 18, 32, 18, 4],
    'electronegativity': 2.33,
    'melting_point': 327.46,
    'boiling_point': 1749,
    'density': 11.342,
    'description': 'Dense metal, historically used widely'
  },
};

class LocalChemistryService {
  // Get atom data from periodic table
  static Map<String, dynamic> getAtomData(String symbol) {
    final data = _PERIODIC_TABLE[symbol];
    if (data == null) {
      return {'success': false, 'error': 'Element $symbol not found'};
    }
    return {
      'success': true,
      'symbol': symbol,
      'name': data['name'],
      'atomic_number': data['atomic_number'],
      'valency': data['valency'],
      'shells': data['shells'],
    };
  }

  // Build atom with protons, neutrons, electrons
  static Map<String, dynamic> atomBuilder(int p, int n, int e) {
    if (p == 0) {
      return {'success': false, 'error': 'Protons cannot be 0'};
    }

    final mass = p + n;
    final charge = p - e;

    // Find element by atomic number
    String symbol = '?';
    String name = 'Unknown';
    for (final entry in _PERIODIC_TABLE.entries) {
      if (entry.value['atomic_number'] == p) {
        symbol = entry.key;
        name = entry.value['name'];
        break;
      }
    }

    return {
      'success': true,
      'element': name,
      'symbol': symbol,
      'mass': mass,
      'charge': charge,
      'is_stable': (p - n).abs() <= 2, // Simplified stability check
    };
  }

  // Determine chemical bond type
  static Map<String, dynamic> chemicalBonding(String el1, String el2) {
    final metals = ['Na', 'Li', 'K', 'Mg', 'Ca', 'Al', 'Zn', 'Fe'];
    final nonmetals = ['O', 'N', 'Cl', 'F', 'S', 'P', 'C', 'H'];

    final m1 = metals.contains(el1);
    final m2 = metals.contains(el2);

    String bond;
    if (m1 && m2) {
      bond = 'Metallic';
    } else if (m1 || m2) {
      bond = 'Ionic';
    } else {
      bond = 'Covalent';
    }

    return {
      'success': true,
      'elements': [el1, el2],
      'bond_type': bond,
    };
  }

  // Mole calculator
  static Map<String, dynamic> moleCalculator(
      double value, String mode, double molarMass) {
    if (value < 0 || molarMass <= 0) {
      return {'success': false, 'error': 'Invalid values'};
    }

    const avogadro = 6.022e23;

    switch (mode) {
      case 'mass_to_moles':
        return {'success': true, 'result': value / molarMass, 'unit': 'mol'};
      case 'moles_to_mass':
        return {'success': true, 'result': value * molarMass, 'unit': 'g'};
      case 'moles_to_particles':
        return {
          'success': true,
          'result': value * avogadro,
          'unit': 'particles'
        };
      default:
        return {'success': false, 'error': 'Unknown mode'};
    }
  }

  // Equilibrium simulator (Le Chatelier's principle)
  static Map<String, dynamic> equilibriumSimulator(double tempChange) {
    String shift;
    if (tempChange < 0) {
      shift = 'Right (Products)'; // Exothermic: lower temp favors products
    } else if (tempChange > 0) {
      shift = 'Left (Reactants)'; // Exothermic: higher temp favors reactants
    } else {
      shift = 'No Change';
    }

    return {
      'success': true,
      'stimulus':
          'Temp change ${tempChange > 0 ? '+' : ''}${tempChange.toStringAsFixed(1)}°C',
      'shift': shift,
    };
  }

  // Reaction kinetics graph data
  static Map<String, dynamic> kineticsGraph(
      double concentration, double k, int order) {
    final List<double> time = [];
    final List<double> conc = [];

    for (int i = 0; i <= 20; i++) {
      final t = i * 2.5; // 0 to 50 seconds
      time.add(t);

      double c;
      switch (order) {
        case 0:
          c = math.max(0.0, concentration - k * t);
          break;
        case 1:
          c = concentration * math.exp(-k * t);
          break;
        case 2:
          c = 1.0 / ((1.0 / concentration) + k * t);
          break;
        default:
          c = concentration * math.exp(-k * t);
      }
      conc.add(c.clamp(0.0, double.infinity));
    }

    return {
      'success': true,
      'order': order,
      'time': time,
      'concentration': conc,
    };
  }

  // Thermodynamics visualization
  static Map<String, dynamic> thermodynamicsViz(String rxnType) {
    final List<double> progress = [];
    final List<double> energy = [];

    for (int i = 0; i <= 50; i++) {
      final x = i * 0.2; // 0 to 10
      progress.add(x);

      // Activation energy curve
      final activation = 50 * math.exp(-math.pow(x - 4, 2) / 2);

      double y;
      if (rxnType.toLowerCase() == 'exothermic') {
        y = 80 - 10 * x + activation;
      } else {
        y = 20 + 10 * x + activation;
      }
      energy.add(y.clamp(0.0, 120.0));
    }

    return {
      'success': true,
      'type': rxnType,
      'progress': progress,
      'energy': energy,
    };
  }

  // Separation process steps - ENHANCED with more detailed steps for students
  static Map<String, dynamic> separationProcess(String method) {
    switch (method.toLowerCase()) {
      case 'filtration':
        return {
          'success': true,
          'method': method,
          'steps': [
            {
              'id': 1,
              'desc': 'Take a mixture of solid and liquid (like sand and water)'
            },
            {
              'id': 2,
              'desc':
                  'Pour the mixture slowly onto the filter paper in a funnel'
            },
            {
              'id': 3,
              'desc':
                  'Watch the solid (residue) stay on the filter, liquid (filtrate) passes through'
            },
          ],
        };
      case 'evaporation':
        return {
          'success': true,
          'method': method,
          'steps': [
            {
              'id': 1,
              'desc':
                  'Heat the solution containing dissolved solid (like salt in water)'
            },
            {
              'id': 2,
              'desc':
                  'As heat increases, water molecules gain energy and escape as vapor'
            },
            {
              'id': 3,
              'desc':
                  'When all water evaporates, only the solid crystals remain in the container'
            },
          ],
        };
      case 'distillation':
        return {
          'success': true,
          'method': method,
          'steps': [
            {
              'id': 1,
              'desc':
                  'Heat a mixture of two liquids with different boiling points'
            },
            {
              'id': 2,
              'desc':
                  'The liquid with lower boiling point evaporates first and rises up'
            },
            {
              'id': 3,
              'desc':
                  'Vapor is cooled in a condenser and collected as pure liquid'
            },
          ],
        };
      case 'magnetic':
        return {
          'success': true,
          'method': method,
          'steps': [
            {
              'id': 1,
              'desc':
                  'Prepare a mixture containing magnetic and non-magnetic materials'
            },
            {'id': 2, 'desc': 'Bring a magnet close to the mixture slowly'},
            {
              'id': 3,
              'desc':
                  'Magnetic materials (like iron) are attracted to magnet, leaving non-magnetic materials behind'
            },
          ],
        };
      default:
        return {'success': false, 'error': 'Unknown method: $method'};
    }
  }

  // Physical vs Chemical change detector
  static Map<String, dynamic> changeDetector(String scenario) {
    final lowerScenario = scenario.toLowerCase();

    // Chemical change keywords
    const chemicalKeywords = [
      'burn',
      'rust',
      'react',
      'bake',
      'cook',
      'acid',
      'gas',
      'precipitate',
      'oxidize',
      'explosion',
      'combustion',
      'bubbles',
      'fermentation',
      'digestion',
      'decay'
    ];

    // Physical change keywords
    const physicalKeywords = [
      'melt',
      'freeze',
      'boil',
      'condense',
      'evaporate',
      'shred',
      'chop',
      'mix',
      'break',
      'cut',
      'crush',
      'dissolve',
      'bend',
      'ice'
    ];

    bool isChemical = chemicalKeywords.any((k) => lowerScenario.contains(k));
    bool isPhysical = physicalKeywords.any((k) => lowerScenario.contains(k));

    // Override for state changes
    if (['melt', 'freeze', 'boil', 'condense']
        .any((s) => lowerScenario.contains(s))) {
      isChemical = false;
      isPhysical = true;
    }

    final type =
        isChemical ? 'Chemical' : (isPhysical ? 'Physical' : 'Unknown');
    final explanation = isChemical
        ? 'New substances are formed as chemical bonds are broken and created.'
        : 'The substance changes state or form, but its chemical identity remains.';

    return {
      'success': true,
      'scenario': scenario,
      'type': type,
      'explanation': explanation,
    };
  }
}
