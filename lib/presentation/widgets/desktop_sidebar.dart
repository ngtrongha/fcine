import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool hasSource;
  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.hasSource = true,
  });

  static const double width = 240;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: const Color(0xFF0A0F1A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Brand
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF5252), AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'F-CINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'MENU',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _NavItem(
            icon: Icons.play_circle_rounded,
            label: 'Video',
            subtitle: 'File trên thiết bị',
            selected: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          if (hasSource) ...[
            _NavItem(
              icon: Icons.cloud_rounded,
              label: 'Online',
              subtitle: 'Kho phim trực tuyến',
              selected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.video_library_rounded,
              label: 'Tủ Phim',
              subtitle: 'Lịch sử & yêu thích',
              selected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Cài Đặt',
            subtitle: 'Nguồn phim & app',
            selected: selectedIndex == 3,
            onTap: () => onTap(3),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'F-Cine v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF475569), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.primary, Color(0xFF8E0A10)],
              )
            : null,
        color: selected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: selected
            ? null
            : Colors.white.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.18)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: selected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.75)
                            : const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
