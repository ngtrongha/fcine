import 'package:freezed_annotation/freezed_annotation.dart';

part 'replay_event.freezed.dart';

@freezed
class ReplayEvent with _$ReplayEvent {
  const factory ReplayEvent.started({
    required String movieSlug,
    required String episodeSlug,
    required String serverName,
  }) = ReplayStarted;

  const factory ReplayEvent.seekRequested({
    required Duration position,
  }) = ReplaySeekRequested;

  const factory ReplayEvent.replayRequested() = ReplayRequested;

  const factory ReplayEvent.completed() = ReplayCompleted;

  const factory ReplayEvent.reset() = ReplayReset;
}
