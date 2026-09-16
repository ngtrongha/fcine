import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:fcine/core/di/injection.dart';
import 'package:fcine/core/database/app_database.dart';
import 'package:fcine/core/config/master_config.dart';
import 'package:fcine/domain/repositories/movie_repository.dart';
import 'package:fcine/domain/entities/movie.dart';
import 'package:fcine/domain/entities/episode.dart';
import 'package:fcine/domain/entities/pagination.dart';
import 'package:fcine/presentation/pages/detail_page.dart';

class MockMovieRepository implements MovieRepository {
  @override
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(
    String slug, {
    String? sourceId,
  }) async {
    const movie = Movie(
      id: '1',
      slug: 'test-slug',
      name: 'Test Movie',
      originName: 'Original Title',
      thumbUrl: 'https://phimimg.com/thumb.webp',
      posterUrl: 'https://phimimg.com/poster.webp',
      year: 2026,
      quality: 'FHD',
      lang: 'Vietsub',
      time: '120 phút',
      episodeCurrent: 'Full',
      content: '<p>Đây là tóm tắt phim test.</p>',
      categories: [Category(id: '1', name: 'Hành Động', slug: 'hanh-dong')],
      countries: [Country(id: '1', name: 'Việt Nam', slug: 'viet-nam')],
      actors: ['Diễn viên A', 'Diễn viên B'],
      directors: ['Đạo diễn X'],
      voteAverage: 8.5,
    );

    const servers = [
      EpisodeServer(
        serverName: 'Vietsub',
        episodes: [
          Episode(
            name: 'Tập 1',
            slug: 'tap-1',
            m3u8Url: 'https://test.com/1.m3u8',
          ),
          Episode(
            name: 'Tập 2',
            slug: 'tap-2',
            m3u8Url: 'https://test.com/2.m3u8',
          ),
        ],
      ),
      EpisodeServer(
        serverName: 'Thuyết Minh',
        episodes: [
          Episode(
            name: 'Tập 1',
            slug: 'tap-1-tm',
            m3u8Url: 'https://test.com/1-tm.m3u8',
          ),
        ],
      ),
    ];

    return (movie: movie, servers: servers);
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getLatest({
    int page = 1,
    String? sourceId,
  }) async {
    return (
      movies: <Movie>[],
      pagination: const Pagination(
        totalItems: 0,
        totalItemsPerPage: 24,
        currentPage: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getListByType(
    String type, {
    int page = 1,
    String? sourceId,
  }) async {
    return (
      movies: <Movie>[],
      pagination: const Pagination(
        totalItems: 0,
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
    return (
      movies: <Movie>[],
      pagination: const Pagination(
        totalItems: 0,
        totalItemsPerPage: 24,
        currentPage: 1,
        totalPages: 1,
      ),
    );
  }
}

void main() {
  setUpAll(() {
    if (!getIt.isRegistered<AppDatabase>()) {
      getIt.registerSingleton<AppDatabase>(
        AppDatabase.forTesting(NativeDatabase.memory()),
      );
    }
    if (!getIt.isRegistered<MasterConfig>()) {
      getIt.registerSingleton<MasterConfig>(
        MasterConfig(
          version: 2,
          updatedAt: DateTime.now(),
          sources: [
            SourceConfig(
              id: 'kkphim',
              name: 'KKPhim',
              enabled: true,
              baseUrl: 'https://phimapi.com',
              fallbackUrls: [],
              cdnImage: 'https://phimimg.com',
              headers: {},
              endpoints: Endpoints(
                latest: Endpoint(path: '', method: 'GET'),
                search: Endpoint(path: '', method: 'GET'),
                detail: Endpoint(path: '', method: 'GET'),
              ),
            ),
            SourceConfig(
              id: 'nguonc',
              name: 'NguonC',
              enabled: true,
              baseUrl: 'https://phim.nguonc.com',
              fallbackUrls: [],
              cdnImage: 'https://phim.nguonc.com',
              headers: {},
              endpoints: Endpoints(
                latest: Endpoint(path: '', method: 'GET'),
                search: Endpoint(path: '', method: 'GET'),
                detail: Endpoint(path: '', method: 'GET'),
              ),
            ),
          ],
          settings: AppSettings.defaults(),
        ),
      );
    }
    if (!getIt.isRegistered<MovieRepository>()) {
      getIt.registerSingleton<MovieRepository>(MockMovieRepository());
    }
  });

  testWidgets('DetailPage displays movie info, sources, and servers', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(home: DetailPage(slug: 'test-slug')),
    );

    // Wait for async loadDetail
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Kiểm tra tên phim
    expect(find.text('Test Movie'), findsWidgets);
    expect(find.text('Original Title'), findsOneWidget);

    // 2. Kiểm tra badges thông tin
    expect(find.text('★ 8.5'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('FHD'), findsOneWidget);
    expect(find.text('Vietsub'), findsWidgets);
    expect(find.text('Full'), findsOneWidget);
    expect(find.text('120 phút'), findsOneWidget);

    // 3. Kiểm tra thể loại & quốc gia
    expect(find.text('Hành Động'), findsOneWidget);
    expect(find.textContaining('Việt Nam'), findsOneWidget);

    // 4. Kiểm tra nội dung tóm tắt (đã lọc thẻ HTML)
    expect(find.textContaining('Đây là tóm tắt phim test.'), findsOneWidget);

    // 5. Kiểm tra nút hành động chính
    expect(find.text('XEM PHIM'), findsOneWidget);
    expect(find.text('Lưu phim'), findsOneWidget);

    // 6. Kiểm tra bộ chọn Nguồn Phim (Data source pills)
    expect(find.text('Nguồn Phim:'), findsOneWidget);
    expect(find.text('KKPhim'), findsOneWidget);
    expect(find.text('NguonC'), findsOneWidget);

    // 7. Kiểm tra bộ chọn Server phát (Choice chips)
    expect(find.text('Server phát:'), findsOneWidget);
    expect(find.text('Vietsub (2)'), findsOneWidget);
    expect(find.text('Thuyết Minh (1)'), findsOneWidget);

    // 8. Kiểm tra danh sách tập của server đang chọn
    expect(find.text('Tập 1'), findsOneWidget);
    expect(find.text('Tập 2'), findsOneWidget);

    // 9. Thử bấm chuyển server sang Thuyết Minh
    await tester.tap(find.text('Thuyết Minh (1)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Kiểm tra danh sách tập của Thuyết Minh
    expect(find.text('Danh Sách Tập (1)'), findsOneWidget);
  });
}
