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

/// Có nên phục hồi stream bị reset không (pure, để dễ test).
/// Luồng HLS có ads chèn (discontinuity/timeline riêng) hoặc segment lỗi
/// làm mpv báo vị trí tụt sâu so với mốc ổn định -> seek về mốc đó.
/// - seekLocked: đang seek/open chủ động (tua, đổi chất lượng/tập, resume)
///   -> vị trí đổi là có chủ đích, không phải reset.
/// - tụt ít hơn ngưỡng (nhiễu buffer/discontinuity nhỏ) -> bỏ qua.
/// - quá số lần phục hồi tối đa -> thôi, tránh lặp vô hạn khi ads lỗi
///   dai dẳng (lúc đó để user tự tua tay).
bool shouldRecoverStream({
  required int stableMs,
  required int posMs,
  required bool seekLocked,
  required int recoverCount,
  int dropThresholdMs = 15000,
  int maxRecoveries = 3,
}) {
  if (seekLocked) return false;
  if (posMs >= stableMs) return false;
  if (stableMs - posMs < dropThresholdMs) return false;
  if (recoverCount >= maxRecoveries) return false;
  return true;
}

/// Có nên bỏ qua lượt lưu tiến trình này không: vị trí đang tụt sâu so với
/// mốc ổn định (stream vừa reset) -> giữ tiến trình cũ, không ghi đè bằng
/// vị trí sau reset (nếu không sẽ mất mốc resume đúng).
bool shouldSkipSaveOnRegress({
  required int stableMs,
  required int posMs,
  int dropThresholdMs = 15000,
}) =>
    stableMs - posMs > dropThresholdMs;

/// `completed` có phải hết tập thật không: vị trí phải ở gần cuối phim.
/// Stream reset giữa chừng (ads/HLS lỗi) cũng có thể bắn completed giả —
/// lúc đó vị trí còn xa cuối phim, phải bỏ qua để không nhảy tập bậy và
/// không xóa tiến trình đang xem dở.
bool isGenuineCompletion({
  required int posMs,
  required int durMs,
  int tailMs = 15000,
}) {
  if (durMs <= 0) return false;
  return posMs >= durMs - tailMs;
}

/// Lần tự skip trước có "ăn thua" không: vị trí hiện tại vẫn loanh quanh
/// điểm đáp của lần skip trước (không tiến được) mà lại đứng tiếp ->
/// skip không giải quyết gì (mạng yếu chứ không phải ads) -> dừng hẳn.
/// Pure để dễ test; caller tự đếm số lần liên tiếp và block.
bool isSkipIneffective({
  required int posMs,
  required int landedMs,
  int toleranceMs = 15000,
}) =>
    (posMs - landedMs).abs() < toleranceMs;
/// Điều kiện: vị trí đứng yên đủ lâu + đã phát được một lúc + còn cách cuối
/// phim một đoạn + chưa vượt số lần tự skip cho phép của media này.
/// KHÔNG phân biệt được đứng hình do ads hay do mạng yếu ở đây — caller
/// phải giới hạn số lần (ads thường chỉ vài chục giây, mạng yếu thì skip
/// tiếp cũng vẫn đứng) và cho user tắt trong Settings.
bool shouldAutoSkipStall({
  required int frozenSec,
  required int posMs,
  required int durMs,
  required int autoSkipCount,
  int triggerSec = 10,
  int minPosMs = 5000,
  int minRemainingMs = 25000,
  int maxSkips = 4,
}) {
  if (frozenSec < triggerSec) return false;
  if (posMs < minPosMs) return false;
  if (durMs - posMs < minRemainingMs) return false;
  if (autoSkipCount >= maxSkips) return false;
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
