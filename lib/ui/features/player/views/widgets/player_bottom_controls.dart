import 'package:flutter/material.dart';
import '../../../../../presentation/theme/app_theme.dart';
import '../../logic/player_logic.dart';

class PlayerBottomControls extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onSeek;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;
  final bool hasNext;
  final VoidCallback onNext;
  final bool loadingQualities;
  final List qualities;
  final String? selectedQualityUrl;
  final VoidCallback onQualityTap;
  final VoidCallback onToggleEpisodeDrawer;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const PlayerBottomControls({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    required this.onSeekStart,
    required this.onSeekEnd,
    required this.hasNext,
    required this.onNext,
    required this.loadingQualities,
    required this.qualities,
    required this.selectedQualityUrl,
    required this.onQualityTap,
    required this.onToggleEpisodeDrawer,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xE6000000)]),
      ),
      child: Column(children: [
        Row(children: [
          Text(formatDuration(position), style: const TextStyle(color: Colors.white, fontSize: 12, fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
              ),
              child: Stack(
                children: [
                  Slider(
                    value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble()),
                    max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1,
                    onChanged: onSeek,
                    onChangeStart: (_) => onSeekStart(),
                    onChangeEnd: (_) => onSeekEnd(),
                  ),
                  if (duration.inMilliseconds > 0)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${((position.inMilliseconds / duration.inMilliseconds) * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(formatDuration(duration), style: const TextStyle(color: Colors.white60, fontSize: 12, fontFeatures: [FontFeature.tabularFigures()])),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          TextButton.icon(
            onPressed: hasNext ? onNext : null,
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 18),
            label: const Text('Tập Tiếp', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          if (loadingQualities)
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)))
          else if (qualities.isNotEmpty)
            TextButton.icon(
              onPressed: onQualityTap,
              icon: const Icon(Icons.high_quality_rounded, color: Colors.white70, size: 18),
              label: Text(qualities.first.label as String, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: onToggleEpisodeDrawer,
            icon: const Icon(Icons.featured_play_list_rounded, color: Colors.white70, size: 18),
            label: const Text('Danh Sách Tập', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          IconButton(
            icon: Icon(isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, color: Colors.white70, size: 20),
            onPressed: onToggleFullscreen,
          ),
        ]),
      ]),
    );
  }
}
