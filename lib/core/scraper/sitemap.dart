import 'package:dio/dio.dart';

/// Đọc sitemap của web phim để lấy catalog khi trang list render bằng JS
/// (VD web Next.js như Rophim: HTML gốc không có card phim nhưng
/// sitemap-movie-*.xml liệt kê đầy đủ URL chi tiết).
///
/// Không cần thêm dependency XML: sitemap có cấu trúc đơn giản, parse
/// bằng regex `<loc>` là đủ và nhanh.
class SitemapStore {
  SitemapStore._();

  static final Map<String, _SitemapCache> _cache = {};
  static const Duration ttl = Duration(hours: 6);

  /// Tối đa child sitemap và URL để không treo máy với sitemap khổng lồ.
  static const int maxChildren = 5;
  static const int maxLocs = 3000;

  /// Path segment loại khỏi catalog (trang tĩnh, taxonomy, auth...).
  static const Set<String> _excluded = {
    'lien-he',
    'gioi-thieu',
    'chinh-sach-bao-mat',
    'dieu-khoan-su-dung',
    'hoi-dap',
    'blog',
    'tin-tuc',
    'the-loai',
    'quoc-gia',
    'dien-vien',
    'dao-dien',
    'chu-de',
    'genre',
    'genres',
    'country',
    'countries',
    'actor',
    'actors',
    'director',
    'tag',
    'tags',
    'category',
    'categories',
    'author',
    'page',
    'trang',
    'login',
    'register',
    'dang-nhap',
    'dang-ky',
    'user',
    'search',
    'tim-kiem',
    'duyet-tim',
    'lich-chieu',
    'collection',
    'collections',
    'network',
    'networks',
    'nha-san-xuat',
  };

  static const Set<String> _excludedContains = {
    'login',
    'register',
    'dang-nhap',
    'dang-ky',
  };

  /// Lấy (có cache TTL) toàn bộ URL phim từ sitemap của [baseUrl].
  /// Ném [SitemapException] khi không có sitemap dùng được.
  static Future<List<Uri>> locsFor(
    Dio dio,
    String baseUrl, {
    bool force = false,
  }) async {
    final base = Uri.parse(baseUrl);
    final key = '${base.scheme}://${base.host}';
    final hit = _cache[key];
    if (!force &&
        hit != null &&
        DateTime.now().difference(hit.at) < ttl &&
        hit.locs.isNotEmpty) {
      return hit.locs;
    }
    final locs = await _collect(dio, base);
    if (locs.isEmpty) {
      throw SitemapException('Sitemap không chứa URL phim nào khả dụng');
    }
    _cache[key] = _SitemapCache(locs, DateTime.now());
    return locs;
  }

  static void clear() => _cache.clear();

  static Future<List<Uri>> _collect(Dio dio, Uri base) async {
    final indexXml = await _getText(
      dio,
      base.resolve('/sitemap.xml').toString(),
    );
    if (indexXml == null) {
      throw SitemapException('Không tải được /sitemap.xml');
    }
    List<String> childXmls;
    if (indexXml.contains('<sitemapindex')) {
      final all = _parseLocs(indexXml)
          .map((e) => e.toString())
          .where((u) => u.toLowerCase().endsWith('.xml'))
          .toList();
      childXmls = _preferMovieSitemaps(all).take(maxChildren).toList();
      if (childXmls.isEmpty) {
        throw SitemapException('Sitemap index không có sitemap con .xml');
      }
    } else if (indexXml.contains('<urlset')) {
      childXmls = const [];
      final direct = _filterMovieLocs(_parseLocs(indexXml), base);
      return direct.take(maxLocs).toList();
    } else {
      throw SitemapException('Nội dung /sitemap.xml không phải sitemap');
    }
    final results = await Future.wait(
      childXmls.map((u) => _getText(dio, u).then((xml) {
        if (xml == null) return <Uri>[];
        return _filterMovieLocs(_parseLocs(xml), base);
      })),
    );
    final seen = <String>{};
    final out = <Uri>[];
    for (final list in results) {
      for (final u in list) {
        if (seen.add(u.toString())) out.add(u);
        if (out.length >= maxLocs) return out;
      }
    }
    return out;
  }

