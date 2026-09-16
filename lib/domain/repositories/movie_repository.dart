import '../entities/movie.dart';
import '../entities/episode.dart';
import '../entities/pagination.dart';

abstract class MovieRepository {
  Future<({List<Movie> movies, Pagination pagination})> getLatest({
    int page,
    String? sourceId,
  });
  Future<({List<Movie> movies, Pagination pagination})> search(
    String keyword, {
    int page,
    int limit,
    String? category,
    String? country,
    String? year,
    String? type,
    String? sourceId,
  });
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(
    String slug, {
    String? sourceId,
  });
  Future<({List<Movie> movies, Pagination pagination})> getListByType(
    String type, {
    int page,
    String? sourceId,
  });
}
