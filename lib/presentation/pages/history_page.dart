import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/cache/image_cache_manager.dart';
import '../providers/local_providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  String _fmt(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchHistoryStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử xem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Xóa toàn bộ lịch sử?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa'))]));
              if (ok == true) {
                // xóa từng item - drift không có deleteAll, làm loop
                final list = ref.read(watchHistoryStreamProvider).value ?? [];
                final repo = ref.read(historyRepositoryProvider);
                for (final h in list) {
                  await repo.deleteProgress(h.movieSlug, h.episodeSlug, h.serverName);
                }
              }
            },
          )
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('Chưa có lịch sử xem', style: TextStyle(color: Colors.white54)));
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, i) {
              final h = list[i];
              final progress = h.durationMs > 0 ? (h.positionMs / h.durationMs).clamp(0.0, 1.0) : 0.0;
              return Dismissible(
                key: ValueKey('${h.movieSlug}_${h.episodeSlug}_${h.serverName}'),
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) => ref.read(historyRepositoryProvider).deleteProgress(h.movieSlug, h.episodeSlug, h.serverName),
                child: ListTile(
                  leading: ClipRRect(borderRadius: BorderRadius.circular(6), child: h.posterUrl != null ? CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: h.posterUrl!, width: 56, height: 80, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(width: 56, height: 80, color: Colors.white10, child: const Icon(Icons.movie))) : Container(width: 56, height: 80, color: Colors.white10, child: const Icon(Icons.movie))),
                  title: Text(h.movieName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${h.serverName} • ${h.episodeName} • ${_fmt(h.positionMs)} / ${_fmt(h.durationMs)}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: progress, minHeight: 3, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Colors.redAccent)),
                  ]),
                  trailing: const Icon(Icons.play_circle_fill, color: Colors.deepPurpleAccent),
                  onTap: () => context.push('/movie/${h.movieSlug}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
