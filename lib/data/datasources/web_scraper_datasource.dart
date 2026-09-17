import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';

import '../../core/config/master_config.dart';
import '../../core/scraper/sitemap.dart';
import '../../core/scraper/web_scraper.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/pagination.dart';
import '../models/movie_model.dart';
import 'remote_datasource.dart';

/// Băm web phim bất kỳ (WordPress/DooPlay như MotChill, ...) về cùng model
/// [Movie]/[EpisodeServer] như nguồn API — UI không cần đổi.
///
/// Mọi quy tắc nằm trong [SourceConfig.selectors] (CSS selectors) nên thêm
/// web mới chỉ cần config, không sửa code. Preset xem [SourceTemplates].
///
/// Quy ước slug phim web (router-safe, 1 segment): `{section}~{slug}`
/// vd `tvshows~ngu-dinh-dao`. Slug tập = URL trang tập (full).
class WebScraperDataSource extends RemoteDataSource {
  WebScraperDataSource({required super.dio, required super.source});

  static const _htmlTimeout = Duration(seconds: 15);

  String _buildPath(String template, Map<String, String> params) {
    var url = template;
    params.forEach(
      (k, v) => url = url.replaceAll('{$k}', Uri.encodeComponent(v)),
    );
    return url;
  }

  /// GET HTML với fallback bases + header trình duyệt.
  Future<({String html, String finalUrl})> _getHtml(String path) async {
    final bases = <String>{source.baseUrl, ...source.fallbackUrls}.toList();
    DioException? lastErr;
    for (final base in bases) {
      try {
        final url = path.startsWith('http')
            ? path
            : WebScraper.absUrl(base, path);
        var res = await _getPlain(url);
        // Đổi trailing slash khi 404: WordPress bắt buộc có '/', còn web
        // Next.js/modern lại 404 khi thừa '/'. Thử cả 2 biến thể.
        if (res.statusCode == 404) {
          final alt = _toggleTrailingSlash(url);
          if (alt != url) {
            try {
              final retry = await _getPlain(alt);
              if (retry.statusCode == 200) res = retry;
            } catch (_) {}
          }
        }
        if (res.statusCode == 200 && res.data is String) {
          final html = res.data as String;
          // Soft-404: web WP đá về trang chủ (VD slug API gọi nhầm lên
          // nguồn WEB). Parse trang chủ sẽ ra phim rác "Full" không link,
          // nên báo 404 luôn để lớp trên fallback sang nguồn khác.
          final reqUri = Uri.tryParse(url);
          final wantDetail = reqUri != null &&
              reqUri.path != '/' &&
              reqUri.path.isNotEmpty;
          final finalUri = res.realUri;
          if (wantDetail &&
              (finalUri.path == '/' || finalUri.path.isEmpty) &&
              !finalUri.hasQuery) {
            lastErr = DioException(
              requestOptions: res.requestOptions,
              response: res,
              error: 'Phim không tồn tại trên nguồn này (404)',
            );
            continue;
          }
          if (_looksLikeChallenge(html)) {
            lastErr = DioException(
              requestOptions: res.requestOptions,
              response: res,
              error: 'Web chặn bot kiểm tra (thử lại sau vài phút)',
            );
            continue;
          }
          if (html.contains('<html') || html.contains('<article')) {
            return (html: html, finalUrl: url);
          }
        }
        lastErr = DioException(
          requestOptions: res.requestOptions,
          response: res,
          error: 'Status ${res.statusCode} at $url',
        );
      } catch (e) {
        lastErr = e is DioException
            ? e
            : DioException(
                requestOptions: RequestOptions(path: path),
                error: e.toString(),
              );
      }
    }
    throw lastErr!;
  }

