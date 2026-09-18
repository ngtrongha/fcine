import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../../../../../presentation/theme/app_theme.dart';
import '../../../../../core/extractor/m3u8_parser.dart';

class PlayerSettingsSheet extends StatelessWidget {
  final double playbackSpeed;
  final VoidCallback onChangeSpeed;
  final BoxFit fit;
  final VoidCallback onCycleFit;
  final bool muted;
  final VoidCallback onToggleMute;
  final bool loadingQualities;
  final List<QualityVariant> qualities;
  final VoidCallback onQualityTap;
  final Tracks? tracks;
  final Track? currentTrack;
  final VoidCallback onAudioTap;
  final VoidCallback onSubtitleTap;
  final VoidCallback onExternalSubtitleTap;
  final String? externalSubtitleTitle;
  final int introEndMs;
  final VoidCallback onIntroTap;
  final VoidCallback onCastTap;
  final VoidCallback onPipTap;
  final VoidCallback onExternalTap;
  final VoidCallback onClearIntro;

  const PlayerSettingsSheet({
    super.key,
    required this.playbackSpeed,
    required this.onChangeSpeed,
    required this.fit,
    required this.onCycleFit,
    required this.muted,
    required this.onToggleMute,
    required this.loadingQualities,
    required this.qualities,
    required this.onQualityTap,
    required this.tracks,
    required this.currentTrack,
    required this.onAudioTap,
    required this.onSubtitleTap,
    required this.onExternalSubtitleTap,
    this.externalSubtitleTitle,
    required this.introEndMs,
    required this.onIntroTap,
    required this.onCastTap,
    required this.onPipTap,
    required this.onExternalTap,
    required this.onClearIntro,
  });

  void _popAnd(VoidCallback cb, BuildContext ctx) {
    Navigator.pop(ctx);
    cb();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        hoverColor: Colors.white10,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.speed_rounded, color: Colors.white70), title: Text('Tốc độ: ${playbackSpeed}x', style: const TextStyle(color: Colors.white)), onTap: () => _popAnd(onChangeSpeed, context)),
            ListTile(leading: const Icon(Icons.fit_screen_rounded, color: Colors.white70), title: const Text('Tỉ lệ khung hình', style: TextStyle(color: Colors.white)), onTap: () => _popAnd(onCycleFit, context)),
            ListTile(
              leading: Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white70),
              title: Text(muted ? 'Bật tiếng' : 'Tắt tiếng', style: const TextStyle(color: Colors.white)),
              onTap: () => _popAnd(onToggleMute, context),
            ),
            if (loadingQualities)
              const ListTile(
                leading: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
                title: Text('Đang tải chất lượng...', style: TextStyle(color: Colors.white54)),
              )
            else if (qualities.isNotEmpty)
              ListTile(leading: const Icon(Icons.high_quality_rounded, color: Colors.white70), title: const Text('Chất lượng', style: TextStyle(color: Colors.white)), onTap: () => _popAnd(onQualityTap, context)),
            const Divider(color: Color(0xFF1E293B)),
            if (tracks != null && tracks!.audio.length > 1)
              ListTile(
                leading: const Icon(Icons.audiotrack_rounded, color: Colors.white70),
                title: Text('Âm thanh: ${currentTrack?.audio.language ?? currentTrack?.audio.id ?? "Auto"}', style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 18),
                onTap: () => _popAnd(onAudioTap, context),
              ),
            if (tracks != null && tracks!.subtitle.length > 1)
              ListTile(
                leading: Icon(currentTrack?.subtitle.id == 'no' ? Icons.subtitles_off_rounded : Icons.subtitles_rounded, color: Colors.white70),
                title: Text(currentTrack?.subtitle.id == 'no' ? 'Phụ đề: Tắt' : 'Phụ đề: ${currentTrack?.subtitle.language ?? currentTrack?.subtitle.title ?? currentTrack?.subtitle.id}', style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 18),
                onTap: () => _popAnd(onSubtitleTap, context),
              ),
            ListTile(
              leading: Icon(Icons.subtitles_rounded, color: externalSubtitleTitle != null ? Colors.amber : Colors.white70),
              title: Text(externalSubtitleTitle != null ? 'Phụ đề ngoài: $externalSubtitleTitle' : 'Tải phụ đề từ tệp...', style: const TextStyle(color: Colors.white)),
              subtitle: const Text('Hỗ trợ .srt / .ass / .vtt', style: TextStyle(color: Colors.white54, fontSize: 11)),
              onTap: () => _popAnd(onExternalSubtitleTap, context),
            ),
            ListTile(
              leading: Icon(Icons.skip_next_rounded, color: introEndMs > 0 ? Colors.amber : Colors.white70),
              title: Text(introEndMs > 0 ? 'Skip intro: ${introEndMs ~/ 1000}s' : 'Đặt Skip intro', style: const TextStyle(color: Colors.white)),
              subtitle: Text(introEndMs > 0 ? 'Tự động bỏ qua intro' : 'Lưu vị trí hiện tại làm intro', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              onTap: () => _popAnd(onIntroTap, context),
            ),
            ListTile(leading: const Icon(Icons.cast_rounded, color: Colors.white70), title: const Text('Chromecast / AirPlay', style: TextStyle(color: Colors.white)), onTap: () => _popAnd(onCastTap, context)),
            ListTile(leading: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white70), title: const Text('Picture-in-Picture', style: TextStyle(color: Colors.white)), onTap: () => _popAnd(onPipTap, context)),
            ListTile(leading: const Icon(Icons.open_in_new_rounded, color: Colors.white70), title: const Text('Mở bằng app ngoài', style: TextStyle(color: Colors.white)), onTap: () => _popAnd(onExternalTap, context)),
            if (introEndMs > 0)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text('Xóa Skip intro', style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  Navigator.pop(context);
                  onClearIntro();
                },
              ),
          ]),
        ),
      ),
    );
  }
}

