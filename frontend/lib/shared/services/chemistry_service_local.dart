// Chemistry Module - Local implementation (no external API calls)
// All chemistry calculations are performed locally in Dart

import 'dart:math' as math;

// Local periodic table data
const Map<String, Map<String, dynamic>> _PERIODIC_TABLE = {
  'H': {
    'atomic_number': 1,
    'name': 'Hydrogen',
    'valency': 1,
    'shells': [1]
  },
  'He': {
    'atomic_number': 2,
    'name': 'Helium',
    'valency': 0,
    'shells': [2]
  },
  'Li': {
    'atomic_number': 3,
    'name': 'Lithium',
    'valency': 1,
    'shells': [2, 1]
  },
  'Be': {
    'atomic_number': 4,
    'name': 'Beryllium',
    'valency': 2,
    'shells': [2, 2]
  },
  'B': {
    'atomic_number': 5,
    'name': 'Boron',
    'valency': 3,
    'shells': [2, 3]
  },
  'C': {
    'atomic_number': 6,
    'name': 'Carbon',
    'valency': 4,
    'shells': [2, 4]
  },
  'N': {
    'atomic_number': 7,
    'name': 'Nitrogen',
    'valency': 3,
    'shells': [2, 5]
  },
  'O': {
    'atomic_number': 8,
    'name': 'Oxygen',
    'valency': 2,
    'shells': [2, 6]
  },
  'F': {
    'atomic_number': 9,
    'name': 'Fluorine',
    'valency': 1,
    'shells': [2, 7]
  },
  'Ne': {
    'atomic_number': 10,
    'name': 'Neon',
    'valency': 0,
    'shells': [2, 8]
  },
  'Na': {
    'atomic_number': 11,
    'name': 'Sodium',
    'valency': 1,
    'shells': [2, 8, 1]
  },
  'Mg': {
    'atomic_number': 12,
    'name': 'Magnesium',
    'valency': 2,
    'shells': [2, 8, 2]
  },
  'Al': {
    'atomic_number': 13,
    'name': 'Aluminum',
    'valency': 3,
    'shells': [2, 8, 3]
  },
  'Si': {
    'atomic_number': 14,
    'name': 'Silicon',
    'valency': 4,
    'shells': [2, 8, 4]
  },
  'P': {
    'atomic_number': 15,
    'name': 'Phosphorus',
    'valency': 3,
    'shells': [2, 8, 5]
  },
  'S': {
    'atomic_number': 16,
    'name': 'Sulfur',
    'valency': 2,
    'shells': [2, 8, 6]
  },
  'Cl': {
    'atomic_number': 17,
    'name': 'Chlorine',
    'valency': 1,
    'shells': [2, 8, 7]
  },
  'Ar': {
    'atomic_number': 18,
    'name': 'Argon',
    'valency': 0,
    'shells': [2, 8, 8]
  },
  'K': {
    'atomic_number': 19,
    'name': 'Potassium',
    'valency': 1,
    'shells': [2, 8, 8, 1]
  },
  'Ca': {
    'atomic_number': 20,
    'name': 'Calcium',
    'valency': 2,
    'shells': [2, 8, 8, 2]
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

  // Separation process steps
  static Map<String, dynamic> separationProcess(String method) {
    if (method.toLowerCase() == 'filtration') {
      return {
        'success': true,
        'method': method,
        'steps': [
          {'id': 1, 'desc': 'Mix solid particles in liquid solvent'},
          {'id': 2, 'desc': 'Pour mixture through filter paper'},
          {'id': 3, 'desc': 'Solid remains on filter, liquid passes through'},
        ],
      };
    } else if (method.toLowerCase() == 'evaporation') {
      return {
        'success': true,
        'method': method,
        'steps': [
          {'id': 1, 'desc': 'Heat the solution to evaporate solvent'},
          {'id': 2, 'desc': 'Continue heating until only solid remains'},
          {'id': 3, 'desc': 'Collect the crystallized solid'},
        ],
      };
    }
    return {'success': false, 'error': 'Unknown method: $method'};
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
