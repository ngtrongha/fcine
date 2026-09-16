import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import 'master_config.dart';
import 'source_templates.dart';

/// Quản lý nguồn phim do USER tự nhập.
///
/// Nguyên tắc mới (theo yêu cầu):
/// - KHÔNG tự động điền URL nguồn, KHÔNG fallback assets có sẵn URL.
/// - App khởi động với config rỗng (sources = []) cho tới khi user nhập.
/// - Khi chưa có nguồn: app hoạt động như 1 phần mềm player video thuần túy.
/// - URL nguồn do user nhập được lưu ở SharedPreferences + Drift cache.
class ConfigService {
  final AppDatabase db;
  final Dio dio;

  static const String kUserConfigUrlKey = 'fcine_user_config_url';
  static const String kUserConfigJsonKey = 'fcine_user_config_json';
  static const String kUserConfiguredKey = 'fcine_user_configured';
  static const String kActiveSourceIdKey = 'fcine_active_source_id';

  ConfigService({required this.db, required this.dio});

  /// Tải config theo thứ tự:
  /// 1. Remote URL do user nhập (nếu có) → lưu cache rồi trả về.
  /// 2. JSON do user lưu trong SharedPreferences.
  /// 3. Drift cache (chỉ khi user đã từng cấu hình — để loại bỏ cache
  ///    mẫu cũ tự động đi kèm app).
  /// 4. Config rỗng (player-only mode).
  Future<MasterConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userUrl = prefs.getString(kUserConfigUrlKey)?.trim() ?? '';
    final configured = prefs.getBool(kUserConfiguredKey) ?? false;

    // 1. Remote do user nhập
    if (userUrl.isNotEmpty) {
      try {
        final config = await fetchFromUrl(userUrl);
        await _persist(config, prefs, userUrl: userUrl);
        return config;
      } catch (_) {
        // rớt xuống cache bên dưới
      }
    }

    // 2. JSON user đã lưu
    try {
      final savedJson = prefs.getString(kUserConfigJsonKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final map = jsonDecode(savedJson) as Map<String, dynamic>;
        final config = MasterConfig.fromJson(map);
        if (config.hasSource) return config;
      }
    } catch (_) {}

    // 3. Drift cache — chỉ dùng khi user đã từng cấu hình.
    // Điều này đảm bảo gỡ bỏ hoàn toàn fallback tự động từ assets mẫu.
    if (configured) {
      try {
        final cached = await db.getLatestConfig();
        if (cached != null) {
          final map = jsonDecode(cached.json) as Map<String, dynamic>;
          final config = MasterConfig.fromJson(map);
          if (config.hasSource) return config;
        }
      } catch (_) {}
    }

