import 'package:dio/dio.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extractor/m3u8_parser.dart';
import '../../../../data/repositories/history_repository.dart';

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

Duration clampSeek(Duration pos, Duration dur, int deltaSec) {
  final t = pos + Duration(seconds: deltaSec);
  if (t < Duration.zero) return Duration.zero;
  if (t > dur) return dur;
  return t;
}

bool shouldSkipIntro({
  required int introEndMs,
  required bool hasSkipped,
  required Duration pos,
}) {
  if (introEndMs <= 0 || hasSkipped) return false;
  final ms = pos.inMilliseconds;
  return ms > 1000 && ms < introEndMs && ms < introEndMs - 500;
}

bool shouldSaveProgress(Duration pos, Duration dur) {
  if (dur.inMilliseconds == 0) return false;
  if (pos.inMilliseconds < 5000) return false;
  if (pos.inMilliseconds / dur.inMilliseconds > 0.95) return false;
  return true;
}

class QualityService {
  static Future<List<QualityVariant>> load(String url) async {
    final parser = M3u8Parser(Dio());
    return parser.parseMaster(url);
  }

  static Future<void> switchQuality(
    Player player,
    QualityVariant q,
    Duration currentPos,
  ) async {
    await player.open(Media(q.url), play: true);
    if (currentPos.inMilliseconds <= 1000) return;
    // open() reset vị trí về 0 — phải đợi media mới load xong rồi seek về,
    // seek mù sau delay cố định dễ bị nuốt khiến phim chạy lại từ đầu.
    try {
      await player.stream.duration
          .firstWhere((d) => d.inMilliseconds > 0)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return;
    }
    try {
      await player.seek(currentPos);
      await Future.delayed(const Duration(milliseconds: 600));
      final pos = player.state.position.inMilliseconds;
      if ((pos - currentPos.inMilliseconds).abs() > 5000) {
        await player.seek(currentPos);
      }
    } catch (_) {}
  }
}

class IntroService {
  static Future<int> load(String slug) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('intro_$slug') ?? 0;
  }

  static Future<void> save(String slug, int ms) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('intro_$slug', ms);
  }
}

class ProgressService {
  static Future<void> save({
    required dynamic movie,
    required dynamic episode,
    required String serverName,
    required Duration pos,
    required Duration dur,
  }) async {
    if (!shouldSaveProgress(pos, dur)) return;
    final repo = getIt<HistoryRepository>();
    try {
      dynamic src;
      try {
        src = (movie as dynamic).sourceId;
      } catch (_) {
        src = null;
      }
      await repo.saveProgress(
        movieSlug: movie.slug,
        movieName: movie.name,
        posterUrl: movie.posterUrl,
        episodeName: episode.name,
        episodeSlug: episode.slug,
        serverName: serverName,
        positionMs: pos.inMilliseconds,
        durationMs: dur.inMilliseconds,
        sourceId: src is String && src.isNotEmpty ? src : null,
      );
    } catch (_) {}
  }
}

class OutroService {
  static Future<int> load(String slug) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('outro_$slug') ?? 0;
  }

  static Future<void> save(String slug, int ms) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('outro_$slug', ms);
  }
}
