import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state.freezed.dart';
part 'player_state.g.dart';

enum PlayerStatus { initial, loading, playing, paused, completed, error }

@freezed
abstract class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default('') String movieSlug,
    @Default('') String episodeSlug,
    @Default('') String serverName,
    @Default('') String linkM3u8,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(PlayerStatus.initial) PlayerStatus status,
    @Default(false) bool isDownloading,
    String? errorMessage,
    String? localM3u8,
  }) = _PlayerState;

  factory PlayerState.fromJson(Map<String, dynamic> json) => _$PlayerStateFromJson(json);
}
