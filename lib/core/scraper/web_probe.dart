import 'package:dio/dio.dart';

import '../../domain/entities/movie.dart';
import '../config/master_config.dart';
import '../config/source_templates.dart';
import 'sitemap.dart';
import 'web_scraper.dart';
import '../../data/datasources/web_scraper_datasource.dart';

/// Kết quả dò web: config đã tune + mô tả cách dò thành công.
class WebProbeResult {
  final SourceConfig source;
  final int sample;
  final String via;

  /// Phim mẫu để preview trước khi lưu (tối đa [WebProbe.previewLimit]).
  final List<Movie> movies;
  const WebProbeResult({
    required this.source,
    required this.sample,
    required this.via,
    this.movies = const [],
  });
}

class WebProbeException implements Exception {
  final List<String> tried;
  const WebProbeException(this.tried);

  String get message {
    final detail = tried.isEmpty ? '' : ' (đã thử: ${tried.join(', ')})';
    return 'Không bóc được phim nào$detail. '
        'Web có thể render bằng JS, chặn bot, hoặc đã đổi cấu trúc — '
        'thử lại sau hoặc kiểm tra URL.';
  }

  @override
  String toString() => message;
}

class _ListCandidate {
  /// Họ layout: 'dooplay' (theme DooPlay dùng chung hàng trăm web) hoặc
  /// 'generic' (đoán theo pattern phổ biến). Không có preset riêng từng
  /// site — engine tự thử và giữ cái thắng.
  final String family;
  final String latestPath;

  /// Lý do thất bại ngắn cho báo cáo (gán trong lúc probe).
  String shortError = 'lỗi';
  _ListCandidate(this.family, this.latestPath);

  String get label => latestPath;
}

/// Tự động dò cấu hình cho web phim bất kỳ: thử nhiều đường dẫn danh
/// sách × preset selector, ai bóc được phim thì thắng. Config thắng được
/// lưu lại nên mỗi web chỉ dò 1 lần (dynamic theo từng web).
class WebProbe {
  WebProbe._();

  /// Số phim tối thiểu để coi như dò trúng.
  static const int minMovies = 3;

  /// Số phim tối thiểu để nhận sitemap làm nguồn danh sách.
  static const int minSitemapMovies = 10;

  /// Số phim mẫu tối đa trả về trong kết quả (dùng cho dialog preview).
  static const int previewLimit = 12;

  static Map<String, String> get _browserHeaders => {
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'user-agent': WebScraper.ua,
    'accept-language': 'vi-VN,vi;q=0.9,en;q=0.8',
  };

  /// Thứ tự ứng viên theo gợi ý preset của user.
  static List<_ListCandidate> _candidates(String hint) {
    final dooplay = [
      _ListCandidate('dooplay', '/movies/page/{page}/'),
      _ListCandidate('dooplay', '/tvshows/page/{page}/'),
    ];
    final generic = [
      _ListCandidate('generic', '/page/{page}/'),
      _ListCandidate('generic', '/'),
    ];
    // Web custom (Next.js/SPA...): trang list SSR nếu có.
    final custom = [
      _ListCandidate('generic', '/phimhay'),
      _ListCandidate('generic', '/phim-moi'),
      _ListCandidate('generic', '/danh-sach/phim-moi'),
      _ListCandidate('generic', '/movies'),
      _ListCandidate('generic', '/movie'),
      _ListCandidate('generic', '/phim-bo'),
      _ListCandidate('generic', '/phim-le'),
    ];
    switch (hint) {
      case 'dooplay':
        return [...dooplay, ...generic, ...custom];
      case 'generic':
        return [...generic, ...dooplay, ...custom];
      case 'auto':
      default:
        return [...dooplay, ...generic, ...custom];
    }
  }

  static SourceConfig _familyBase(
    String family,
    String baseUrl,
    String? name,
  ) {
    switch (family) {
      case 'dooplay':
        return SourceTemplates.webDooplay(baseUrl: baseUrl, name: name);
      case 'generic':
      default:
        return SourceTemplates.webGeneric(baseUrl: baseUrl, name: name);
    }
  }

