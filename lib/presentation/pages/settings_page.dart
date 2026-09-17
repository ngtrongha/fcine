import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/cache/image_cache_manager.dart';
import '../../core/scraper/web_probe.dart';
import '../../core/config/master_config.dart';
import '../../core/config/config_service.dart';
import '../../core/config/source_templates.dart';
import '../../core/di/injection.dart';
import '../../core/toast/app_toast.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../data/datasources/web_scraper_datasource.dart';

/// Cài đặt — user TỰ NHẬP url nguồn, không có giá trị tự động điền sẵn.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _configUrlController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _baseNameController = TextEditingController();
  final _webUrlController = TextEditingController();
  final _webNameController = TextEditingController();
  String _webPreset = 'auto';

  MasterConfig? _config;
  String? _savedConfigUrl;
  bool _loading = true;
  bool _savingConfigUrl = false;
  bool _savingBaseUrl = false;
  bool _savingWeb = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final svc = getIt<ConfigService>();
      final cfg = await svc.load();
      final url = await svc.getUserConfigUrl();
      if (!mounted) return;
      setState(() {
        _config = cfg;
        _savedConfigUrl = url;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveConfigUrl() async {
    final url = _configUrlController.text.trim();
    if (url.isEmpty) {
      AppToast.show(context, message: 'Vui lòng nhập URL file cấu hình', type: ToastType.warning);
      return;
    }
    setState(() => _savingConfigUrl = true);
    try {
      final cfg = await getIt<ConfigService>().saveConfigUrl(url);
      await refreshSources();
      _configUrlController.clear();
      if (!mounted) return;
      setState(() {
        _config = cfg;
        _savedConfigUrl = url;
      });
      AppToast.show(context, message: 'Đã lưu ${cfg.sources.length} nguồn phim', type: ToastType.success);
      await _reload();
      // Có nguồn mới -> mở chế độ ứng dụng xem phim (tab Online).
      if (mounted && cfg.hasSource) context.go('/home');
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: 'Lưu thất bại: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _savingConfigUrl = false);
    }
  }

  Future<void> _saveBaseUrl() async {
    final url = _baseUrlController.text.trim();
    final err = SourceTemplates.validateSourceUrl(url);
    if (err != null) {
      AppToast.show(context, message: err, type: ToastType.warning);
      return;
    }
    setState(() => _savingBaseUrl = true);
    try {
      final source = SourceTemplates.kkphimCompatible(
        baseUrl: url,
        name: _baseNameController.text.trim().isEmpty
            ? null
            : _baseNameController.text.trim(),
      );
      // Probe: API JSON thật (phimapi.com/KKPhim) mới trả items.
      // Web HTML như motchilltv.zip sẽ trả rỗng -> chặn, gợi ý thêm ở mục Web.
      try {
        final probe = RemoteDataSource(
          dio: Dio(BaseOptions(baseUrl: source.baseUrl, headers: source.headers)),
          source: source,
        );
        final res = await probe
            .getLatest(page: 1)
            .timeout(const Duration(seconds: 25));
        if (res.movies.isEmpty) {
          throw Exception(
            'Nguồn không trả danh sách JSON. '
            'Nếu là web phim (vd motchilltv.zip), hãy thêm ở mục '
            '"Web phim bất kỳ" preset DooPlay, không phải mục API.',
          );
        }
      } catch (e) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        // Dio trả HTML thay vì JSON cũng rớt vào đây.
        if (msg.contains('Web phim bất kỳ')) rethrow;
        throw Exception(
          'Không lấy được danh sách API ($msg). '
          'Nếu là web phim (vd motchilltv.zip), hãy thêm ở mục '
          '"Web phim bất kỳ" preset DooPlay.',
        );
      }
      final cfg = await getIt<ConfigService>().saveBaseUrl(
        url,
        name: _baseNameController.text.trim().isEmpty ? null : _baseNameController.text.trim(),
      );
      await refreshSources();
      _baseUrlController.clear();
      _baseNameController.clear();
      if (!mounted) return;
      setState(() => _config = cfg);
      AppToast.show(context, message: 'Đã thêm nguồn phim', type: ToastType.success);
      await _reload();
      // Có nguồn mới -> mở chế độ ứng dụng xem phim (tab Online).
      if (mounted && cfg.hasSource) context.go('/home');
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: 'Thêm thất bại: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _savingBaseUrl = false);
    }
  }

  /// Thêm web phim bất kỳ: engine tự dò (nhiều đường dẫn × preset,
  /// sitemap) rồi lưu cấu hình thắng. Không gắn cứng theo từng site.
  Future<void> _saveWebSource() async {
    final url = _webUrlController.text.trim();
    final err = SourceTemplates.validateWebUrl(url);
    if (err != null) {
      AppToast.show(context, message: err, type: ToastType.warning);
      return;
    }
    final name = _webNameController.text.trim().isEmpty
        ? null
        : _webNameController.text.trim();
    setState(() => _savingWeb = true);
    try {
      final found = await WebProbe.probe(
        baseUrl: url,
        name: name,
        hint: _webPreset,
      ).timeout(
        const Duration(seconds: 120),
        onTimeout: () => throw TimeoutException(
          'Web phản hồi quá chậm, thử lại sau.',
        ),
      );
      if (!mounted) return;
      // Xem trước phim mẫu trước khi lưu — Hủy thì không lưu nguồn.
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => _WebSourcePreviewDialog(result: found),
      );
      if (confirmed != true || !mounted) return;
      final cfg = await getIt<ConfigService>().saveWebSource(found.source);
      await refreshSources();
      _webUrlController.clear();
      _webNameController.clear();
      if (!mounted) return;
      setState(() => _config = cfg);
      AppToast.show(
        context,
        message:
            'Đã thêm web ${found.source.name} (${found.sample} phim qua ${found.via})',
        type: ToastType.success,
      );
      await _reload();
      if (mounted && cfg.hasSource) context.go('/home');
    } on WebProbeException catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Thêm web thất bại: ${e.message}',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Thêm web thất bại: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _savingWeb = false);
    }
  }

  Future<void> _removeSource(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: Text('Xóa "$name"?', style: const TextStyle(color: Colors.white)),
        content: const Text('App sẽ về chế độ Player nếu hết nguồn.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final cfg = await getIt<ConfigService>().removeSource(id);
      await refreshSources();
      if (!mounted) return;
      setState(() => _config = cfg);
      AppToast.show(context, message: 'Đã xóa nguồn', type: ToastType.success);
      await _reload();
      // Hết nguồn -> về chế độ Player video (tab Video mặc định).
      if (mounted && !cfg.hasSource) context.go('/');
    } catch (e) {
      if (mounted) AppToast.show(context, message: 'Xóa thất bại: $e', type: ToastType.error);
    }
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: const Text('Xóa toàn bộ nguồn?', style: TextStyle(color: Colors.white)),
        content: const Text('App sẽ thành Player video thuần túy.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Xóa hết')),
        ],
      ),
    );
    if (ok != true) return;
    await getIt<ConfigService>().clearAll();
    await refreshSources();
    await _reload();
    if (mounted) AppToast.show(context, message: 'Đã về chế độ Player video', type: ToastType.info);
    if (mounted) context.go('/');
  }

  Future<void> _clearCache() async {
    await FImageCacheManager.instance.emptyCache();
    await DefaultCacheManager().emptyCache();
    if (mounted) AppToast.show(context, message: 'Đã xóa bộ nhớ đệm ảnh', type: ToastType.success);
  }

  @override
  void dispose() {
    _configUrlController.dispose();
    _baseUrlController.dispose();
    _baseNameController.dispose();
    _webUrlController.dispose();
    _webNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sources = _config?.sources ?? [];
    final hasSource = _config?.hasSource ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Cài Đặt')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('CHẾ ĐỘ HIỆN TẠI'),
                _statusCard(hasSource, sources.length),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.play_circle_rounded),
                    label: const Text('Mở trình phát'),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('NGUỒN PHIM ĐÃ LƯU (${sources.length})'),
                if (sources.isEmpty)
                  _emptySources()
                else
                  ...sources.map(_sourceTile),
                if (sources.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                    label: const Text('Xóa toàn bộ nguồn'),
                  ),
                ],
                const SizedBox(height: 24),
                _sectionTitle('THÊM NGUỒN — NHẬP TAY'),
                _addBaseUrlCard(),
                const SizedBox(height: 12),
                _addWebCard(),
                const SizedBox(height: 12),
                _addConfigUrlCard(),
                const SizedBox(height: 24),
                _sectionTitle('BỘ NHỚ'),
                _cacheCard(),
                const SizedBox(height: 12),
                const Text(
                  'F-Cine v1.0.0 • Không còn URL nguồn mặc định — user tự quản lý',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
      );

  Widget _statusCard(bool hasSource, int count) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: hasSource ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: hasSource ? const Color(0xFF22C55E) : const Color(0xFFF59E0B), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasSource ? 'Online — $count nguồn' : 'Player-only — chưa có nguồn',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  hasSource ? 'Duyệt kho phim online bình thường' : 'App là trình phát video',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySources() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
      child: const Text(
        'Chưa có nguồn nào. Nhập URL API bên dưới (vd: https://phimapi.com) hoặc URL file master_config.json do bạn tự quản lý.',
        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.5),
      ),
    );
  }

  Widget _sourceTile(SourceConfig s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF1E293B))),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: const Color(0xFF1A2130), borderRadius: BorderRadius.circular(8)),
            child: Icon(s.isWeb ? Icons.web_rounded : Icons.cloud_rounded, color: const Color(0xFFE50914), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(s.name.isEmpty ? s.id : s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: s.isWeb ? const Color(0xFF452600) : const Color(0xFF1A2130),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        s.isWeb ? 'WEB' : 'API',
                        style: TextStyle(color: s.isWeb ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                Text(s.baseUrl, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Kiểm tra nguồn',
            icon: const Icon(Icons.bolt_rounded, color: Color(0xFF94A3B8), size: 18),
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => _SourceTestDialog(source: s),
            ),
          ),
          IconButton(
            tooltip: 'Xóa nguồn',
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF94A3B8), size: 18),
            onPressed: () => _removeSource(s.id, s.name.isEmpty ? s.id : s.name),
          ),
        ],
      ),
    );
  }

  Widget _addBaseUrlCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('URL API phim trực tiếp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('VD: https://phimapi.com — app tự dựng cấu hình tương thích.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 10),
          TextField(
            controller: _baseUrlController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(hintText: 'https://...', hintStyle: TextStyle(color: Color(0xFF64748B))),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _baseNameController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(hintText: 'Tên gợi nhớ (tùy chọn)', hintStyle: TextStyle(color: Color(0xFF64748B))),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _savingBaseUrl ? null : _saveBaseUrl,
              icon: _savingBaseUrl
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.add_link_rounded, size: 16),
              label: Text(_savingBaseUrl ? 'Đang thêm...' : 'Thêm nguồn'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addWebCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Web phim bất kỳ (tự băm)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('VD: https://motchilltv.zip, https://www.rophim.ad — app tự dò cấu hình bóc được.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 10),
          TextField(
            controller: _webUrlController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(hintText: 'https://web-phim...', hintStyle: TextStyle(color: Color(0xFF64748B))),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _webNameController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(hintText: 'Tên gợi nhớ (tùy chọn)', hintStyle: TextStyle(color: Color(0xFF64748B))),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _webPreset,
            isExpanded: true,
            dropdownColor: const Color(0xFF1A2130),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(hintStyle: TextStyle(color: Color(0xFF64748B))),
            items: const [
              DropdownMenuItem(value: 'auto', child: Text('Tự động (khuyến nghị)')),
              DropdownMenuItem(value: 'dooplay', child: Text('WordPress DooPlay (MotChill...)')),
              DropdownMenuItem(value: 'generic', child: Text('Web thường (tự đoán markup)')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _webPreset = v);
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _savingWeb ? null : _saveWebSource,
              icon: _savingWeb
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.web_rounded, size: 16),
              label: Text(_savingWeb ? 'Đang băm thử...' : 'Băm thử & thêm web'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addConfigUrlCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('URL file master_config.json', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            _savedConfigUrl == null ? 'Chưa lưu URL nào — hãy dán URL do bạn quản lý.' : 'Đang dùng: $_savedConfigUrl',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _configUrlController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(hintText: 'https://.../master_config.json', hintStyle: TextStyle(color: Color(0xFF64748B))),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _savingConfigUrl ? null : _saveConfigUrl,
              icon: _savingConfigUrl
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cloud_download_outlined, size: 16),
              label: Text(_savingConfigUrl ? 'Đang tải...' : 'Tải & lưu cấu hình'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cacheCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
      child: Row(
        children: [
          const Icon(Icons.image_rounded, color: Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          const Expanded(child: Text('Bộ nhớ đệm ảnh', style: TextStyle(color: Colors.white, fontSize: 13))),
          OutlinedButton(onPressed: _clearCache, child: const Text('Xóa')),
        ],
      ),
    );
  }
}

/// Dialog chẩn đoán nguồn theo từng bước: danh sách -> chi tiết -> link phát.
class _SourceTestDialog extends StatefulWidget {
  final SourceConfig source;
  const _SourceTestDialog({required this.source});

  @override
  State<_SourceTestDialog> createState() => _SourceTestDialogState();
}

class _SourceTestDialogState extends State<_SourceTestDialog> {
  final List<String> _lines = [];
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  void _log(String line) {
    if (mounted) setState(() => _lines.add(line));
  }

  Future<void> _run() async {
    final s = widget.source;
    _log('Nguồn: ${s.name.isEmpty ? s.id : s.name} (${s.isWeb ? 'WEB' : 'API'})');
    dynamic ds;
    try {
      ds = s.isWeb
          ? WebScraperDataSource(
              dio: Dio(BaseOptions(baseUrl: s.baseUrl, headers: s.headers)),
              source: s,
            )
          : RemoteDataSource(
              dio: Dio(BaseOptions(baseUrl: s.baseUrl, headers: s.headers)),
              source: s,
            );
    } catch (e) {
      _log('Lỗi dựng nguồn: $e');
      if (mounted) setState(() => _done = true);
      return;
    }
    // B1: danh sách.
    dynamic first;
    try {
      final latest = await (ds.getLatest(page: 1) as Future)
          .timeout(const Duration(seconds: 25));
      final movies = (latest as dynamic).movies as List;
      if (movies.isEmpty) {
        if (!s.isWeb) {
          _log('B1 danh sách: Lỗi (rỗng) — nguồn đang là API mà web này trả HTML.');
          _log('Gợi ý: Xóa nguồn này, thêm lại ở "Web phim bất kỳ" preset DooPlay.');
        } else {
          _log('B1 danh sách: Lỗi (rỗng)');
        }
      } else {
        first = movies.first;
        _log('B1 danh sách: OK (${movies.length} phim)');
      }
    } catch (e) {
      if (!s.isWeb) {
        _log('B1 danh sách: Lỗi $e');
        _log('Gợi ý: nếu là motchilltv.zip, đó là WEB không phải API — thêm lại ở "Web phim bất kỳ".');
      } else {
        _log('B1 danh sách: Lỗi $e');
      }
    }
    if (first == null) {
      if (mounted) setState(() => _done = true);
      return;
    }
    // B2: chi tiết + B3: link phát.
    try {
      final detail = await (ds.getDetail(first.slug as String) as Future)
          .timeout(const Duration(seconds: 30));
      final movie = (detail as dynamic).movie;
      final servers = ((detail as dynamic).servers as List);
      var epCount = 0;
      for (final sv in servers) {
        epCount += ((sv as dynamic).episodes as List).length;
      }
      _log('B2 chi tiết: OK (${movie.name}, $epCount tập, ${servers.length} server)');
      dynamic targetEp;
      String targetServer = '';
      for (final sv in servers) {
        for (final ep in ((sv as dynamic).episodes as List)) {
          final url = ((ep as dynamic).linkM3u8 as String?) ?? '';
          if (url.isNotEmpty) {
            _log('B3 link phát: OK trực tiếp (${sv.serverName}/${ep.name})');
            if (mounted) setState(() => _done = true);
            return;
          }
          targetEp ??= ep;
          if (targetServer.isEmpty) targetServer = (sv.serverName as String?) ?? '';
        }
      }
      if (ds is WebScraperDataSource && targetEp != null) {
        try {
          final r = await ds
              .resolveStream(
                (targetEp.slug as String?) ?? '',
                serverName: targetServer,
              )
              .timeout(const Duration(seconds: 30));
          if ((r.m3u8 ?? '').isNotEmpty) {
            _log('B3 link phát: OK m3u8 ($targetServer)');
          } else if ((r.embed ?? '').isNotEmpty) {
            _log('B3 link phát: OK embed ($targetServer)');
          } else {
            _log('B3 link phát: Lỗi (rỗng)');
          }
        } catch (e) {
          _log('B3 link phát: Lỗi $e');
        }
      } else {
        _log('B3 link phát: Lỗi (tập không có link)');
      }
    } catch (e) {
      _log('B2 chi tiết: Lỗi $e');
    }
    if (mounted) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111622),
      title: const Text('Kiểm tra nguồn', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._lines.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(l, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
              ),
            ),
            if (!_done)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _done ? () => Navigator.pop(context) : null,
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}

/// Xem trước phim mẫu trước khi lưu nguồn web — poster + tên, grid nhỏ.
class _WebSourcePreviewDialog extends StatelessWidget {
  final WebProbeResult result;

  const _WebSourcePreviewDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final s = result.source;
    final movies = result.movies;
    return AlertDialog(
      backgroundColor: const Color(0xFF111622),
      title: const Text(
        'Xem trước nguồn',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${s.name.isEmpty ? s.id : s.name} • ${s.baseUrl}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Dò qua: ${result.via} — ${result.sample} phim',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (movies.isEmpty)
              const Text(
                'Không có phim mẫu để hiển thị. Vẫn có thể lưu nếu bạn muốn.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              )
            else
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: movies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.55,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, i) {
                    final m = movies[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: m.posterUrl.isEmpty
                                ? Container(
                                    color: const Color(0xFF1A2130),
                                    child: const Icon(Icons.movie_rounded, color: Color(0xFF64748B)),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: m.posterUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorWidget: (_, _, _) => Container(
                                      color: const Color(0xFF1A2130),
                                      child: const Icon(Icons.movie_rounded, color: Color(0xFF64748B)),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.name,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.check_rounded, size: 16),
          label: const Text('Lưu nguồn'),
        ),
      ],
    );
  }
}
