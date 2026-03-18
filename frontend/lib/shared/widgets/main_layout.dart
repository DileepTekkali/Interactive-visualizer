import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'app_sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isHome = title == 'Home / Dashboard';
    return Scaffold(
      backgroundColor: AppTheme.background,
      endDrawer: const AppSidebar(), // Right-side drawer
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        // Back arrow on the left for non-home screens
        leading: isHome
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
                tooltip: 'Back to Home',
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            fontSize: 18,
          ),
        ),
        actions: [
          // Existing actions (e.g., refresh buttons)
          if (actions != null) ...actions!,
          // Hamburger / menu icon always at top-right
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
              tooltip: 'Open Navigation',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: child,
    );
  }
}
