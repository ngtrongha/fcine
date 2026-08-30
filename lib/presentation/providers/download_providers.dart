import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/database/database_provider.dart';
import '../../core/download/download_service.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DownloadService(db: db, dio: Dio());
});

final downloadsStreamProvider = StreamProvider((ref) {
  final service = ref.watch(downloadServiceProvider);
  return service.watchAll();
});
