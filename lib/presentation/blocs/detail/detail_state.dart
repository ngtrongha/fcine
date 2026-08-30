import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/episode.dart';

part 'detail_state.freezed.dart';
part 'detail_state.g.dart';

enum DetailStatus { initial, loading, success, failure }

@freezed
abstract class DetailState with _$DetailState {
  const factory DetailState({
    @Default(DetailStatus.initial) DetailStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false) Movie? movie,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default([]) List<EpisodeServer> servers,
    @Default(false) bool isBookmarked,
    String? errorMessage,
  }) = _DetailState;

  factory DetailState.fromJson(Map<String, dynamic> json) => _$DetailStateFromJson(json);
}
