import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

class BookmarkRepository {
  final AppDatabase db;
  BookmarkRepository(this.db);

  Stream<List<Bookmark>> watchBookmarks() => db.watchAllBookmarks();
  Future<List<Bookmark>> getBookmarks() => db.getAllBookmarks();
  Future<Bookmark?> getBookmark(String slug) => db.getBookmark(slug);
  Future<bool> isBookmarked(String slug) => db.isBookmarked(slug);

  Future<void> toggleBookmark({
    required String movieSlug,
    required String movieName,
    String? posterUrl,
    int? year,
    String? dataJson,
  }) async {
    final exists = await isBookmarked(movieSlug);
    if (exists) {
      await db.removeBookmark(movieSlug);
    } else {
      await db.addBookmark(BookmarksCompanion(
        movieSlug: Value(movieSlug),
        movieName: Value(movieName),
        posterUrl: Value(posterUrl),
        year: Value(year),
        addedAt: Value(DateTime.now()),
        dataJson: Value(dataJson),
      ));
    }
  }

  Future<void> remove(String slug) => db.removeBookmark(slug);
}
