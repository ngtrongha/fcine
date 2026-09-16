import 'package:flutter/material.dart';
import 'package:fcine/core/config/master_config.dart';
import 'package:fcine/presentation/theme/app_theme.dart';

/// Tên hiển thị của 1 nguồn (fallback về baseUrl khi chưa đặt tên).
String sourceDisplayName(SourceConfig s) =>
    s.name.trim().isEmpty ? s.baseUrl : s.name.trim();

/// Nút chọn nguồn phim trực tiếp trên top bar.
///
/// - Desktop: pill button hiện nguồn đang dùng + dropdown danh sách.
/// - Mobile (`compact: true`): icon button mở dialog chọn.
/// - Mục cuối "Quản lý nguồn..." gọi [onManageSources] (mở Cài Đặt).
class SourcePickerButton extends StatelessWidget {
  final List<SourceConfig> sources;
  final String? activeSourceId;
  final ValueChanged<String> onSelected;
  final VoidCallback onManageSources;
  final bool compact;

  const SourcePickerButton({
    super.key,
    required this.sources,
    required this.activeSourceId,
    required this.onSelected,
    required this.onManageSources,
    this.compact = false,
  });

  SourceConfig? get _active {
    if (sources.isEmpty) return null;
    if (activeSourceId != null) {
      for (final s in sources) {
        if (s.id == activeSourceId) return s;
      }
    }
    return sources.first;
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    if (compact) {
      return IconButton(
        tooltip: active == null
            ? 'Chọn nguồn phim'
            : 'Nguồn: ${sourceDisplayName(active)}',
        icon: const Icon(Icons.cloud_rounded, color: Colors.white70),
        onPressed: () => _openDialog(context),
      );
    }
    return PopupMenuButton<String>(
      color: const Color(0xFF1A2130),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: 'Chọn nguồn phim',
      onSelected: (id) {
        if (id == '__manage__') {
          onManageSources();
        } else {
          onSelected(id);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'NGUỒN PHIM',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...sources.map(
          (s) => PopupMenuItem<String>(
            value: s.id,
            child: Row(
              children: [
                Icon(
                  Icons.cloud_rounded,
                  size: 16,
                  color: s.id == active?.id
                      ? AppColors.primary
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sourceDisplayName(s),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        s.baseUrl,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (s.id == active?.id)
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: '__manage__',
          child: Row(
            children: [
              Icon(Icons.settings_rounded, size: 16, color: Colors.white70),
              SizedBox(width: 10),
              Text('Quản lý nguồn...', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_rounded,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                active == null ? 'Chọn nguồn' : sourceDisplayName(active),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDialog(BuildContext context) async {
    final id = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: const Text(
          'Nguồn phim',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ...sources.map(
                (s) => ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.cloud_rounded,
                    color: s.id == _active?.id
                        ? AppColors.primary
                        : const Color(0xFF64748B),
                  ),
                  title: Text(
                    sourceDisplayName(s),
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    s.baseUrl,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                  trailing: s.id == _active?.id
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(ctx, s.id),
                ),
              ),
              const Divider(color: Color(0xFF1E293B)),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white70,
                ),
                title: const Text(
                  'Quản lý nguồn...',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () => Navigator.pop(ctx, '__manage__'),
              ),
            ],
          ),
        ),
      ),
    );
    if (id == null) return;
    if (id == '__manage__') {
      onManageSources();
    } else {
      onSelected(id);
    }
  }
}
