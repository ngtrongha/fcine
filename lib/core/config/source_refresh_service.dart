import 'package:fcine/core/config/config_service.dart';
import 'package:fcine/core/config/master_config.dart';
import 'package:fcine/core/scraper/web_probe.dart';

/// Auto re-probe khi nguồn web liên tục fail: dùng WebProbe dò lại URL hiện tại
/// và cập nhật config. Thực hiện khi nguồn fail liên tục (repository gọi sau
/// mỗi lần fail), không tự động chạy nền (tránh tải quá).
class SourceRefreshService {
  SourceRefreshService(this._cfg);
  final ConfigService _cfg;

  /// Số lần fail tối thiểu để trigger re-probe.
  static const maxFailures = 3;

  /// Khoảng thời gian để periodic re-probe (7 ngày).
  static const probeInterval = Duration(days: 7);

  /// Đếm fail liên tục theo sourceId (session-only, không persist).
  final Map<String, int> _failCount = {};

  /// Gọi sau mỗi lần fail: cập nhật counter, nếu đến ngưỡng thì re-probe.
  /// Trả về MasterConfig mới nếu refresh thành công, null nếu không đổi.
  Future<MasterConfig?> maybeReprobe(String sourceId) async {
    final count = _incFail(sourceId);
    if (count < maxFailures) return null;
    final current = await _getCurrent();
    final target = current.sources.where((s) => s.id == sourceId).firstOrNull;
    if (target == null || !target.isWeb) return null;
    final newCfg = await _reprobe(target);
    if (newCfg != null) {
      _failCount.remove(sourceId); // reset counter khi thành công
    }
    return newCfg;
  }

  /// Reset counter (gọi sau khi source hoạt động bình thường).
  void resetCount(String sourceId) {
    _failCount.remove(sourceId);
  }

  /// Kiểm tra và re-probe các nguồn web cũ hơn [probeInterval] (7 ngày).
  /// Chạy khi app khởi động (background, không block UI).
  Future<void> checkAndReprobeStale() async {
    try {
      final current = await _getCurrent();
      final staleSources = current.sources.where((s) {
        if (!s.isWeb || s.probedAt == null) return false;
        final probed = DateTime.tryParse(s.probedAt!);
        if (probed == null) return false;
        return DateTime.now().difference(probed) > probeInterval;
      }).toList();

      for (final source in staleSources) {
        try {
          await _reprobeAndSave(source);
        } catch (_) {
          // Bỏ qua lỗi từng nguồn, tiếp tục nguồn khác
        }
      }
    } catch (_) {
      // Bỏ qua lỗi chung, không block app start
    }
  }

  /// Re-probe một source và lưu với probedAt = now.
  Future<MasterConfig?> _reprobeAndSave(SourceConfig source) async {
    try {
      final found = await WebProbe.probe(
        baseUrl: source.baseUrl,
        name: source.name.isEmpty ? null : source.name,
        hint: 'auto',
      ).timeout(const Duration(seconds: 30));
      // Cập nhật probedAt = now trước khi lưu
      final updatedSource = found.source.copyWith(
        probedAt: DateTime.now().toIso8601String(),
      );
      return await _cfg.saveWebSource(updatedSource);
    } catch (_) {
      return null;
    }
  }

  Future<MasterConfig> _getCurrent() async {
    try {
      return await _cfg.load();
    } catch (_) {
      return MasterConfig.empty();
    }
  }

  Future<MasterConfig?> _reprobe(SourceConfig source) async {
    try {
      final found = await WebProbe.probe(
        baseUrl: source.baseUrl,
        name: source.name.isEmpty ? null : source.name,
        hint: 'auto',
      ).timeout(const Duration(seconds: 30));
      return await _cfg.saveWebSource(
        found.source.copyWith(
          probedAt: DateTime.now().toIso8601String(),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  int _incFail(String sourceId) {
    final count = _failCount[sourceId] ?? 0;
    final next = count + 1;
    _failCount[sourceId] = next;
    return next;
  }
}