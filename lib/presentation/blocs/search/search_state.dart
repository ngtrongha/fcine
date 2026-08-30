import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/movie.dart';

part 'search_state.freezed.dart';
part 'search_state.g.dart';

enum SearchStatus { initial, loading, success, failure, loadingMore }

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default(SearchStatus.initial) SearchStatus status,
    @Default('') String keyword,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default([]) List<Movie> movies,
    @Default(1) int page,
    @Default(1) int totalPages,
    String? category,
    String? country,
    String? year,
    String? type,
    @Default([]) List<String> recentSearches,
    String? errorMessage,
  }) = _SearchState;

  factory SearchState.fromJson(Map<String, dynamic> json) => _$SearchStateFromJson(json);
}

extension SearchStateX on SearchState {
  bool get hasFilter => category != null || country != null || year != null || type != null;
}
