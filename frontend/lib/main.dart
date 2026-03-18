import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants.dart';
import 'features/home/home_screen.dart';
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
        AppRoutes.home: (context) => const HomeScreen(),
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
      },
      builder: (context, child) {
        // Apply global constraints or overlay here if needed
        return child!;
      },
    );
  }
}
