import 'package:dio/dio.dart';
import '../../core/config/master_config.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/pagination.dart';
import '../models/movie_model.dart';

class NguoncRemoteDataSource {
  final Dio dio;
  final SourceConfig source;

  NguoncRemoteDataSource({required this.dio, required this.source});

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

  // GET /films/phim-moi-cap-nhat?page=1
  Future<({List<Movie> movies, Pagination pagination})> getLatest({int page = 1}) async {
    final path = _buildUrl(source.endpoints.latest.path, {'page': page.toString()});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(requestOptions: res.requestOptions, response: res, error: 'Failed latest ${res.statusCode}');
    }
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    final paginate = data['paginate'] as Map<String, dynamic>;
    final pagination = Pagination(
      totalItems: (paginate['total_items'] as num?)?.toInt() ?? items.length,
      totalItemsPerPage: (paginate['items_per_page'] as num?)?.toInt() ?? 10,
      currentPage: (paginate['current_page'] as num?)?.toInt() ?? page,
      totalPages: (paginate['total_page'] as num?)?.toInt() ?? 1,
    );
    final movies = items.map((e) => _movieFromListItem(e)).toList();
    return (movies: movies, pagination: pagination);
  }

  // GET /films/search?keyword=avengers&page=1
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
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    final paginate = data['paginate'] as Map<String, dynamic>?;
    final pagination = paginate != null
        ? Pagination(
            totalItems: (paginate['total_items'] as num?)?.toInt() ?? items.length,
            totalItemsPerPage: (paginate['items_per_page'] as num?)?.toInt() ?? limit,
            currentPage: (paginate['current_page'] as num?)?.toInt() ?? page,
            totalPages: (paginate['total_page'] as num?)?.toInt() ?? 1,
          )
        : Pagination(totalItems: items.length, totalItemsPerPage: limit, currentPage: page, totalPages: 1);
    final movies = items.map((e) => _movieFromListItem(e)).toList();
    return (movies: movies, pagination: pagination);
  }

  // GET /film/{slug}
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(String slug) async {
    final path = _buildUrl(source.endpoints.detail.path, {'slug': slug});
    final res = await _getWithFallback(path);
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(requestOptions: res.requestOptions, response: res, error: 'Detail failed ${res.statusCode}');
    }
    final data = res.data as Map<String, dynamic>;
    final movieJson = data['movie'] as Map<String, dynamic>;
    final movie = _movieFromDetailJson(movieJson);

    // Map NguonC episodes format to our format
    final episodesRaw = (movieJson['episodes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final servers = <EpisodeServer>[];
    for (final server in episodesRaw) {
      final serverName = server['server_name'] ?? '';
      final items = (server['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final episodes = items.map((ep) => Episode(
        name: ep['name']?.toString() ?? '',
        slug: ep['slug']?.toString() ?? '',
        embedUrl: ep['embed']?.toString(),
      )).toList();
      servers.add(EpisodeServer(serverName: serverName, episodes: episodes));
    }
    return (movie: movie, servers: servers);
  }

  Movie _movieFromListItem(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id']?.toString() ?? json['slug']?.toString() ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      originName: json['original_name'] ?? '',
      thumbUrl: json['thumb_url'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      year: _parseInt(json['year']) ?? 0,
      quality: json['quality'],
      lang: json['language'],
      time: json['time'],
      episodeCurrent: json['current_episode'],
      type: _detectType(json),
    );
  }

  Movie _movieFromDetailJson(Map<String, dynamic> json) {
    // Parse categories
    final categories = <Category>[];
    final categoryMap = json['category'] as Map<String, dynamic>?;
    if (categoryMap != null) {
      for (final entry in categoryMap.entries) {
        final group = entry.value['group'] as Map<String, dynamic>?;
        final list = (entry.value['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (group?['name'] == 'Thể loại') {
          for (final cat in list) {
            categories.add(Category(
              id: cat['id']?.toString() ?? '',
              name: cat['name'] ?? '',
              slug: cat['name']?.toLowerCase().replaceAll(' ', '-') ?? '',
            ));
          }
        }
      }
    }

    // Detect type from category
    String? type;
    if (categoryMap != null) {
      for (final entry in categoryMap.entries) {
        final list = (entry.value['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        for (final item in list) {
          final name = item['name']?.toString().toLowerCase() ?? '';
          if (name.contains('phim bộ') || name.contains('series')) {
            type = 'series';
          } else if (name.contains('phim lẻ') || name.contains('single')) {
            type = 'single';
          } else if (name.contains('hoạt hình') || name.contains('animation')) {
            type = 'hoathinh';
          }
        }
      }
    }

    return MovieModel(
      id: json['id']?.toString() ?? json['slug']?.toString() ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      originName: json['original_name'] ?? '',
      thumbUrl: json['thumb_url'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      year: _parseInt(json['year']) ?? 0,
      quality: json['quality'],
      lang: json['language'],
      time: json['time'],
      episodeCurrent: json['current_episode'],
      type: type,
      categories: categories,
      content: json['description'],
      actors: json['casts']?.toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [],
      directors: json['director']?.toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [],
    );
  }

  String? _detectType(Map<String, dynamic> json) {
    // NguonC doesn't have explicit type field, try to detect from other fields
    final lang = json['language']?.toString().toLowerCase() ?? '';
    if (lang.contains('hoạt hình') || lang.contains('animation')) return 'hoathinh';
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
