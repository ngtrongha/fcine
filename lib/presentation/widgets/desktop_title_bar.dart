import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_theme.dart';

/// Chỉ dùng custom title bar (ẩn thanh native) trên Windows/Linux.
/// macOS + mobile + web giữ thanh hệ thống.
bool get useCustomTitleBar {
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    default:
      return false;
  }
}

/// Thanh tiêu đề cửa sổ tự vẽ theo theme Cinematic Dark:
/// logo + tên app bên trái, kéo-thả để di chuyển cửa sổ,
/// cụm nút Thu nhỏ / Phóng to / Đóng bên phải kiểu Windows.
class DesktopTitleBar extends StatefulWidget {
  const DesktopTitleBar({super.key});

  @override
  State<DesktopTitleBar> createState() => _DesktopTitleBarState();
}

class _DesktopTitleBarState extends State<DesktopTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncMaximized();
  }

  Future<void> _syncMaximized() async {
    try {
      final v = await windowManager.isMaximized();
      if (mounted) setState(() => _isMaximized = v);
    } catch (_) {
      // Chạy trong test / nền tảng không hỗ trợ -> giữ mặc định.
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    if (mounted) setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) setState(() => _isMaximized = false);
  }

  Future<void> _minimize() async {
    try {
      await windowManager.minimize();
    } catch (_) {}
  }

  Future<void> _toggleMaximize() async {
    try {
      if (_isMaximized) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    } catch (_) {}
  }

  Future<void> _close() async {
    try {
      await windowManager.close();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0F1A),
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: _toggleMaximize,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Text(
                            'F',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'F-Cine',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _CaptionButton(
            icon: Icons.remove_rounded,
            tooltip: 'Thu nhỏ',
            onTap: _minimize,
          ),
          _CaptionButton(
            icon: _isMaximized
                ? Icons.filter_none_rounded
                : Icons.crop_square_rounded,
            tooltip: _isMaximized ? 'Khôi phục' : 'Phóng to',
            onTap: _toggleMaximize,
          ),
          _CaptionButton(
            icon: Icons.close_rounded,
            tooltip: 'Đóng',
            danger: true,
            onTap: _close,
          ),
        ],
      ),
    );
  }
}

class _CaptionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool danger;
  const _CaptionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.danger = false,
  });

  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.tooltip,
          child: Container(
            width: 48,
            height: double.infinity,
            color: _hover
                ? (widget.danger
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.08))
                : Colors.transparent,
            child: Icon(
              widget.icon,
              size: 16,
              color: _hover && widget.danger
                  ? Colors.white
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
