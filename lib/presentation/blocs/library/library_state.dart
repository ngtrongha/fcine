import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/database/app_database.dart';

part 'library_state.freezed.dart';
part 'library_state.g.dart';

@freezed
abstract class LibraryState with _$LibraryState {
  const factory LibraryState({
    @Default(0) int selectedTab,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default([]) List<WatchHistoryData> history,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default([]) List<Bookmark> bookmarks,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default([]) List<Download> downloads,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _LibraryState;

  factory LibraryState.fromJson(Map<String, dynamic> json) => _$LibraryStateFromJson(json);
}
