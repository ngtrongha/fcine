import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/master_config.dart';
import '../config/source_templates.dart';
import 'web_scraper.dart';

/// Cấu hình AI do user tự nhập trong Cài đặt (OpenAI-compatible endpoints).
class AiConfig {
  final String endpoint;
  final String key;
  final String model;
  const AiConfig({required this.endpoint, required this.key, this.model = ''});

  bool get isValid => endpoint.trim().isNotEmpty && key.trim().isNotEmpty;

  Map<String, String> toJson() => {
    'endpoint': endpoint,
    'key': key,
    'model': model,
  };

  factory AiConfig.fromJson(Map<String, dynamic> json) => AiConfig(
    endpoint: json['endpoint']?.toString() ?? '',
    key: json['key']?.toString() ?? '',
    model: json['model']?.toString() ?? '',
  );
}

/// Lỗi khi AI không sinh được config hợp lệ.
class AiConfigException implements Exception {
  final String message;
  const AiConfigException(this.message);
  @override
  String toString() => message;
}

/// Dùng LLM (OpenAI-compatible) sinh selectors cho web phim lạ sau khi
/// heuristic probe fail. CHỈ là TÙY CHỌN bổ sung — không cấu hình thì luồng
/// thêm nguồn vẫn chạy độc lập bằng WebProbe heuristic.
class AiConfigGenerator {
  final Dio _ai;
  final AiConfig config;

  static const _timeout = Duration(seconds: 30);

  AiConfigGenerator(this.config, {Dio? aiDio})
    : _ai =
          aiDio ??
          Dio(
            BaseOptions(
              baseUrl: config.endpoint,
              connectTimeout: _timeout,
              sendTimeout: _timeout,
              receiveTimeout: _timeout,
              validateStatus: (s) => s != null && s < 500,
            ),
          );

  /// Sinh [SourceConfig] từ homepage của [baseUrl].
  ///
  /// Trả về `null` khi AI không trả config hợp lệ (caller fallback heuristic).
  /// Ném [AiConfigException] với lý do rõ ràng khi lỗi mạng/auth (user nên biết).
Future<SourceConfig?> generate({
    required String baseUrl,
    String? name,
    Dio? siteDio,
  }) async {
    // 1. Fetch homepage (trim head + đầu body, ~28KB).
    final html = await _fetchHomepage(
      siteDio ?? _siteDio(baseUrl),
      baseUrl,
    );
    // 2. Build prompt → call AI.
    final reply = await _chat(_buildPrompt(html));
    if (reply == null || reply.trim().isEmpty) return null;
    // 3. Parse JSON → validate → trả config.
    final json = _extractJson(reply.trim());
    if (json == null) return null;
    final cfg = _toSourceConfig(json, baseUrl: baseUrl, name: name);
    return cfg;
  }

