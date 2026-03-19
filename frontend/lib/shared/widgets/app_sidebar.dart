import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.axisLine)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school,
                      size: 28, color: AppTheme.accentGlow),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'study_viz',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accent,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Interactive Learning',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // MATHEMATICS Section
                _buildSectionHeader('MATHEMATICS', Icons.calculate),
                _buildSubjectTile(
                  context,
                  'Algebra',
                  Icons.functions,
                  [
                    _SubItem('Linear Equations', '/linear',
                        'Solve equations with two variables'),
                    _SubItem('Quadratic Graphs', '/quadratic',
                        'Parabolas and roots'),
                    _SubItem('Arithmetic Progressions',
                        '/arithmetic_progressions', 'Sequences and series'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Geometry',
                  Icons.category,
                  [
                    _SubItem('Basic Shapes', '/geometry',
                        'Circles, triangles, polygons'),
                    _SubItem('Coordinate Geometry', '/coordinate_geometry',
                        'Points and lines on plane'),
                    _SubItem('Circles & Tangents', '/circles_tangents',
                        'Circle properties'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Trigonometry',
                  Icons.architecture,
                  [
                    _SubItem('Trigonometry Ratios', '/trigonometry',
                        'Sin, Cos, Tan functions'),
                    _SubItem('Conic Sections', '/conic_sections',
                        'Ellipse, Parabola, Hyperbola'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Calculus',
                  Icons.timeline,
                  [
                    _SubItem(
                        'Limits & Derivatives', '/calculus', 'Rate of change'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Advanced Math',
                  Icons.auto_graph,
                  [
                    _SubItem(
                        'Vectors (2D)', '/vectors', 'Direction and magnitude'),
                    _SubItem('Complex Numbers', '/complex_numbers',
                        'Real and imaginary'),
                    _SubItem('Linear Programming', '/linear_programming',
                        'Optimization'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Statistics & Data',
                  Icons.bar_chart,
                  [
                    _SubItem('Data Handling', '/data_handling',
                        'Collect and organize data'),
                    _SubItem('Statistics', '/statistics', 'Mean, median, mode'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Basic Math',
                  Icons.numbers,
                  [
                    _SubItem('Number Line', '/number_line',
                        'Positive and negative numbers'),
                    _SubItem('Mensuration 3D', '/mensuration_3d',
                        'Volume and surface area'),
                  ],
                ),

                const Divider(color: AppTheme.axisLine, height: 24),

                // PHYSICS Section
                _buildSectionHeader('PHYSICS', Icons.science),
                _buildSubjectTile(
                  context,
                  'Mechanics',
                  Icons.speed,
                  [
                    _SubItem("Newton's Laws", '/physics/newtons_laws',
                        'F = ma calculations'),
                    _SubItem('Friction Simulator', '/physics/friction',
                        'Inclined plane forces'),
                    _SubItem('Lever Machine', '/physics/lever',
                        'Mechanical advantage'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Energy & Motion',
                  Icons.bolt,
                  [
                    _SubItem('Motion Graphs', '/physics/motion',
                        'Position and velocity'),
                    _SubItem('Energy Simulator', '/physics/energy',
                        'Kinetic and potential'),
                    _SubItem(
                        'Wave Simulator', '/physics/wave', 'Wave properties'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Electricity & Magnetism',
                  Icons.electric_bolt,
                  [
                    _SubItem('Circuit Simulator', '/physics/circuit',
                        'Series and parallel circuits'),
                    _SubItem('Magnetic Field', '/physics/magnetic_field',
                        'Field lines and poles'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Optics & Waves',
                  Icons.visibility,
                  [
                    _SubItem(
                        "Snell's Law", '/physics/optics', 'Light refraction'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Thermal Physics',
                  Icons.thermostat,
                  [
                    _SubItem('Heat Transfer', '/physics/heat_transfer',
                        'Conduction, convection'),
                  ],
                ),

                const Divider(color: AppTheme.axisLine, height: 24),

                // CHEMISTRY Section
                _buildSectionHeader('CHEMISTRY', Icons.biotech),
                _buildSubjectTile(
                  context,
                  'Atomic Structure',
                  Icons.blur_circular,
                  [
                    _SubItem('Atom Builder', '/chemistry/atom_builder',
                        'Protons, neutrons, electrons'),
                    _SubItem('Periodic Table', '/chemistry/periodic_table',
                        'Element explorer'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Chemical Bonding',
                  Icons.link,
                  [
                    _SubItem('Bonding Simulator', '/chemistry/bonding',
                        'Ionic, covalent, metallic'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Chemical Processes',
                  Icons.science,
                  [
                    _SubItem('Separation Process', '/chemistry/separation',
                        'Filtration, evaporation'),
                    _SubItem('Mole Calculator', '/chemistry/mole_calculator',
                        'Moles and mass'),
                  ],
                ),
                _buildSubjectTile(
                  context,
                  'Reaction Chemistry',
                  Icons.transform,
                  [
                    _SubItem('Le Chatelier Principle', '/chemistry/equilibrium',
                        'Equilibrium shifts'),
                    _SubItem('Reaction Kinetics', '/chemistry/kinetics',
                        'Rate of reactions'),
                    _SubItem('Thermodynamics', '/chemistry/thermodynamics',
                        'Energy changes'),
                    _SubItem('Change Detector', '/chemistry/change_detector',
                        'Physical vs chemical'),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.accent,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(
      BuildContext context, String title, IconData icon, List<_SubItem> items) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.textSecondary, size: 20),
        iconColor: AppTheme.accent,
        collapsedIconColor: AppTheme.textSecondary,
        title: Text(
          title,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary),
        ),
        children: items.map((item) => _buildSubItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildSubItem(BuildContext context, _SubItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      dense: true,
      leading: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      title: Text(
        item.title,
        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
      ),
      subtitle: Text(
        item.subtitle,
        style: GoogleFonts.inter(
            fontSize: 10, color: AppTheme.textSecondary.withValues(alpha: 0.6)),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
            context, item.route, (route) => false);
      },
      hoverColor: AppTheme.accent.withValues(alpha: 0.1),
    );
  }
}

class _SubItem {
  final String title;
  final String route;
  final String subtitle;

  _SubItem(this.title, this.route, this.subtitle);
}
