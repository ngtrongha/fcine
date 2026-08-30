import 'package:flutter/material.dart';
import 'package:fcine/presentation/theme/app_theme.dart';
import 'package:fcine/presentation/widgets/responsive_layout.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchTap;
  const HomeAppBar({super.key, required this.onSearchTap});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.80),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
          child: Row(
            children: [
              if (!isDesktop)
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white70),
                  onPressed: () {},
                ),
              if (isDesktop) ...[
                const Text(
                  'F-Cine',
                  style: TextStyle(
                    color: Color(0xFFE50914),
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    letterSpacing: -0.5,
                    shadows: [Shadow(color: Color(0xFFE50914), blurRadius: 8)],
                  ),
                ),
                const SizedBox(width: 48),
                _NavLink(label: 'Home', selected: true, onTap: () {}),
                _NavLink(label: 'Movies', onTap: () {}),
                _NavLink(label: 'Series', onTap: () {}),
              ] else
                const Expanded(
                  child: Center(
                    child: Text(
                      'F-Cine',
                      style: TextStyle(
                        color: Color(0xFFE50914),
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(color: Color(0xFFE50914), blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              if (isDesktop)
                Container(
                  width: 260,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(
                        Icons.search_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tìm kiếm phim...',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isDesktop) const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  isDesktop
                      ? Icons.notifications_none_rounded
                      : Icons.search_rounded,
                  color: Colors.white70,
                ),
                onPressed: onSearchTap,
              ),
              if (isDesktop) ...[
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF1A2130),
                  child: Icon(Icons.person_rounded, color: Colors.white70, size: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavLink({
    required this.label,
    this.selected = false,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 24,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
