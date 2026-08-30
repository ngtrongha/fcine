import 'package:flutter/material.dart';

import 'responsive_layout.dart';
import 'desktop_sidebar.dart';
import '../theme/app_theme.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            DesktopSidebar(selectedIndex: selectedIndex, onTap: onTabSelected),
            VerticalDivider(
              width: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile: floating glass bottom nav
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: _FloatingBottomNav(
        selectedIndex: selectedIndex,
        onTap: onTabSelected,
      ),
      extendBody: true,
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _FloatingBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: NavigationBar(
          height: 64,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primary.withValues(alpha: 0.18),
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: selectedIndex,
          onDestinationSelected: onTap,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Trang Chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Tìm Kiếm',
            ),
            NavigationDestination(
              icon: Icon(Icons.video_library_rounded),
              selectedIcon: Icon(Icons.video_library_rounded),
              label: 'Tủ Phim',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Cài Đặt',
            ),
          ],
        ),
      ),
    );
  }
}
