import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/cache/image_cache_manager.dart';
import '../providers/movie_providers.dart';
import '../providers/local_providers.dart';
import '../providers/download_providers.dart';

class DetailPage extends ConsumerWidget {
  final String slug;
  const DetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(movieDetailProvider(slug));
    final isBookmarkedAsync = ref.watch(isBookmarkedProvider(slug));
    return Scaffold(
      appBar: AppBar(title: Text(slug), actions: [
        detailAsync.when(
          data: (data) {
            final movie = data.movie;
            final isMarked = isBookmarkedAsync.value ?? false;
            return IconButton(
              icon: Icon(isMarked ? Icons.bookmark : Icons.bookmark_border, color: isMarked ? Colors.amber : Colors.white),
              onPressed: () async {
                final repo = ref.read(bookmarkRepositoryProvider);
                await repo.toggleBookmark(movieSlug: movie.slug, movieName: movie.name, posterUrl: movie.posterUrl, year: movie.year);
                ref.invalidate(isBookmarkedProvider(slug));
                ref.invalidate(bookmarksStreamProvider);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isMarked ? 'Đã xóa khỏi yêu thích' : 'Đã thêm vào yêu thích')));
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        )
      ]),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi chi tiết: $e')),
        data: (data) {
          final movie = data.movie;
          final servers = data.servers as List;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: movie.posterUrl, width: double.infinity, height: 380, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(height: 380, color: Colors.white10)),
                    Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.85)])))),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movie.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(movie.originName, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(spacing: 6, children: [
                        Chip(label: Text('${movie.year}')),
                        if (movie.quality != null) Chip(label: Text(movie.quality!)),
                        if (movie.lang != null) Chip(label: Text(movie.lang!)),
                        Chip(label: Text(movie.type ?? '')),
                      ]),
                      const SizedBox(height: 12),
                      if (movie.content != null) Text(movie.content!.replaceAll(RegExp(r'<[^>]*>'), '').trim(), style: const TextStyle(color: Colors.white70, height: 1.5)),
                      const SizedBox(height: 16),
                      Text('Diễn viên: ${movie.actors.join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      Text('Đạo diễn: ${movie.directors.join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      const SizedBox(height: 8),
                      Text('Thể loại: ${movie.categories.map((c) => c.name).join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      Text('Quốc gia: ${movie.countries.map((c) => c.name).join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      const SizedBox(height: 20),
                      const Text('Danh sách tập / Server', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      for (final s in servers) ...[
                        Row(children: [Icon(Icons.play_circle_fill, size: 16, color: const Color(0xFFE50914)), const SizedBox(width: 6), Text(s.serverName, style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.w600))]),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final ep in s.episodes)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ActionChip(
                                    label: Text(ep.name),
                                    backgroundColor: Colors.white10,
                                    labelStyle: const TextStyle(color: Colors.white),
                                    onPressed: () {
                                      final historyRepo = ref.read(historyRepositoryProvider);
                                      historyRepo.saveProgress(movieSlug: movie.slug, movieName: movie.name, posterUrl: movie.posterUrl, episodeName: ep.name, episodeSlug: ep.slug, serverName: s.serverName, positionMs: 0, durationMs: 0);
                                      context.push('/player', extra: {
                                        'movie': movie,
                                        'episode': ep,
                                        'serverName': s.serverName,
                                        'servers': servers,
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  Consumer(builder: (context, ref, _) {
                                    final dlAsync = ref.watch(downloadsStreamProvider);
                                    final dl = dlAsync.value?.where((d) => d.movieSlug == movie.slug && d.episodeSlug == ep.slug && d.serverName == s.serverName).firstOrNull;
                                    final isCompleted = dl?.status == 'completed';
                                    final isDownloading = dl?.status == 'downloading';
                                    return IconButton(
                                      icon: Icon(isCompleted ? Icons.check_circle : isDownloading ? Icons.downloading : Icons.download, size: 18, color: isCompleted ? Colors.green : isDownloading ? Colors.amber : Colors.white54),
                                      tooltip: isCompleted ? 'Đã tải - nhấn để xóa' : isDownloading ? '${dl?.progress ?? 0}%' : 'Tải xuống',
                                      onPressed: () async {
                                        if (isCompleted) {
                                          final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Xóa bản tải?'), content: Text('${movie.name} - ${ep.name}'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa'))]));
                                          if (ok == true) {
                                            await ref.read(downloadServiceProvider).deleteDownload(dl!);
                                          }
                                          return;
                                        }
                                        if (isDownloading) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đang tải ${dl?.progress ?? 0}%')));
                                          return;
                                        }
                                        final service = ref.read(downloadServiceProvider);
                                        await service.startDownload(movieSlug: movie.slug, movieName: movie.name, posterUrl: movie.posterUrl, episodeName: ep.name, episodeSlug: ep.slug, serverName: s.serverName, remoteM3u8: ep.linkM3u8);
                                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${ep.name} vào hàng đợi tải')));
                                      },
                                    );
                                  }),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 12),
                      // Gợi ý liên quan (A)
                      if (movie.categories.isNotEmpty) _RelatedRow(movie: movie),
                      const SizedBox(height: 12),
                      Wrap(spacing: 12, children: [
                        TextButton.icon(
                          onPressed: () {
                            final first = servers.isNotEmpty && servers.first.episodes.isNotEmpty ? servers.first.episodes.first : null;
                            if (first != null) {
                              showDialog(context: context, builder: (_) => AlertDialog(title: Text(first.name), content: SelectableText('m3u8:\n${first.linkM3u8}\n\nembed:\n${first.linkEmbed}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))]));
                            }
                          },
                          icon: const Icon(Icons.link, size: 16),
                          label: const Text('Xem link m3u8'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            // ignore: avoid_print
                            print('[REPORT] Detail broken: ${movie.slug}');
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi báo cáo - sẽ thử domain dự phòng')));
                          },
                          icon: const Icon(Icons.bug_report, size: 16, color: Colors.amber),
                          label: const Text('Báo lỗi link', style: TextStyle(color: Colors.amber)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RelatedRow extends ConsumerWidget {
  final dynamic movie;
  const _RelatedRow({required this.movie});

  String _mapType(String? t) {
    switch (t) {
      case 'single':
        return 'phim-le';
      case 'series':
        return 'phim-bo';
      case 'hoathinh':
        return 'hoat-hinh';
      case 'tv':
        return 'tv-shows';
      default:
        return 'phim-le';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = _mapType(movie.type);
    final relatedAsync = ref.watch(listByTypeProvider((type: type, page: 1)));
    return relatedAsync.when(
      loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
      data: (res) {
        final list = (res.movies as List).where((m) => m.slug != movie.slug).take(10).toList();
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phim tương tự', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final m = list[i];
                  return GestureDetector(
                    onTap: () => context.push('/movie/${m.slug}'),
                    child: SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                cacheManager: FImageCacheManager.instance,
                                imageUrl: m.posterUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorWidget: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.broken_image, size: 20)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          Text('${m.year}', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
