// Physics Subject Screen with categorized subtopics
// Organized by topic type

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/subtopic_card.dart';

class PhysicsScreen extends StatelessWidget {
  const PhysicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
              'Physics',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.textSecondary),
                onPressed: () {},
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

                // Mechanics
                _buildSection('Mechanics', 'Forces & Motion',
                    Icons.sports_baseball_rounded, Colors.blueAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData("Newton's Laws", Icons.sports_baseball_rounded,
                      Colors.blueAccent, '/physics/newtons_laws'),
                  SubtopicData('Motion Graph', Icons.analytics_rounded,
                      Colors.greenAccent, '/physics/motion'),
                  SubtopicData('Friction', Icons.sports_tennis_rounded,
                      Colors.orangeAccent, '/physics/friction'),
                  SubtopicData(
                      'Work & Energy',
                      Icons.battery_charging_full_rounded,
                      Colors.yellowAccent,
                      '/physics/energy'),
                  SubtopicData('Lever Machine', Icons.keyboard_capslock_rounded,
                      Colors.tealAccent, '/physics/lever'),
                ]),
                const SizedBox(height: 32),

                // Waves & Optics
                _buildSection('Waves & Optics', 'Light & Sound',
                    Icons.waves_rounded, Colors.purpleAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData('Wave Simulator', Icons.waves_rounded,
                      Colors.cyanAccent, '/physics/wave'),
                  SubtopicData('Optics', Icons.wb_sunny_rounded,
                      Colors.amberAccent, '/physics/optics'),
                  SubtopicData('Magnetic Field', Icons.lens_blur_rounded,
                      Colors.purpleAccent, '/physics/magnetic_field'),
                ]),
                const SizedBox(height: 32),

                // Thermal & Electric
                _buildSection('Energy', 'Heat & Electricity',
                    Icons.local_fire_department_rounded, Colors.redAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData(
                      'Heat Transfer',
                      Icons.local_fire_department_rounded,
                      Colors.redAccent,
                      '/physics/heat_transfer'),
                  SubtopicData('Circuits', Icons.electrical_services_rounded,
                      Colors.lightBlueAccent, '/physics/circuit'),
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
          colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
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
              Icons.bolt_rounded,
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
                  '10 Topics',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Explore forces, energy & waves',
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
