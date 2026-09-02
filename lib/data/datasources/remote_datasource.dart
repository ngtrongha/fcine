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
    params.forEach((k, v) => url = url.replaceAll('{$k}', Uri.encodeComponent(v)));
    return url;
  }

  Future<Response> _getWithFallback(String path) async {
    final bases = <String>{source.baseUrl, ...source.fallbackUrls}.toList();
    DioException? lastErr;
    for (final base in bases) {
      try {
        final client = base == source.baseUrl
            ? dio
            : Dio(BaseOptions(
                baseUrl: base,
                headers: dio.options.headers,
                connectTimeout: dio.options.connectTimeout,
                receiveTimeout: dio.options.receiveTimeout,
                validateStatus: (s) => s != null && s < 500,
              ));
        final res = await client.get(path);
        if (res.statusCode == 200 && res.data != null) return res;
        lastErr = DioException(requestOptions: res.requestOptions, response: res, error: 'Status ${res.statusCode} at $base');
      } catch (e) {
        lastErr = e is DioException ? e : DioException(requestOptions: RequestOptions(path: path), error: e.toString());
      }
    }
    throw lastErr!;
  }

  // GET latest movies
  Future<({List<Movie> movies, Pagination pagination})> getLatest({int page = 1}) async {
    final path = _buildUrl(source.endpoints.latest.path, {'page': page.toString()});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(requestOptions: res.requestOptions, response: res, error: 'Failed latest ${res.statusCode}');
    }
    final data = res.data;
    final ex = source.extractor('latest');
    final pagEx = source.extractor('pagination');

    final items = JsonPathExtractor.extractMapList(data, ex['list']);
    final movies = items.map((e) => _movieFromJson(e, ex)).toList();

    final pagination = Pagination(
      totalItems: JsonPathExtractor.extractInt(data, pagEx['totalItems']) ?? items.length,
      totalItemsPerPage: JsonPathExtractor.extractInt(data, pagEx['itemsPerPage']) ?? 24,
      currentPage: JsonPathExtractor.extractInt(data, pagEx['currentPage']) ?? page,
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
    var path = _buildUrl(source.endpoints.search.path, {'keyword': keyword, 'page': page.toString()});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(requestOptions: res.requestOptions, response: res, error: 'Search failed ${res.statusCode}');
    }
    final data = res.data;
    final ex = source.extractor('search');

    final items = JsonPathExtractor.extractMapList(data, ex['list']);
    final movies = items.map((e) => _movieFromJson(e, source.extractor('latest'))).toList();

    final pagination = Pagination(
      totalItems: JsonPathExtractor.extractInt(data, ex['totalItems']) ?? items.length,
      totalItemsPerPage: limit,
      currentPage: JsonPathExtractor.extractInt(data, ex['currentPage']) ?? page,
      totalPages: JsonPathExtractor.extractInt(data, ex['totalPages']) ?? 1,
    );

    return (movies: movies, pagination: pagination);
  }

  // GET detail
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(String slug) async {
    final path = _buildUrl(source.endpoints.detail.path, {'slug': slug});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(requestOptions: res.requestOptions, response: res, error: 'Detail failed ${res.statusCode}');
    }
    final data = res.data;
    final detailEx = source.extractor('detail');
    final epEx = source.extractor('episodes');

    final movieJson = JsonPathExtractor.extract(data, detailEx['movie']);
    final movie = _movieFromDetailJson(movieJson, detailEx);

    final episodesRaw = JsonPathExtractor.extractMapList(data, detailEx['episodes']);
    final servers = _parseEpisodes(episodesRaw, epEx);

    return (movie: movie, servers: servers);
  }

  // GET list by type
  Future<({List<Movie> movies, Pagination pagination})> getListByType(String type, {int page = 1}) async {
    final tpl = source.endpoints.listByType?.path ?? '/v1/api/danh-sach/{type}?page={page}';
    final path = _buildUrl(tpl, {'type': type, 'page': page.toString()});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(requestOptions: res.requestOptions, response: res, error: 'ListByType failed ${res.statusCode}');
    }
    final data = res.data;
    final ex = source.extractor('latest');

    // Try v1 format first, then fallback
    final dataInner = JsonPathExtractor.extract(data, '\$.data') as Map<String, dynamic>?;
    List<Map<String, dynamic>> items;
    Map<String, dynamic>? paginateData;

    if (dataInner != null) {
      items = JsonPathExtractor.extractMapList(dataInner, '\$.items');
      paginateData = JsonPathExtractor.extract(dataInner, '\$.params.pagination') as Map<String, dynamic>?;
    } else {
      items = JsonPathExtractor.extractMapList(data, ex['list']);
      paginateData = JsonPathExtractor.extract(data, '\$.pagination') as Map<String, dynamic>?;
    }

    final movies = items.map((e) => _movieFromJson(e, ex)).toList();
    final pagination = paginateData != null
        ? Pagination(
            totalItems: (paginateData['totalItems'] as num?)?.toInt() ?? items.length,
            totalItemsPerPage: (paginateData['totalItemsPerPage'] as num?)?.toInt() ?? 24,
            currentPage: (paginateData['currentPage'] as num?)?.toInt() ?? page,
            totalPages: (paginateData['totalPages'] as num?)?.toInt() ?? 1,
          )
        : Pagination(totalItems: items.length, totalItemsPerPage: 24, currentPage: page, totalPages: 1);

    return (movies: movies, pagination: pagination);
  }

  Movie _movieFromJson(Map<String, dynamic> json, Map<String, dynamic> ex) {
    return MovieModel(
      id: JsonPathExtractor.extractString(json, ex['id']) ?? '',
      slug: JsonPathExtractor.extractString(json, ex['id']) ?? '',
      name: JsonPathExtractor.extractString(json, ex['title']) ?? '',
      originName: JsonPathExtractor.extractString(json, ex['originalTitle']) ?? '',
      thumbUrl: JsonPathExtractor.extractString(json, ex['thumb']) ?? '',
      posterUrl: JsonPathExtractor.extractString(json, ex['poster']) ?? '',
      year: JsonPathExtractor.extractInt(json, ex['year']) ?? 0,
      quality: JsonPathExtractor.extractString(json, ex['quality']),
      lang: JsonPathExtractor.extractString(json, ex['language']),
      time: JsonPathExtractor.extractString(json, ex['time']),
      episodeCurrent: JsonPathExtractor.extractString(json, ex['episodeCurrent']),
    );
  }

  Movie _movieFromDetailJson(dynamic json, Map<String, dynamic> ex) {
    if (json == null) {
      return const Movie(
        id: '', slug: '', name: '', originName: '', thumbUrl: '', posterUrl: '', year: 0,
      );
    }

    // Parse categories
    final categories = <Category>[];
    final categoryRaw = JsonPathExtractor.extract(json, ex['categories']);
    if (categoryRaw is Map) {
      for (final entry in (categoryRaw as Map<String, dynamic>).entries) {
        final group = JsonPathExtractor.extract(entry.value, '\$.group.name');
        final list = JsonPathExtractor.extract(entry.value, '\$.list');
        if (group == 'Thể loại' && list is List) {
          for (final cat in list) {
            if (cat is Map) {
              categories.add(Category(
                id: cat['id']?.toString() ?? '',
                name: cat['name'] ?? '',
                slug: cat['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? '',
              ));
            }
          }
        }
      }
    } else if (categoryRaw is List) {
      for (final cat in categoryRaw) {
        if (cat is Map) {
          categories.add(Category(
            id: cat['id']?.toString() ?? '',
            name: cat['name'] ?? '',
            slug: cat['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? '',
          ));
        }
      }
    }

    // Parse actors/directors (could be string or list)
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      if (value is String) return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return [];
    }

    return MovieModel(
      id: JsonPathExtractor.extractString(json, ex['id']) ?? '',
      slug: JsonPathExtractor.extractString(json, ex['slug']) ?? '',
      name: JsonPathExtractor.extractString(json, ex['title']) ?? '',
      originName: JsonPathExtractor.extractString(json, ex['originalTitle']) ?? '',
      thumbUrl: JsonPathExtractor.extractString(json, ex['thumb']) ?? '',
      posterUrl: JsonPathExtractor.extractString(json, ex['poster']) ?? '',
      year: JsonPathExtractor.extractInt(json, ex['year']) ?? 0,
      quality: JsonPathExtractor.extractString(json, ex['quality']),
      lang: JsonPathExtractor.extractString(json, ex['language']),
      time: JsonPathExtractor.extractString(json, ex['time']),
      episodeCurrent: JsonPathExtractor.extractString(json, ex['episodeCurrent']),
      type: JsonPathExtractor.extractString(json, ex['type']),
      content: JsonPathExtractor.extractString(json, ex['content']),
      actors: parseStringList(JsonPathExtractor.extract(json, ex['actors'])),
      directors: parseStringList(JsonPathExtractor.extract(json, ex['directors'])),
      categories: categories,
    );
  }

  List<EpisodeServer> _parseEpisodes(List<Map<String, dynamic>> episodesRaw, Map<String, dynamic> epEx) {
    final servers = <EpisodeServer>[];
    for (final server in episodesRaw) {
      final serverName = JsonPathExtractor.extractString(server, epEx['serverName']) ?? '';
      final itemsRaw = JsonPathExtractor.extract(server, epEx['serverData']);

      final episodes = <Episode>[];
      if (itemsRaw is List) {
        for (final ep in itemsRaw) {
          if (ep is Map<String, dynamic>) {
            episodes.add(Episode(
              name: JsonPathExtractor.extractString(ep, epEx['name']) ?? '',
              slug: JsonPathExtractor.extractString(ep, epEx['slug']) ?? '',
              m3u8Url: JsonPathExtractor.extractString(ep, epEx['m3u8']),
              embedUrl: JsonPathExtractor.extractString(ep, epEx['embed']),
            ));
          }
        }
      }

      servers.add(EpisodeServer(serverName: serverName, episodes: episodes));
    }
    return servers;
  }
}