  /// Ưu tiên sitemap phim (movie/phim/film/video/post) trước.
  static List<String> _preferMovieSitemaps(List<String> urls) {
    bool isMovie(String u) {
      final l = u.toLowerCase();
      return l.contains('movie') ||
          l.contains('phim') ||
          l.contains('film') ||
          l.contains('video') ||
          l.contains('post') ||
          l.contains('url');
    }

    final movies = urls.where(isMovie).toList();
    final rest = urls.where((u) => !isMovie(u)).toList();
    return [...movies, ...rest];
  }

  static List<Uri> _parseLocs(String xml) {
    final re = RegExp(
      r'<loc>\s*(https?://[^<\s]+)\s*</loc>',
      caseSensitive: false,
    );
    final out = <Uri>[];
    for (final m in re.allMatches(xml)) {
      final uri = Uri.tryParse(m.group(1)!.trim());
      if (uri != null && uri.hasScheme && uri.hasAuthority) out.add(uri);
    }
    return out;
  }

  static List<Uri> _filterMovieLocs(List<Uri> locs, Uri base) {
    final host = base.host.toLowerCase();
    final out = <Uri>[];
    for (final u in locs) {
      if (u.host.toLowerCase() != host) continue;
      final segs = u.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segs.length < 2) continue;
      var bad = false;
      for (final s in segs) {
        final l = s.toLowerCase();
        if (_excluded.contains(l) ||
            _excludedContains.any((k) => l.contains(k))) {
          bad = true;
          break;
        }
      }
      if (!bad) out.add(u);
    }
    return out;
  }

  static Future<String?> _getText(Dio dio, String url) async {
    try {
      final res = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (res.statusCode == 200 && res.data is String) {
        return res.data as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// "bay-vao-tim-anh.nW5PZega" -> "Bay Vao Tim Anh".
  /// (Slug không dấu nên tên list sẽ không dấu — tên đầy đủ có dấu lấy
  /// ở trang chi tiết SSR.)
  static String prettifySlug(String seg) {
    var s = seg.replaceAll(RegExp(r'\.[A-Za-z0-9]{6,12}$'), '');
    s = s.replaceAll(RegExp(r'[-_]+'), ' ').trim();
    if (s.isEmpty) return seg;
    return s
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static const Map<String, String> _viMap = {
    'à': 'a',
    'á': 'a',
    'ạ': 'a',
    'ả': 'a',
    'ã': 'a',
    'â': 'a',
    'ầ': 'a',
    'ấ': 'a',
    'ậ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ă': 'a',
    'ằ': 'a',
    'ắ': 'a',
    'ặ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'è': 'e',
    'é': 'e',
    'ẹ': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ê': 'e',
    'ề': 'e',
    'ế': 'e',
    'ệ': 'e',
    'ể': 'e',
    'ễ': 'e',
    'ì': 'i',
    'í': 'i',
    'ị': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'ò': 'o',
    'ó': 'o',
    'ọ': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ô': 'o',
    'ồ': 'o',
    'ố': 'o',
    'ộ': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ơ': 'o',
    'ờ': 'o',
    'ớ': 'o',
    'ợ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'ù': 'u',
    'ú': 'u',
    'ụ': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ư': 'u',
    'ừ': 'u',
    'ứ': 'u',
    'ự': 'u',
    'ử': 'u',
    'ữ': 'u',
    'ỳ': 'y',
    'ý': 'y',
    'ỵ': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'đ': 'd',
  };

  /// "Bay Vào Tim Anh" -> "bay vao tim anh" để tìm không dấu khớp slug.
  static String stripDiacritics(String input) {
    final sb = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      final lower = ch.toLowerCase();
      sb.write(_viMap[lower] ?? lower);
    }
    return sb.toString();
  }
}

class _SitemapCache {
  final List<Uri> locs;
  final DateTime at;
  const _SitemapCache(this.locs, this.at);
}

class SitemapException implements Exception {
  final String message;
  const SitemapException(this.message);
  @override
  String toString() => message;
}
