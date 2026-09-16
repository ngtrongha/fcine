import 'package:dio/dio.dart';

import '../../core/config/master_config.dart';
import '../../core/extractor/json_path.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/pagination.dart';
import '../models/movie_model.dart';

/// Generic remote data source that works with any source config.
/// Adding a new source only requires config changes, no code changes.
class RemoteDataSource {
  final Dio dio;
  final SourceConfig source;

  RemoteDataSource({required this.dio, required this.source});

  String _buildUrl(String template, Map<String, String> params) {
    var url = template;
    params.forEach(
      (k, v) => url = url.replaceAll('{$k}', Uri.encodeComponent(v)),
    );
    return url;
  }

  Future<Response> _getWithFallback(String path) async {
    final bases = <String>{source.baseUrl, ...source.fallbackUrls}.toList();
    DioException? lastErr;
    for (final base in bases) {
      try {
        final client = base == source.baseUrl
            ? dio
            : Dio(
                BaseOptions(
                  baseUrl: base,
                  headers: dio.options.headers,
                  connectTimeout: dio.options.connectTimeout,
                  receiveTimeout: dio.options.receiveTimeout,
                  validateStatus: (s) => s != null && s < 500,
                ),
              );
        final res = await client.get(path);
        if (res.statusCode == 200 && res.data != null) return res;
        lastErr = DioException(
          requestOptions: res.requestOptions,
          response: res,
          error: 'Status ${res.statusCode} at $base',
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

  // GET latest movies
  Future<({List<Movie> movies, Pagination pagination})> getLatest({
    int page = 1,
  }) async {
    final path = _buildUrl(source.endpoints.latest.path, {
      'page': page.toString(),
    });
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Failed latest ${res.statusCode}',
      );
    }
    final data = res.data;
    final ex = source.extractor('latest');
    final pagEx = source.extractor('pagination');

    final items = JsonPathExtractor.extractMapList(data, ex['list']);
    final movies = items.map((e) => _movieFromJson(e, ex)).toList();

    final pagination = Pagination(
      totalItems:
          JsonPathExtractor.extractInt(data, pagEx['totalItems']) ??
          items.length,
      totalItemsPerPage:
          JsonPathExtractor.extractInt(data, pagEx['itemsPerPage']) ?? 24,
      currentPage:
          JsonPathExtractor.extractInt(data, pagEx['currentPage']) ?? page,
      totalPages: JsonPathExtractor.extractInt(data, pagEx['totalPages']) ?? 1,
    );

    return (movies: movies, pagination: pagination);
  }

  // GET search
  Future<({List<Movie> movies, Pagination pagination})> search({
    required String keyword,
    int page = 1,
    int limit = 24,
    String? category,
    String? country,
    String? year,
    String? type,
  }) async {
    var path = _buildUrl(source.endpoints.search.path, {
      'keyword': keyword,
      'page': page.toString(),
    });
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Search failed ${res.statusCode}',
      );
    }
    final data = res.data;
    final ex = source.extractor('search');

    final items = JsonPathExtractor.extractMapList(data, ex['list']);
    final movies = items
        .map((e) => _movieFromJson(e, source.extractor('latest')))
        .toList();

    final pagination = Pagination(
      totalItems:
          JsonPathExtractor.extractInt(data, ex['totalItems']) ?? items.length,
      totalItemsPerPage: limit,
      currentPage:
          JsonPathExtractor.extractInt(data, ex['currentPage']) ?? page,
      totalPages: JsonPathExtractor.extractInt(data, ex['totalPages']) ?? 1,
    );

    return (movies: movies, pagination: pagination);
  }

