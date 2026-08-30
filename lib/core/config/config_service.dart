import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import 'master_config.dart';

class ConfigService {
  final AppDatabase db;
  final Dio dio;
  // URL remote Master Config - thay bằng Gist/R2 của bạn khi deploy
  // Để dev, mặc định dùng assets nếu không set
  final String? remoteUrl;

  ConfigService({required this.db, required this.dio, this.remoteUrl});

  Future<MasterConfig> load() async {
    // 1. Thử tải remote nếu có remoteUrl
    if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      try {
        final res = await dio.get(remoteUrl!, options: Options(headers: {'accept': 'application/json'}));
        if (res.statusCode == 200 && res.data != null) {
          final String jsonStr = res.data is String ? res.data as String : jsonEncode(res.data);
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          final config = MasterConfig.fromJson(map);
          // lưu cache
          await db.saveConfig(jsonStr, config.version);
          return config;
        }
      } catch (_) {
        // fall through to cache
      }
    }

    // 2. Thử cache Drift
    try {
      final cached = await db.getLatestConfig();
      if (cached != null) {
        final map = jsonDecode(cached.json) as Map<String, dynamic>;
        return MasterConfig.fromJson(map);
      }
    } catch (_) {}

    // 3. Fallback assets
    final jsonStr = await rootBundle.loadString('assets/config/master_config.sample.json');
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final config = MasterConfig.fromJson(map);
    // lưu vào cache để lần sau có
    try {
      await db.saveConfig(jsonStr, config.version);
    } catch (_) {}
    return config;
  }

  Future<bool> isOfflineFallbackUsed() async {
    if (remoteUrl == null) return false;
    try {
      final res = await dio.get(remoteUrl!, options: Options(sendTimeout: const Duration(seconds: 3), receiveTimeout: const Duration(seconds: 3)));
      return res.statusCode != 200;
    } catch (_) {
      return true;
    }
  }
}
