import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/cache/image_cache_manager.dart';
import '../providers/local_providers.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu thích')),
      body: bookmarksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('Chưa có phim yêu thích\nNhấn bookmark ở trang chi tiết để thêm', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)));
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final b = list[i];
              return GestureDetector(
                onTap: () => context.push('/movie/${b.movieSlug}'),
                onLongPress: () async {
                  final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Xóa yêu thích?'), content: Text(b.movieName), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa'))]));
                  if (ok == true) {
                    final repo = ref.read(bookmarkRepositoryProvider);
                    await repo.remove(b.movieSlug);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: b.posterUrl != null ? CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: b.posterUrl!, fit: BoxFit.cover, width: double.infinity, errorWidget: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.broken_image))) : Container(color: Colors.white10, child: const Icon(Icons.movie)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(b.movieName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('${b.year ?? ""}', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
