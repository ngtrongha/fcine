import 'package:dio/dio.dart';
import '../../core/config/master_config.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/pagination.dart';
import '../models/movie_model.dart';
import '../models/episode_model.dart';

class KkphimRemoteDataSource {
  final Dio dio;
  final SourceConfig source;

  KkphimRemoteDataSource({required this.dio, required this.source});

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

  // GET /danh-sach/phim-moi-cap-nhat?page=1
  Future<({List<Movie> movies, Pagination pagination})> getLatest({int page = 1}) async {
    final path = _buildUrl(source.endpoints.latest.path, {'page': page.toString()});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) throw DioException(requestOptions: res.requestOptions, response: res, error: 'Failed latest ${res.statusCode}');
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    final pagination = Pagination(
      totalItems: (data['pagination']?['totalItems'] as num?)?.toInt() ?? items.length,
      totalItemsPerPage: (data['pagination']?['totalItemsPerPage'] as num?)?.toInt() ?? 24,
      currentPage: (data['pagination']?['currentPage'] as num?)?.toInt() ?? page,
      totalPages: (data['pagination']?['totalPages'] as num?)?.toInt() ?? 1,
    );
    final movies = items.map((e) => MovieModel.fromListJson(e, cdn: source.cdnImage)).toList();
    return (movies: movies, pagination: pagination);
  }

  // GET /v1/api/tim-kiem?keyword=avengers&page=1&limit=24 + filters
  Future<({List<Movie> movies, Pagination pagination})> search(
      {required String keyword, int page = 1, int limit = 24, String? category, String? country, String? year, String? type}) async {
    var path = _buildUrl(source.endpoints.search.path, {'keyword': keyword, 'page': page.toString()});
    // append optional filters (API hỗ trợ category, country, year, type ...)
    final extras = <String, String>{};
    if (category != null && category.isNotEmpty) extras['category'] = category;
    if (country != null && country.isNotEmpty) extras['country'] = country;
    if (year != null && year.isNotEmpty) extras['year'] = year;
    if (type != null && type.isNotEmpty) extras['type'] = type;
    if (extras.isNotEmpty) {
      final qs = extras.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      path = '$path&$qs';
    }
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) throw DioException(requestOptions: res.requestOptions, response: res, error: 'Search failed ${res.statusCode}');
    final data = res.data as Map<String, dynamic>;
    // v1 wrapper: data.data.items
    final dataInner = data['data'] as Map<String, dynamic>?;
    if (dataInner == null) return (movies: <Movie>[], pagination: Pagination(totalItems: 0, totalItemsPerPage: limit, currentPage: page, totalPages: 0));
    final items = (dataInner['items'] as List).cast<Map<String, dynamic>>();
    final paginationJson = dataInner['params']?['pagination'] as Map<String, dynamic>?;
    final pagination = paginationJson != null ? Pagination.fromV1Json(paginationJson) : Pagination(totalItems: items.length, totalItemsPerPage: limit, currentPage: page, totalPages: 1);
    final movies = items.map((e) => MovieModel.fromListJson(e, cdn: source.cdnImage)).toList();
    return (movies: movies, pagination: pagination);
  }

  // GET /phim/{slug}
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(String slug) async {
    final path = _buildUrl(source.endpoints.detail.path, {'slug': slug});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) throw DioException(requestOptions: res.requestOptions, response: res, error: 'Detail failed ${res.statusCode}');
    final data = res.data as Map<String, dynamic>;
    final movieJson = data['movie'] as Map<String, dynamic>;
    final movie = MovieModel.fromDetailJson(movieJson, cdn: source.cdnImage);
    final episodesJson = (data['episodes'] as List).cast<Map<String, dynamic>>();
    final servers = episodesJson.map((e) => EpisodeServerModel.fromJson(e)).toList();
    return (movie: movie, servers: servers);
  }

  // GET /v1/api/danh-sach/{type}?page={page}
  Future<({List<Movie> movies, Pagination pagination})> getListByType(String type, {int page = 1}) async {
    final tpl = source.endpoints.listByType?.path ?? '/v1/api/danh-sach/{type}?page={page}';
    final path = _buildUrl(tpl, {'type': type, 'page': page.toString()});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) throw DioException(requestOptions: res.requestOptions, response: res, error: 'ListByType failed ${res.statusCode}');
    final data = res.data as Map<String, dynamic>;
    // v1: data.data.items + data.data.params.pagination
    final dataInner = data['data'] as Map<String, dynamic>?;
    if (dataInner == null) {
      // fallback cũ: items trực tiếp
      final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return (movies: items.map((e) => MovieModel.fromListJson(e, cdn: source.cdnImage)).toList(), pagination: Pagination(totalItems: items.length, totalItemsPerPage: 24, currentPage: page, totalPages: 1));
    }
    final items = (dataInner['items'] as List).cast<Map<String, dynamic>>();
    final paginationJson = dataInner['params']?['pagination'] as Map<String, dynamic>?;
    final pagination = paginationJson != null ? Pagination.fromV1Json(paginationJson) : Pagination(totalItems: items.length, totalItemsPerPage: 24, currentPage: page, totalPages: 1);
    final movies = items.map((e) => MovieModel.fromListJson(e, cdn: source.cdnImage)).toList();
    return (movies: movies, pagination: pagination);
  }
}
