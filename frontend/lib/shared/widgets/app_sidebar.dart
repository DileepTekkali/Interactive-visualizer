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
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.axisLine)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 40, color: AppTheme.accentGlow),
                  const SizedBox(height: 12),
                  Text(
                    'MathViz Syllabus',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildRouteTile(context, 'Home / Dashboard', AppRoutes.home, Icons.dashboard),
                const Divider(color: AppTheme.axisLine, height: 1),
                
                _buildExpansionTile(
                  title: 'Class 6 - 8 (Middle School)',
                  children: [
                    _buildSubRouteTile(context, 'Basic Geometry', AppRoutes.geometry),
                    _buildSubRouteTile(context, 'Data Handling', '/data_handling'),
                    _buildSubRouteTile(context, 'Number Line', '/number_line'),
                    _buildSubRouteTile(context, 'Mensuration 3D', '/mensuration_3d'),
                  ],
                ),
                _buildExpansionTile(
                  title: 'Class 9 - 10 (High School)',
                  children: [
                    _buildSubRouteTile(context, 'Linear Equations', AppRoutes.linear),
                    _buildSubRouteTile(context, 'Quadratic Graphs', AppRoutes.quadratic),
                    _buildSubRouteTile(context, 'Trigonometry Ratios', AppRoutes.trigonometry),
                    _buildSubRouteTile(context, 'Statistics (Distributions)', AppRoutes.statistics),
                    _buildSubRouteTile(context, 'Coordinate Geometry', '/coordinate_geometry'),
                    _buildSubRouteTile(context, 'Arithmetic Progressions', '/arithmetic_progressions'),
                    _buildSubRouteTile(context, 'Circles & Tangents', '/circles_tangents'),
                  ],
                ),
                _buildExpansionTile(
                  title: 'Class 11 - 12 (Senior Sec.)',
                  children: [
                    _buildSubRouteTile(context, 'Calculus (Limits & Deriv.)', AppRoutes.calculus),
                    _buildSubRouteTile(context, 'Vectors (2D Addition)', AppRoutes.vectors),
                    _buildSubRouteTile(context, 'Conic Sections', '/conic_sections'),
                    _buildSubRouteTile(context, 'Complex Numbers', '/complex_numbers'),
                    _buildSubRouteTile(context, 'Linear Programming', '/linear_programming'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({required String title, required List<Widget> children}) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        iconColor: AppTheme.accent,
        collapsedIconColor: AppTheme.textSecondary,
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        children: children,
      ),
    );
  }

  Widget _buildRouteTile(BuildContext context, String title, String routeName, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accent),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      onTap: () {
        Navigator.pop(context); // Close drawer
        // Replace to avoid infinite stack
        Navigator.pushReplacementNamed(context, routeName);
      },
      hoverColor: AppTheme.accent.withOpacity(0.1),
    );
  }

  Widget _buildSubRouteTile(BuildContext context, String title, String routeName) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 40, right: 16),
      title: Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
      onTap: () {
        Navigator.pop(context); 
        Navigator.pushReplacementNamed(context, routeName);
      },
      hoverColor: AppTheme.accent.withOpacity(0.1),
    );
  }
}
