import '../../domain/entities/movie.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/kkphim_remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  final KkphimRemoteDataSource remote;
  MovieRepositoryImpl(this.remote);

  @override
  Future<({List<Movie> movies, Pagination pagination})> getLatest({int page = 1}) => remote.getLatest(page: page);

  @override
  Future<({List<Movie> movies, Pagination pagination})> search(String keyword, {int page = 1, int limit = 24, String? category, String? country, String? year, String? type}) =>
      remote.search(keyword: keyword, page: page, limit: limit, category: category, country: country, year: year, type: type);

  @override
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(String slug) => remote.getDetail(slug);

  @override
  Future<({List<Movie> movies, Pagination pagination})> getListByType(String type, {int page = 1}) =>
      remote.getListByType(type, page: page);
}
