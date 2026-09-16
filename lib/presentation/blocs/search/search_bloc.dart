import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/movie_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends HydratedBloc<SearchEvent, SearchState> with ReplayBlocMixin<SearchEvent, SearchState> {
  /// Xem chú thích tương tự ở HomeBloc: null = luôn dùng repo mới nhất.
  final MovieRepository? _overrideRepository;

  MovieRepository get _repo =>
      _overrideRepository ?? getIt<MovieRepository>();
  static const _historyKey = 'search_history';

  SearchBloc({MovieRepository? repository})
      : _overrideRepository = repository,
        super(const SearchState()) {
    on<SearchKeywordChanged>(_onKeywordChanged);
    on<SearchFilterChanged>(_onFilterChanged);
    on<SearchLoadMore>(_onLoadMore);
    on<SearchClear>(_onClear);
    on<SearchRecentLoaded>(_onRecentLoaded);
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    add(SearchEvent.recentLoaded(list));
  }

  Future<void> _saveRecent(String kw) async {
    if (kw.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    list.remove(kw);
    list.insert(0, kw);
    if (list.length > 10) list.removeLast();
    await prefs.setStringList(_historyKey, list);
    add(SearchEvent.recentLoaded(list));
  }

  Future<void> _onKeywordChanged(SearchKeywordChanged event, Emitter<SearchState> emit) async {
    final kw = event.keyword.trim();
    emit(state.copyWith(keyword: kw, status: kw.isEmpty ? SearchStatus.initial : SearchStatus.loading, movies: [], page: 1, totalPages: 1));
    if (kw.isEmpty) return;
    await _saveRecent(kw);
    await Future.delayed(const Duration(milliseconds: 400));
    if (kw != state.keyword) return;
    try {
      final res = await _repo.search(kw, page: 1, category: state.category, country: state.country, year: state.year, type: state.type);
      emit(state.copyWith(status: SearchStatus.success, movies: res.movies, page: 1, totalPages: res.pagination.totalPages));
    } catch (e) {
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onFilterChanged(SearchFilterChanged event, Emitter<SearchState> emit) async {
    emit(state.copyWith(category: event.category, country: event.country, year: event.year, type: event.type));
    if (state.keyword.isNotEmpty) {
      emit(state.copyWith(status: SearchStatus.loading));
      try {
        final res = await _repo.search(state.keyword, page: 1, category: state.category, country: state.country, year: state.year, type: state.type);
        emit(state.copyWith(status: SearchStatus.success, movies: res.movies, page: 1, totalPages: res.pagination.totalPages));
      } catch (e) {
        emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onLoadMore(SearchLoadMore event, Emitter<SearchState> emit) async {
    if (state.page >= state.totalPages || state.status == SearchStatus.loadingMore) return;
    emit(state.copyWith(status: SearchStatus.loadingMore));
    try {
      final nextPage = state.page + 1;
      final res = await _repo.search(state.keyword, page: nextPage, category: state.category, country: state.country, year: state.year, type: state.type);
      emit(state.copyWith(status: SearchStatus.success, movies: [...state.movies, ...res.movies], page: nextPage, totalPages: res.pagination.totalPages));
    } catch (e) {
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onClear(SearchClear event, Emitter<SearchState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    emit(const SearchState());
  }

  Future<void> _onRecentLoaded(SearchRecentLoaded event, Emitter<SearchState> emit) async {
    emit(state.copyWith(recentSearches: event.recent));
  }

  @override
  SearchState? fromJson(Map<String, dynamic> json) {
    try {
      return SearchState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SearchState state) {
    return state.toJson();
  }

  @override
  bool shouldReplay(SearchState state) {
    return state.status == SearchStatus.success;
  }
}
