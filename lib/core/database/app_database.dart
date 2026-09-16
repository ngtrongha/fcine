import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class WatchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get movieSlug => text()();
  TextColumn get movieName => text()();
  TextColumn get posterUrl => text().nullable()();
  TextColumn get episodeName => text()();
  TextColumn get episodeSlug => text()();
  TextColumn get serverName => text().withDefault(const Constant('Vietsub'))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get sourceId => text().withDefault(const Constant('kkphim'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {movieSlug, episodeSlug, serverName},
  ];
}

class Bookmarks extends Table {
  TextColumn get movieSlug => text()();
  TextColumn get movieName => text()();
  TextColumn get posterUrl => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get sourceId => text().withDefault(const Constant('kkphim'))();
  DateTimeColumn get addedAt => dateTime()();
  TextColumn get dataJson => text().nullable()(); // lưu full movie json nếu cần

  @override
  Set<Column> get primaryKey => {movieSlug};
}

class ConfigCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get json => text()();
  IntColumn get version => integer()();
  DateTimeColumn get updatedAt => dateTime()();
}

class Downloads extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get movieSlug => text()();
  TextColumn get movieName => text()();
  TextColumn get posterUrl => text().nullable()();
  TextColumn get episodeName => text()();
  TextColumn get episodeSlug => text()();
  TextColumn get serverName => text().withDefault(const Constant('Vietsub'))();
  TextColumn get remoteM3u8 => text()();
  TextColumn get localM3u8 => text().nullable()();
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // pending, downloading, completed, failed
  IntColumn get progress => integer().withDefault(const Constant(0))(); // 0-100
  IntColumn get totalSegments => integer().withDefault(const Constant(0))();
  IntColumn get downloadedSegments =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {movieSlug, episodeSlug, serverName},
  ];
}

@DriftDatabase(tables: [WatchHistory, Bookmarks, ConfigCache, Downloads])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(downloads);
      }
    },
  );

  // --- Watch History ---
  Future<List<WatchHistoryData>> getAllHistory() => (select(
    watchHistory,
  )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
  Stream<List<WatchHistoryData>> watchAllHistory() => (select(
    watchHistory,
  )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();

  Future<WatchHistoryData?> getHistory(
    String movieSlug,
    String episodeSlug,
    String serverName,
  ) =>
      (select(watchHistory)..where(
            (t) =>
                t.movieSlug.equals(movieSlug) &
                t.episodeSlug.equals(episodeSlug) &
                t.serverName.equals(serverName),
          ))
          .getSingleOrNull();

  Future<void> upsertHistory(WatchHistoryCompanion entry) async {
    // Fix: original `insertOnConflictUpdate` targets PK `id` only.
    // Table unique is (movie_slug, episode_slug, server_name) -> must target that.
    await into(watchHistory).insert(
      entry,
      onConflict: DoUpdate(
        (old) => entry,
        target: [
          watchHistory.movieSlug,
          watchHistory.episodeSlug,
          watchHistory.serverName,
        ],
      ),
    );
  }

  Future<int> deleteHistory(
    String movieSlug,
    String episodeSlug,
    String serverName,
  ) =>
      (delete(watchHistory)..where(
            (t) =>
                t.movieSlug.equals(movieSlug) &
                t.episodeSlug.equals(episodeSlug) &
                t.serverName.equals(serverName),
          ))
          .go();

  // --- Bookmarks ---
  Future<List<Bookmark>> getAllBookmarks() =>
      (select(bookmarks)..orderBy([(t) => OrderingTerm.desc(t.addedAt)])).get();
  Stream<List<Bookmark>> watchAllBookmarks() => (select(
    bookmarks,
  )..orderBy([(t) => OrderingTerm.desc(t.addedAt)])).watch();
  Future<Bookmark?> getBookmark(String slug) => (select(
    bookmarks,
  )..where((t) => t.movieSlug.equals(slug))).getSingleOrNull();
  Future<void> addBookmark(BookmarksCompanion entry) =>
      into(bookmarks).insertOnConflictUpdate(entry);
  Future<int> removeBookmark(String slug) =>
      (delete(bookmarks)..where((t) => t.movieSlug.equals(slug))).go();
  Future<bool> isBookmarked(String slug) async =>
      await getBookmark(slug) != null;

  // --- Config Cache ---
  Future<ConfigCacheData?> getLatestConfig() async {
    final q = select(configCache)
      ..orderBy([(t) => OrderingTerm.desc(t.version)])
      ..limit(1);
    return q.getSingleOrNull();
  }

  Future<int> saveConfig(String jsonStr, int version) =>
      into(configCache).insert(
        ConfigCacheCompanion.insert(
          json: jsonStr,
          version: version,
          updatedAt: DateTime.now(),
        ),
      );

  Future<int> clearConfigCache() => delete(configCache).go();

  // --- Downloads ---
  Future<List<Download>> getAllDownloads() => (select(
    downloads,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  Stream<List<Download>> watchAllDownloads() => (select(
    downloads,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  Future<Download?> getDownload(
    String movieSlug,
    String episodeSlug,
    String serverName,
  ) =>
      (select(downloads)..where(
            (t) =>
                t.movieSlug.equals(movieSlug) &
                t.episodeSlug.equals(episodeSlug) &
                t.serverName.equals(serverName),
          ))
          .getSingleOrNull();
  Future<void> upsertDownload(DownloadsCompanion entry) =>
      into(downloads).insert(
        entry,
        onConflict: DoUpdate(
          (old) => entry,
          target: [
            downloads.movieSlug,
            downloads.episodeSlug,
            downloads.serverName,
          ],
        ),
      );
  Future<int> deleteDownload(
    String movieSlug,
    String episodeSlug,
    String serverName,
  ) =>
      (delete(downloads)..where(
            (t) =>
                t.movieSlug.equals(movieSlug) &
                t.episodeSlug.equals(episodeSlug) &
                t.serverName.equals(serverName),
          ))
          .go();
  Future<int> updateDownloadProgress(int id, int progress, int downloaded) =>
      (update(downloads)..where((t) => t.id.equals(id))).write(
        DownloadsCompanion(
          progress: Value(progress),
          downloadedSegments: Value(downloaded),
          updatedAt: Value(DateTime.now()),
        ),
      );
  Future<int> updateDownloadStatus(
    int id,
    String status, {
    String? localM3u8,
  }) => (update(downloads)..where((t) => t.id.equals(id))).write(
    DownloadsCompanion(
      status: Value(status),
      localM3u8: Value(localM3u8),
      updatedAt: Value(DateTime.now()),
    ),
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'fcine.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
