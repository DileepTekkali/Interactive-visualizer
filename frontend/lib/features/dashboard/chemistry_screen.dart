// Chemistry Subject Screen with categorized subtopics
// Organized by topic type

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/subtopic_card.dart';

class ChemistryScreen extends StatelessWidget {
  const ChemistryScreen({super.key});

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
              'Chemistry',
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

                // Atomic Structure
                _buildSection('Atomic Structure', 'Building Blocks',
                    Icons.bubble_chart_rounded, Colors.blueAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData('Atom Builder', Icons.bubble_chart_rounded,
                      Colors.blueAccent, '/chemistry/atom_builder'),
                  SubtopicData('Periodic Table', Icons.grid_on_rounded,
                      Colors.orangeAccent, '/chemistry/periodic_table'),
                ]),
                const SizedBox(height: 32),

                // Chemical Bonding
                _buildSection('Chemical Bonding', 'Bonds & Reactions',
                    Icons.link_rounded, Colors.greenAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData('Chemical Bonding', Icons.link_rounded,
                      Colors.greenAccent, '/chemistry/bonding'),
                  SubtopicData('Mole Calculator', Icons.calculate_rounded,
                      Colors.redAccent, '/chemistry/mole_calculator'),
                ]),
                const SizedBox(height: 32),

                // Reactions & Equilibrium
                _buildSection('Reactions', 'Kinetics & Equilibrium',
                    Icons.show_chart_rounded, Colors.purpleAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData('Reaction Kinetics', Icons.show_chart_rounded,
                      Colors.yellowAccent, '/chemistry/kinetics'),
                  SubtopicData('Equilibrium', Icons.balance_rounded,
                      Colors.lightBlueAccent, '/chemistry/equilibrium'),
                  SubtopicData('Thermodynamics', Icons.thermostat_rounded,
                      Colors.pinkAccent, '/chemistry/thermodynamics'),
                ]),
                const SizedBox(height: 32),

                // Separation & Changes
                _buildSection('Separation', 'Methods & Changes',
                    Icons.filter_alt_rounded, Colors.tealAccent),
                const SizedBox(height: 16),
                _buildSubtopicGrid(context, [
                  SubtopicData('Separation Process', Icons.filter_alt_rounded,
                      Colors.tealAccent, '/chemistry/separation'),
                  SubtopicData('Change Detector', Icons.compare_arrows_rounded,
                      Colors.purpleAccent, '/chemistry/change_detector'),
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
          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
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
              Icons.science_rounded,
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
                  '9 Topics',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Explore atoms, reactions & elements',
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
