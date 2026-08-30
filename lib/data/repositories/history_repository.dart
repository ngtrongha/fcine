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
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteProgress(String movieSlug, String episodeSlug, String serverName) =>
      db.deleteHistory(movieSlug, episodeSlug, serverName);
}
