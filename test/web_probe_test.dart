import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/core/config/source_templates.dart';
import 'package:fcine/core/scraper/sitemap.dart';
import 'package:fcine/core/scraper/web_probe.dart';
import 'package:fcine/core/scraper/web_scraper.dart';
import 'package:fcine/data/datasources/web_scraper_datasource.dart';
import 'package:fcine/presentation/router/movie_route.dart';

// Trang list DooPlay tối giản.
const _dooplayListHtml = '''
<html><body><div class="items">
<article class="item"><div class="image">
<a href="https://probe1.test/tvshows/phim-a/"><img data-src="https://probe1.test/a.jpg" /></a>
<a href="https://probe1.test/tvshows/phim-a/"><div class="data"><h3 class="title">Phim A</h3><span>2026</span></div></a>
</div></article>
<article class="item"><div class="image">
<a href="https://probe1.test/tvshows/phim-b/"><img data-src="https://probe1.test/b.jpg" /></a>
<a href="https://probe1.test/tvshows/phim-b/"><div class="data"><h3 class="title">Phim B</h3><span>2025</span></div></a>
</div></article>
<article class="item"><div class="image">
<a href="https://probe1.test/tvshows/phim-c/"><img data-src="https://probe1.test/c.jpg" /></a>
<a href="https://probe1.test/tvshows/phim-c/"><div class="data"><h3 class="title">Phim C</h3><span>2024</span></div></a>
</div></article>
</div></body></html>
''';

String _sitemapIndex(String host) => '''
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
<sitemap><loc>https://$host/sitemap-movie-1.xml</loc></sitemap>
<sitemap><loc>https://$host/sitemap-page.xml</loc></sitemap>
</sitemapindex>
''';

String _sitemapMovies(String host, int n, {String prefix = 'phim'}) {
  final buf = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
  );
  const names = [
    'bay-vao-tim-anh',
    'ngu-dinh-dao',
    'tuoc-cot',
    'lan-huong-nhu-co',
    'keo-ngot-tinh-yeu',
  ];
  for (var i = 0; i < n; i++) {
    final slug = '${names[i % names.length]}-$i';
    buf.write(
      '<url><loc>https://$host/$prefix/$slug.ab12cd34</loc></url>',
    );
  }
  buf.write('</urlset>');
  return buf.toString();
}

/// Dio mock: định tuyến theo path.
Dio _mockDio(Map<String, Object> routes, {int status = 200}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final url = options.uri.toString();
        for (final entry in routes.entries) {
          if (url.contains(entry.key)) {
            final body = entry.value;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: status,
                data: body,
              ),
            );
            return;
          }
        }
        handler.resolve(
          Response(requestOptions: options, statusCode: 404, data: 'nope'),
        );
      },
    ),
  );
  return dio;
}

