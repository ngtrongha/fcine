import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:fcine/core/config/config_service.dart';
import 'package:fcine/core/config/master_config.dart';
import 'package:fcine/core/database/app_database.dart';
import 'package:fcine/core/di/injection.dart';
import 'package:fcine/domain/entities/episode.dart';
import 'package:fcine/domain/entities/movie.dart';
import 'package:fcine/domain/entities/pagination.dart';
import 'package:fcine/domain/repositories/movie_repository.dart';
import 'package:fcine/presentation/pages/detail_page.dart';

const _movie = Movie(
  id: '1',
  slug: 'test-slug',
  name: 'Test Movie',
  originName: 'Original Title',
  thumbUrl: '',
  posterUrl: '',
  year: 2026,
  sourceId: 'kkphim',
);

const _servers = [
  EpisodeServer(
    serverName: 'Vietsub',
    episodes: [
      Episode(name: 'Tập 1', slug: 'tap-1', m3u8Url: 'https://x/1.m3u8'),
      Episode(name: 'Tập 2', slug: 'tap-2', m3u8Url: 'https://x/2.m3u8'),
    ],
  ),
];

class _MockRepo implements MovieRepository {
  int searchCalls = 0;

  @override
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(
    String slug, {
    String? sourceId,
  }) async =>
      (movie: _movie, servers: _servers);

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
    searchCalls++;
    return (
      movies: const <Movie>[_movie],
      pagination: const Pagination(
        totalItems: 1,
        totalItemsPerPage: 24,
        currentPage: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getLatest({
    int page = 1,
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
    return (
      movies: const <Movie>[],
      pagination: const Pagination(
        totalItems: 0,
        totalItemsPerPage: 24,
        currentPage: 1,
        totalPages: 1,
      ),
    );
  }
}

SourceConfig _src(String id, String name) => SourceConfig(
      id: id,
      name: name,
      enabled: true,
      baseUrl: 'https://$id.test',
      fallbackUrls: const [],
      cdnImage: '',
      headers: const {},
      endpoints: Endpoints(
        latest: Endpoint(path: '/', method: 'GET'),
        search: Endpoint(path: '/', method: 'GET'),
        detail: Endpoint(path: '/', method: 'GET'),
      ),
    );

/// Mở phim phải tự quét nguồn còn lại và hiện chip chọn khi khớp.
void main() {
  testWidgets('Hiện chip nguồn khác khi cùng phim tồn tại', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    getIt.registerSingleton<AppDatabase>(
      AppDatabase.forTesting(NativeDatabase.memory()),
    );
    getIt.registerSingleton<ConfigService>(
      ConfigService(db: getIt<AppDatabase>(), dio: Dio()),
    );
    getIt.registerSingleton<MasterConfig>(
      MasterConfig(
        version: 1,
        updatedAt: DateTime.now(),
        sources: [_src('kkphim', 'KKPhim'), _src('motchill', 'MotChill')],
        settings: AppSettings.defaults(),
      ),
    );
    final repo = _MockRepo();
    getIt.registerSingleton<MovieRepository>(repo);
    addTearDown(() async {
      try {
        await getIt<AppDatabase>().close();
      } catch (_) {}
      await getIt.reset();
    });

    tester.view.physicalSize = const Size(1280, 2000);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: DetailPage(slug: 'test-slug', initialSourceId: 'kkphim'),
      ),
    );
    await tester.pumpAndSettle();

    // Phim chính load xong.
    expect(find.text('Test Movie'), findsWidgets);
    // Đã quét nguồn còn lại (search gọi cho motchill).
    expect(repo.searchCalls, greaterThanOrEqualTo(1));
    // Hiện mục chọn nguồn khác với số tập.
    expect(find.text('Phim này còn có trên:'), findsOneWidget);
    expect(find.textContaining('MotChill'), findsWidgets);
    expect(find.textContaining('2 tập'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
