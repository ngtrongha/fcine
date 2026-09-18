import '../../domain/entities/movie.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/remote_datasource.dart';
// Re-probe service được DI inject từ injection.dart (lazy singleton)
import 'package:fcine/core/config/source_refresh_service.dart';

/// Throw khi app chưa có nguồn phim do user nhập.
/// UI bắt exception này để hiển thị chế độ player-only.
class NoSourceConfiguredException implements Exception {
  final String message;
  const NoSourceConfiguredException([
    this.message =
        'Chưa cấu hình nguồn phim. Vui lòng nhập URL nguồn trong Cài đặt, hoặc dùng chế độ Player video.',
  ]);

  @override
  String toString() => message;
}

class MovieRepositoryImpl implements MovieRepository {
  final RemoteDataSource? primary;
  final Map<String, RemoteDataSource> allDatasources;
  final SourceRefreshService? refreshService;

  MovieRepositoryImpl({
    required this.primary,
    this.allDatasources = const {},
    this.refreshService,
  });

  bool get hasSource => primary != null && allDatasources.isNotEmpty;

  RemoteDataSource _requireSource(String? sourceId) {
    if (sourceId != null && allDatasources.containsKey(sourceId)) {
      return allDatasources[sourceId]!;
    }
    if (primary != null) return primary!;
    throw const NoSourceConfiguredException();
  }

  /// Try primary source first, then fallback to other sources
  Future<T> _withFallback<T>(
    Future<T> Function(RemoteDataSource ds) action, {
    String? sourceId,
  }) async {
    final first = _requireSource(sourceId);
    // Nếu user chỉ định source cụ thể → dùng đúng source đó.
    if (sourceId != null && allDatasources.containsKey(sourceId)) {
      return action(first);
    }
    // Try primary source
    try {
      return await action(first);
    } catch (e) {
      if (e is NoSourceConfiguredException) rethrow;
      // If primary fails, try other sources
      for (final entry in allDatasources.entries) {
        if (entry.key == first.source.id) continue;
        try {
          return await action(entry.value);
        } catch (_) {
          continue;
        }
      }
      // Re-probe web source blunt khi fail liên tục (self-heal)
      if (refreshService != null && first.source.isWeb) {
        try {
          final maybeReprobed = await refreshService!.maybeReprobe(first.source.id);
          if (maybeReprobed != null) {
            // Manager off-chảy gọi lại bằng config mới
            final newDs = MovieRepositoryImpl(
              primary: primary,
              allDatasources: allDatasources,
              refreshService: refreshService,
            )._requireSource(first.source.id);
            return await action(newDs);
          }
        } catch (_) {
          // Re-probe crack không được → trung bình dùng lỗi gốc
        }
      }
      rethrow; // Fallback nếu không refresh: trả lỗi gốc
    }
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getLatest({
    int page = 1,
    String? sourceId,
  }) {
    return _withFallback((ds) => ds.getLatest(page: page), sourceId: sourceId);
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
    String? sourceId,
  }) {
    return _withFallback(
      (ds) => ds.search(
        keyword: keyword,
        page: page,
        limit: limit,
        category: category,
        country: country,
        year: year,
        type: type,
      ),
      sourceId: sourceId,
    );
  }

  @override
  Future<({Movie movie, List<EpisodeServer> servers})> getDetail(
    String slug, {
    String? sourceId,
  }) {
    return _withFallback((ds) => ds.getDetail(slug), sourceId: sourceId);
  }

  @override
  Future<({List<Movie> movies, Pagination pagination})> getListByType(
    String type, {
    int page = 1,
    String? sourceId,
  }) {
    return _withFallback(
      (ds) => ds.getListByType(type, page: page),
      sourceId: sourceId,
    );
  }
}