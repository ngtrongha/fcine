import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:fcine/core/di/injection.dart';
import 'package:fcine/domain/entities/episode.dart';
import 'package:fcine/domain/entities/movie.dart';
import 'package:fcine/domain/entities/pagination.dart';
import 'package:fcine/domain/repositories/movie_repository.dart';
import 'package:fcine/presentation/blocs/home/home_bloc.dart';
import 'package:fcine/presentation/blocs/home/home_event.dart';
import 'package:fcine/presentation/blocs/home/home_state.dart';

class _FakeRepo implements MovieRepository {
  final String tag;
  int latestCalls = 0;
  _FakeRepo(this.tag);

  @override
  Future<({List<Movie> movies, Pagination pagination})> getLatest({
    int page = 1,
    String? sourceId,
  }) async {
    latestCalls++;
    return (
      movies: [
        Movie(
          id: tag,
          slug: 'slug-$tag',
          name: 'Movie $tag',
          originName: '',
          thumbUrl: '',
          posterUrl: '',
          year: 2026,
        ),
      ],
      pagination: const Pagination(
        totalItems: 1,
        totalItemsPerPage: 24,
        currentPage: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> search(
    String keyword, {
    int page = 1,
    int limit = 24,
    String? category,
    String? country,
    String? year,
    String? type,
    String? sourceId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(
    String slug, {
    String? sourceId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getListByType(
    String type, {
    int page = 1,
    String? sourceId,
  }) async {
    throw UnimplementedError();
  }
}

/// Hồi quy: thêm nguồn mới (rebuild DI) nhưng tab Online giữ bloc cũ —
/// bloc phải gọi repository MỚI NHẤT, không phải repo lúc khởi tạo.
void main() {
  setUpAll(() async {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        Directory.systemTemp.createTempSync('fcine_test_').path,
      ),
    );
  });

  test('HomeBloc dùng repository mới nhất sau khi rebuild DI', () async {
    await getIt.reset();
    final repoA = _FakeRepo('A');
    getIt.registerSingleton<MovieRepository>(repoA);

    // Bloc dựng lúc app start (repo A).
    final bloc = HomeBloc();
    addTearDown(bloc.close);

    // User thêm nguồn -> refreshSources thay repo trong getIt.
    await getIt.unregister<MovieRepository>();
    final repoB = _FakeRepo('B');
    getIt.registerSingleton<MovieRepository>(repoB);

    bloc.add(const HomeInitialLoad());
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<HomeState>((s) => s.status == HomeStatus.success),
      ),
    );

    expect(repoA.latestCalls, 0, reason: 'không được gọi repo cũ');
    expect(repoB.latestCalls, 1, reason: 'phải gọi repo mới nhất');
    expect(bloc.state.movies.first.name, 'Movie B');
  });
}
