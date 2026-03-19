import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants.dart';
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
      endDrawer: const AppSidebar(),
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: isHome
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textPrimary),
                tooltip: 'Go Back',
                onPressed: () => Navigator.pop(context),
              ),
        title: GestureDetector(
          onTap: () {
            if (!isHome) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (route) => false);
            }
          },
          child: MouseRegion(
            cursor:
                isHome ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isHome)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.home_rounded,
                        color: AppTheme.accent, size: 20),
                  ),
                Text(
                  'study_viz',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: isHome ? AppTheme.accent : AppTheme.textPrimary,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (actions != null) ...actions!,
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
