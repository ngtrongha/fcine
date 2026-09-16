import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/core/config/source_templates.dart';
import 'package:fcine/core/scraper/web_scraper.dart';
import 'package:fcine/data/datasources/web_scraper_datasource.dart';

// Fixture mô phỏng markup DooPlay thật (MotChill).
const _listHtml = '''
<html><body><div class="module"><div class="content"><div class="items">
<article class="item"><div class="image">
<a href="https://web.test/tvshows/ngu-dinh-dao/">
<img data-src="https://web.test/poster1.jpg" alt="Ngu Dinh Dao" /></a>
<a href="https://web.test/tvshows/ngu-dinh-dao/">
<div class="data"><h3 class="title">Ngu Dinh Dao</h3><span>2026</span></div></a>
<span class="item_type">Phim Bộ</span></div></article>
<article class="item"><div class="image">
<a href="https://web.test/movies/tieu-dao/">
<img src="https://web.test/poster2.jpg" alt="Tieu Dao" /></a>
<a href="https://web.test/movies/tieu-dao/">
<div class="data"><h3 class="title">Tieu Dao</h3><span>2025</span></div></a>
<span class="item_type">Phim Lẻ</span></div></article>
</div></div></div></body></html>
''';

const _detailHtml = '''
<html><head>
<meta property="og:title" content="Ngu Dinh Dao (2026) Full Vietsub - Web" />
<meta property="og:image" content="https://web.test/og.jpg" />
<meta name="description" content="Mo ta phim" />
</head><body>
<h1>Ngu Dinh Dao</h1>
<div id="seasons"><div class="se-c"><div class="se-a"><ul class="episodios">
<li><div class="episodiotitle"><a href="https://web.test/episodes/ngu-dinh-dao-tap-1/">Tập 1</a></div></li>
<li><div class="episodiotitle"><a href="https://web.test/episodes/ngu-dinh-dao-tap-2/">Tập 2</a></div></li>
</ul></div></div></div>
</body></html>
''';

const _episodeHtml = '''
<html><body><div class="dooplay_player"><div id="playeroptions"><ul>
<li class="dooplay_player_option" data-type="tv" data-post="54168" data-nume="1">
<span class="title">Vietsub #1</span><span class="server">embed.test</span></li>
<li class="dooplay_player_option" data-type="tv" data-post="54168" data-nume="2">
<span class="title">Vietsub #2</span><span class="server">phimapi.test</span></li>
</ul></div></div></body></html>
''';

const _playerApiJson =
    '{"embed_url":"https://player.phimapi.test/player/?url=https://v7.test/abc/index.m3u8","type":"iframe"}';

WebScraperDataSource _datasource() {
  final src = SourceTemplates.webDooplay(
    baseUrl: 'https://web.test',
    name: 'WebTest',
  );
  final dio = Dio(BaseOptions(baseUrl: src.baseUrl, headers: src.headers));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final url = options.uri.toString();
        String body = _listHtml;
        if (url.contains('dooplayer')) {
          body = _playerApiJson;
        } else if (url.contains('/episodes/')) {
          body = _episodeHtml;
        } else if (url.contains('/tvshows/')) {
          body = _detailHtml;
        }
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: url.contains('dooplayer') ? body : '<html>$body</html>',
          ),
        );
      },
    ),
  );
  return WebScraperDataSource(dio: dio, source: src);
}

