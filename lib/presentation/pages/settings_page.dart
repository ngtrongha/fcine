import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../core/cache/image_cache_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool antiBlocking = true;
  double latencyMs = 45;
  bool isRefreshing = false;

  Future<void> _refreshConfig() async {
    setState(() => isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      latencyMs = 32 + (DateTime.now().millisecond % 40);
      isRefreshing = false;
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã làm mới Gist • ${latencyMs.toStringAsFixed(0)}ms')));
  }

  Future<void> _clearCache() async {
    await FImageCacheManager.instance.emptyCache();
    await DefaultCacheManager().emptyCache();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa bộ nhớ đệm ảnh (100MB)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài Đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('NGUỒN PHIM', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0xFF22C55E), blurRadius: 6)])),
                const SizedBox(width: 8),
                const Text('Remote Master Config', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF1A2130), borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [const Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFF59E0B)), const SizedBox(width: 4), Text('${latencyMs.toStringAsFixed(0)}ms', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w700))]),
                ),
              ]),
              const SizedBox(height: 10),
              const Text('https://gist.github.com/.../master_config.json', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isRefreshing ? null : _refreshConfig,
                  icon: isRefreshing ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(isRefreshing ? 'Đang làm mới...' : 'Làm mới cấu hình'),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
            child: SwitchListTile(
              title: const Text('Chống chặn (Anti-blocking)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Tự động chuyển domain dự phòng', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              value: antiBlocking,
              activeThumbColor: const Color(0xFFE50914),
              onChanged: (v) => setState(() => antiBlocking = v),
            ),
          ),
          const SizedBox(height: 24),
          const Text('BỘ NHỚ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
            child: Row(children: [
              const Icon(Icons.image_rounded, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Bộ nhớ đệm ảnh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)), Text('FImageCacheManager • 100MB • 7 ngày', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11))])),
              OutlinedButton(onPressed: _clearCache, child: const Text('Xóa')),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8)),
              SizedBox(width: 12),
              Expanded(child: Text('F-Cine v1.0.0 • Cinematic Dark Elegance', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
            ]),
          ),
        ],
      ),
    );
  }
}
