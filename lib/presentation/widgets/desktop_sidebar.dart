import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const DesktopSidebar({super.key, required this.selectedIndex, required this.onTap});

  static const double width = 240;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: const Color(0xFF0A0F1A),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Brand logo with glow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 12, spreadRadius: 1),
                    ],
                  ),
                  child: const Center(child: Text('F', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(colors: [Colors.white, Color(0xFFFF6B6B)]).createShader(bounds),
                  child: const Text('F-CINE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2, shadows: [Shadow(color: Color(0xFFE50914), blurRadius: 16)])),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _NavItem(icon: Icons.home_rounded, label: 'Trang Chủ', selected: selectedIndex == 0, onTap: () => onTap(0)),
          _NavItem(icon: Icons.explore_rounded, label: 'Khám Phá', selected: selectedIndex == 1, onTap: () => onTap(1)),
          _NavItem(icon: Icons.video_library_rounded, label: 'Tủ Phim', selected: selectedIndex == 2, onTap: () => onTap(2)),
          _NavItem(icon: Icons.settings_rounded, label: 'Cài Đặt', selected: selectedIndex == 3, onTap: () => onTap(3)),
          const Spacer(),
          // Mini status card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0xFF22C55E), blurRadius: 6)])),
                    const SizedBox(width: 8),
                    const Text('Master Config', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.cloud_done_rounded, size: 14, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 6),
                    Text('Gist • 45ms', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    Spacer(),
                    Icon(Icons.shield_rounded, size: 14, color: Color(0xFF22C55E)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Anti-blocking: Bật', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: selected ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.white.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.onSurfaceVariant, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
              if (selected) ...[
                const Spacer(),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
