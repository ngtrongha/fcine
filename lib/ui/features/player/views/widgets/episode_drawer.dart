import 'package:flutter/material.dart';
import '../../../../../presentation/theme/app_theme.dart';

/// Glassmorphism episode list drawer for mobile player.
/// Reused in both mobile overlay and desktop theater.
/// Shows current episode highlight with equalizer icon.
/// Handles tap to switch episode via [onSelect].

class EpisodeDrawer extends StatelessWidget {
  final List flatEpisodes;
  final dynamic currentEpisode;
  final String currentServer;
  final VoidCallback onClose;
  final Function(dynamic ep, String server) onSelect;

  const EpisodeDrawer({
    super.key,
    required this.flatEpisodes,
    required this.currentEpisode,
    required this.currentServer,
    required this.onClose,
    required this.onSelect,
  });

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Text('Danh Sách Tập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 16),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(dynamic item) {
    final ep = item['ep'];
    final isCurrent = ep.slug == currentEpisode.slug && item['server'] == currentServer;
    return InkWell(
      onTap: () => onSelect(ep, item['server']),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.primary.withValues(alpha: 0.20) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isCurrent ? AppColors.primary.withValues(alpha: 0.30) : Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(child: Text(ep.name, style: TextStyle(color: isCurrent ? AppColors.primary : Colors.white70, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500, fontSize: 13))),
            Icon(isCurrent ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded, color: isCurrent ? AppColors.primary : Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 16)],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: Color(0xFF1E293B)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: flatEpisodes.length,
              itemBuilder: (context, i) => _buildTile(flatEpisodes[i]),
            ),
          ),
        ],
      ),
    );
  }
}