    // 4. Chưa có nguồn → player-only mode
    return MasterConfig.empty();
  }

  /// Tải + validate master_config.json từ URL do user nhập.
  Future<MasterConfig> fetchFromUrl(String url) async {
    final normalized = url.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('URL cấu hình trống');
    }
    final res = await dio.get(
      normalized,
      options: Options(headers: {'accept': 'application/json'}),
    );
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Tải cấu hình thất bại (${res.statusCode})',
      );
    }
    final String jsonStr =
        res.data is String ? res.data as String : jsonEncode(res.data);
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final config = MasterConfig.fromJson(map);
    if (!config.hasSource) {
      throw FormatException('File cấu hình không chứa nguồn phim nào khả dụng');
    }
    return config;
  }

  /// User nhập URL file master_config.json → tải, lưu, trả về config.
  Future<MasterConfig> saveConfigUrl(String url) async {
    final err = SourceTemplates.validateConfigUrl(url);
    if (err != null) throw ArgumentError(err);
    final config = await fetchFromUrl(url.trim());
    final prefs = await SharedPreferences.getInstance();
    await _persist(config, prefs, userUrl: url.trim());
    return config;
  }

  /// User nhập trực tiếp baseUrl API (vd https://phimapi.com).
  /// App dựng 1 SourceConfig tương thích KKPhim từ template.
  Future<MasterConfig> saveBaseUrl(String baseUrl, {String? name}) async {
    final err = SourceTemplates.validateSourceUrl(baseUrl);
    if (err != null) throw ArgumentError(err);
    final source = SourceTemplates.kkphimCompatible(
      baseUrl: baseUrl.trim(),
      name: (name ?? '').trim().isEmpty ? null : name!.trim(),
    );

    // Giữ lại các nguồn user đã có (nếu có), thay thế nếu trùng id/baseUrl.
    final prefs = await SharedPreferences.getInstance();
    MasterConfig current;
    try {
      current = await load();
    } catch (_) {
      current = MasterConfig.empty();
    }
    final others = current.sources
        .where((s) => s.baseUrl != source.baseUrl && s.id != source.id)
        .toList();
    final merged = MasterConfig(
      version: current.version + 1,
      updatedAt: DateTime.now(),
      sources: [...others, source],
      settings: current.settings,
    );
    await _persist(merged, prefs, keepUrl: true);
    return merged;
  }

  /// User thêm nguồn web (băm HTML) đã dựng sẵn từ preset.
  /// Merge vào danh sách hiện có (thay thế nếu trùng id/baseUrl).
  Future<MasterConfig> saveWebSource(SourceConfig source) async {
    if (!source.isWeb) throw ArgumentError('Không phải nguồn web');
    final err = SourceTemplates.validateWebUrl(source.baseUrl);
    if (err != null) throw ArgumentError(err);
    final prefs = await SharedPreferences.getInstance();
    MasterConfig current;
    try {
      current = await load();
    } catch (_) {
      current = MasterConfig.empty();
    }
    final others = current.sources
        .where((s) => s.baseUrl != source.baseUrl && s.id != source.id)
        .toList();
    final merged = MasterConfig(
      version: current.version + 1,
      updatedAt: DateTime.now(),
      sources: [...others, source],
      settings: current.settings,
    );
    await _persist(merged, prefs, keepUrl: true);
    return merged;
  }

  /// User dán trực tiếp nội dung JSON master_config.
  Future<MasterConfig> saveMasterJson(String jsonStr) async {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final config = MasterConfig.fromJson(map);
    if (!config.hasSource) {
      throw FormatException('JSON không chứa nguồn phim nào khả dụng');
    }
    final prefs = await SharedPreferences.getInstance();
    await _persist(config, prefs, keepUrl: true, rawJson: jsonStr);
    return config;
  }

  /// Xóa 1 nguồn theo id.
  Future<MasterConfig> removeSource(String sourceId) async {
    final prefs = await SharedPreferences.getInstance();
    MasterConfig current;
    try {
      current = await load();
    } catch (_) {
      current = MasterConfig.empty();
    }
    final remaining =
        current.sources.where((s) => s.id != sourceId).toList();
    // Xóa luôn lựa chọn đang dùng nếu nguồn đó bị gỡ.
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(kActiveSourceIdKey) == sourceId) {
        await prefs.remove(kActiveSourceIdKey);
      }
    } catch (_) {}
    final next = MasterConfig(
      version: current.version + 1,
      updatedAt: DateTime.now(),
      sources: remaining,
      settings: current.settings,
    );
    if (remaining.isEmpty) {
      // Hết nguồn → về player-only, nhưng vẫn giữ cờ để user thêm lại dễ dàng.
      // Xóa hẳn URL + JSON để đảm bảo không còn fallback tự động.
      await prefs.remove(kUserConfigUrlKey);
      await prefs.remove(kUserConfigJsonKey);
      await prefs.setBool(kUserConfiguredKey, false);
      try {
        await db.clearConfigCache();
      } catch (_) {}
      return MasterConfig.empty();
    }
    await _persist(next, prefs, keepUrl: true);
    return next;
  }

  /// Xóa toàn bộ cấu hình nguồn → về chế độ player video.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kUserConfigUrlKey);
    await prefs.remove(kUserConfigJsonKey);
    await prefs.remove(kActiveSourceIdKey);
    await prefs.setBool(kUserConfiguredKey, false);
    try {
      await db.clearConfigCache();
    } catch (_) {}
  }

  Future<String?> getUserConfigUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(kUserConfigUrlKey);
    if (v == null || v.trim().isEmpty) return null;
    return v;
  }

  /// Id nguồn đang được chọn để browse (dropdown trên top bar).
  /// null = dùng nguồn enabled đầu tiên. Được DI dùng làm primary.
  Future<String?> getActiveSourceId() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(kActiveSourceIdKey);
    if (v == null || v.trim().isEmpty) return null;
    return v;
  }

  Future<void> setActiveSourceId(String sourceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kActiveSourceIdKey, sourceId);
  }

  Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(kUserConfiguredKey) == true) return true;
    try {
      final cfg = await load();
      return cfg.hasSource;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasSource() async {
    try {
      final cfg = await load();
      return cfg.hasSource;
    } catch (_) {
      return false;
    }
  }

  /// Kiểm tra offline — chỉ có ý nghĩa khi user đã nhập URL.
  /// Trả về false khi chưa có URL (không còn khái niệm fallback tự động).
  Future<bool> isOfflineFallbackUsed() async {
    final prefs = await SharedPreferences.getInstance();
    final userUrl = prefs.getString(kUserConfigUrlKey)?.trim() ?? '';
    if (userUrl.isEmpty) return false;
    try {
      final res = await dio.get(
        userUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      return res.statusCode != 200;
    } catch (_) {
      return true;
    }
  }

  Future<void> _persist(
    MasterConfig config,
    SharedPreferences prefs, {
    String? userUrl,
    bool keepUrl = false,
    String? rawJson,
  }) async {
    final jsonStr = rawJson ?? jsonEncode(config.toJson());
    await prefs.setString(kUserConfigJsonKey, jsonStr);
    await prefs.setBool(kUserConfiguredKey, true);
    if (userUrl != null && userUrl.isNotEmpty) {
      await prefs.setString(kUserConfigUrlKey, userUrl);
    } else if (!keepUrl) {
      // Không đụng tới URL cũ khi keepUrl=true (thêm nguồn baseUrl).
    }
    try {
      await db.saveConfig(jsonStr, config.version);
    } catch (_) {}
  }
}
