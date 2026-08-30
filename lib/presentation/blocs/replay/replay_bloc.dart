import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'replay_event.dart';
import 'replay_state.dart';

class AppReplayBloc extends HydratedBloc<ReplayEvent, ReplayState> {
  AppReplayBloc() : super(const ReplayState()) {
    on<ReplayStarted>(_onStarted);
    on<ReplaySeekRequested>(_onSeekRequested);
    on<ReplayRequested>(_onReplayRequested);
    on<ReplayCompleted>(_onCompleted);
    on<ReplayReset>(_onReset);
  }

  void _onStarted(ReplayStarted event, Emitter<ReplayState> emit) {
    emit(
      state.copyWith(
        movieSlug: event.movieSlug,
        episodeSlug: event.episodeSlug,
        serverName: event.serverName,
        isReplaying: false,
        isCompleted: false,
      ),
    );
  }

  void _onSeekRequested(ReplaySeekRequested event, Emitter<ReplayState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onReplayRequested(ReplayRequested event, Emitter<ReplayState> emit) {
    emit(
      state.copyWith(
        position: Duration.zero,
        isReplaying: true,
        isCompleted: false,
        replayCount: state.replayCount + 1,
      ),
    );
  }

  void _onCompleted(ReplayCompleted event, Emitter<ReplayState> emit) {
    emit(state.copyWith(isCompleted: true, isReplaying: false));
  }

  void _onReset(ReplayReset event, Emitter<ReplayState> emit) {
    emit(const ReplayState());
  }

  @override
  ReplayState? fromJson(Map<String, dynamic> json) {
    try {
      return ReplayState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ReplayState state) {
    // Only persist identifiers and replayCount, not transient position/duration
    return {
      'movieSlug': state.movieSlug,
      'episodeSlug': state.episodeSlug,
      'serverName': state.serverName,
      'replayCount': state.replayCount,
    };
  }
}
