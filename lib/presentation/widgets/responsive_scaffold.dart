import 'package:flutter/material.dart';

import 'responsive_layout.dart';
import 'desktop_sidebar.dart';
import 'desktop_title_bar.dart';
import '../theme/app_theme.dart';
import '../../core/di/injection.dart';

/// Branch trong GoRouter: 0=Video, 1=Online, 2=Tủ Phim, 3=Cài Đặt.
/// Chưa có nguồn phim -> ẩn Online + Tủ Phim, nav chỉ còn [Video, Cài Đặt].
int _branchToNav(int branch, bool hasSource) {
  if (hasSource) return branch;
  return branch == 3 ? 1 : 0;
}

int _navToBranch(int nav, bool hasSource) {
  if (hasSource) return nav;
  return nav == 1 ? 3 : 0;
}

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
    final hasSource = hasConfiguredSource();

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            if (useCustomTitleBar) const DesktopTitleBar(),
            Expanded(
              child: Row(
                children: [
                  DesktopSidebar(
                    selectedIndex: selectedIndex,
                    onTap: onTabSelected,
                    hasSource: hasSource,
                  ),
                  VerticalDivider(
                    width: 1,
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile: floating glass bottom nav
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: _FloatingBottomNav(
        selectedIndex: _branchToNav(selectedIndex, hasSource),
        onTap: (nav) => onTabSelected(_navToBranch(nav, hasSource)),
        hasSource: hasSource,
      ),
      extendBody: true,
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool hasSource;
  const _FloatingBottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.hasSource,
  });

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
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.play_circle_rounded),
              selectedIcon: Icon(Icons.play_circle_rounded),
              label: 'Video',
            ),
            if (hasSource) ...[
              const NavigationDestination(
                icon: Icon(Icons.cloud_rounded),
                selectedIcon: Icon(Icons.cloud_rounded),
                label: 'Online',
              ),
              const NavigationDestination(
                icon: Icon(Icons.video_library_rounded),
                selectedIcon: Icon(Icons.video_library_rounded),
                label: 'Tủ Phim',
              ),
            ],
            const NavigationDestination(
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
