// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReplayState _$ReplayStateFromJson(Map<String, dynamic> json) => _ReplayState(
  movieSlug: json['movieSlug'] as String? ?? '',
  episodeSlug: json['episodeSlug'] as String? ?? '',
  serverName: json['serverName'] as String? ?? '',
  position: json['position'] == null
      ? Duration.zero
      : Duration(microseconds: (json['position'] as num).toInt()),
  duration: json['duration'] == null
      ? Duration.zero
      : Duration(microseconds: (json['duration'] as num).toInt()),
  isReplaying: json['isReplaying'] as bool? ?? false,
  isCompleted: json['isCompleted'] as bool? ?? false,
  replayCount: (json['replayCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReplayStateToJson(_ReplayState instance) =>
    <String, dynamic>{
      'movieSlug': instance.movieSlug,
      'episodeSlug': instance.episodeSlug,
      'serverName': instance.serverName,
      'position': instance.position.inMicroseconds,
      'duration': instance.duration.inMicroseconds,
      'isReplaying': instance.isReplaying,
      'isCompleted': instance.isCompleted,
      'replayCount': instance.replayCount,
    };
