class Movie {
  final String id;
  final String slug;
  final String name;
  final String originName;
  final String thumbUrl;
  final String posterUrl;
  final int year;
  final String? quality;
  final String? lang;
  final String? time;
  final String? episodeCurrent;
  final String? type; // single, series, hoathinh
  final List<Category> categories;
  final List<Country> countries;
  final String? content; // html detail
  final List<String> actors;
  final List<String> directors;
  final String? trailerUrl;
  final DateTime? modifiedTime;
  final double? voteAverage;
  final String sourceId; // kkphim

  const Movie({
    required this.id,
    required this.slug,
    required this.name,
    required this.originName,
    required this.thumbUrl,
    required this.posterUrl,
    required this.year,
    this.quality,
    this.lang,
    this.time,
    this.episodeCurrent,
    this.type,
    this.categories = const [],
    this.countries = const [],
    this.content,
    this.actors = const [],
    this.directors = const [],
    this.trailerUrl,
    this.modifiedTime,
    this.voteAverage,
    this.sourceId = 'kkphim',
  });

  /// Chuẩn hóa URL ảnh: nếu là filename thì prepend cdn
  static String normalizeImage(String? url, {String cdn = 'https://phimimg.com'}) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return '$cdn$url';
    if (url.startsWith('uploads/')) return '$cdn/$url';
    return '$cdn/uploads/movies/$url';
  }
}

class Category {
  final String id;
  final String name;
  final String slug;
  const Category({required this.id, required this.name, required this.slug});
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
      );
}

class Country {
  final String id;
  final String name;
  final String slug;
  const Country({required this.id, required this.name, required this.slug});
  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
      );
}
