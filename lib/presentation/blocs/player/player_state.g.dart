// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerState _$PlayerStateFromJson(Map<String, dynamic> json) => _PlayerState(
  movieSlug: json['movieSlug'] as String? ?? '',
  episodeSlug: json['episodeSlug'] as String? ?? '',
  serverName: json['serverName'] as String? ?? '',
  linkM3u8: json['linkM3u8'] as String? ?? '',
  position: json['position'] == null
      ? Duration.zero
      : Duration(microseconds: (json['position'] as num).toInt()),
  duration: json['duration'] == null
      ? Duration.zero
      : Duration(microseconds: (json['duration'] as num).toInt()),
  status:
      $enumDecodeNullable(_$PlayerStatusEnumMap, json['status']) ??
      PlayerStatus.initial,
  isDownloading: json['isDownloading'] as bool? ?? false,
  errorMessage: json['errorMessage'] as String?,
  localM3u8: json['localM3u8'] as String?,
);

Map<String, dynamic> _$PlayerStateToJson(_PlayerState instance) =>
    <String, dynamic>{
      'movieSlug': instance.movieSlug,
      'episodeSlug': instance.episodeSlug,
      'serverName': instance.serverName,
      'linkM3u8': instance.linkM3u8,
      'position': instance.position.inMicroseconds,
      'duration': instance.duration.inMicroseconds,
      'status': _$PlayerStatusEnumMap[instance.status]!,
      'isDownloading': instance.isDownloading,
      'errorMessage': instance.errorMessage,
      'localM3u8': instance.localM3u8,
    };

const _$PlayerStatusEnumMap = {
  PlayerStatus.initial: 'initial',
  PlayerStatus.loading: 'loading',
  PlayerStatus.playing: 'playing',
  PlayerStatus.paused: 'paused',
  PlayerStatus.completed: 'completed',
  PlayerStatus.error: 'error',
};
