import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';
import '../../../domain/repositories/movie_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends HydratedBloc<HomeEvent, HomeState> with ReplayBlocMixin<HomeEvent, HomeState> {
  final MovieRepository repository;
  static const Map<String, String> categoryToType = {
    'Tất Cả': 'latest',
    'Phim Mới': 'latest',
    'Phim Bộ': 'phim-bo',
    'Phim Lẻ': 'phim-le',
    'Hoạt Hình': 'hoat-hinh',
    'TV Shows': 'tv-shows',
  };

  HomeBloc({required this.repository}) : super(const HomeState()) {
    on<HomeInitialLoad>(_onInitialLoad);
    on<HomeCategoryChanged>(_onCategoryChanged);
    on<HomeLoadMore>(_onLoadMore);
    on<HomeRefresh>(_onRefresh);
    on<HomeUndo>(_onUndo);
    on<HomeRedo>(_onRedo);
  }

  Future<void> _onInitialLoad(HomeInitialLoad event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final type = categoryToType[state.selectedCategory] ?? 'latest';
      final res = type == 'latest' ? await repository.getLatest(page: 1) : await repository.getListByType(type, page: 1);
      emit(state.copyWith(status: HomeStatus.success, movies: res.movies, page: 1, hasMore: 1 < res.pagination.totalPages));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCategoryChanged(HomeCategoryChanged event, Emitter<HomeState> emit) async {
    emit(state.copyWith(selectedCategory: event.category, status: HomeStatus.loading, movies: [], page: 1, hasMore: true));
    try {
      final type = categoryToType[event.category] ?? 'latest';
      final res = type == 'latest' ? await repository.getLatest(page: 1) : await repository.getListByType(type, page: 1);
      emit(state.copyWith(status: HomeStatus.success, movies: res.movies, page: 1, hasMore: 1 < res.pagination.totalPages));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMore(HomeLoadMore event, Emitter<HomeState> emit) async {
    if (!state.hasMore || state.status == HomeStatus.loadingMore) return;
    emit(state.copyWith(status: HomeStatus.loadingMore));
    try {
      final nextPage = state.page + 1;
      final type = categoryToType[state.selectedCategory] ?? 'latest';
      final res = type == 'latest' ? await repository.getLatest(page: nextPage) : await repository.getListByType(type, page: nextPage);
      emit(state.copyWith(status: HomeStatus.success, movies: [...state.movies, ...res.movies], page: nextPage, hasMore: nextPage < res.pagination.totalPages));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefresh(HomeRefresh event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final type = categoryToType[state.selectedCategory] ?? 'latest';
      final res = type == 'latest' ? await repository.getLatest(page: 1) : await repository.getListByType(type, page: 1);
      emit(state.copyWith(status: HomeStatus.success, movies: res.movies, page: 1, hasMore: 1 < res.pagination.totalPages));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onUndo(HomeUndo event, Emitter<HomeState> emit) {
    undo();
  }

  void _onRedo(HomeRedo event, Emitter<HomeState> emit) {
    redo();
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    try {
      return HomeState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    return state.toJson();
  }

  @override
  bool shouldReplay(HomeState state) {
    // Only replay category changes, not loading states
    return state.status == HomeStatus.success;
  }
}
