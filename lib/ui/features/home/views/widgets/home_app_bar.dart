import 'package:flutter/material.dart';
import 'package:fcine/core/config/master_config.dart';
import 'package:fcine/presentation/theme/app_theme.dart';
import 'package:fcine/presentation/widgets/responsive_layout.dart';
import 'source_picker_button.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<SourceConfig> sources;
  final String? activeSourceId;
  final ValueChanged<String>? onSourceSelected;
  final VoidCallback? onManageSources;

  /// Tìm kiếm nhanh nội tuyến (desktop: ô search nằm ngay trong hàng
  /// app bar). Mobile dùng ô search riêng trên danh sách nên để null.
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchCleared;
  final ValueChanged<String>? onSearchSubmitted;

  const HomeAppBar({
    super.key,
    this.sources = const [],
    this.activeSourceId,
    this.onSourceSelected,
    this.onManageSources,
    this.searchController,
    this.onSearchChanged,
    this.onSearchCleared,
    this.onSearchSubmitted,
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
                const Spacer(),
                if (searchController != null && onSearchChanged != null)
                  SizedBox(
                    width: 260,
                    child: QuickSearchField(
                      controller: searchController!,
                      onChanged: onSearchChanged!,
                      onCleared: onSearchCleared ?? () {},
                      onSubmitted: onSearchSubmitted,
                      height: 36,
                    ),
                  ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF1A2130),
                  child: Icon(Icons.person_rounded, color: Colors.white70, size: 18),
                ),
              ] else ...[
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
                if (sources.isNotEmpty &&
                    onSourceSelected != null &&
                    onManageSources != null)
                  SourcePickerButton(
                    compact: true,
                    sources: sources,
                    activeSourceId: activeSourceId,
                    onSelected: onSourceSelected!,
                    onManageSources: onManageSources!,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Ô tìm kiếm nhanh: lọc danh sách ngay tại chỗ, không chuyển trang.
/// Nhấn Enter (submit) -> chuyển sang trang tìm kiếm server (nếu [onSubmitted]
/// được truyền). Dùng chung cho app bar desktop và thanh search mobile.
class QuickSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;
  final ValueChanged<String>? onSubmitted;
  final double height;

  const QuickSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onCleared,
    this.onSubmitted,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search_rounded,
            color: Colors.white54,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm nhanh...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              textInputAction: onSubmitted != null
                  ? TextInputAction.search
                  : TextInputAction.done,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onCleared,
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.clear_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
