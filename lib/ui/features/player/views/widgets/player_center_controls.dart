import 'package:flutter/material.dart';
import '../../../../../presentation/theme/app_theme.dart';

class PlayerCenterControls extends StatelessWidget {
  final double brightness;
  final ValueChanged<double> onBrightnessChanged;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onSeekBack;
  final VoidCallback onSeekForward;
  final double volume;
  final bool muted;
  final ValueChanged<double> onVolumeChanged;

  const PlayerCenterControls({
    super.key,
    required this.brightness,
    required this.onBrightnessChanged,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onSeekBack,
    required this.onSeekForward,
    required this.volume,
    required this.muted,
    required this.onVolumeChanged,
  });

  Widget _sideSlider({required IconData icon, required double value, required ValueChanged<double> onChanged, required Color active}) {
    return Container(
      width: 40,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(children: [
        Padding(padding: const EdgeInsets.only(top: 12), child: Icon(icon, color: Colors.white70, size: 16)),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: value,
              min: 0,
              max: 1,
              activeColor: active,
              inactiveColor: Colors.white24,
              thumbColor: Colors.white,
              onChanged: onChanged,
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: _sideSlider(
          icon: Icons.light_mode_rounded,
          value: brightness,
          onChanged: onBrightnessChanged,
          active: Colors.white.withValues(alpha: 0.80),
        ),
      ),
      Row(children: [
        IconButton(icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 40), onPressed: onSeekBack),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onTogglePlay,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.20),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x66E50914), blurRadius: 12)],
              ),
              child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 36),
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 40), onPressed: onSeekForward),
      ]),
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: _sideSlider(
          icon: Icons.volume_up_rounded,
          value: muted ? 0 : volume,
          onChanged: onVolumeChanged,
          active: AppColors.primary,
        ),
      ),
    ]);
  }
}
