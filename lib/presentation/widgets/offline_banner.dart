import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import '../../core/config/config_service.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});
  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final svc = getIt<ConfigService>();
      final v = await svc.isOfflineFallbackUsed();
      if (mounted) setState(() { _isOffline = v; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_isOffline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.amber.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Colors.black),
          const SizedBox(width: 8),
          const Expanded(child: Text('Đang dùng dữ liệu ngoại tuyến (cache)', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () async {
              setState(() => _loading = true);
              await getIt<ConfigService>().load();
              _check();
            },
            child: const Text('Thử lại', style: TextStyle(color: Colors.black, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
