import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:replay_bloc/replay_bloc.dart' as replay;
import '../../../core/database/app_database.dart';

part 'library_event.freezed.dart';

@freezed
class LibraryEvent extends replay.ReplayEvent with _$LibraryEvent {
  const LibraryEvent._() : super();
  const factory LibraryEvent.started() = LibraryStarted;
  const factory LibraryEvent.tabChanged(int index) = LibraryTabChanged;
  const factory LibraryEvent.historyUpdated(List<WatchHistoryData> items) = LibraryHistoryUpdated;
  const factory LibraryEvent.bookmarksUpdated(List<Bookmark> items) = LibraryBookmarksUpdated;
  const factory LibraryEvent.downloadsUpdated(List<Download> items) = LibraryDownloadsUpdated;
  const factory LibraryEvent.deleteHistory(String movieSlug, String episodeSlug, String serverName) = LibraryDeleteHistory;
  const factory LibraryEvent.deleteBookmark(String movieSlug) = LibraryDeleteBookmark;
  const factory LibraryEvent.deleteDownload(Download download) = LibraryDeleteDownload;
}
