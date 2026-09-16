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
  final VoidCallback? onSearchTap;
  final int selectedNav;
  final ValueChanged<int>? onNavSelected;
  final List<SourceConfig> sources;
  final String? activeSourceId;
  final ValueChanged<String>? onSourceSelected;
  final VoidCallback? onManageSources;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onSearchCleared;

  const HomeAppBar({
    super.key,
    this.onSearchTap,
    this.selectedNav = 0,
    this.onNavSelected,
    this.sources = const [],
    this.activeSourceId,
    this.onSourceSelected,
    this.onManageSources,
    this.searchQuery = '',
    required this.onSearchChanged,
    this.onSearchCleared,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final showInlineSearch = isDesktop || searchQuery.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.80),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
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
            if (showInlineSearch)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 16,
                  8,
                  isDesktop ? 32 : 16,
                  8,
                ),
                child: _InlineSearchField(
                  query: searchQuery,
                  onChanged: onSearchChanged,
                  onCleared: onSearchCleared,
                  isDesktop: isDesktop,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Ô tìm kiếm nội tuyến (inline) cho app bar.
class _InlineSearchField extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCleared;
  final bool isDesktop;

  const _InlineSearchField({
    required this.query,
    required this.onChanged,
    this.onCleared,
    this.isDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: query);
    controller.selection = TextSelection.collapsed(offset: query.length);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            color: Colors.white54,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm phim...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 20),
              onPressed: onCleared,
              tooltip: 'Xóa tìm kiếm',
            ),
          const SizedBox(width: 8),
        ],
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
