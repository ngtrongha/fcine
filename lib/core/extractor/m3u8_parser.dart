import 'package:dio/dio.dart';

class QualityVariant {
  final String url; // absolute
  final String? resolution; // e.g. 1280x720
  final int? bandwidth;
  final String label; // e.g. 720p
  final String? name;
  const QualityVariant({required this.url, this.resolution, this.bandwidth, required this.label, this.name});
}

class M3u8Parser {
  final Dio dio;
  M3u8Parser(this.dio);

  Future<List<QualityVariant>> parseMaster(String masterUrl) async {
    try {
      final res = await dio.get(masterUrl, options: Options(responseType: ResponseType.plain));
      final content = res.data as String;
      if (!content.contains('#EXT-X-STREAM-INF')) return [];
      final baseUri = Uri.parse(masterUrl);
      final lines = content.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final List<QualityVariant> variants = [];
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.startsWith('#EXT-X-STREAM-INF')) {
          final attrs = _parseAttrs(line);
          final urlLine = (i + 1 < lines.length) ? lines[i + 1].trim() : '';
          if (urlLine.isEmpty || urlLine.startsWith('#')) continue;
          final absolute = _resolve(baseUri, urlLine);
          final resStr = attrs['RESOLUTION'];
          final bw = int.tryParse(attrs['BANDWIDTH'] ?? '');
          String label = 'Auto';
          if (resStr != null) {
            final h = resStr.split('x').last;
            label = '${h}p';
          } else if (bw != null) {
            label = '${(bw / 1000).round()}k';
          }
          variants.add(QualityVariant(url: absolute, resolution: resStr, bandwidth: bw, label: label, name: attrs['NAME']));
        }
      }
      // sort by resolution height desc
      variants.sort((a, b) => _height(b.resolution).compareTo(_height(a.resolution)));
      return variants;
    } catch (_) {
      return [];
    }
  }

  Map<String, String> _parseAttrs(String line) {
    final map = <String, String>{};
    final reg = RegExp(r'([A-Z\-]+)=("[^"]+"|[^,]+)');
    for (final m in reg.allMatches(line)) {
      final k = m.group(1)!;
      var v = m.group(2)!;
      if (v.startsWith('"') && v.endsWith('"')) v = v.substring(1, v.length - 1);
      map[k] = v;
    }
    return map;
  }

  String _resolve(Uri base, String url) {
    if (url.startsWith('http')) return url;
    return base.resolve(url).toString();
  }

  int _height(String? res) {
    if (res == null) return 0;
    final parts = res.split('x');
    if (parts.length == 2) return int.tryParse(parts[1]) ?? 0;
    return 0;
  }
}