  Dio _siteDio(String baseUrl) => Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'user-agent': WebScraper.ua,
        'accept-language': 'vi-VN,vi;q=0.9,en;q=0.8',
      },
      connectTimeout: _timeout,
      sendTimeout: _timeout,
      receiveTimeout: _timeout,
      validateStatus: (s) => s != null && s < 500,
      followRedirects: true,
    ),
  );

  static Future<String> _fetchHomepage(Dio dio, String baseUrl) async {
    final res = await dio.get(
      baseUrl,
      options: Options(responseType: ResponseType.plain),
    );
    if (res.statusCode != 200 || res.data is! String) {
      throw AiConfigException('Không tải được homepage (${res.statusCode})');
    }
    final html = res.data as String;

    // Giữ <head> nguyên (meta/JSON-LD), cắt phần body đầu.
    // HTML thường là <html><head>...</head><body>... ⟵ lấy ở đây.
    const headLimit = 20000;
    const bodyLimit = 8000;
    if (html.length <= headLimit + bodyLimit) return html;

    final bodyIdx = html.indexOf('<body');
    if (bodyIdx == -1) return html.substring(0, headLimit);

    final head = html.substring(0, bodyIdx.clamp(0, headLimit));
    final body = html.substring(bodyIdx, bodyIdx + bodyLimit.clamp(0, html.length - bodyIdx));
    return head + body;
  }

  String _buildPrompt(String html) => '''
You are a web scraping configuration generator for a movie streaming app.
Analyze this homepage HTML and output ONLY valid JSON (no markdown fences) with this exact schema:
{
  "selectors": {
    "list": "<CSS selector for repeated movie card container>",
    "link": "a[href]",
    "title": "<selector for movie title within card>",
    "poster": "img",
    "posterAttr": "data-src,src",
    "year": "<selector for year text within card>",
    "typeBadge": "<selector for type badge (Phim Bộ/Phim Lẻ/etc) within card>",
    "detailTitle": "<selector for movie title on detail page>",
    "detailContent": "<selector for movie synopsis/description on detail page>",
    "detailPoster": "<selector for movie poster image on detail page>",
    "episodeItem": "<selector for episode number links on detail page (e.g. <a>Tập 1</a>)>",
    "playerOption": "<CSS selector for server/player option button (empty if none)>",
    "playerApi": "<URL template for player JSON API if exists (e.g. /wp-json/dooplayer/v2/{post}/{ptype}/{source}), else empty>",
    "typeMap": {}
  },
  "endpoints": {
    "latest": {"method": "GET", "path": "<path with {page} placeholder, e.g. /movies/page/{page}/ or /page/{page}/>"},
    "search": {"method": "GET", "path": "<path with {keyword} placeholder, e.g. /?s={keyword} or /tim-kiem?keyword={keyword}>"},
    "detail": {"method": "GET", "path": "/{slug}"},
    "listByType": {"method": "GET", "path": "<path with {type} placeholder, e.g. /{type}/page/{page}/>"}
  },
  "pagination": {"type": "web_next_page"}
}
RULES:
- Only use CSS3 selectors. Do NOT use :has(), ::parent, or any pseudo beyond CSS3 basics.
- Extract REAL paths from the HTML (nav links, pagination hrefs, form actions).
- "playerOption" and "playerApi": detect if site uses DooPlay/hooks (li.dooplay_player_option, data-post attributes). If detected, set playerApi to the dooplayer REST path template. Otherwise leave both as empty strings.
- The "year" selector should match text with a 4-digit year (e.g. 2025) inside movie cards.
- episodeItem": links containing episode numbers (Tập 1, Ep 1, Episode 1, or numbered hrefs) on detail pages.
- Output ONLY the JSON. No explanations, no code fences.

HOMEPAGE HTML:
$html
''';

  /// Trích JSON từ reply AI (hỗ trợ ```json fence hoặc plain text).
  static Map<String, dynamic>? _extractJson(String raw) {
    var s = raw.trim();
    final fence = RegExp(r'```(?:json)?\s*(.*?)\s*```', dotAll: true).firstMatch(s);
    if (fence != null) s = fence.group(1)!.trim();
    final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(s);
    if (match == null) return null;
    try {
      return jsonDecode(match.group(0)!) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Build và validate SourceConfig từ raw JSON. Trả null nếu thiếu phần bắt buộc.
  SourceConfig? _toSourceConfig(
    Map<String, dynamic> json, {
    required String baseUrl,
    String? name,
  }) {
    final selectors = (json['selectors'] as Map?)?.cast<String, dynamic>() ?? {};
    final endpoints = (json['endpoints'] as Map?)?.cast<String, dynamic>() ?? {};
    if (selectors.isEmpty) return null;

    // Validate bắt buộc phải có.
    final search = endpoints['search'] is Map
        ? (endpoints['search'] as Map).cast<String, dynamic>()
        : null;
    final latest = endpoints['latest'] is Map
        ? (endpoints['latest'] as Map).cast<String, dynamic>()
        : null;
    final detail = endpoints['detail'] is Map
        ? (endpoints['detail'] as Map).cast<String, dynamic>()
        : null;
    final searchPath = search?['path']?.toString() ?? '';
    final latestPath = latest?['path']?.toString() ?? '';
    final detailPath = detail?['path']?.toString() ?? '';
    if (searchPath.isEmpty || !searchPath.contains('{keyword}')) return null;
    if (latestPath.isEmpty || !latestPath.contains('{page}')) return null;
    if (detailPath.isEmpty) return null;

    // Validate listByType (bắt buộc có {type}).
    final listByTypeMap = endpoints['listByType'] is Map
        ? (endpoints['listByType'] as Map).cast<String, dynamic>()
        : null;
    final listByTypePath = listByTypeMap?['path']?.toString();
    if (listByTypePath != null &&
        listByTypePath.isNotEmpty &&
        !listByTypePath.contains('{type}')) {
      return null;
    }

    final base = SourceTemplates.webGeneric(baseUrl: baseUrl, name: name);
    return base.copyWith(
      selectors: selectors,
      endpoints: Endpoints(
        latest: Endpoint(path: latestPath, method: 'GET'),
        latestV1: null,
        search: Endpoint(path: searchPath, method: search?['method']?.toString() ?? 'GET'),
        detail: Endpoint(path: detailPath, method: 'GET'),
        listByType: listByTypePath != null && listByTypePath.isNotEmpty
            ? Endpoint(path: listByTypePath, method: 'GET')
            : null,
      ),
    );
  }

  /// Hỏi LLM qua OpenAI-compatible /chat/completions.
  Future<String?> _chat(String prompt) async {
    try {
      final res = await _ai.post(
        '${config.endpoint}/chat/completions',
        data: jsonEncode({
          'model': config.model.isEmpty ? 'gpt-4o-mini' : config.model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0,
        }),
        options: Options(
          headers: {
            'authorization': 'Bearer ${config.key}',
            'content-type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
      );
      if (res.statusCode != 200) {
        throw AiConfigException('AI trả về ${res.statusCode}');
      }
      final data = res.data;
      if (data is! Map || data['choices'] is! List) return null;
      final choices = data['choices'] as List;
      if (choices.isEmpty) return null;
      final first = choices.first;
      if (first is! Map) return null;
      final message = first['message'];
      if (message is! Map) return null;
      final content = message['content'];
      return content is String ? content : null;
    } on DioException catch (e) {
      final msg = e.response?.statusCode != null
          ? 'AI lỗi HTTP ${e.response!.statusCode}'
          : 'Không kết nối được AI (${e.message})';
      throw AiConfigException(msg);
    } catch (e) {
      if (e is AiConfigException) rethrow;
      throw AiConfigException('AI lỗi: $e');
    }
  }
}
