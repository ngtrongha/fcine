import 'package:media_kit/media_kit.dart';
import '../../../../core/extractor/m3u8_parser.dart';
import 'player_logic.dart';

/// Thin controller that delegates quality/intro/progress to [PlayerLogic] services.
/// Kept widget-local per task: Player remains in widget, controller is helper.
/// Provides single entry-point for player-related business logic.

class PlayerController {
  final Player player;
  PlayerController(this.player);

  /// Loads available quality variants for [url] via [QualityService].
  Future<List<QualityVariant>> loadQualities(String url) => QualityService.load(url);

  /// Switches to [q] while preserving [pos].
  Future<void> switchQuality(QualityVariant q, Duration pos) => QualityService.switchQuality(player, q, pos);

  /// Loads intro end marker for [slug] from shared preferences.
  Future<int> loadIntro(String slug) => IntroService.load(slug);

  /// Persists intro end marker [ms] for [slug].
  Future<void> saveIntro(String slug, int ms) => IntroService.save(slug, ms);

  /// Persists watch progress if guards pass.
  Future<void> saveProgress({
    required dynamic movie,
    required dynamic episode,
    required String server,
    required Duration pos,
    required Duration dur,
  }) =>
      ProgressService.save(movie: movie, episode: episode, serverName: server, pos: pos, dur: dur);

  /// Whether intro should be skipped for given state.
  bool shouldSkip(int introEndMs, bool hasSkipped, Duration pos) => shouldSkipIntro(introEndMs: introEndMs, hasSkipped: hasSkipped, pos: pos);

  /// Whether progress should be saved.
  bool shouldSave(Duration pos, Duration dur) => shouldSaveProgress(pos, dur);

  /// Formats [d] as mm:ss or h:mm:ss.
  String fmt(Duration d) => formatDuration(d);

  /// Clamps seek target within [0, dur].
  Duration clamp(Duration pos, Duration dur, int delta) => clampSeek(pos, dur, delta);

  /// Computes next playback speed in cycle.
  double nextSpeed(double current) {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final idx = speeds.indexOf(current);
    return speeds[(idx + 1) % speeds.length];
  }
}
