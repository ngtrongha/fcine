import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/cache/image_cache_manager.dart';

class MovieCard extends StatelessWidget {
  final String posterUrl;
  final String name;
  final int year;
  final String? quality;
  final VoidCallback onTap;
  final double? progress; // 0..1 for continue watching

  const MovieCard({
    super.key,
    required this.posterUrl,
    required this.name,
    required this.year,
    this.quality,
    required this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    cacheManager: FImageCacheManager.instance,
                    imageUrl: posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.white10),
                    errorWidget: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.broken_image, color: Colors.white38)),
                  ),
                ),
                if (quality != null && quality!.isNotEmpty)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                      child: Text(quality!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                if (progress != null && progress! > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                      child: LinearProgressIndicator(value: progress, minHeight: 3, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.redAccent)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text('$year${quality != null ? " • $quality" : ""}', style: const TextStyle(fontSize: 10, color: Colors.white60)),
        ],
      ),
    );
  }
}