  /// Dò và trả về config chạy được. Ném [WebProbeException] khi thất bại.
  /// [client] chỉ dùng cho test (mock Dio).
  static Future<WebProbeResult> probe({
    required String baseUrl,
    String? name,
    String hint = 'auto',
    Duration timeout = const Duration(seconds: 10),
    Dio? client,
  }) async {
    final normalized = baseUrl.trim();
    final dio =
        client ??
        Dio(
          BaseOptions(
            baseUrl: normalized,
            headers: _browserHeaders,
            connectTimeout: timeout,
            sendTimeout: timeout,
            receiveTimeout: timeout,
            validateStatus: (s) => s != null && s < 500,
            responseType: ResponseType.plain,
            followRedirects: true,
          ),
        );
    final tried = <String>[];

    // B1: thử các combo HTML (chạy song song, ai xong trước xét trước
    // theo thứ tự ưu tiên).
    final cands = _candidates(hint);
    final results = await Future.wait(
      cands.map((c) => _tryHtml(dio, normalized, name, c, timeout)),
    );
    for (var i = 0; i < cands.length; i++) {
      final r = results[i];
      tried.add(
        r == null
            ? '${cands[i].label} (${cands[i].shortError})'
            : '${cands[i].label} (${r.sample} phim)',
      );
      // Config thắng được tune thêm search + listByType (B1.5) trước khi trả.
      if (r != null) return _tuneEndpoints(dio, r, timeout);
    }

    // B2: sitemap (cho web render JS nhưng có sitemap đầy đủ).
    final sm = await _trySitemap(dio, normalized, name, tried);
    if (sm != null) return sm;

    throw WebProbeException(tried);
  }

  static Future<WebProbeResult?> _tryHtml(
    Dio dio,
    String baseUrl,
    String? name,
    _ListCandidate cand,
    Duration timeout,
  ) async {
    try {
      final tmp = _familyBase(cand.family, baseUrl, name).copyWith(
        endpoints: _withLatestPath(
          _familyBase(cand.family, baseUrl, name).endpoints,
          cand.latestPath,
        ),
      );
      final ds = WebScraperDataSource(dio: dio, source: tmp);
      final res = await ds.getLatest(page: 1).timeout(timeout);
      if (res.movies.length < minMovies) {
        cand.shortError = '${res.movies.length} phim';
        return null;
      }
      final tuned = _familyBase(cand.family, baseUrl, name).copyWith(
        endpoints: _withLatestPath(
          _familyBase(cand.family, baseUrl, name).endpoints,
          cand.latestPath,
        ),
      );
      return WebProbeResult(
        source: tuned,
        sample: res.movies.length,
        via: cand.label,
        movies: res.movies.take(previewLimit).toList(),
      );
    } catch (e) {
      cand.shortError = _shortReason(e);
      return null;
    }
  }

  static Endpoints _withLatestPath(Endpoints e, String path) => Endpoints(
    latest: Endpoint(path: path, method: 'GET'),
    latestV1: e.latestV1,
    search: e.search,
    detail: e.detail,
    listByType: e.listByType,
  );

  /// Pattern search phổ biến của web phim (WP + custom VN).
  static const _searchPatterns = [
    '/?s={keyword}',
    '/tim-kiem?keyword={keyword}',
    '/search?q={keyword}',
    '/timkiem?keyword={keyword}',
    '?keyword={keyword}',
  ];

  /// Từ khóa dò search: 'tinh' trúng hầu hết web phim VN,
  /// 'a' dự phòng cho web ngoại/không dấu.
  static const _searchKeywords = ['tinh', 'a'];

  /// Pattern trang thể loại phổ biến. `{type}` giữ nguyên để runtime map
  /// qua `typeMap` của config (VD dooplay: phim-bo -> tvshows).
  static const _typePatterns = [
    '/{type}/page/{page}/',
    '/{type}/',
    '/the-lo/{type}/page/{page}/',
    '/the-loai/{type}/page/{page}/',
    '/genre/{type}/page/{page}/',
    '/danh-muc/{type}/page/{page}/',
  ];

  /// B1.5: tune search + listByType cho config thắng từ B1. Pattern hiện tại
  /// của config được thử trước (giữ nguyên nếu đã chạy). Bỏ qua nguồn
  /// sitemap (search/list nội bộ qua locs đã hoạt động, không cần tune).
  static Future<WebProbeResult> _tuneEndpoints(
    Dio dio,
    WebProbeResult won,
    Duration timeout,
  ) async {
    if (won.source.endpoints.latest.path.startsWith('sitemap:')) return won;
    final results = await Future.wait([
      _tuneSearch(dio, won.source, timeout),
      _tuneListByType(dio, won.source, timeout),
    ]);
    final searchPath = results[0];
    final typePath = results[1];
    if (searchPath == null && typePath == null) return won;
    var ep = won.source.endpoints;
    if (searchPath != null) {
      ep = Endpoints(
        latest: ep.latest,
        latestV1: ep.latestV1,
        search: Endpoint(path: searchPath, method: 'GET'),
        detail: ep.detail,
        listByType: ep.listByType,
      );
    }
    if (typePath != null) {
      ep = Endpoints(
        latest: ep.latest,
        latestV1: ep.latestV1,
        search: ep.search,
        detail: ep.detail,
        listByType: Endpoint(path: typePath, method: 'GET'),
      );
    }
    return WebProbeResult(
      source: won.source.copyWith(endpoints: ep),
      sample: won.sample,
      via: won.via,
      movies: won.movies,
    );
  }

