import 'package:flutter/material.dart';
import 'package:fcine/core/config/master_config.dart';
import 'package:fcine/presentation/theme/app_theme.dart';
import 'package:fcine/presentation/widgets/responsive_layout.dart';
import 'source_picker_button.dart';

/// Ánh xạ tab nav trên top bar <-> category của Home feed.
/// Home = Tất Cả, Movies = Phim Lẻ, Series = Phim Bộ.
/// Các chip khác (Phim Mới, Hoạt Hình, TV Shows) không gắn tab nào (-1).
const homeNavCategories = ['Tất Cả', 'Phim Lẻ', 'Phim Bộ'];
const homeNavLabels = ['Home', 'Movies', 'Series'];

/// Index tab nav cho 1 category, -1 khi category không gắn tab nào.
int homeNavIndexForCategory(String category) =>
    homeNavCategories.indexOf(category);

/// Category tương ứng 1 tab nav.
String homeCategoryForNavIndex(int index) =>
    homeNavCategories[index.clamp(0, homeNavCategories.length - 1)];

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchTap;
  final int selectedNav;
  final ValueChanged<int>? onNavSelected;
  final List<SourceConfig> sources;
  final String? activeSourceId;
  final ValueChanged<String>? onSourceSelected;
  final VoidCallback? onManageSources;

  const HomeAppBar({
    super.key,
    required this.onSearchTap,
    this.selectedNav = 0,
    this.onNavSelected,
    this.sources = const [],
    this.activeSourceId,
    this.onSourceSelected,
    this.onManageSources,
  });

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
                const SizedBox(width: 32),
                _SegmentedNav(
                  selected: selectedNav,
                  onSelected: onNavSelected ?? (_) {},
                ),
                if (sources.isNotEmpty &&
                    onSourceSelected != null &&
                    onManageSources != null) ...[
                  const SizedBox(width: 12),
                  SourcePickerButton(
                    sources: sources,
                    activeSourceId: activeSourceId,
                    onSelected: onSourceSelected!,
                    onManageSources: onManageSources!,
                  ),
                ],
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
              if (isDesktop && MediaQuery.of(context).size.width >= 1280)
                GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
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
                ),
              if (isDesktop &&
                  MediaQuery.of(context).size.width >= 1280)
                const SizedBox(width: 16),
              if (!isDesktop &&
                  sources.isNotEmpty &&
                  onSourceSelected != null &&
                  onManageSources != null)
                SourcePickerButton(
                  compact: true,
                  sources: sources,
                  activeSourceId: activeSourceId,
                  onSelected: onSourceSelected!,
                  onManageSources: onManageSources!,
                ),
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

/// Cụm tab Home / Movies / Series kiểu segmented control.
class _SegmentedNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  const _SegmentedNav({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(homeNavLabels.length, (i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                homeNavLabels[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
