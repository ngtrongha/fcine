import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.originName,
    required super.thumbUrl,
    required super.posterUrl,
    required super.year,
    super.quality,
    super.lang,
    super.time,
    super.episodeCurrent,
    super.type,
    super.categories,
    super.countries,
    super.content,
    super.actors,
    super.directors,
    super.trailerUrl,
    super.modifiedTime,
    super.sourceId,
  });

  factory MovieModel.fromListJson(Map<String, dynamic> json, {String cdn = 'https://phimimg.com'}) {
    String normalize(String? u) => Movie.normalizeImage(u, cdn: cdn);
    return MovieModel(
      id: json['_id']?.toString() ?? json['slug']?.toString() ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      originName: json['origin_name'] ?? '',
      thumbUrl: normalize(json['thumb_url']),
      posterUrl: normalize(json['poster_url']),
      year: (json['year'] as num?)?.toInt() ?? 0,
      quality: json['quality'],
      lang: json['lang'],
      time: json['time'],
      episodeCurrent: json['episode_current'],
      type: json['type'],
      categories: (json['category'] as List?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      countries: (json['country'] as List?)
              ?.map((e) => Country.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      modifiedTime: json['modified'] != null ? DateTime.tryParse(json['modified']['time'] ?? '') : null,
    );
  }

  factory MovieModel.fromDetailJson(Map<String, dynamic> movieJson, {String cdn = 'https://phimimg.com'}) {
    String normalize(String? u) => Movie.normalizeImage(u, cdn: cdn);
    return MovieModel(
      id: movieJson['_id']?.toString() ?? movieJson['slug'] ?? '',
      slug: movieJson['slug'] ?? '',
      name: movieJson['name'] ?? '',
      originName: movieJson['origin_name'] ?? '',
      thumbUrl: normalize(movieJson['thumb_url']),
      posterUrl: normalize(movieJson['poster_url']),
      year: (movieJson['year'] as num?)?.toInt() ?? 0,
      quality: movieJson['quality'],
      lang: movieJson['lang'],
      time: movieJson['time'],
      episodeCurrent: movieJson['episode_current'],
      type: movieJson['type'],
      content: movieJson['content'],
      trailerUrl: movieJson['trailer_url'],
      categories: (movieJson['category'] as List?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      countries: (movieJson['country'] as List?)
              ?.map((e) => Country.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      actors: (movieJson['actor'] as List?)?.map((e) => e.toString()).toList() ?? [],
      directors: (movieJson['director'] as List?)?.map((e) => e.toString()).toList() ?? [],
      modifiedTime: movieJson['modified'] != null ? DateTime.tryParse(movieJson['modified']['time'] ?? '') : null,
    );
  }
}
