import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/download/download_service.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends HydratedBloc<LibraryEvent, LibraryState>
    with ReplayBlocMixin<LibraryEvent, LibraryState> {
  final AppDatabase db;
  final DownloadService downloadService;
  StreamSubscription? _hSub;
  StreamSubscription? _bSub;
  StreamSubscription? _dSub;

  LibraryBloc({required this.db, required this.downloadService})
      : super(const LibraryState()) {
    on<LibraryStarted>(_onStarted);
    on<LibraryTabChanged>(_onTabChanged);
    on<LibraryHistoryUpdated>(_onHistoryUpdated);
    on<LibraryBookmarksUpdated>(_onBookmarksUpdated);
    on<LibraryDownloadsUpdated>(_onDownloadsUpdated);
    on<LibraryDeleteHistory>(_onDeleteHistory);
    on<LibraryDeleteBookmark>(_onDeleteBookmark);
    on<LibraryDeleteDownload>(_onDeleteDownload);
  }

  void _onStarted(LibraryStarted e, Emitter<LibraryState> emit) {
    _hSub?.cancel();
    _bSub?.cancel();
    _dSub?.cancel();
    _hSub = db.watchAllHistory().listen((items) => add(LibraryEvent.historyUpdated(items)));
    _bSub = db.watchAllBookmarks().listen((items) => add(LibraryEvent.bookmarksUpdated(items)));
    _dSub = db.watchAllDownloads().listen((items) => add(LibraryEvent.downloadsUpdated(items)));
    emit(state.copyWith(isLoading: true));
  }

  void _onTabChanged(LibraryTabChanged e, Emitter<LibraryState> emit) {
    emit(state.copyWith(selectedTab: e.index));
  }

  void _onHistoryUpdated(LibraryHistoryUpdated e, Emitter<LibraryState> emit) {
    emit(state.copyWith(history: e.items, isLoading: false));
  }

  void _onBookmarksUpdated(LibraryBookmarksUpdated e, Emitter<LibraryState> emit) {
    emit(state.copyWith(bookmarks: e.items, isLoading: false));
  }

  void _onDownloadsUpdated(LibraryDownloadsUpdated e, Emitter<LibraryState> emit) {
    emit(state.copyWith(downloads: e.items, isLoading: false));
  }

  Future<void> _onDeleteHistory(LibraryDeleteHistory e, Emitter<LibraryState> emit) async {
    await db.deleteHistory(e.movieSlug, e.episodeSlug, e.serverName);
  }

  Future<void> _onDeleteBookmark(LibraryDeleteBookmark e, Emitter<LibraryState> emit) async {
    await db.removeBookmark(e.movieSlug);
  }

  Future<void> _onDeleteDownload(LibraryDeleteDownload e, Emitter<LibraryState> emit) async {
    await downloadService.deleteDownload(e.download);
  }

  @override
  Future<void> close() {
    _hSub?.cancel();
    _bSub?.cancel();
    _dSub?.cancel();
    return super.close();
  }

  @override
  LibraryState? fromJson(Map<String, dynamic> json) {
    try { return LibraryState.fromJson(json); } catch (_) { return null; }
  }

  @override
  Map<String, dynamic>? toJson(LibraryState state) => state.toJson();

  @override
  bool shouldReplay(LibraryState state) => state.selectedTab != 0;
}
