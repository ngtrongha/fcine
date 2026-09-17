import 'master_config.dart';
import '../scraper/web_scraper.dart';

/// Template tạo [SourceConfig] tương thích KKPhim/OPhim từ baseUrl do user nhập.
/// Không hard-code URL nguồn trong app — chỉ dùng làm mẫu khi user chủ động thêm.
class SourceTemplates {
  /// Tạo 1 nguồn tương thích KKPhim từ baseUrl.
  /// Ví dụ: https://phimapi.com
  static SourceConfig kkphimCompatible({
    required String baseUrl,
    String? id,
    String? name,
  }) {
    final normalized = _normalizeBaseUrl(baseUrl);
    final derivedId =
        id ??
        'custom-${normalized.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase()}';
    final derivedName = name ?? _guessName(normalized);
    return SourceConfig(
      id: derivedId,
      name: derivedName,
      enabled: true,
      baseUrl: normalized,
      fallbackUrls: const [],
      cdnImage: 'https://phimimg.com',
      headers: const {'accept': 'application/json'},
      endpoints: Endpoints(
        latest: Endpoint(
          path: '/danh-sach/phim-moi-cap-nhat?page={page}',
          method: 'GET',
        ),
        latestV1: Endpoint(
          path: '/v1/api/danh-sach?page={page}',
          method: 'GET',
        ),
        search: Endpoint(
          path: '/v1/api/tim-kiem?keyword={keyword}&page={page}&limit=24',
          method: 'GET',
        ),
        detail: Endpoint(path: '/phim/{slug}', method: 'GET'),
        listByType: Endpoint(
          path: '/v1/api/danh-sach/{type}?page={page}',
          method: 'GET',
        ),
      ),
      extractors: {
        'latest': {
          'list': r'$.items',
          'id': r'$.slug',
          'title': r'$.name',
          'originalTitle': r'$.origin_name',
          'poster': r'$.poster_url',
          'thumb': r'$.thumb_url',
          'year': r'$.year',
          'quality': r'$.quality',
          'language': r'$.lang',
          'time': r'$.time',
          'episodeCurrent': r'$.episode_current',
        },
        'pagination': {
          'items': r'$.items',
          'totalItems': r'$.pagination.totalItems',
          'totalPages': r'$.pagination.totalPages',
          'currentPage': r'$.pagination.currentPage',
          'itemsPerPage': r'$.pagination.totalItemsPerPage',
        },
        'search': {
          'list': r'$.items',
          'totalItems': r'$.pagination.totalItems',
          'totalPages': r'$.pagination.totalPages',
          'currentPage': r'$.pagination.currentPage',
        },
        'detail': {
          'movie': r'$.movie',
          'episodes': r'$.episodes',
          'id': r'$.movie._id',
          'slug': r'$.movie.slug',
          'title': r'$.movie.name',
          'originalTitle': r'$.movie.origin_name',
          'poster': r'$.movie.poster_url',
          'thumb': r'$.movie.thumb_url',
          'year': r'$.movie.year',
          'quality': r'$.movie.quality',
          'language': r'$.movie.lang',
          'time': r'$.movie.time',
          'episodeCurrent': r'$.movie.episode_current',
          'type': r'$.movie.type',
          'content': r'$.movie.content',
          'actors': r'$.movie.actor',
          'directors': r'$.movie.director',
          'categories': r'$.movie.category',
          'countries': r'$.movie.country',
        },
        'episodes': {
          'serverName': r'$.server_name',
          'serverData': r'$.server_data',
          'name': r'$.name',
          'slug': r'$.slug',
          'm3u8': r'$.link_m3u8',
          'embed': r'$.link_embed',
        },
      },
      pagination: const {'type': 'page_number', 'param': 'page'},
    );
  }

  /// Tạo nguồn web WordPress theme DooPlay (MotChill, ...) từ URL trang chủ.
  /// Ví dụ: https://motchilltv.zip
  static SourceConfig webDooplay({required String baseUrl, String? name}) {
    final normalized = _normalizeBaseUrl(baseUrl);
    final derivedId =
        'web-${normalized.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase()}';
    return SourceConfig(
      id: derivedId,
      name: (name ?? '').trim().isEmpty ? _guessName(normalized) : name!.trim(),
      enabled: true,
      sourceType: 'web',
      baseUrl: normalized,
      fallbackUrls: const [],
      cdnImage: '',
      headers: const {'accept': 'text/html', 'user-agent': WebScraper.ua},
      endpoints: Endpoints(
        latest: Endpoint(path: '/movies/page/{page}/', method: 'GET'),
        search: Endpoint(path: '/?s={keyword}', method: 'GET'),
        detail: Endpoint(path: '/{slug}', method: 'GET'),
        listByType: Endpoint(path: '/{type}/page/{page}/', method: 'GET'),
      ),
      selectors: dooplaySelectors(),
      pagination: const {'type': 'web_next_page'},
    );
  }

