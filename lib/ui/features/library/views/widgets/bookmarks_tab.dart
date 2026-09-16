import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/cache/image_cache_manager.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../presentation/router/movie_route.dart';

class BookmarksTab extends StatelessWidget {
  final List<Bookmark> items;
  const BookmarksTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Chưa có phim yêu thích', style: TextStyle(color: Color(0xFF94A3B8))));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final b = items[i];
        return GestureDetector(
          onTap: () => context.push(movieDetailPath(b.movieSlug, b.sourceId)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: b.posterUrl != null ? CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: b.posterUrl!, fit: BoxFit.cover, width: double.infinity) : Container(color: const Color(0xFF1A2130)))),
            const SizedBox(height: 6),
            Text(b.movieName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        );
      },
    );
  }
}
