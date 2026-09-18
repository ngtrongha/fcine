import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/core/scraper/ai_config_generator.dart';

void main() {
  Dio mockDio(int status, String body) {
    final dio = Dio(BaseOptions());
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          dynamic responseData = body;
          // Nếu body là JSON hợp lệ, parse trước để Dio không bị confuse
          if (body.trim().startsWith('{') || body.trim().startsWith('[')) {
            try {
              responseData = jsonDecode(body);
            } catch (_) {}
          }
          handler.resolve(
            Response(requestOptions: options, statusCode: status, data: responseData),
          );
        },
      ),
    );
    return dio;
  }

  const homepageHtml = '<html><body><div class="film-list">'
      '<div class="film"><a href="https://web.test/xem/phim-a">'
      '<img src="https://web.test/a.jpg" />Phim A</a></div>'
      '</div></body></html>';

  Map<String, dynamic> aiReply(String content) => {
    'choices': [
      {'message': {'content': content}},
    ],
  };

  const validConfigJson = '''
{
  "selectors": {
    "list": "div.film-list .film",
    "link": "a[href]",
    "title": "a",
    "poster": "img",
    "posterAttr": "data-src,src",
    "episodeItem": "a",
    "playerOption": "",
    "playerApi": ""
  },
  "endpoints": {
    "latest": {"path": "/page/{page}/", "method":"GET"},
    "search": {"path": "/?s={keyword}", "method":"GET"},
    "detail": {"path": "/{slug}", "method":"GET"},
    "listByType": {"path": "/{type}/page/{page}/", "method":"GET"}
  },
  "pagination": {"type": "web_next_page"}
}
''';

  group('AiConfigGenerator', () {
    test('parse JSON sạch -> SourceConfig đúng endpoints', () async {
      final gen = AiConfigGenerator(
        const AiConfig(
          endpoint: 'https://api.test',
          key: 'fake-key',
          model: 'gpt-4o-mini',
        ),
        aiDio: mockDio(200, jsonEncode(aiReply(validConfigJson))),
      );
      final cfg = await gen.generate(
        baseUrl: 'https://web.test',
        name: 'TestWeb',
        siteDio: mockDio(200, homepageHtml),
      );
      expect(cfg, isNotNull);
      expect(cfg!.baseUrl, 'https://web.test');
      expect(cfg.name, 'TestWeb');
      expect(cfg.webSelector('list'), 'div.film-list .film');
      expect(cfg.endpoints.search.path, '/?s={keyword}');
      expect(cfg.endpoints.latest.path, '/page/{page}/');
      expect(cfg.endpoints.listByType?.path, '/{type}/page/{page}/');
      expect(cfg.isWeb, isTrue);
    });

    test('AI wrap JSON trong ```fence``` vẫn parse được', () async {
      final wrapped = '```json\n$validConfigJson```';
      final gen = AiConfigGenerator(
        const AiConfig(endpoint: 'https://api.test', key: 'k'),
        aiDio: mockDio(200, jsonEncode(aiReply(wrapped))),
      );
      final cfg = await gen.generate(
        baseUrl: 'https://web.test',
        name: 'T',
        siteDio: mockDio(200, homepageHtml),
      );
      expect(cfg, isNotNull);
      expect(cfg!.endpoints.search.path, '/?s={keyword}');
    });

    test('AI trả JSON hiêu endpoint search -> null (fallback)', () async {
      const badJson = '{"selectors":{"list":"div.movie"},'
          '"endpoints":{"detail":{"path":"detail.php"}}}';
      final gen = AiConfigGenerator(
        const AiConfig(endpoint: 'https://api.test', key: 'k'),
        aiDio: mockDio(200, jsonEncode(aiReply(badJson))),
      );
      final cfg = await gen.generate(
        baseUrl: 'https://web.test',
        siteDio: mockDio(200, homepageHtml),
      );
      expect(cfg, isNull);
    });

    test('endpoint search path thiếu {keyword} -> null', () async {
      // Thiếu {keyword} trong search path -> config null
      const badEndpoint =
          '{"selectors":{"list":"div.movie"},'
          '"endpoints":{"latest":{"path":"/page/{page}/"},'
          '"search":{"path":"/search"},"detail":{"path":"/detail"}}}';
      final gen = AiConfigGenerator(
        const AiConfig(endpoint: 'https://api.test', key: 'k'),
        aiDio: mockDio(200, jsonEncode(aiReply(badEndpoint))),
      );
      final cfg = await gen.generate(
        baseUrl: 'https://web.test',
        siteDio: mockDio(200, homepageHtml),
      );
      expect(cfg, isNull);
    });

    test('AI trả lỗi HTTP 401 -> ném AiConfigException', () async {
      final gen = AiConfigGenerator(
        const AiConfig(endpoint: 'https://api.test', key: 'wrong'),
        aiDio: mockDio(401, '{"error":"unauthorized"}'),
      );
      expect(
        () => gen.generate(baseUrl: 'https://web.test', siteDio: mockDio(200, homepageHtml)),
        throwsA(isA<AiConfigException>()),
      );
    });

    test('homepage dài bị trim an toàn khi vượt quá giới hạn', () async {
      // Html lớn hơn limit sẽ được cắt trong _fetchHomepage, không crash.
      final bigHtml = '<html><body>${"<p>x</p>" * 10000}</body></html>';
      final gen = AiConfigGenerator(
        const AiConfig(endpoint: 'https://api.test', key: 'k'),
        aiDio: mockDio(200, jsonEncode(aiReply(validConfigJson))),
      );
      // Html lớn hơn limit sẽ được cắt trong _fetchHomepage, không crash.
      final cfg = await gen.generate(
        baseUrl: 'https://web.test',
        siteDio: mockDio(200, bigHtml),
      );
      expect(cfg, isNotNull);
      expect(cfg!.baseUrl, 'https://web.test');
    });
  });
}