  /// Tạo nguồn web generic (user tự tuning selectors trong master_config.json).
  static SourceConfig webGeneric({required String baseUrl, String? name}) {
    final normalized = _normalizeBaseUrl(baseUrl);
    final derivedId =
        'web-${normalized.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase()}';
    return SourceConfig(
      id: derivedId,
      name: (name ?? '').trim().isEmpty ? _guessName(normalized) : name!.trim(),
      enabled: true,
      sourceType: 'web',
      baseUrl: normalized,
      fallbackUrls: const [],
      cdnImage: '',
      headers: const {'accept': 'text/html', 'user-agent': WebScraper.ua},
      endpoints: Endpoints(
        latest: Endpoint(path: '/page/{page}/', method: 'GET'),
        search: Endpoint(path: '/?s={keyword}', method: 'GET'),
        detail: Endpoint(path: '/{slug}', method: 'GET'),
        listByType: Endpoint(path: '/{type}/page/{page}/', method: 'GET'),
      ),
      selectors: const {
        'list': 'article',
        'link': 'a',
        'title': 'h2, h3',
        'poster': 'img',
        'posterAttr': 'data-src,src',
        'episodeItem': 'a',
      },
      pagination: const {'type': 'web_next_page'},
    );
  }

  /// Nguồn web lấy danh sách từ sitemap (cho web render JS kiểu SPA:
  /// HTML gốc không có card phim nhưng sitemap liệt kê đủ URL chi tiết).
  /// Đây là CHIẾN LƯỢC chung, không gắn site nào: tiêu đề/poster lấy ở
  /// trang chi tiết SSR + meta/JSON-LD chuẩn.
  static SourceConfig webSitemap({required String baseUrl, String? name}) {
    final base = webGeneric(baseUrl: baseUrl, name: name);
    return base.copyWith(
      endpoints: Endpoints(
        latest: Endpoint(path: 'sitemap:/sitemap.xml', method: 'GET'),
        search: Endpoint(path: 'sitemap:', method: 'GET'),
        detail: base.endpoints.detail,
        listByType: base.endpoints.listByType,
      ),
    );
  }

  static String _normalizeBaseUrl(String input) {
    var url = input.trim();
    if (url.isEmpty) return url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    // Bỏ trailing slash
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static String _guessName(String baseUrl) {
    try {
      final uri = Uri.parse(baseUrl);
      var host = uri.host;
      if (host.startsWith('www.')) host = host.substring(4);
      final first = host.split('.').first;
      if (first.isEmpty) return 'Nguồn phim';
      return first[0].toUpperCase() + first.substring(1);
    } catch (_) {
      return 'Nguồn phim';
    }
  }

  /// Validate nhanh URL do user nhập.
  static String? validateSourceUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập URL nguồn';
    }
    final trimmed = value.trim();
    final normalized = _normalizeBaseUrl(trimmed);
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'URL không hợp lệ (vd: https://phimapi.com)';
    }
    if (!(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'Chỉ hỗ trợ http/https';
    }
    return null;
  }

  /// Validate URL file cấu hình JSON (master_config.json).
  static String? validateConfigUrl(String? value) {
    final err = validateSourceUrl(value);
    if (err != null) return err;
    return null;
  }

  /// Validate URL web phim bất kỳ (dùng cho nguồn web).
  static String? validateWebUrl(String? value) {
    final err = validateSourceUrl(value);
    if (err != null) return err;
    return null;
  }
}

/// Key selector CSS chuẩn cho nguồn web (dùng trong `SourceConfig.selectors`).
/// Mọi web phim đều map được về cùng 1 bộ key này — app không cần sửa code.
class WebSelectors {
  // Danh sách card phim.
  static const list = 'list'; // item card
  static const link = 'link'; // <a> tới trang chi tiết
  static const title = 'title'; // tên phim
  static const poster = 'poster'; // <img> poster
  static const posterAttr = 'posterAttr'; // "data-src,src": thử lần lượt
  static const year = 'year'; // năm
  static const typeBadge = 'typeBadge'; // nhãn Phim Bộ/Lẻ/...
  // Trang chi tiết.
  static const detailTitle = 'detailTitle';
  static const detailOrigin = 'detailOrigin'; // tên gốc (alias/original)
  static const detailContent = 'detailContent';
  static const detailPoster = 'detailPoster';
  // Tập phim: <a> tới trang tập (web dạng DooPlay) hoặc rỗng.
  static const episodeItem = 'episodeItem';
  // Player trong trang tập/trang chi tiết.
  static const playerOption = 'playerOption'; // option (data-post/type/nume)
  static const playerApi = 'playerApi'; // template DooPlayer JSON
  // Map type app (phim-bo/phim-le/hoat-hinh/tv-shows) -> path web.
  static const typeMap = 'typeMap';
}

/// Preset selector cho web WordPress theme DooPlay (MotChill, ...).
Map<String, dynamic> dooplaySelectors() => {
      'list': 'article.item',
      'link': '.image a',
      'title': '.data h3.title',
      'poster': 'img',
      'posterAttr': 'data-src,src',
      'year': '.data span',
      'typeBadge': '.item_type',
      'detailTitle': 'h1',
      'detailContent': '.wp-content, .entry-content',
      'detailPoster': '.poster img, .sheader .poster img',
      'episodeItem': '#seasons ul.episodios a',
      'playerOption': '.dooplay_player_option',
      'playerApi': '/wp-json/dooplayer/v2/{post}/{ptype}/{source}',
      'typeMap': {
        'phim-bo': 'tvshows',
        'tv-shows': 'tvshows',
        'phim-le': 'movies',
        'hoat-hinh': 'movies',
      },
    };
