import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../database/app_database.dart';
import '../config/master_config.dart';
import '../config/config_service.dart';
import '../download/download_service.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../data/datasources/web_scraper_datasource.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../domain/repositories/movie_repository.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Dio
  getIt.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(headers: {'accept': 'application/json'})),
  );

  // Repositories (depend on AppDatabase)
  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<DownloadService>(
    () => DownloadService(db: getIt<AppDatabase>(), dio: getIt<Dio>()),
  );

  // Config — CHỈ dùng URL do user nhập.
  // Nếu chưa có nguồn → MasterConfig.empty() (player-only mode), KHÔNG throw.
  final configService = ConfigService(
    db: getIt<AppDatabase>(),
    dio: getIt<Dio>(),
  );
  getIt.registerSingleton<ConfigService>(configService);
  final masterConfig = await configService.load();
  getIt.registerSingleton<MasterConfig>(masterConfig);

  await _registerSources(masterConfig);
}

Future<void> _registerSources(MasterConfig masterConfig) async {
  // Create datasources for all enabled sources (có thể rỗng).
  // Nguồn web dùng WebScraperDataSource, nguồn api dùng RemoteDataSource.
  final datasources = <String, RemoteDataSource>{};
  for (final source in masterConfig.enabledSources) {
    final dioForSource = Dio(
      BaseOptions(baseUrl: source.baseUrl, headers: source.headers),
    );
    datasources[source.id] = source.isWeb
        ? WebScraperDataSource(dio: dioForSource, source: source)
        : RemoteDataSource(dio: dioForSource, source: source);
  }
  if (getIt.isRegistered<Map<String, RemoteDataSource>>()) {
    getIt.unregister<Map<String, RemoteDataSource>>();
  }
  getIt.registerSingleton<Map<String, RemoteDataSource>>(datasources);

  // Primary datasource — ưu tiên nguồn user đang chọn trên top bar,
  // nullable khi chưa có nguồn.
  SourceConfig? primarySource;
  try {
    final activeId = await getIt<ConfigService>().getActiveSourceId();
    final enabled = masterConfig.enabledSources;
    if (activeId != null) {
      primarySource = enabled.where((s) => s.id == activeId).firstOrNull;
    }
    primarySource ??= masterConfig.enabledSource;
  } catch (_) {
    primarySource = masterConfig.enabledSource;
  }
  if (getIt.isRegistered<RemoteDataSource>()) {
    getIt.unregister<RemoteDataSource>();
  }
  if (primarySource != null && datasources.containsKey(primarySource.id)) {
    getIt.registerSingleton<RemoteDataSource>(
      datasources[primarySource.id]!,
    );
  }

  // Repository — luôn đăng ký, kể cả khi chưa có nguồn.
  // Các call sẽ throw NoSourceConfiguredException để UI hiển thị
  // placeholder player-only.
  if (getIt.isRegistered<MovieRepository>()) {
    getIt.unregister<MovieRepository>();
  }
  getIt.registerSingleton<MovieRepository>(
    MovieRepositoryImpl(
      primary: primarySource != null ? datasources[primarySource.id] : null,
      allDatasources: datasources,
    ),
  );

  if (getIt.isRegistered<MasterConfig>()) {
    getIt.unregister<MasterConfig>();
  }
  getIt.registerSingleton<MasterConfig>(masterConfig);
}

/// Gọi sau khi user thêm/xóa nguồn trong Settings để rebuild DI
/// mà không cần restart app.
Future<void> refreshSources() async {
  final configService = getIt<ConfigService>();
  final masterConfig = await configService.load();
  await _registerSources(masterConfig);
}

/// Helper cho UI: true khi đã có ít nhất 1 nguồn do user nhập.
bool hasConfiguredSource() {
  if (!getIt.isRegistered<MasterConfig>()) return false;
  return getIt<MasterConfig>().hasSource;
}
