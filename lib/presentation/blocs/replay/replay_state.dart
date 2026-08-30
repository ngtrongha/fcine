import 'package:freezed_annotation/freezed_annotation.dart';

part 'replay_state.freezed.dart';
part 'replay_state.g.dart';

@freezed
abstract class ReplayState with _$ReplayState {
  const factory ReplayState({
    @Default('') String movieSlug,
    @Default('') String episodeSlug,
    @Default('') String serverName,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(false) bool isReplaying,
    @Default(false) bool isCompleted,
    @Default(0) int replayCount,
  }) = _ReplayState;

  factory ReplayState.fromJson(Map<String, dynamic> json) => _$ReplayStateFromJson(json);
}
