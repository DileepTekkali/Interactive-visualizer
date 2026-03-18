import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/linear/linear_screen.dart';
import 'features/quadratic/quadratic_screen.dart';
import 'features/geometry/geometry_screen.dart';
import 'features/trigonometry/trigonometry_screen.dart';
import 'features/calculus/calculus_screen.dart';
import 'features/statistics/statistics_screen.dart';
import 'features/vectors/vectors_screen.dart';
import 'features/data_handling/data_handling_screen.dart';
import 'features/number_line/number_line_screen.dart';
import 'features/mensuration/mensuration_screen.dart';
import 'features/coordinate_geometry/coordinate_geometry_screen.dart';
import 'features/progressions/progressions_screen.dart';
import 'features/circles/circles_screen.dart';
import 'features/conic_sections/conic_sections_screen.dart';
import 'features/complex_numbers/complex_numbers_screen.dart';
import 'features/linear_programming/linear_programming_screen.dart';

// Chemistry
import 'features/chemistry/separation_screen.dart';
import 'features/chemistry/change_detector_screen.dart';
import 'features/chemistry/atom_builder_screen.dart';
import 'features/chemistry/periodic_table_screen.dart';
import 'features/chemistry/bonding_screen.dart';
import 'features/chemistry/mole_calculator_screen.dart';
import 'features/chemistry/kinetics_screen.dart';
import 'features/chemistry/equilibrium_screen.dart';
import 'features/chemistry/thermodynamics_screen.dart';

// Physics
import 'features/physics/friction_screen.dart';
import 'features/physics/heat_transfer_screen.dart';
import 'features/physics/lever_machine_screen.dart';
import 'features/physics/motion_graph_screen.dart';
import 'features/physics/newtons_laws_screen.dart';
import 'features/physics/energy_simulator_screen.dart';
import 'features/physics/optics_screen.dart';
import 'features/physics/circuit_simulator_screen.dart';
import 'features/physics/magnetic_field_screen.dart';
import 'features/physics/wave_simulator_screen.dart';

void main() {
  runApp(const MathVizApp());
}

class MathVizApp extends StatelessWidget {
  const MathVizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Math Visualization',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const DashboardScreen(),
        AppRoutes.linear: (context) => const LinearScreen(),
        AppRoutes.quadratic: (context) => const QuadraticScreen(),
        AppRoutes.geometry: (context) => const GeometryScreen(),
        AppRoutes.trigonometry: (context) => const TrigonometryScreen(),
        AppRoutes.calculus: (context) => const CalculusScreen(),
        AppRoutes.statistics: (context) => const StatisticsScreen(),
        AppRoutes.vectors: (context) => const VectorsScreen(),
        '/data_handling': (context) => const DataHandlingScreen(),
        '/number_line': (context) => const NumberLineScreen(),
        '/mensuration_3d': (context) => const MensurationScreen(),
        '/coordinate_geometry': (context) => const CoordinateGeometryScreen(),
        '/arithmetic_progressions': (context) => const ProgressionsScreen(),
        '/circles_tangents': (context) => const CirclesScreen(),
        '/conic_sections': (context) => const ConicSectionsScreen(),
        '/complex_numbers': (context) => const ComplexNumbersScreen(),
        '/linear_programming': (context) => const LinearProgrammingScreen(),

        // Chemistry Routes
        '/chemistry/separation': (context) => const SeparationScreen(),
        '/chemistry/change_detector': (context) => const ChangeDetectorScreen(),
        '/chemistry/atom_builder': (context) => const AtomBuilderScreen(),
        '/chemistry/periodic_table': (context) => const PeriodicTableScreen(),
        '/chemistry/bonding': (context) => const BondingSimulatorScreen(),
        '/chemistry/mole_calculator': (context) => const MoleCalculatorScreen(),
        '/chemistry/kinetics': (context) => const KineticsScreen(),
        '/chemistry/equilibrium': (context) => const EquilibriumScreen(),
        '/chemistry/thermodynamics': (context) => const ThermodynamicsScreen(),

        // Physics Routes
        '/physics/friction': (context) => const FrictionScreen(),
        '/physics/heat_transfer': (context) => const HeatTransferScreen(),
        '/physics/lever': (context) => const LeverScreen(),
        '/physics/motion': (context) => const MotionGraphScreen(),
        '/physics/newtons_laws': (context) => const NewtonsLawsScreen(),
        '/physics/energy': (context) => const EnergySimulatorScreen(),
        '/physics/optics': (context) => const OpticsScreen(),
        '/physics/circuit': (context) => const CircuitSimulatorScreen(),
        '/physics/magnetic_field': (context) => const MagneticFieldScreen(),
        '/physics/wave': (context) => const WaveSimulatorScreen(),
      },
      builder: (context, child) {
        // Apply global constraints or overlay here if needed
        return child!;
      },
    );
  }
}
