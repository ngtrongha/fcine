import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// Helpers băm HTML chung cho mọi web phim (pure, không network).
class WebScraper {
  /// Giả desktop Chrome để tránh bị chặn bot thô.
  static const ua =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/126.0.0.0 Safari/537.36';

  static Document parse(String html) => html_parser.parse(html);

  /// Text đầu tiên khớp 1 trong các selector (phân tách bởi dấu phẩy).
  static String firstText(Document doc, String selectorsCsv) {
    for (final el in _queryAll(doc, selectorsCsv)) {
      final t = el.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (t.isNotEmpty) return t;
    }
    return '';
  }

  /// Attribute đầu tiên khác rỗng khi thử lần lượt các attr.
  static String firstAttr(Element el, String attrsCsv) {
    for (final name in attrsCsv.split(',')) {
      final v = el.attributes[name.trim()];
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  static List<Element> queryAll(Document doc, String selectorsCsv) =>
      _queryAll(doc, selectorsCsv);

  static List<Element> _queryAll(Document doc, String selectorsCsv) {
    final out = <Element>[];
    for (final sel in selectorsCsv.split(',')) {
      final s = sel.trim();
      if (s.isEmpty) continue;
      try {
        out.addAll(doc.querySelectorAll(s));
      } catch (_) {}
    }
    return out;
  }

  /// Resolve URL tương đối theo base (giữ nguyên http/data:).
  static String absUrl(String base, String? href) {
    if (href == null || href.trim().isEmpty) return '';
    final h = href.trim();
    if (h.startsWith('http://') ||
        h.startsWith('https://') ||
        h.startsWith('data:') ||
        h.startsWith('blob:')) {
      return h;
    }
    try {
      return Uri.parse(base).resolve(h).toString();
    } catch (_) {
      return h;
    }
  }

  /// content của <meta property|name=...>.
  static String metaContent(Document doc, String key) {
    for (final m in doc.getElementsByTagName('meta')) {
      final prop = m.attributes['property'] ?? m.attributes['name'] ?? '';
      if (prop.toLowerCase() == key.toLowerCase()) {
        return m.attributes['content']?.trim() ?? '';
      }
    }
    return '';
  }

  /// JSON-LD đầu tiên có @type khớp (so khớp chứa, không phân biệt hoa thường).
  static Map<String, dynamic>? jsonLd(
    String html,
    List<String> types,
  ) {
    final re = RegExp(
      r'<script[^>]*application/ld\+json[^>]*>(.*?)</script>',
      dotAll: true,
      caseSensitive: false,
    );
    for (final m in re.allMatches(html)) {
      final raw = m.group(1) ?? '';
      final decoded = _tryJson(raw);
      if (decoded == null) continue;
      final graphs = <dynamic>[decoded];
      if (decoded is Map && decoded['@graph'] is List) {
        graphs.addAll(decoded['@graph'] as List);
      }
      for (final g in graphs) {
        if (g is! Map) continue;
        final t = (g['@type']?.toString() ?? '').toLowerCase();
        if (types.any((w) => t.contains(w.toLowerCase()))) {
          return Map<String, dynamic>.from(g);
        }
      }
    }
    return null;
  }

  static dynamic _tryJson(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Năm đầu tiên dạng (YYYY) hoặc YYYY trong text.
  static int yearFromText(String text) {
    final m = RegExp(r'(19|20)\d{2}').firstMatch(text);
    return m == null ? 0 : int.tryParse(m.group(0)!) ?? 0;
  }

  /// Tách detail href thành (section, slug) để dựng slug router-safe "sec~slug".
  /// Trả về null khi không parse được. URL 1 segment (permalink trơn
  /// /ten-phim/) map section='p' để _detailUrl dựng lại đúng.
  static ({String section, String slug})? splitDetailPath(
    String base,
    String href,
  ) {
    final abs = absUrl(base, href);
    Uri? uri = Uri.tryParse(abs);
    if (uri == null || !uri.hasAuthority) return null;
    final segs =
        uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segs.isEmpty) return null;
    if (segs.length < 2) return (section: 'p', slug: segs.last);
    return (
      section: segs[segs.length - 2],
      slug: segs[segs.length - 1],
    );
  }

  static String webSlug(String section, String slug) => '$section~$slug';

  static ({String section, String slug})? parseWebSlug(String slug) {
    final i = slug.indexOf('~');
    if (i <= 0 || i == slug.length - 1) return null;
    return (section: slug.substring(0, i), slug: slug.substring(i + 1));
  }

  /// Bóc link stream trực tiếp từ embed_url kiểu player (`?url=<m3u8>`).
  /// Trả về null khi không phải link media trực tiếp.
  static String? directUrlFromEmbed(String embedUrl) {
    final uri = Uri.tryParse(embedUrl);
    if (uri == null) return null;
    for (final v in uri.queryParametersAll.values.expand((e) => e)) {
      if (_looksLikeStream(v)) return v;
    }
    if (_looksLikeStream(embedUrl)) return embedUrl;
    return null;
  }

  static bool _looksLikeStream(String url) {
    final u = url.toLowerCase().split('?').first;
    return u.endsWith('.m3u8') ||
        u.endsWith('.mp4') ||
        u.endsWith('.mkv') ||
        u.endsWith('.webm');
  }

  /// Quét link play trực tiếp trong HTML: <video><source>, m3u8/mp4 regex.
  static List<String> scanStreamUrls(String html, String base) {
    final found = <String>[];
    void add(String? u) {
      if (u == null || u.isEmpty) return;
      final abs = absUrl(base, u);
      if (_looksLikeStream(abs) && !found.contains(abs)) found.add(abs);
    }

    try {
      final doc = parse(html);
      for (final v in doc.getElementsByTagName('video')) {
        add(v.attributes['src']);
        for (final s in v.getElementsByTagName('source')) {
          add(s.attributes['src']);
        }
      }
    } catch (_) {}

    final re = RegExp(
      r'https?://[^\s\x22\x27\\<>]+?\.(m3u8|mp4|mkv|webm)(\?[^\s\x22\x27\\<>]*)?',
      caseSensitive: false,
    );
    for (final m in re.allMatches(html)) {
      add(m.group(0));
    }
    return found;
  }

  /// Heuristic tìm card phim cho web lạ: nhóm ≥ [minGroup] element anh em
  /// cùng tag+class, mỗi block chứa `<a href>` + `<img>` với link khác nhau.
  /// Dùng khi selector config + fallback generic đều rỗng. Bỏ qua vùng
  /// chrome (header/nav/footer/menu/sidebar). Trả về nhóm lớn nhất tìm được.
  static List<Element> siblingCards(Document doc, {int minGroup = 3}) {
    List<Element> best = const [];
    for (final parent in doc.querySelectorAll('*')) {
      if (parent.children.length < minGroup) continue;
      if (_inChrome(parent)) continue;
      final groups = <String, List<Element>>{};
      for (final c in parent.children) {
        final key = '${c.localName}|${c.classes.join(' ')}';
        (groups[key] ??= <Element>[]).add(c);
      }
      for (final g in groups.values) {
        if (g.length < minGroup || g.length <= best.length) continue;
        var sameHref = true;
        String? firstHref;
        var ok = true;
        for (final b in g) {
          final a = b.querySelector('a[href]');
          final img = b.querySelector('img');
          final href = a?.attributes['href']?.trim() ?? '';
          if (a == null || img == null || href.isEmpty || href.startsWith('#')) {
            ok = false;
            break;
          }
          if (firstHref == null) {
            firstHref = href;
          } else if (firstHref != href) {
            sameHref = false;
          }
        }
        if (ok && !sameHref) best = g;
      }
      if (best.length >= 24) break;
    }
    return best;
  }

  /// True khi [el] nằm trong vùng chrome (nav/header/footer/menu/sidebar).
  static bool _inChrome(Element el) {
    Node? n = el;
    for (var i = 0; i < 4 && n != null; i++) {
      if (n is Element) {
        final tag = n.localName;
        if (tag == 'header' || tag == 'nav' || tag == 'footer') return true;
        final cls = n.classes.join(' ').toLowerCase();
        if (cls.contains('menu') ||
            cls.contains('nav') ||
            cls.contains('sidebar')) {
          return true;
        }
      }
      n = n.parent;
    }
    return false;
  }

  /// Quét link stream trong block setup của player JS phổ biến (JWPlayer,
  /// PlayerJS, VideoJS...) trong inline script. Khác scanStreamUrls ở chỗ:
  /// gỡ escape JS (`\/` -> `/`, `\/u002F` -> `/`) nên bắt được URL mã hoá
  /// kiểu `"file":"https:\/\/cdn.test\/a.m3u8"`. Chỉ quét cửa sổ nhỏ ngay
  /// sau anchor player để tránh dính quảng cáo/tracking URL lung tung.
  static List<String> playerSetupStreams(String html, String base) {
    final text = html
        .replaceAll('\\/', '/')
        .replaceAll('\\u002F', '/')
        .replaceAll('\\u002f', '/');
    final anchors = RegExp(
      r'jwplayer|playerjs|new\s+Playerjs|videojs|file\s*[:=]\s*["\x27]https?',
      caseSensitive: false,
    );
    final urlRe = RegExp(
      r'https?://[^\s\x22\x27\\<>]+?\.(m3u8|mp4|mkv|webm)(\?[^\s\x22\x27\\<>]*)?',
      caseSensitive: false,
    );
    final out = <String>[];
    for (final m in anchors.allMatches(text)) {
      final start = m.start;
      final end = start + 1600 <= text.length ? start + 1600 : text.length;
      final window = text.substring(start, end);
      for (final u in urlRe.allMatches(window)) {
        final abs = absUrl(base, u.group(0)!);
        if (abs.isNotEmpty && !out.contains(abs)) out.add(abs);
      }
    }
    return out;
  }

  /// src các <iframe> trong trang (fallback mở embed).
  static List<String> iframeSrcs(String html, String base) {
    final out = <String>[];
    try {
      final doc = parse(html);
      for (final f in doc.getElementsByTagName('iframe')) {
        final src = absUrl(base, f.attributes['src']);
        if (src.startsWith('http') && !out.contains(src)) out.add(src);
      }
    } catch (_) {}
    return out;
  }
}
