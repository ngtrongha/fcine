import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/local_providers.dart';
import '../providers/download_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/cache/image_cache_manager.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});
  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(watchHistoryStreamProvider);
    final bookmarksAsync = ref.watch(bookmarksStreamProvider);
    final downloadsAsync = ref.watch(downloadsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tủ Phim'),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFFE50914),
          tabs: [
            Tab(child: historyAsync.when(data: (l) => Text('Lịch Sử (${l.length})'), loading: () => const Text('Lịch Sử'), error: (_, __) => const Text('Lịch Sử'))),
            Tab(child: bookmarksAsync.when(data: (l) => Text('Yêu Thích (${l.length})'), loading: () => const Text('Yêu Thích'), error: (_, __) => const Text('Yêu Thích'))),
            Tab(child: downloadsAsync.when(data: (l) => Text('Đã Tải (${l.length})'), loading: () => const Text('Đã Tải'), error: (_, __) => const Text('Đã Tải'))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Storage usage card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
            child: downloadsAsync.when(
              data: (list) {
                // rough estimate: assume each download ~400MB if completed
                final usedGb = list.where((d) => d.status == 'completed').length * 0.4;
                return Row(
                  children: [
                    const Icon(Icons.hard_drive_2_rounded, color: Color(0xFFE50914), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Bộ nhớ Offline: ${usedGb.toStringAsFixed(1)} GB / 128 GB', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(value: (usedGb / 128).clamp(0, 1), backgroundColor: const Color(0xFF1E293B), valueColor: const AlwaysStoppedAnimation(Color(0xFFE50914)), minHeight: 6),
                        ),
                      ]),
                    ),
                    TextButton(onPressed: () {}, child: const Text('Quản lý', style: TextStyle(color: Color(0xFFE50914), fontSize: 12))),
                  ],
                );
              },
              loading: () => const SizedBox(height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _HistoryTab(historyAsync: historyAsync),
                _BookmarksTab(bookmarksAsync: bookmarksAsync),
                _DownloadsTab(downloadsAsync: downloadsAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final AsyncValue historyAsync;
  const _HistoryTab({required this.historyAsync});
  String _fmt(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (list) {
        final items = list as List;
        if (items.isEmpty) return const Center(child: Text('Chưa có lịch sử xem', style: TextStyle(color: Color(0xFF94A3B8))));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final h = items[i];
            final progress = h.durationMs > 0 ? (h.positionMs / h.durationMs).clamp(0.0, 1.0) : 0.0;
            return InkWell(
              onTap: () => context.push('/movie/${h.movieSlug}'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: h.posterUrl != null ? CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: h.posterUrl!, width: 72, height: 96, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(width: 72, height: 96, color: const Color(0xFF1A2130))) : Container(width: 72, height: 96, color: const Color(0xFF1A2130))),
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
      },
    );
  }
}

class _BookmarksTab extends StatelessWidget {
  final AsyncValue bookmarksAsync;
  const _BookmarksTab({required this.bookmarksAsync});
  @override
  Widget build(BuildContext context) {
    return bookmarksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (list) {
        final items = list as List;
        if (items.isEmpty) return const Center(child: Text('Chưa có phim yêu thích', style: TextStyle(color: Color(0xFF94A3B8))));
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final b = items[i];
            return GestureDetector(
              onTap: () => context.push('/movie/${b.movieSlug}'),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: b.posterUrl != null ? CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: b.posterUrl!, fit: BoxFit.cover, width: double.infinity) : Container(color: const Color(0xFF1A2130)))),
                const SizedBox(height: 6),
                Text(b.movieName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            );
          },
        );
      },
    );
  }
}

class _DownloadsTab extends StatelessWidget {
  final AsyncValue downloadsAsync;
  const _DownloadsTab({required this.downloadsAsync});
  @override
  Widget build(BuildContext context) {
    return downloadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (list) {
        final items = list as List;
        if (items.isEmpty) return const Center(child: Text('Chưa có bản tải', style: TextStyle(color: Color(0xFF94A3B8))));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final d = items[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
              child: Row(children: [
                Icon(d.status == 'completed' ? Icons.check_circle : Icons.downloading, color: d.status == 'completed' ? Colors.green : Colors.amber),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${d.movieName} - ${d.episodeName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('${d.serverName} • ${d.progress}%', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: d.progress / 100, backgroundColor: const Color(0xFF1E293B), valueColor: AlwaysStoppedAnimation(d.status == 'completed' ? Colors.green : Colors.amber), minHeight: 4)),
                ])),
                const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
              ]),
            );
          },
        );
      },
    );
  }
}