void showQualitySheet(BuildContext ctx, List<QualityVariant> qs, String? selected, Future<void> Function(QualityVariant) onSelect) {
  showModalBottomSheet(
    context: ctx,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => Theme(
      data: Theme.of(ctx).copyWith(splashColor: Colors.white10, highlightColor: Colors.white10, hoverColor: Colors.white10),
      child: ListView(children: [for (final q in qs) ListTile(title: Text(q.label, style: TextStyle(color: selected == q.url ? AppColors.primary : Colors.white)), trailing: selected == q.url ? const Icon(Icons.check_rounded, color: AppColors.primary) : null, onTap: () { Navigator.pop(ctx); onSelect(q); })]),
    ),
  );
}

void showAudioSheet(BuildContext ctx, Tracks tracks, Track? current, Future<void> Function(AudioTrack) onSelect) {
  showModalBottomSheet(
    context: ctx,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => Theme(
      data: Theme.of(ctx).copyWith(splashColor: Colors.white10, highlightColor: Colors.white10, hoverColor: Colors.white10),
      child: ListView(shrinkWrap: true, children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('Chọn Âm Thanh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        for (final a in tracks.audio)
          ListTile(
            title: Text('${a.language ?? a.id}${a.title != null ? " - ${a.title}" : ""}', style: TextStyle(color: current?.audio.id == a.id ? AppColors.primary : Colors.white)),
            trailing: current?.audio.id == a.id ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () { Navigator.pop(ctx); onSelect(a); },
          ),
      ]),
    ),
  );
}

void showSubtitleSheet(BuildContext ctx, Tracks tracks, Track? current, Future<void> Function(SubtitleTrack) onSelect) {
  showModalBottomSheet(
    context: ctx,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => Theme(
      data: Theme.of(ctx).copyWith(splashColor: Colors.white10, highlightColor: Colors.white10, hoverColor: Colors.white10),
      child: ListView(shrinkWrap: true, children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('Chọn Phụ Đề', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        for (final s in tracks.subtitle)
          ListTile(
            title: Text(s.id == 'no' ? 'Tắt' : s.language ?? s.title ?? s.id, style: TextStyle(color: current?.subtitle.id == s.id ? AppColors.primary : Colors.white)),
            trailing: current?.subtitle.id == s.id ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () { Navigator.pop(ctx); onSelect(s); },
          ),
      ]),
    ),
  );
}

void showIntroSheet(BuildContext ctx, int introEndMs, Duration pos, Future<void> Function(int) onSet) {
  String fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  showModalBottomSheet(
    context: ctx,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => Theme(
      data: Theme.of(ctx).copyWith(splashColor: Colors.white10, highlightColor: Colors.white10, hoverColor: Colors.white10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Skip Intro ${introEndMs > 0 ? "(${introEndMs ~/ 1000}s)" : ""}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ListTile(leading: const Icon(Icons.my_location_rounded, color: Colors.white70), title: Text('Đặt intro tại ${fmt(pos)}', style: const TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); onSet(pos.inSeconds); }),
          if (introEndMs > 0) ListTile(leading: const Icon(Icons.clear_rounded, color: Colors.white70), title: const Text('Xóa intro', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); onSet(0); }),
          const Divider(color: Color(0xFF1E293B)),
          ListTile(title: const Text('Intro 30s', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); onSet(30); }),
          ListTile(title: const Text('Intro 60s', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); onSet(60); }),
          ListTile(title: const Text('Intro 90s', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); onSet(90); }),
        ]),
      ),
    ),
  );
}
