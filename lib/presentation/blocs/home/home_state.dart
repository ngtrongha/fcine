import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/movie.dart';

part 'home_state.freezed.dart';
part 'home_state.g.dart';

enum HomeStatus { initial, loading, success, failure, loadingMore }

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default([]) List<Movie> movies,
    @Default('Tất Cả') String selectedCategory,
    @Default(1) int page,
    @Default(true) bool hasMore,
    String? errorMessage,
  }) = _HomeState;

  factory HomeState.fromJson(Map<String, dynamic> json) => _$HomeStateFromJson(json);
}
