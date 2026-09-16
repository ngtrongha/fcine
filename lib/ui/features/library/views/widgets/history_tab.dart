import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/cache/image_cache_manager.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../presentation/router/movie_route.dart';

class HistoryTab extends StatelessWidget {
  final List<WatchHistoryData> items;
  const HistoryTab({super.key, required this.items});

  String _fmt(int ms) {
    final d = Duration(milliseconds: ms);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Chưa có lịch sử xem', style: TextStyle(color: Color(0xFF94A3B8))));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final h = items[i];
        final progress = h.durationMs > 0 ? (h.positionMs / h.durationMs).clamp(0.0, 1.0) : 0.0;
        return InkWell(
          onTap: () => context.push(movieDetailPath(h.movieSlug, h.sourceId)),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: h.posterUrl != null
                    ? CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: h.posterUrl!, width: 72, height: 96, fit: BoxFit.cover, errorWidget: (_, _, _) => Container(width: 72, height: 96, color: const Color(0xFF1A2130)))
                    : Container(width: 72, height: 96, color: const Color(0xFF1A2130)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(h.movieName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${h.serverName} • ${h.episodeName} • ${_fmt(h.positionMs)} / ${_fmt(h.durationMs)}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFF1E293B), valueColor: const AlwaysStoppedAnimation(Color(0xFFE50914)), minHeight: 4)),
                const SizedBox(height: 4),
                Text('${(progress * 100).toStringAsFixed(0)}% còn lại', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              ])),
              const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFE50914), size: 28),
            ]),
          ),
        );
      },
    );
  }
}
