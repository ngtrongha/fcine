import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../database/app_database.dart';
import '../config/master_config.dart';
import '../config/config_service.dart';
import '../download/download_service.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../domain/repositories/movie_repository.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Dio
  getIt.registerLazySingleton<Dio>(() => Dio(BaseOptions(headers: {'accept': 'application/json'})));

  // Repositories (depend on AppDatabase)
  getIt.registerLazySingleton<HistoryRepository>(() => HistoryRepository(getIt<AppDatabase>()));
  getIt.registerLazySingleton<BookmarkRepository>(() => BookmarkRepository(getIt<AppDatabase>()));
  getIt.registerLazySingleton<DownloadService>(() => DownloadService(db: getIt<AppDatabase>(), dio: getIt<Dio>()));

  // Config — load synchronously so MovieRepository is ready before first widget builds
  final configService = ConfigService(db: getIt<AppDatabase>(), dio: getIt<Dio>());
  getIt.registerSingleton<ConfigService>(configService);
  final masterConfig = await configService.load();
  getIt.registerSingleton<MasterConfig>(masterConfig);

  // Create datasources for all enabled sources
  final datasources = <String, RemoteDataSource>{};
  for (final source in masterConfig.sources.where((s) => s.enabled)) {
    final dioForSource = Dio(BaseOptions(
      baseUrl: source.baseUrl,
      headers: source.headers,
    ));
    datasources[source.id] = RemoteDataSource(dio: dioForSource, source: source);
  }
  getIt.registerSingleton<Map<String, RemoteDataSource>>(datasources);

  // Primary datasource (first enabled source)
  final primarySource = masterConfig.enabledSource;
  if (primarySource == null) {
    throw Exception('No enabled source found in config');
  }
  final primaryDatasource = datasources[primarySource.id]!;
  getIt.registerSingleton<RemoteDataSource>(primaryDatasource);

  // Repository with fallback support
  getIt.registerSingleton<MovieRepository>(MovieRepositoryImpl(
    primary: primaryDatasource,
    allDatasources: datasources,
  ));
}
