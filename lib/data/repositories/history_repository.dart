import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

class HistoryRepository {
  final AppDatabase db;
  HistoryRepository(this.db);

  Stream<List<WatchHistoryData>> watchHistory() => db.watchAllHistory();
  Future<List<WatchHistoryData>> getHistory() => db.getAllHistory();

  Future<void> saveProgress({
    required String movieSlug,
    required String movieName,
    String? posterUrl,
    required String episodeName,
    required String episodeSlug,
    required String serverName,
    required int positionMs,
    required int durationMs,
    String? sourceId,
  }) {
    return db.upsertHistory(WatchHistoryCompanion(
      movieSlug: Value(movieSlug),
      movieName: Value(movieName),
      posterUrl: Value(posterUrl),
      episodeName: Value(episodeName),
      episodeSlug: Value(episodeSlug),
      serverName: Value(serverName),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      sourceId: Value(sourceId ?? 'kkphim'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteProgress(String movieSlug, String episodeSlug, String serverName) =>
      db.deleteHistory(movieSlug, episodeSlug, serverName);

  /// Gộp lịch sử theo phim cho rail "Tiếp tục xem": mỗi phim chỉ 1 dòng
  /// MỚI NHẤT (theo timestamp).
  /// Khớp cả slug cross-source (`tvshows~abc` ≈ `abc`).
  /// List đầu vào đã xếp mới nhất trước (getAllHistory/watchAllHistory).
  static List<WatchHistoryData> latestPerMovie(List<WatchHistoryData> rows) {
    String base(String s) => s.contains('~') ? s.split('~').last : s;
    final seen = <String>{};
    final out = <WatchHistoryData>[];
    for (final h in rows) {
      if (seen.add(base(h.movieSlug))) out.add(h);
    }
    return out;
  }
}