  Future<Response> _getPlain(String url) => dio.get(
    url,
    options: Options(
      responseType: ResponseType.plain,
      sendTimeout: _htmlTimeout,
      receiveTimeout: _htmlTimeout,
      headers: {
        'accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'user-agent': WebScraper.ua,
        'accept-language': 'vi-VN,vi;q=0.9,en;q=0.8',
      },
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  /// '/phim/x/' <-> '/phim/x' (giữ nguyên '/' gốc).
  static String _toggleTrailingSlash(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.path.isEmpty || uri.path == '/') return url;
    final toggled = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : '${uri.path}/';
    return uri.replace(path: toggled).toString();
  }

  static bool _looksLikeChallenge(String html) {
    final head = html.length > 6000 ? html.substring(0, 6000) : html;
    final h = head.toLowerCase();
    return h.contains('just a moment') ||
        h.contains('cf-challenge') ||
        h.contains('cf_clearance') ||
        h.contains('checking your browser') ||
        h.contains('verify you are human');
  }

  // ---------------- Danh sách ----------------

  List<Movie> _parseCards(String base, String html) {
    final doc = WebScraper.parse(html);
    var cards = WebScraper.queryAll(
      doc,
      source.webSelector('list', 'article.item'),
    );
    // Fallback generic khi selector config không khớp (vd trang search WP).
    if (cards.isEmpty) {
      cards = WebScraper.queryAll(doc, 'article, .post, div.item');
    }
    final movies = <Movie>[];
    final seen = <String>{};
    for (final card in cards) {
      final m = _cardToMovie(base, doc, card);
      if (m == null) continue;
      if (!seen.add(m.slug)) continue;
      movies.add(m);
      if (movies.length >= 60) break;
    }
    return movies;
  }

  Movie? _cardToMovie(String base, Document doc, Element card) {
    Element? linkEl;
    for (final a in card.querySelectorAll(
      '${source.webSelector('link', '.image a')}, a[href]',
    )) {
      final href = a.attributes['href'] ?? '';
      if (href.isNotEmpty && !href.startsWith('#')) {
        linkEl = a;
        break;
      }
    }
    if (linkEl == null) return null;
    final href = linkEl.attributes['href']!;
    final split = WebScraper.splitDetailPath(base, href);
    if (split == null) return null;

    String pickText(String key, String fallbackSel) {
      final sel = source.webSelector(key, '');
      if (sel.isNotEmpty) {
        for (final el in card.querySelectorAll(sel)) {
          final t = el.text.trim().replaceAll(RegExp(r'\s+'), ' ');
          if (t.isNotEmpty) return t;
        }
      }
      return '';
    }

    var title = pickText('title', '');
    title = title.isEmpty
        ? (card
                .querySelector('h1, h2, h3')
                ?.text
                .trim()
                .replaceAll(RegExp(r'\s+'), ' ') ??
            '')
        : title;
    if (title.isEmpty) {
      title = linkEl.attributes['title']?.trim() ??
          linkEl.querySelector('img')?.attributes['alt']?.trim() ??
          '';
    }
    if (title.isEmpty) return null;

    var poster = '';
    final posterSel = source.webSelector('poster', 'img');
    final posterAttrs = source.webSelector('posterAttr', 'data-src,src');
    final img = card.querySelector(posterSel);
    if (img != null) {
      poster = WebScraper.absUrl(base, WebScraper.firstAttr(img, posterAttrs));
    }
    if (poster.startsWith('data:')) poster = '';

    final yearText = pickText('year', '');
    final year = WebScraper.yearFromText(
      yearText.isNotEmpty ? yearText : title,
    );
    final badge = pickText('typeBadge', '');
    String? type;
    final b = badge.toLowerCase();
    if (b.contains('bộ')) {
      type = 'series';
    } else if (b.contains('lẻ') || b.contains('full')) {
      type = 'single';
    }

    return MovieModel(
      id: '${split.section}/${split.slug}',
      slug: WebScraper.webSlug(split.section, split.slug),
      name: _cleanTitle(title),
      originName: '',
      thumbUrl: poster,
      posterUrl: poster,
      year: year,
      episodeCurrent: badge.isEmpty ? null : badge,
      type: type,
      sourceId: source.id,
    );
  }

  Pagination _paginationFromHtml(Document doc, int page, int count) {
    // Nguồn 1 trang (path không có {page}, VD sitemap hay trang custom):
    // không loadMore để tránh trùng lặp.
    if (!source.endpoints.latest.path.contains('{page}')) {
      return Pagination(
        totalItems: count,
        totalItemsPerPage: count,
        currentPage: page,
        totalPages: page,
      );
    }
    var maxPage = page;
    for (final a in doc.querySelectorAll('.pagination a, .page-numbers')) {
      final n = int.tryParse(a.text.trim());
      if (n != null && n > maxPage) maxPage = n;
    }
    // Dạng "Page 1 of 7" (DooPlay) cho tổng số trang thật.
    // Lưu ý: phải match trên từng span riêng vì text nối liền
    // ("Page 1 of 7"+"1"+"2"+"3" -> "Page 1 of 7123").
    final pageOf = RegExp(r'[Pp]age\s+\d+\s+of\s+(\d+)');
    for (final el in doc.querySelectorAll('.pagination span')) {
      final m = pageOf.firstMatch(el.text.trim());
      if (m != null) {
        final total = int.tryParse(m.group(1)!);
        if (total != null && total > maxPage) maxPage = total;
      }
    }
    if (maxPage == page && count > 0) maxPage = page + 1;
    return Pagination(
      totalItems: count,
      totalItemsPerPage: count,
      currentPage: page,
      totalPages: maxPage,
    );
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getLatest({
    int page = 1,
  }) async {
    final latestPath = source.endpoints.latest.path;
    // Nguồn sitemap (web SPA render JS): cắt lát catalog client-side.
    if (latestPath.startsWith('sitemap:')) {
      return _latestFromSitemap(page);
    }
    final path = _buildPath(latestPath, {
      'page': page.toString(),
    });
    final res = await _getHtml(path);
    final movies = _parseCards(source.baseUrl, res.html);
    if (movies.isEmpty) throw Exception('Không bóc được danh sách phim');
    return (
      movies: movies,
      pagination: _paginationFromHtml(
        WebScraper.parse(res.html),
        page,
        movies.length,
      ),
    );
  }

  /// Danh sách từ sitemap: slug = URL tuyệt đối (router encode khi push),
  /// tên prettify từ slug (không dấu), poster/năm bổ sung ở chi tiết SSR.
  static const int _sitemapPerPage = 24;

  Future<({List<Movie> movies, Pagination pagination})> _latestFromSitemap(
    int page,
  ) async {
    final locs = await SitemapStore.locsFor(dio, source.baseUrl);
    if (locs.isEmpty) throw Exception('Sitemap không có phim nào');
    final totalPages = (locs.length / _sitemapPerPage).ceil().clamp(1, 1 << 30);
    final slice = locs
        .skip((page - 1) * _sitemapPerPage)
        .take(_sitemapPerPage)
        .toList();
    return (
      movies: slice.map(_movieFromSitemap).toList(),
      pagination: Pagination(
        totalItems: locs.length,
        totalItemsPerPage: _sitemapPerPage,
        currentPage: page,
        totalPages: totalPages,
      ),
    );
  }

  Movie _movieFromSitemap(Uri loc) {
    final segs = loc.pathSegments.where((s) => s.isNotEmpty).toList();
    final last = segs.isEmpty ? loc.toString() : segs.last;
    return MovieModel(
      id: loc.toString(),
      slug: loc.toString(),
      name: SitemapStore.prettifySlug(last),
      originName: '',
      thumbUrl: '',
      posterUrl: '',
      year: 0,
      sourceId: source.id,
    );
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> search({
    required String keyword,
    int page = 1,
    int limit = 24,
    String? category,
    String? country,
    String? year,
    String? type,
    String? sourceId,
  }) async {
    // Tìm trong sitemap (không dấu khớp slug): "bay vao" ~ "bay-vao-tim-anh".
    if (source.endpoints.search.path.startsWith('sitemap:')) {
      final locs = await SitemapStore.locsFor(dio, source.baseUrl);
      final q = SitemapStore.stripDiacritics(keyword.trim().toLowerCase());
      final words = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final matched = locs.where((u) {
        final hay = SitemapStore.stripDiacritics(
          '${SitemapStore.prettifySlug(u.pathSegments.isEmpty ? '' : u.pathSegments.last)} ${u.pathSegments.join(' ')}'
              .toLowerCase(),
        );
        return words.every(hay.contains);
      }).take(limit).toList();
      return (
        movies: matched.map(_movieFromSitemap).toList(),
        pagination: Pagination(
          totalItems: matched.length,
          totalItemsPerPage: limit,
          currentPage: page,
          totalPages: page,
        ),
      );
    }
    final path = _buildPath(source.endpoints.search.path, {
      'keyword': keyword,
      'page': page.toString(),
    });
    final res = await _getHtml(path);
    final movies = _parseCards(source.baseUrl, res.html).take(limit).toList();
    return (
      movies: movies,
      pagination: Pagination(
        totalItems: movies.length,
        totalItemsPerPage: limit,
        currentPage: page,
        totalPages: movies.isEmpty ? page : page + 1,
      ),
    );
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getListByType(
    String type, {
    int page = 1,
  }) async {
    final typeMap = source.selectors['typeMap'];
    var mapped = type;
    if (typeMap is Map && typeMap[type]?.toString().isNotEmpty == true) {
      mapped = typeMap[type].toString();
    }
    var tpl = source.endpoints.listByType?.path ?? '/{type}/page/{page}/';
    final path = _buildPath(tpl, {'type': mapped, 'page': page.toString()});
    final res = await _getHtml(path);
    final movies = _parseCards(source.baseUrl, res.html);
    if (movies.isEmpty) throw Exception('Không bóc được danh sách $type');
    return (
      movies: movies,
      pagination: _paginationFromHtml(
        WebScraper.parse(res.html),
        page,
        movies.length,
      ),
    );
  }

  // ---------------- Chi tiết ----------------

  String _detailUrl(String slug) {
    if (slug.startsWith('http://') || slug.startsWith('https://')) {
      return slug;
    }
    final parsed = WebScraper.parseWebSlug(slug);
    if (parsed != null) {
      // section 'p' = slug 1 segment (permalink trơn /ten-phim/).
      if (parsed.section == 'p') {
        return WebScraper.absUrl(source.baseUrl, '/${parsed.slug}/');
      }
      // WordPress bắt buộc trailing slash — thiếu là server trả trang lạ.
      return WebScraper.absUrl(
        source.baseUrl,
        '/${parsed.section}/${parsed.slug}/',
      );
    }
    // Slug trơn (thường là slug API đi lạc): vẫn thêm trailing slash
    // để WordPress không redirect về trang chủ (soft-404).
    final plain = slug.startsWith('/') ? slug : '/$slug';
    return WebScraper.absUrl(
      source.baseUrl,
      plain.endsWith('/') ? plain : '$plain/',
    );
  }

  @override
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(
    String slug,
  ) async {
    final url = _detailUrl(slug);
    final res = await _getHtml(url);
    final html = res.html;
    final doc = WebScraper.parse(html);
    final schema = WebScraper.jsonLd(html, const ['movie', 'tvseries', 'tvepisode', 'webpage']);

    final title = _detailTitle(doc, html);
    if (title.isEmpty) throw Exception('Không bóc được chi tiết phim');

    var content = '';
    // Selector config trước, rồi pattern phổ biến của các theme phim.
    final contentSels = <String>[
      source.webSelector('detailContent', ''),
      '.description, .entry-content, .post-content, .film-content, '
          '.video-description, [itemprop="description"]',
    ];
    for (final sel in contentSels) {
      if (sel.isEmpty) continue;
      try {
        final c = doc.querySelector(sel)?.innerHtml.trim() ?? '';
        if (c.length > 20) {
          content = c;
          break;
        }
        if (content.isEmpty) content = c;
      } catch (_) {}
    }
    content = content.isEmpty
        ? (schema?['description']?.toString() ??
            WebScraper.metaContent(doc, 'description'))
        : content;

    // Tên gốc (alias): config + pattern phổ biến + schema.
    var originName = '';
    final originSels = <String>[
      source.webSelector('detailOrigin', ''),
      '.alias-name, .original-title, .org-title, [itemprop="alternateName"]',
    ];
    for (final sel in originSels) {
      if (sel.isEmpty) continue;
      try {
        final t = WebScraper.firstText(doc, sel);
        if (t.isNotEmpty && t != title) {
          originName = t;
          break;
        }
      } catch (_) {}
    }
    if (originName.isEmpty) {
      final alt = schema?['alternateName']?.toString().trim() ?? '';
      if (alt.isNotEmpty && alt != title) originName = alt;
    }

    var poster = WebScraper.absUrl(
      source.baseUrl,
      WebScraper.metaContent(doc, 'og:image'),
    );
    if (poster.isEmpty) {
      poster = WebScraper.absUrl(
        source.baseUrl,
        WebScraper.metaContent(doc, 'twitter:image'),
      );
    }
    if (poster.isEmpty) {
      // Microdata schema.org: <meta itemprop="image" content="...">.
      try {
        final meta = doc.querySelector('[itemprop="image"]');
        if (meta != null) {
          final raw = meta.localName == 'meta'
              ? (meta.attributes['content'] ?? '')
              : WebScraper.firstAttr(
                  meta,
                  source.webSelector('posterAttr', 'data-src,src'),
                );
          poster = WebScraper.absUrl(source.baseUrl, raw);
        }
      } catch (_) {}
    }
    final posterSel = source.webSelector('detailPoster', '');
    if (posterSel.isNotEmpty) {
      try {
        final img = doc.querySelector(posterSel);
        final p = WebScraper.absUrl(
          source.baseUrl,
          img == null
              ? ''
              : WebScraper.firstAttr(
                  img,
                  source.webSelector('posterAttr', 'data-src,src'),
                ),
        );
        if (p.isNotEmpty && !p.startsWith('data:')) poster = p;
      } catch (_) {}
    }

    final year = WebScraper.yearFromText(
      '$title ${schema?['datePublished'] ?? ''}',
    );
    // Chuẩn schema.org (JSON-LD Movie): genre/actor/director/countryOfOrigin
    // có ở mọi web làm SEO — không cần selector riêng từng site.
    final schemaCats = _schemaStrings(schema?['genre']);
    final categories = <Category>[
      for (final g in schemaCats)
        Category(
          id: g.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
          name: g,
          slug: g.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
        ),
    ];
    final schemaCountries = _schemaStrings(
      schema?['countryOfOrigin'] ?? schema?['contentLocation'],
    );
    final countries = <Country>[
      for (final c in schemaCountries)
        Country(
          id: c.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
          name: c,
          slug: c.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
        ),
    ];
    final actors = _schemaStrings(schema?['actor']);
    final directors = _schemaStrings(schema?['director']);
    final parsed = WebScraper.parseWebSlug(slug);
    final section = parsed?.section.toLowerCase() ?? '';
    String? type;
    if (section.contains('tv') ||
        section.contains('series') ||
        section.contains('bo')) {
      type = 'series';
    } else if (section.contains('movie') ||
        section.contains('phim-le') ||
        section.contains('le')) {
      type = 'single';
    }

    // Tập phim: link tới trang tập.
    final epSel = source.webSelector('episodeItem', '#seasons a');
    final episodes = <Episode>[];
    final seenEp = <String>{};
    for (final a in doc.querySelectorAll(epSel)) {
      final href = a.attributes['href'] ?? '';
      if (href.isEmpty || href.startsWith('#')) continue;
      final page = WebScraper.absUrl(source.baseUrl, href);
      if (!seenEp.add(page)) continue;
      final name = a.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      episodes.add(
        Episode(
          name: name.isEmpty ? 'Tập ${episodes.length + 1}' : name,
          slug: page,
        ),
      );
      if (episodes.length >= 300) break;
    }
    // Heuristic generic khi theme lạ không khớp selector: link cùng host
    // có text/href dạng tập ("Tập 12", "Full", "/tap-3", "/ep-3"...).
    if (episodes.isEmpty) {
      episodes.addAll(_heuristicEpisodes(doc, url));
    }

    // Server tabs: bóc options từ trang tập đầu (DooPlay liệt kê server/tập).
    var servers = <EpisodeServer>[];
    if (episodes.isNotEmpty) {
      servers = await _serversFromEpisodePage(episodes.first.slug, episodes);
    } else {
      // Phim lẻ 1 tập: player nằm ngay trang chi tiết.
      final opts = _parsePlayerOptions(html);
      final eps = [
        Episode(name: 'Full', slug: url),
      ];
      servers = [
        EpisodeServer(
          serverName: opts.isEmpty ? 'Mặc định' : _serverLabel(opts.first),
          episodes: eps,
        ),
      ];
      if (opts.length > 1) {
        servers = [
          for (final o in opts)
            EpisodeServer(serverName: _serverLabel(o), episodes: eps),
        ];
      }
    }

    final movie = MovieModel(
      id: slug,
      slug: slug,
      name: title,
      originName: originName,
      thumbUrl: poster,
      posterUrl: poster,
      year: year,
      content: content.isEmpty ? null : content,
      type: type,
      categories: categories,
      countries: countries,
      actors: actors,
      directors: directors,
      episodeCurrent:
          episodes.isEmpty ? 'Full' : 'Tập ${episodes.length}',
      sourceId: source.id,
    );
    return (movie: movie, servers: servers);
  }

  /// Chuẩn hóa field schema.org: string ("A, B"), list string, hoặc list
  /// map có name (actor: [{@type, name}]) — mọi site làm SEO đều theo chuẩn.
  static List<String> _schemaStrings(dynamic value) {
    final out = <String>[];
    void add(String s) {
      final t = s.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (t.isNotEmpty && !out.contains(t)) out.add(t);
    }

    if (value == null) return out;
    if (value is String) {
      for (final part in value.split(',')) {
        add(part);
      }
      return out;
    }
    if (value is Map) {
      if (value['name'] != null) add(value['name'].toString());
      return out;
    }
    if (value is List) {
      for (final item in value) {
        if (item is String) {
          add(item);
        } else if (item is Map && item['name'] != null) {
          add(item['name'].toString());
        }
      }
    }
    return out;
  }

  /// Heuristic generic tìm link tập khi theme không khớp selector config:
  /// quét mọi link cùng host, giữ lại link có text ("Tập 12", "Full",
  /// "Trailer") hoặc href (.../tap-3, .../ep-3, .../episode-3) dạng tập.
  /// Bỏ qua link trùng trang chi tiết và link ngoài.
  List<Episode> _heuristicEpisodes(Document doc, String detailUrl) {
    final textRe = RegExp(
      r'^(tập|tap|ep|episode|eps|full|trailer|preview|thuyết minh|vietsub)'
      r'[\s\-_#:]*\d*\s*$',
      caseSensitive: false,
    );
    final hrefRe = RegExp(
      r'/(tap|ep|eps|episode|taps)[\-_/]?\d*([\-_/]|$)',
      caseSensitive: false,
    );
    final host = Uri.tryParse(source.baseUrl)?.host.toLowerCase() ?? '';
    final detail = detailUrl.toLowerCase();
    final out = <Episode>[];
    final seen = <String>{};
    try {
      for (final a in doc.querySelectorAll('a[href]')) {
        final href = a.attributes['href'] ?? '';
        if (href.isEmpty ||
            href.startsWith('#') ||
            href.startsWith('javascript:')) {
          continue;
        }
        final page = WebScraper.absUrl(source.baseUrl, href);
        final uri = Uri.tryParse(page);
        if (uri == null ||
            !(uri.scheme == 'http' || uri.scheme == 'https')) {
          continue;
        }
        if (host.isNotEmpty && uri.host.toLowerCase() != host) continue;
        if (page.toLowerCase() == detail) continue;
        final text = a.text.trim().replaceAll(RegExp(r'\s+'), ' ');
        final path = uri.path.toLowerCase();
        if (!textRe.hasMatch(text) && !hrefRe.hasMatch(path)) continue;
        if (!seen.add(page)) continue;
        out.add(
          Episode(
            name: text.isEmpty ? 'Tập ${out.length + 1}' : text,
            slug: page,
          ),
        );
        if (out.length >= 300) break;
      }
    } catch (_) {}
    return out;
  }

  Future<List<EpisodeServer>> _serversFromEpisodePage(    String episodePageUrl,
    List<Episode> episodes,
  ) async {
    try {
      final res = await _getHtml(episodePageUrl);
      final opts = _parsePlayerOptions(res.html);
      if (opts.isEmpty) {
        return [EpisodeServer(serverName: 'Mặc định', episodes: episodes)];
      }
      return [
        for (final o in opts)
          EpisodeServer(serverName: _serverLabel(o), episodes: episodes),
      ];
    } catch (_) {
      return [EpisodeServer(serverName: 'Mặc định', episodes: episodes)];
    }
  }

  String _serverLabel(_PlayerOption o) {
    final t = o.title.trim();
    if (t.isNotEmpty) return t;
    if (o.host.isNotEmpty) return o.host;
    return 'Server ${o.nume}';
  }

  List<_PlayerOption> _parsePlayerOptions(String html) {
    final out = <_PlayerOption>[];
    try {
      final doc = WebScraper.parse(html);
      final sel = source.webSelector(
        'playerOption',
        '.dooplay_player_option',
      );
      for (final el in doc.querySelectorAll(sel)) {
        final post = el.attributes['data-post'] ?? '';
        final ptype = el.attributes['data-type'] ?? '';
        final nume = el.attributes['data-nume'] ?? '';
        final title =
            el.querySelector('.title')?.text.trim() ?? el.text.trim();
        final host =
            el.querySelector('.server')?.text.trim().toLowerCase() ?? '';
        out.add(
          _PlayerOption(
            post: post,
            ptype: ptype,
            nume: nume.isEmpty ? '${out.length + 1}' : nume,
            title: title,
            host: host,
          ),
        );
      }
    } catch (_) {}
    return out;
  }

  // ---------------- Link phát ----------------

  /// Resolve link phát cho 1 trang tập.
  /// Trả về m3u8 trực tiếp nếu bóc được, ngược lại embed để WebView/player mở.
  Future<({String? m3u8, String? embed, String serverUsed})> resolveStream(
    String episodePageUrl, {
    String? serverName,
  }) async {
    final res = await _getHtml(episodePageUrl);
    final html = res.html;
    final base = source.baseUrl;

    final opts = _parsePlayerOptions(html);
    _PlayerOption? picked;
    if (opts.isNotEmpty) {
      picked = _pickOption(opts, serverName);
      // 1) DooPlayer JSON API (ổn định nhất, không cần chạy JS).
      final apiTpl = source.webSelector('playerApi', '');
      if (apiTpl.isNotEmpty && picked.post.isNotEmpty) {
        try {
          final api = apiTpl
              .replaceAll('{post}', picked.post)
              .replaceAll('{ptype}', picked.ptype)
              .replaceAll('{source}', picked.nume);
          final apiUrl =
              api.startsWith('http') ? api : WebScraper.absUrl(base, api);
          final apiRes = await dio.get(
            apiUrl,
            options: Options(
              responseType: ResponseType.plain,
              sendTimeout: _htmlTimeout,
              receiveTimeout: _htmlTimeout,
              headers: {
                'accept': 'application/json',
                'user-agent': WebScraper.ua,
                'referer': episodePageUrl,
              },
              validateStatus: (s) => s != null && s < 500,
            ),
          );
          if (apiRes.statusCode == 200 && apiRes.data is String) {
            final embed = _embedFromPlayerApi(apiRes.data as String);
            if (embed != null && embed.isNotEmpty) {
              final direct = WebScraper.directUrlFromEmbed(embed);
              if (direct != null) {
                return (
                  m3u8: direct,
                  embed: null,
                  serverUsed: _serverLabel(picked),
                );
              }
              return (
                m3u8: null,
                embed: embed,
                serverUsed: _serverLabel(picked),
              );
            }
          }
        } catch (_) {}
      }
    }

    // 2) Quét link media trực tiếp trong HTML.
    final streams = WebScraper.scanStreamUrls(html, base);
    if (streams.isNotEmpty) {
      return (
        m3u8: streams.first,
        embed: null,
        serverUsed: picked == null ? 'Mặc định' : _serverLabel(picked),
      );
    }

    // 3) Fallback: iframe embed đầu tiên.
    final iframes = WebScraper.iframeSrcs(html, base);
    if (iframes.isNotEmpty) {
      return (
        m3u8: null,
        embed: iframes.first,
        serverUsed: picked == null ? 'Mặc định' : _serverLabel(picked),
      );
    }

    throw Exception('Không bóc được link phát');
  }

  _PlayerOption _pickOption(List<_PlayerOption> opts, String? serverName) {
    if (serverName != null && serverName.isNotEmpty) {
      final want = serverName.toLowerCase();
      for (final o in opts) {
        if (_serverLabel(o).toLowerCase() == want) return o;
      }
      for (final o in opts) {
        if (_serverLabel(o).toLowerCase().contains(want) ||
            want.contains(_serverLabel(o).toLowerCase())) {
          return o;
        }
      }
    }
    return opts.first;
  }

  String? _embedFromPlayerApi(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        for (final k in ['embed_url', 'embedUrl', 'embed', 'url', 'src']) {
          final v = decoded[k]?.toString() ?? '';
          if (v.startsWith('http')) return v;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Tiêu đề trang chi tiết: thử nhiều selector theo độ ưu tiên, bỏ qua
  /// text rác (h1 logo / tiêu đề trang chủ như
  /// "Motphim | Phim Mới | Phim Hay | Xem Phim Online").
  String _detailTitle(Document doc, String html) {
    final siteName = WebScraper.metaContent(doc, 'og:site_name').trim();
    bool isJunk(String t) {
      if (t.isEmpty) return true;
      final l = t.toLowerCase();
      // Slogan trang chủ — không bao giờ là tên phim.
      if (l.contains('xem phim online')) return true;
      if (siteName.isNotEmpty) {
        final s = siteName.toLowerCase();
        if (l == s) return true;
        // Bắt đầu bằng tên web + dài hơn hẳn ("Motphim | Phim Mới | ...",
        // "RoPhim - Phim hay cả rổ - ...") thì là tiêu đề trang chủ.
        if (l.startsWith(s) && t.length > s.length + 8) return true;
      }
      return false;
    }

    String norm(String t) => _cleanTitle(t, siteName: siteName);

    // 1. Selector theo độ ưu tiên: config trước, pattern phổ biến của các
    // theme phim (.media-name, .movie-title...), microdata schema.org, rồi
    // h1 chung. Duyệt TẤT CẢ match (kể cả khi h1 logo đứng trước).
    final ordered = <String>[];
    void addSel(String s) {
      for (final part in s.split(',')) {
        final p = part.trim();
        if (p.isNotEmpty && !ordered.contains(p)) ordered.add(p);
      }
    }

    addSel(source.webSelector('detailTitle', ''));
    addSel('.sheader .data h1, .sheader h1, .data h1, h1.entry-title');
    addSel(
      '.media-name, .movie-title, .film-title, .video-title, '
      '.entry-title, .post-title, [itemprop="name"]',
    );
    addSel('h1');

    var fallback = '';
    for (final sel in ordered) {
      List<Element> els;
      try {
        els = doc.querySelectorAll(sel);
      } catch (_) {
        continue;
      }
      for (final el in els) {
        final raw = el.text.trim().replaceAll(RegExp(r'\s+'), ' ');
        if (raw.isEmpty) continue;
        final cleaned = norm(raw);
        if (cleaned.isEmpty) continue;
        if (!isJunk(cleaned)) return cleaned;
        fallback = fallback.isEmpty ? cleaned : fallback;
      }
    }

    // 2. JSON-LD của phim (bỏ qua WebPage/WebSite vì đó là tên web).
    final movieSchema =
        WebScraper.jsonLd(html, const ['movie', 'tvseries', 'tvepisode']);
    final schemaName = (movieSchema?['name']?.toString() ?? '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    if (schemaName.isNotEmpty && !isJunk(norm(schemaName))) {
      return norm(schemaName);
    }

    // 3. og:title.
    final og = norm(WebScraper.metaContent(doc, 'og:title'));
    if (og.isNotEmpty && !isJunk(og)) return og;

    // 4. Giữ hành vi cũ để không crash regression.
    if (fallback.isNotEmpty) return fallback;
    if (schemaName.isNotEmpty) return norm(schemaName);
    return og;
  }

  static String _cleanTitle(String title, {String siteName = ''}) {
    var t = title.trim();
    // Bỏ hậu tố tên site: "Tên Phim (2026) Full Vietsub - Motchill".
    final dash = RegExp(r'\s+[-|–]\s+[^-|–]+$').firstMatch(t);
    if (dash != null && dash.start > 8) {
      t = t.substring(0, dash.start).trim();
    }
    // "Tên Phim | Motphim": hậu tố sau | trùng tên web -> bỏ.
    if (siteName.isNotEmpty) {
      final m = RegExp(r'\s+[|\-–]\s+(.+)$').firstMatch(t);
      if (m != null &&
          m.group(1)!.trim().toLowerCase() == siteName.toLowerCase()) {
        t = t.substring(0, m.start).trim();
      }
    }
    return t;
  }
}

class _PlayerOption {
  final String post;
  final String ptype;
  final String nume;
  final String title;
  final String host;
  const _PlayerOption({
    required this.post,
    required this.ptype,
    required this.nume,
    required this.title,
    required this.host,
  });
}