void main() {
  group('WebScraper helpers', () {
    test('absUrl resolve tương đối/tuyệt đối', () {
      expect(
        WebScraper.absUrl('https://web.test/a/', '/x/y'),
        'https://web.test/x/y',
      );
      expect(
        WebScraper.absUrl('https://web.test', 'https://cdn.test/p.jpg'),
        'https://cdn.test/p.jpg',
      );
      expect(WebScraper.absUrl('https://web.test', ''), '');
    });

    test('yearFromText bắt năm đầu tiên', () {
      expect(WebScraper.yearFromText('Ten Phim (2026) Full'), 2026);
      expect(WebScraper.yearFromText('Khong nam'), 0);
    });

    test('webSlug router-safe 2 chiều', () {
      expect(
        WebScraper.webSlug('tvshows', 'ngu-dinh-dao'),
        'tvshows~ngu-dinh-dao',
      );
      final p = WebScraper.parseWebSlug('tvshows~ngu-dinh-dao')!;
      expect(p.section, 'tvshows');
      expect(p.slug, 'ngu-dinh-dao');
      expect(WebScraper.parseWebSlug('no-separator'), isNull);
    });

    test('splitDetailPath tách section/slug từ href', () {
      final s = WebScraper.splitDetailPath(
        'https://web.test',
        'https://web.test/tvshows/ngu-dinh-dao/',
      )!;
      expect(s.section, 'tvshows');
      expect(s.slug, 'ngu-dinh-dao');
    });

    test('directUrlFromEmbed bóc m3u8 trong ?url=', () {
      expect(
        WebScraper.directUrlFromEmbed(
          'https://player.phimapi.test/player/?url=https://v7.test/abc/index.m3u8',
        ),
        'https://v7.test/abc/index.m3u8',
      );
      expect(WebScraper.directUrlFromEmbed('https://embed.test/e/123'), isNull);
    });

    test('scanStreamUrls bắt video source + m3u8 regex', () {
      const html = '<video><source src="/v/1.m3u8"></video>'
          '<script>var u="https://cdn.test/a.mp4";</script>';
      final urls = WebScraper.scanStreamUrls(html, 'https://web.test');
      expect(urls, contains('https://web.test/v/1.m3u8'));
      expect(urls, contains('https://cdn.test/a.mp4'));
    });

    test('iframeSrcs liệt kê iframe', () {
      const html = '<iframe src="https://embed.test/e/1"></iframe>';
      expect(
        WebScraper.iframeSrcs(html, 'https://web.test'),
        ['https://embed.test/e/1'],
      );
    });
  });

  group('SourceTemplates web', () {
    test('preset dooplay đủ selectors + endpoints', () {
      final src = SourceTemplates.webDooplay(
        baseUrl: 'https://motchilltv.zip',
        name: 'MotChill',
      );
      expect(src.isWeb, isTrue);
      expect(src.selectors['list'], 'article.item');
      expect(src.selectors['playerOption'], '.dooplay_player_option');
      expect(
        (src.selectors['playerApi'] as String).contains('dooplayer'),
        isTrue,
      );
      expect(src.endpoints.search.path.contains('{keyword}'), isTrue);
    });
  });

  group('WebScraperDataSource (fixture offline)', () {
    test('getLatest bóc cards -> slug section~slug', () async {
      final ds = _datasource();
      final res = await ds.getLatest(page: 1);
      expect(res.movies.length, 2);
      expect(res.movies[0].slug, 'tvshows~ngu-dinh-dao');
      expect(res.movies[0].name, 'Ngu Dinh Dao');
      expect(res.movies[0].posterUrl, 'https://web.test/poster1.jpg');
      expect(res.movies[0].year, 2026);
      expect(res.movies[0].type, 'series');
      expect(res.movies[0].sourceId, isNotEmpty);
    });

    test('getDetail bóc meta + tập + servers từ options', () async {
      final ds = _datasource();
      final res = await ds.getDetail('tvshows~ngu-dinh-dao');
      expect(res.movie.name, 'Ngu Dinh Dao');
      expect(res.movie.posterUrl, 'https://web.test/og.jpg');
      expect(res.servers.length, 2);
      expect(res.servers[0].serverName, 'Vietsub #1');
      expect(res.servers[0].episodes.length, 2);
      expect(
        res.servers[0].episodes[0].slug,
        'https://web.test/episodes/ngu-dinh-dao-tap-1/',
      );
    });

    test('resolveStream gọi player API -> m3u8 trực tiếp', () async {
      final ds = _datasource();
      final r = await ds.resolveStream(
        'https://web.test/episodes/ngu-dinh-dao-tap-1/',
        serverName: 'Vietsub #2',
      );
      expect(r.m3u8, 'https://v7.test/abc/index.m3u8');
      expect(r.serverUsed, 'Vietsub #2');
    });
  });
}
