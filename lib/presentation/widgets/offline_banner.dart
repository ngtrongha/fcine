import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/movie_providers.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineAsync = ref.watch(configOfflineBannerProvider);
    return offlineAsync.when(
      data: (isOffline) {
        if (!isOffline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: Colors.amber.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, size: 16, color: Colors.black),
              const SizedBox(width: 8),
              const Expanded(child: Text('Đang dùng dữ liệu ngoại tuyến (cache)', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600))),
              TextButton(onPressed: () => ref.invalidate(masterConfigProvider), child: const Text('Thử lại', style: TextStyle(color: Colors.black, fontSize: 12))),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
