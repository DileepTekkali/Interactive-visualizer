import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants.dart';
import '../../shared/widgets/main_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Home / Dashboard',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Math Visualization',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Interactive simulations for deep understanding. Select your class to explore.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              _buildClassSection(
                context,
                title: 'Class 6 - 8',
                subtitle: 'Foundations of Mathematics',
                icon: Icons.school_outlined,
                color: Colors.greenAccent,
                modules: [
                  _ModDef('Basic Geometry', AppRoutes.geometry, Icons.category, Colors.greenAccent),
                  _ModDef('Data Handling', '/data_handling', Icons.pie_chart, Colors.tealAccent),
                  _ModDef('Number Line', '/number_line', Icons.linear_scale, Colors.cyanAccent),
                  _ModDef('Mensuration 2D/3D', '/mensuration_3d', Icons.view_in_ar, Colors.amberAccent),
                ],
              ),
              const SizedBox(height: 16),
              _buildClassSection(
                context,
                title: 'Class 9 - 10',
                subtitle: 'Secondary Core Topics',
                icon: Icons.menu_book,
                color: Colors.blueAccent,
                modules: [
                  _ModDef('Linear Graphs', AppRoutes.linear, Icons.show_chart, AppTheme.accent),
                  _ModDef('Quadratic Graphs', AppRoutes.quadratic, Icons.paragliding, AppTheme.secondary),
                  _ModDef('Trigonometry', AppRoutes.trigonometry, Icons.waves, Colors.pinkAccent),
                  _ModDef('Coordinate Geo', '/coordinate_geometry', Icons.grid_4x4, Colors.blueAccent),
                  _ModDef('Circles', '/circles_tangents', Icons.radio_button_unchecked, Colors.lightGreenAccent),
                  _ModDef('Statistics', AppRoutes.statistics, Icons.insert_chart_outlined, Colors.purpleAccent),
                  _ModDef('Progressions', '/arithmetic_progressions', Icons.format_list_numbered, Colors.indigoAccent),
                ],
              ),
              const SizedBox(height: 16),
              _buildClassSection(
                context,
                title: 'Class 11 - 12',
                subtitle: 'Advanced Mathematics',
                icon: Icons.science_outlined,
                color: Colors.deepOrangeAccent,
                modules: [
                  _ModDef('Calculus: Limits', AppRoutes.calculus, Icons.auto_graph, Colors.orangeAccent),
                  _ModDef('Vectors', AppRoutes.vectors, Icons.north_east, Colors.redAccent),
                  _ModDef('Conic Sections', '/conic_sections', Icons.architecture, Colors.deepOrangeAccent),
                  _ModDef('Complex Numbers', '/complex_numbers', Icons.superscript, Colors.deepPurpleAccent),
                  _ModDef('Linear Prog', '/linear_programming', Icons.area_chart, Colors.lightBlueAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<_ModDef> modules,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: title == 'Class 9 - 10', // Expand middle one by default
          iconColor: color,
          collapsedIconColor: AppTheme.textSecondary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 5 : (MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 500 ? 2 : 1)),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemCount: modules.length,
                itemBuilder: (context, i) {
                  final mod = modules[i];
                  return InkWell(
                    onTap: () => Navigator.pushReplacementNamed(context, mod.route),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: mod.color.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: mod.color.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(mod.icon, color: mod.color, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mod.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModDef {
  final String title;
  final String route;
  final IconData icon;
  final Color color;
  _ModDef(this.title, this.route, this.icon, this.color);
}
