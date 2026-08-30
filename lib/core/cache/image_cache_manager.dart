import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FImageCacheManager {
  static const key = 'fCineImageCache';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 300, // ~100MB nếu mỗi ảnh ~300KB trung bình
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
