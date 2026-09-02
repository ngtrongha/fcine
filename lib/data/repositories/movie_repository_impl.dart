import '../../domain/entities/movie.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  final RemoteDataSource primary;
  final Map<String, RemoteDataSource> allDatasources;

  MovieRepositoryImpl({required this.primary, this.allDatasources = const {}});

  /// Try primary source first, then fallback to other sources
  Future<T> _withFallback<T>(Future<T> Function(RemoteDataSource ds) action) async {
    // Try primary source
    try {
      return await action(primary);
    } catch (e) {
      // If primary fails, try other sources
      for (final entry in allDatasources.entries) {
        if (entry.key == primary.source.id) continue;
        try {
          return await action(entry.value);
        } catch (_) {
          continue;
        }
      }
      // All sources failed, rethrow original error
      rethrow;
    }
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getLatest({int page = 1}) {
    return _withFallback((ds) => ds.getLatest(page: page));
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> search(
    String keyword, {
    int page = 1,
    int limit = 24,
    String? category,
    String? country,
    String? year,
    String? type,
  }) {
    return _withFallback((ds) => ds.search(
      keyword: keyword,
      page: page,
      limit: limit,
      category: category,
      country: country,
      year: year,
      type: type,
    ));
  }

  @override
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(String slug) {
    return _withFallback((ds) => ds.getDetail(slug));
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getListByType(String type, {int page = 1}) {
    return _withFallback((ds) => ds.getListByType(type, page: page));
  }
}