  /// Thử các pattern search (song song), giữ pattern đầu tiên bóc được
  /// ≥1 phim (theo thứ tự ưu tiên: config hiện tại trước).
  static Future<String?> _tuneSearch(
    Dio dio,
    SourceConfig base,
    Duration timeout,
  ) async {
    final paths = <String>{
      base.endpoints.search.path,
      ..._searchPatterns,
    }.toList();
    final hits = await Future.wait(
      paths.map((p) => _trySearchPath(dio, base, p, timeout)),
    );
    for (var i = 0; i < paths.length; i++) {
      if (hits[i]) return paths[i];
    }
    return null;
  }

  static Future<bool> _trySearchPath(
    Dio dio,
    SourceConfig base,
    String path,
    Duration timeout,
  ) async {
    final e = base.endpoints;
    final tmp = base.copyWith(
      endpoints: Endpoints(
        latest: e.latest,
        latestV1: e.latestV1,
        search: Endpoint(path: path, method: 'GET'),
        detail: e.detail,
        listByType: e.listByType,
      ),
    );
    final ds = WebScraperDataSource(dio: dio, source: tmp);
    for (final kw in _searchKeywords) {
      try {
        final res = await ds.search(keyword: kw, limit: 5).timeout(timeout);
        if (res.movies.isNotEmpty) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Thử các pattern thể loại với type='phim-bo' (song song), giữ pattern
  /// đầu tiên bóc được ≥ [minMovies] phim.
  static Future<String?> _tuneListByType(
    Dio dio,
    SourceConfig base,
    Duration timeout,
  ) async {
    final paths = <String>{
      if (base.endpoints.listByType?.path case final String current)
        current,
      ..._typePatterns,
    }.toList();
    final hits = await Future.wait(
      paths.map((p) => _tryTypePath(dio, base, p, timeout)),
    );
    for (var i = 0; i < paths.length; i++) {
      if (hits[i]) return paths[i];
    }
    return null;
  }

  static Future<bool> _tryTypePath(
    Dio dio,
    SourceConfig base,
    String path,
    Duration timeout,
  ) async {
    final e = base.endpoints;
    final tmp = base.copyWith(
      endpoints: Endpoints(
        latest: e.latest,
        latestV1: e.latestV1,
        search: e.search,
        detail: e.detail,
        listByType: Endpoint(path: path, method: 'GET'),
      ),
    );
    final ds = WebScraperDataSource(dio: dio, source: tmp);
    try {
      final res = await ds.getListByType('phim-bo', page: 1).timeout(timeout);
      return res.movies.length >= minMovies;
    } catch (_) {
      return false;
    }
  }

  static String _shortReason(Object e) {
    final s = e.toString();
    if (s.contains('404')) return '404';
    if (s.contains('403') || s.contains('401')) return 'bị chặn';
    if (s.contains('SocketException') || s.contains('Connection')) {
      return 'mất kết nối';
    }
    if (s.contains('Timeout')) return 'quá chậm';
    if (s.contains('chặn bot')) return 'chặn bot';
    if (s.contains('Không bóc được')) return 'rỗng';
    return 'lỗi';
  }
  static Future<WebProbeResult?> _trySitemap(
    Dio dio,
    String baseUrl,
    String? name,
    List<String> tried,
  ) async {
    try {
      final locs = await SitemapStore.locsFor(dio, baseUrl);
      if (locs.length < minSitemapMovies) {
        tried.add('sitemap (${locs.length} url)');
        return null;
      }
      final src = SourceTemplates.webSitemap(
        baseUrl: baseUrl,
        name: name,
      );
      tried.add('sitemap (${locs.length} phim)');
      // Preview từ sitemap: tên từ prettify slug, chưa có poster (lấy ở
      // trang chi tiết sau khi lưu).
      final preview = <Movie>[];
      for (final u in locs.take(previewLimit)) {
        final segs = u.pathSegments.where((s) => s.isNotEmpty).toList();
        final epName = SitemapStore.prettifySlug(
          segs.isEmpty ? u.toString() : segs.last,
        );
        preview.add(
          Movie(
            id: u.toString(),
            slug: u.toString(),
            name: epName,
            originName: '',
            thumbUrl: '',
            posterUrl: '',
            year: 0,
          ),
        );
      }
      return WebProbeResult(
        source: src,
        sample: locs.length,
        via: 'sitemap (${locs.length} phim)',
        movies: preview,
      );
    } catch (e) {
      tried.add('sitemap (${_shortReason(e)})');
      return null;
    }
  }
}
