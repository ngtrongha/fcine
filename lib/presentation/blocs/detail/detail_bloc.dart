import 'package:drift/drift.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';
import '../../../domain/repositories/movie_repository.dart';
import '../../../core/database/app_database.dart';
import 'detail_event.dart';
import 'detail_state.dart';

class DetailBloc extends HydratedBloc<DetailEvent, DetailState> with ReplayBlocMixin<DetailEvent, DetailState> {
  final MovieRepository repository;
  final AppDatabase database;
  String? _currentSlug;

  DetailBloc({required this.repository, required this.database}) : super(const DetailState()) {
    on<DetailLoad>(_onLoad);
    on<DetailToggleBookmark>(_onToggleBookmark);
  }

  Future<void> _onLoad(DetailLoad event, Emitter<DetailState> emit) async {
    _currentSlug = event.slug;
    emit(state.copyWith(status: DetailStatus.loading));
    try {
      final res = await repository.getDetail(event.slug);
      final bookmark = await database.getBookmark(event.slug);
      emit(state.copyWith(status: DetailStatus.success, movie: res.movie, servers: res.servers, isBookmarked: bookmark != null));
    } catch (e) {
      emit(state.copyWith(status: DetailStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleBookmark(DetailToggleBookmark event, Emitter<DetailState> emit) async {
    final movie = state.movie;
    if (movie == null || _currentSlug == null) return;
    final isMarked = state.isBookmarked;
    if (isMarked) {
      await database.removeBookmark(movie.slug);
    } else {
      await database.addBookmark(
        BookmarksCompanion.insert(
          movieSlug: movie.slug,
          movieName: movie.name,
          posterUrl: Value(movie.posterUrl),
          year: Value(movie.year),
          addedAt: DateTime.now(),
        ),
      );
    }
    emit(state.copyWith(isBookmarked: !isMarked));
  }

  @override
  DetailState? fromJson(Map<String, dynamic> json) {
    try {
      return DetailState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(DetailState state) {
    return state.toJson();
  }

  @override
  bool shouldReplay(DetailState state) {
    return state.status == DetailStatus.success;
  }
}
