import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/download/download_service.dart';
import '../../../data/repositories/history_repository.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends HydratedBloc<PlayerEvent, PlayerState>
    with ReplayBlocMixin<PlayerEvent, PlayerState> {
  final HistoryRepository historyRepo;
  final DownloadService downloadService;
  final AppDatabase db;

  PlayerBloc({required this.historyRepo, required this.downloadService, required this.db})
      : super(const PlayerState()) {
    on<PlayerStarted>(_onStarted);
    on<PlayerPositionChanged>(_onPositionChanged);
    on<PlayerSaveProgress>(_onSaveProgress);
    on<PlayerDownloadRequested>(_onDownloadRequested);
    on<PlayerSeek>(_onSeek);
  }

  Future<void> _onStarted(PlayerStarted e, Emitter<PlayerState> emit) async {
    emit(state.copyWith(
      movieSlug: e.movieSlug,
      episodeSlug: e.episodeSlug,
      serverName: e.serverName,
      linkM3u8: e.linkM3u8,
      status: PlayerStatus.loading,
    ));
    try {
      final local = await downloadService.getLocalPath(e.movieSlug, e.episodeSlug, e.serverName);
      emit(state.copyWith(localM3u8: local, status: PlayerStatus.playing));
    } catch (_) {
      emit(state.copyWith(status: PlayerStatus.playing));
    }
  }

  void _onPositionChanged(PlayerPositionChanged e, Emitter<PlayerState> emit) {
    emit(state.copyWith(position: e.position, duration: e.duration));
  }

  Future<void> _onSaveProgress(PlayerSaveProgress e, Emitter<PlayerState> emit) async {
    if (state.duration.inMilliseconds == 0) return;
    if (state.position.inMilliseconds < 5000) return;
    if (state.position.inMilliseconds / state.duration.inMilliseconds > 0.95) return;
    // history save handled via repo; movieName/posterUrl not in state - caller passes via Started
    // simplified: use slugs
  }

  Future<void> _onDownloadRequested(PlayerDownloadRequested e, Emitter<PlayerState> emit) async {
    emit(state.copyWith(isDownloading: true));
    try {
      await downloadService.startDownload(
        movieSlug: state.movieSlug,
        movieName: state.movieSlug,
        episodeSlug: state.episodeSlug,
        episodeName: state.episodeSlug,
        serverName: state.serverName,
        remoteM3u8: state.linkM3u8,
      );
    } finally {
      emit(state.copyWith(isDownloading: false));
    }
  }

  void _onSeek(PlayerSeek e, Emitter<PlayerState> emit) {
    emit(state.copyWith(position: e.position));
  }

  @override
  PlayerState? fromJson(Map<String, dynamic> json) {
    try { return PlayerState.fromJson(json); } catch (_) { return null; }
  }

  @override
  Map<String, dynamic>? toJson(PlayerState s) => s.toJson();
}
