// Mathematics Subject Screen with categorized subtopics
// Organized by difficulty level

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants.dart';
import '../../shared/widgets/subtopic_card.dart';
import '../../shared/widgets/app_sidebar.dart';

class MathScreen extends StatelessWidget {
  const MathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      endDrawer: const AppSidebar(),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Mathematics',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            actions: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded,
                      color: AppTheme.textSecondary),
                  tooltip: 'Open Navigation',
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                _buildHeader(),
                const SizedBox(height: 32),

                // Foundation Topics
                _buildSection('Foundation', 'Class 6-8', Icons.school_outlined,
                    Colors.greenAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData('Basic Geometry', Icons.category_rounded,
                      Colors.greenAccent, AppRoutes.geometry),
                  SubtopicData('Data Handling', Icons.pie_chart_rounded,
                      Colors.tealAccent, '/data_handling'),
                  SubtopicData('Number Line', Icons.linear_scale_rounded,
                      Colors.cyanAccent, '/number_line'),
                  SubtopicData('Mensuration', Icons.view_in_ar_rounded,
                      Colors.amberAccent, '/mensuration_3d'),
                ]),
                const SizedBox(height: 32),

                // Intermediate Topics
                _buildSection('Intermediate', 'Class 9-10',
                    Icons.menu_book_rounded, Colors.blueAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData('Linear Graphs', Icons.show_chart_rounded,
                      AppTheme.accent, AppRoutes.linear),
                  SubtopicData('Quadratic Graphs', Icons.paragliding_rounded,
                      AppTheme.secondary, AppRoutes.quadratic),
                  SubtopicData('Trigonometry', Icons.waves_rounded,
                      Colors.pinkAccent, AppRoutes.trigonometry),
                  SubtopicData('Coordinate Geo', Icons.grid_4x4_rounded,
                      Colors.blueAccent, '/coordinate_geometry'),
                  SubtopicData('Circles', Icons.circle_outlined,
                      Colors.lightGreenAccent, '/circles_tangents'),
                  SubtopicData('Statistics', Icons.insert_chart_rounded,
                      Colors.purpleAccent, AppRoutes.statistics),
                  SubtopicData(
                      'Progressions',
                      Icons.format_list_numbered_rounded,
                      Colors.indigoAccent,
                      '/arithmetic_progressions'),
                ]),
                const SizedBox(height: 32),

                // Advanced Topics
                _buildSection('Advanced', 'Class 11-12', Icons.science_outlined,
                    Colors.deepOrangeAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData('Calculus', Icons.auto_graph_rounded,
                      Colors.orangeAccent, AppRoutes.calculus),
                  SubtopicData('Vectors', Icons.north_east_rounded,
                      Colors.redAccent, AppRoutes.vectors),
                  SubtopicData('Conic Sections', Icons.architecture_rounded,
                      Colors.deepOrangeAccent, '/conic_sections'),
                  SubtopicData('Complex Numbers', Icons.superscript_rounded,
                      Colors.deepPurpleAccent, '/complex_numbers'),
                  SubtopicData('Linear Programming', Icons.area_chart_rounded,
                      Colors.lightBlueAccent, '/linear_programming'),
                ]),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calculate_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '16 Topics',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Explore graphs, geometry & calculus',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubtopicGrid(BuildContext context, List<SubtopicData> topics) {
    final crossAxisCount = MediaQuery.of(context).size.width > 800 ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return SubtopicCard(
          title: topics[index].title,
          icon: topics[index].icon,
          color: topics[index].color,
          onTap: () => Navigator.pushNamed(context, topics[index].route),
        );
      },
    );
  }
}
