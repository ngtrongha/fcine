import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:replay_bloc/replay_bloc.dart' as replay;

part 'search_event.freezed.dart';

@freezed
class SearchEvent extends replay.ReplayEvent with _$SearchEvent {
  const SearchEvent._() : super();
  const factory SearchEvent.keywordChanged(String keyword) = SearchKeywordChanged;
  const factory SearchEvent.filterChanged({
    String? category,
    String? country,
    String? year,
    String? type,
  }) = SearchFilterChanged;
  const factory SearchEvent.loadMore() = SearchLoadMore;
  const factory SearchEvent.clear() = SearchClear;
  const factory SearchEvent.recentLoaded(List<String> recent) = SearchRecentLoaded;
}
