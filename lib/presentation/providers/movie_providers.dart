import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/config/master_config.dart';
import '../../core/config/config_service.dart';
import '../../core/database/database_provider.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/kkphim_remote_datasource.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';

// Remote URL có thể đổi qua --dart-define CONFIG_URL=https://gist... hoặc để rỗng để dùng assets
const String _remoteConfigUrl = String.fromEnvironment('CONFIG_URL');

final configServiceProvider = Provider<ConfigService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final dio = Dio(BaseOptions(headers: {'accept': 'application/json'}));
  return ConfigService(db: db, dio: dio, remoteUrl: _remoteConfigUrl.isEmpty ? null : _remoteConfigUrl);
});

final masterConfigProvider = FutureProvider<MasterConfig>((ref) async {
  final service = ref.watch(configServiceProvider);
  return service.load();
});

final configOfflineBannerProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(configServiceProvider);
  if (_remoteConfigUrl.isEmpty) return false;
  return service.isOfflineFallbackUsed();
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(masterConfigProvider).value;
  if (config == null) {
    return Dio(BaseOptions(headers: {'accept': 'application/json'}));
  }
  final source = config.sources.firstWhere((s) => s.enabled);
  return DioClient.forSource(source, config.settings).dio;
});

final kkphimDataSourceProvider = Provider<KkphimRemoteDataSource>((ref) {
  final config = ref.watch(masterConfigProvider).value;
  if (config == null) throw Exception('Config not loaded');
  final source = config.sources.firstWhere((s) => s.enabled);
  final dio = ref.watch(dioProvider);
  return KkphimRemoteDataSource(dio: dio, source: source);
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final ds = ref.watch(kkphimDataSourceProvider);
  return MovieRepositoryImpl(ds);
});

// Home latest
final latestMoviesProvider = FutureProvider.family<({List movies, dynamic pagination}), int>((ref, page) async {
  final repo = ref.watch(movieRepositoryProvider);
  final res = await repo.getLatest(page: page);
  return (movies: res.movies, pagination: res.pagination);
});

final searchMoviesProvider = FutureProvider.family<({List movies, dynamic pagination}), ({String keyword, int page})>((ref, args) async {
  final repo = ref.watch(movieRepositoryProvider);
  final res = await repo.search(args.keyword, page: args.page);
  return (movies: res.movies, pagination: res.pagination);
});

final movieDetailProvider = FutureProvider.family<dynamic, String>((ref, slug) async {
  final repo = ref.watch(movieRepositoryProvider);
  return repo.getDetail(slug);
});

final listByTypeProvider = FutureProvider.family<({List movies, dynamic pagination}), ({String type, int page})>((ref, args) async {
  final repo = ref.watch(movieRepositoryProvider);
  final res = await repo.getListByType(args.type, page: args.page);
  return (movies: res.movies, pagination: res.pagination);
});
