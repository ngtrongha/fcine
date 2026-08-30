import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:replay_bloc/replay_bloc.dart' as replay;

part 'player_event.freezed.dart';

@freezed
class PlayerEvent extends replay.ReplayEvent with _$PlayerEvent {
  const PlayerEvent._() : super();
  const factory PlayerEvent.started({
    required String movieSlug,
    required String movieName,
    String? posterUrl,
    required String episodeSlug,
    required String episodeName,
    required String serverName,
    required String linkM3u8,
  }) = PlayerStarted;
  const factory PlayerEvent.positionChanged(Duration position, Duration duration) = PlayerPositionChanged;
  const factory PlayerEvent.saveProgress() = PlayerSaveProgress;
  const factory PlayerEvent.downloadRequested() = PlayerDownloadRequested;
  const factory PlayerEvent.playNext() = PlayerPlayNext;
  const factory PlayerEvent.seek(Duration position) = PlayerSeek;
}