void main() {
  group('WebProbe', () {
    test('chọn đúng path DooPlay có phim', () async {
      final dio = _mockDio({'/movies/page/1/': _dooplayListHtml});
      final r = await WebProbe.probe(
        baseUrl: 'https://probe1.test',
        name: 'P1',
        client: dio,
      );
      expect(r.source.endpoints.latest.path, '/movies/page/{page}/');
      expect(r.sample, greaterThanOrEqualTo(3));
      expect(r.via, contains('/movies/page/'));
    });

    test('rớt sang sitemap khi HTML không có card', () async {
      final dio = _mockDio({
        '/sitemap.xml': _sitemapIndex('probe2.test'),
        'sitemap-movie-1.xml': _sitemapMovies('probe2.test', 30),
        'sitemap-page.xml':
            '<?xml version="1.0"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://probe2.test/lien-he</loc></url></urlset>',
      });
      final r = await WebProbe.probe(
        baseUrl: 'https://probe2.test',
        name: 'P2',
        client: dio,
      );
      expect(r.source.endpoints.latest.path.startsWith('sitemap:'), isTrue);
      expect(r.sample, 30);
    });

    test('ném WebProbeException kèm danh sách đã thử', () async {
      final dio = _mockDio({});
      try {
        await WebProbe.probe(
          baseUrl: 'https://probe3.test',
          name: 'P3',
          client: dio,
        );
        fail('phải ném');
      } on WebProbeException catch (e) {
        expect(e.tried, isNotEmpty);
        expect(e.message, contains('sitemap'));
      }
    });
  });

  group('Sitemap datasource', () {
    test('getLatest cắt lát + search không dấu', () async {
      SitemapStore.clear();
      final dio = _mockDio({
        '/sitemap.xml': _sitemapIndex('probe4.test'),
        'sitemap-movie-1.xml': _sitemapMovies('probe4.test', 30),
      });
      final src = SourceTemplates.webSitemap(
        baseUrl: 'https://probe4.test',
        name: 'P4',
      );
      final ds = WebScraperDataSource(dio: dio, source: src);
      final p1 = await ds.getLatest(page: 1);
      expect(p1.movies.length, 24);
      expect(p1.pagination.totalPages, 2);
      final p2 = await ds.getLatest(page: 2);
      expect(p2.movies.length, 6);
      expect(p2.movies.first.name, isNotEmpty);
      // Slug là URL tuyệt đối để mở chi tiết trực tiếp.
      expect(p2.movies.first.slug.startsWith('https://'), isTrue);

      final s = await ds.search(keyword: 'bay vao', limit: 24);
      expect(s.movies, isNotEmpty);
      expect(s.movies.first.slug, contains('bay-vao-tim-anh'));
    });

    test('prettify + stripDiacritics', () {
      expect(
        SitemapStore.prettifySlug('bay-vao-tim-anh.nW5PZega'),
        'Bay Vao Tim Anh',
      );
      expect(
        SitemapStore.stripDiacritics('Bay Vào Tim Anh'),
        'bay vao tim anh',
      );
    });
  });

  group('Dynamic generic', () {
    test('splitDetailPath hỗ trợ slug 1 segment', () {
      final s = WebScraper.splitDetailPath(
        'https://w.test',
        'https://w.test/ten-phim/',
      )!;
      expect(s.section, 'p');
      expect(s.slug, 'ten-phim');
    });

    test('movieDetailPath encode slug tuyệt đối, decode ngược được', () {
      const abs = 'https://www.rophim.ad/phim/bay-vao-tim-anh.nW5PZega';
      final path = movieDetailPath(abs, 'web-x');
      final back = Uri.parse(path).pathSegments.last;
      expect(back, abs);
      // Slug thường không đổi dạng.
      expect(movieDetailPath('tvshows~abc'), '/movie/tvshows~abc');
    });

    test('404 toggle slash: chi tiết Next.js không slash vẫn bóc được',
        () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final url = options.uri.toString();
            if (url.endsWith('/phim/ten-phim/')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 404,
                  data: 'nope',
                ),
              );
              return;
            }
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: '<html><body><h1>Ten Phim</h1></body></html>',
              ),
            );
          },
        ),
      );
      final src = SourceTemplates.webGeneric(
        baseUrl: 'https://probe5.test',
        name: 'P5',
      );
      final ds = WebScraperDataSource(dio: dio, source: src);
      final res = await ds.getDetail('p~ten-phim');
      expect(res.movie.name, 'Ten Phim');
    });

    test('heuristic tìm link tập theme lạ', () async {
      final dio = _mockDio({
        '/phim-la': '<html><body><h1>Phim La</h1>'
            '<div class="eps"><a href="https://probe6.test/xem/tap-1">Tập 1</a>'
            '<a href="https://probe6.test/xem/tap-2">Tập 2</a></div>'
            '</body></html>',
      });
      final src = SourceTemplates.webGeneric(
        baseUrl: 'https://probe6.test',
        name: 'P6',
      );
      final ds = WebScraperDataSource(dio: dio, source: src);
      final res = await ds.getDetail('p~phim-la');
      expect(res.movie.name, 'Phim La');
      // Trang tập con 404 -> server Mặc định, nhưng danh sách tập heuristic
      // vẫn bóc được 2 tập.
      final epCount = res.servers.fold<int>(
        0,
        (sum, s) => sum + s.episodes.length,
      );
      expect(epCount, 2);
      expect(res.servers.first.serverName, 'Mặc định');
    });
  });
}
