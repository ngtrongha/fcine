import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';

import '../../core/config/master_config.dart';
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
        final res = await dio.get(
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
        if (res.statusCode == 200 && res.data is String) {
          final html = res.data as String;
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
    final path = _buildPath(source.endpoints.latest.path, {
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
      // WordPress bắt buộc trailing slash — thiếu là server trả trang lạ.
      return WebScraper.absUrl(
        source.baseUrl,
        '/${parsed.section}/${parsed.slug}/',
      );
    }
    return WebScraper.absUrl(source.baseUrl, '/$slug');
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

    var title = WebScraper.firstText(
      doc,
      source.webSelector('detailTitle', 'h1'),
    );
    title = title.isEmpty
        ? _cleanTitle(WebScraper.metaContent(doc, 'og:title'))
        : _cleanTitle(title);
    if (title.isEmpty) {
      title = (schema?['name']?.toString() ?? '').trim();
    }
    if (title.isEmpty) throw Exception('Không bóc được chi tiết phim');

    var content = '';
    final contentSel = source.webSelector('detailContent', '');
    if (contentSel.isNotEmpty) {
      try {
        content = doc.querySelector(contentSel)?.innerHtml.trim() ?? '';
      } catch (_) {}
    }
    content = content.isEmpty
        ? (schema?['description']?.toString() ??
            WebScraper.metaContent(doc, 'description'))
        : content;

    var poster = WebScraper.absUrl(
      source.baseUrl,
      WebScraper.metaContent(doc, 'og:image'),
    );
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
      originName: '',
      thumbUrl: poster,
      posterUrl: poster,
      year: year,
      content: content.isEmpty ? null : content,
      type: type,
      episodeCurrent:
          episodes.isEmpty ? 'Full' : 'Tập ${episodes.length}',
      sourceId: source.id,
    );
    return (movie: movie, servers: servers);
  }

  Future<List<EpisodeServer>> _serversFromEpisodePage(
    String episodePageUrl,
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

  static String _cleanTitle(String title) {
    var t = title.trim();
    // Bỏ hậu tố tên site: "Tên Phim (2026) Full Vietsub - Motchill".
    final dash = RegExp(r'\s+[-|–]\s+[^-|–]+$').firstMatch(t);
    if (dash != null && dash.start > 8) {
      t = t.substring(0, dash.start).trim();
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
