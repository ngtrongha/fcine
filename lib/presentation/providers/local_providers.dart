import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_provider.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/bookmark_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HistoryRepository(db);
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BookmarkRepository(db);
});

final watchHistoryStreamProvider = StreamProvider((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.watchHistory();
});

final bookmarksStreamProvider = StreamProvider((ref) {
  final repo = ref.watch(bookmarkRepositoryProvider);
  return repo.watchBookmarks();
});

final isBookmarkedProvider = FutureProvider.family<bool, String>((ref, slug) async {
  final repo = ref.watch(bookmarkRepositoryProvider);
  return repo.isBookmarked(slug);
});