  // GET detail
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(
    String slug,
  ) async {
    final path = _buildUrl(source.endpoints.detail.path, {'slug': slug});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Detail failed ${res.statusCode}',
      );
    }
    final data = res.data;
    final detailEx = source.extractor('detail');
    final epEx = source.extractor('episodes');

    final movie = _movieFromDetailJson(data, detailEx);

    final episodesRaw = JsonPathExtractor.extractMapList(
      data,
      detailEx['episodes'],
    );
    final servers = _parseEpisodes(episodesRaw, epEx);

    return (movie: movie, servers: servers);
  }

  // GET list by type
  Future<({List<Movie> movies, Pagination pagination})> getListByType(
    String type, {
    int page = 1,
  }) async {
    final tpl =
        source.endpoints.listByType?.path ??
        '/v1/api/danh-sach/{type}?page={page}';
    final path = _buildUrl(tpl, {'type': type, 'page': page.toString()});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'ListByType failed ${res.statusCode}',
      );
    }
    final data = res.data;
    final ex = source.extractor('latest');

    // Try v1 format first, then fallback
    final dataInner =
        JsonPathExtractor.extract(data, r'$.data') as Map<String, dynamic>?;
    List<Map<String, dynamic>> items;
    Map<String, dynamic>? paginateData;

    if (dataInner != null) {
      items = JsonPathExtractor.extractMapList(dataInner, r'$.items');
      paginateData = JsonPathExtractor.extract(
        dataInner,
        r'$.params.pagination',
      ) as Map<String, dynamic>?;
    } else {
      items = JsonPathExtractor.extractMapList(data, ex['list']);
      paginateData = JsonPathExtractor.extract(
        data,
        r'$.pagination',
      ) as Map<String, dynamic>?;
    }

    final movies = items.map((e) => _movieFromJson(e, ex)).toList();
    final pagination = paginateData != null
        ? Pagination(
            totalItems:
                (paginateData['totalItems'] as num?)?.toInt() ?? items.length,
            totalItemsPerPage:
                (paginateData['totalItemsPerPage'] as num?)?.toInt() ?? 24,
            currentPage: (paginateData['currentPage'] as num?)?.toInt() ?? page,
            totalPages: (paginateData['totalPages'] as num?)?.toInt() ?? 1,
          )
        : Pagination(
            totalItems: items.length,
            totalItemsPerPage: 24,
            currentPage: page,
            totalPages: 1,
          );

    return (movies: movies, pagination: pagination);
  }

  Movie _movieFromJson(Map<String, dynamic> json, Map<String, dynamic> ex) {
    return MovieModel(
      id: JsonPathExtractor.extractString(json, ex['id']) ?? '',
      slug: JsonPathExtractor.extractString(json, ex['id']) ?? '',
      name: JsonPathExtractor.extractString(json, ex['title']) ?? '',
      originName:
          JsonPathExtractor.extractString(json, ex['originalTitle']) ?? '',
      thumbUrl: Movie.normalizeImage(
        JsonPathExtractor.extractString(json, ex['thumb']),
        cdn: source.cdnImage,
      ),
      posterUrl: Movie.normalizeImage(
        JsonPathExtractor.extractString(json, ex['poster']),
        cdn: source.cdnImage,
      ),
      year: JsonPathExtractor.extractInt(json, ex['year']) ?? 0,
      quality: JsonPathExtractor.extractString(json, ex['quality']),
      lang: JsonPathExtractor.extractString(json, ex['language']),
      time: JsonPathExtractor.extractString(json, ex['time']),
      episodeCurrent: JsonPathExtractor.extractString(
        json,
        ex['episodeCurrent'],
      ),
      sourceId: source.id,
    );
  }

  Movie _movieFromDetailJson(dynamic json, Map<String, dynamic> ex) {
    if (json == null) {
      return const Movie(
        id: '',
        slug: '',
        name: '',
        originName: '',
        thumbUrl: '',
        posterUrl: '',
        year: 0,
      );
    }

    dynamic extractVal(String? path) {
      if (path == null || path.isEmpty) return null;
      var val = JsonPathExtractor.extract(json, path);
      if (val == null &&
          path.startsWith(r'$.movie.') &&
          json is Map &&
          !json.containsKey('movie')) {
        val = JsonPathExtractor.extract(json, r'$.' + path.substring(8));
      }
      return val;
    }

    String? extractStr(String? path) {
      final val = extractVal(path);
      return val?.toString();
    }

    int? extractI(String? path) {
      final val = extractVal(path);
      if (val is num) return val.toInt();
      return int.tryParse(val?.toString() ?? '');
    }

    // Parse categories
    final categories = <Category>[];
    final categoryRaw = extractVal(ex['categories']);
    if (categoryRaw is Map) {
      for (final entry in (categoryRaw as Map<String, dynamic>).entries) {
        final group = JsonPathExtractor.extract(entry.value, r'$.group.name');
        final list = JsonPathExtractor.extract(entry.value, r'$.list');
        if (group == 'Thể loại' && list is List) {
          for (final cat in list) {
            if (cat is Map) {
              categories.add(
                Category(
                  id: cat['id']?.toString() ?? '',
                  name: cat['name'] ?? '',
                  slug:
                      cat['slug']?.toString() ??
                      (cat['name']?.toString().toLowerCase().replaceAll(
                            ' ',
                            '-',
                          ) ??
                          ''),
                ),
              );
            }
          }
        }
      }
    } else if (categoryRaw is List) {
      for (final cat in categoryRaw) {
        if (cat is Map) {
          categories.add(
            Category(
              id: cat['id']?.toString() ?? '',
              name: cat['name'] ?? '',
              slug:
                  cat['slug']?.toString() ??
                  (cat['name']?.toString().toLowerCase().replaceAll(' ', '-') ??
                      ''),
            ),
          );
        }
      }
    }

    // Parse countries
    final countries = <Country>[];
    final countryRaw = extractVal(ex['countries']);
    if (countryRaw is Map) {
      for (final entry in (countryRaw as Map<String, dynamic>).entries) {
        final group = JsonPathExtractor.extract(entry.value, r'$.group.name');
        final list = JsonPathExtractor.extract(entry.value, r'$.list');
        if (group == 'Quốc gia' && list is List) {
          for (final c in list) {
            if (c is Map) {
              countries.add(
                Country(
                  id: c['id']?.toString() ?? '',
                  name: c['name'] ?? '',
                  slug:
                      c['slug']?.toString() ??
                      (c['name']?.toString().toLowerCase().replaceAll(
                            ' ',
                            '-',
                          ) ??
                          ''),
                ),
              );
            }
          }
        }
      }
    } else if (countryRaw is List) {
      for (final c in countryRaw) {
        if (c is Map) {
          countries.add(
            Country(
              id: c['id']?.toString() ?? '',
              name: c['name'] ?? '',
              slug:
                  c['slug']?.toString() ??
                  (c['name']?.toString().toLowerCase().replaceAll(' ', '-') ??
                      ''),
            ),
          );
        }
      }
    }

    // Parse actors/directors (could be string or list)
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (value is String) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    // Parse vote average
    double? parseVote() {
      final voteVal =
          extractVal(r'$.movie.vote_average') ?? extractVal(r'$.vote_average');
      if (voteVal is num && voteVal > 0) return voteVal.toDouble();
      final tmdbVote =
          extractVal(r'$.movie.tmdb.vote_average') ??
          extractVal(r'$.tmdb.vote_average');
      if (tmdbVote is num && tmdbVote > 0) return tmdbVote.toDouble();
      final imdbVote =
          extractVal(r'$.movie.imdb.vote_average') ??
          extractVal(r'$.imdb.vote_average');
      if (imdbVote is num && imdbVote > 0) return imdbVote.toDouble();
      return null;
    }

    final rawThumb = extractStr(ex['thumb']);
    final rawPoster = extractStr(ex['poster']);

    int? year = extractI(ex['year']);
    String? type = extractStr(ex['type']);

    // Fallback parsing for year and type from category map (e.g. NguonC)
    if (categoryRaw is Map) {
      for (final entry in (categoryRaw as Map<String, dynamic>).entries) {
        final group = JsonPathExtractor.extract(entry.value, r'$.group.name');
        final list = JsonPathExtractor.extract(entry.value, r'$.list');
        if ((year == null || year == 0) &&
            group == 'Năm' &&
            list is List &&
            list.isNotEmpty) {
          final yName = list.first is Map
              ? list.first['name']?.toString()
              : list.first.toString();
          year = int.tryParse(yName ?? '');
        }
        if (type == null &&
            group == 'Định dạng' &&
            list is List &&
            list.isNotEmpty) {
          final fmtName = list.first is Map
              ? list.first['name']?.toString()
              : list.first.toString();
          if (fmtName != null && fmtName.toLowerCase().contains('bộ')) {
            type = 'series';
          } else if (fmtName != null && fmtName.toLowerCase().contains('lẻ')) {
            type = 'single';
          }
        }
      }
    }

    return MovieModel(
      id: extractStr(ex['id']) ?? '',
      slug: extractStr(ex['slug']) ?? '',
      name: extractStr(ex['title']) ?? '',
      originName: extractStr(ex['originalTitle']) ?? '',
      thumbUrl: Movie.normalizeImage(rawThumb, cdn: source.cdnImage),
      posterUrl: Movie.normalizeImage(rawPoster, cdn: source.cdnImage),
      year: year ?? 0,
      quality: extractStr(ex['quality']),
      lang: extractStr(ex['language']),
      time: extractStr(ex['time']),
      episodeCurrent: extractStr(ex['episodeCurrent']),
      type: type,
      content: extractStr(ex['content']),
      actors: parseStringList(extractVal(ex['actors'])),
      directors: parseStringList(extractVal(ex['directors'])),
      categories: categories,
      countries: countries,
      voteAverage: parseVote(),
      trailerUrl:
          extractStr(r'$.movie.trailer_url') ?? extractStr(r'$.trailer_url'),
      sourceId: source.id,
    );
  }

  List<EpisodeServer> _parseEpisodes(
    List<Map<String, dynamic>> episodesRaw,
    Map<String, dynamic> epEx,
  ) {
    final servers = <EpisodeServer>[];
    for (final server in episodesRaw) {
      final serverName =
          JsonPathExtractor.extractString(server, epEx['serverName']) ?? '';
      final itemsRaw = JsonPathExtractor.extract(server, epEx['serverData']);

      final episodes = <Episode>[];
      if (itemsRaw is List) {
        for (final ep in itemsRaw) {
          if (ep is Map<String, dynamic>) {
            episodes.add(
              Episode(
                name: JsonPathExtractor.extractString(ep, epEx['name']) ?? '',
                slug: JsonPathExtractor.extractString(ep, epEx['slug']) ?? '',
                m3u8Url: JsonPathExtractor.extractString(ep, epEx['m3u8']),
                embedUrl: JsonPathExtractor.extractString(ep, epEx['embed']),
              ),
            );
          }
        }
      }

      servers.add(EpisodeServer(serverName: serverName, episodes: episodes));
    }
    return servers;
  }
}
