import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/cache/image_cache_manager.dart';
import '../theme/app_theme.dart';
import 'responsive_layout.dart';

class BannerCarousel extends StatefulWidget {
  final List movies;
  final void Function(String slug) onTap;
  final void Function(String slug)? onAddToList;
  const BannerCarousel({
    super.key,
    required this.movies,
    required this.onTap,
    this.onAddToList,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.movies.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!_controller.hasClients) return;
        final next = (_current + 1) % widget.movies.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();
    final display = widget.movies.take(5).toList();
    final isDesktop = context.isDesktop;

    // Desktop: ultra-wide 21:9, Mobile: 16:9
    final aspect = isDesktop ? 21 / 9 : 16 / 9;
    final height = isDesktop ? 520.0 : 220.0;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: display.length,
            itemBuilder: (context, i) {
              final m = display[i];
              final thumb = m.thumbUrl.isNotEmpty ? m.thumbUrl : m.posterUrl;
              final category = m.categories.isNotEmpty
                  ? m.categories.first.name
                  : 'Phim';
              final rating = m.voteAverage?.toStringAsFixed(1);

              return GestureDetector(
                onTap: () => widget.onTap(m.slug),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: aspect,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            cacheManager: FImageCacheManager.instance,
                            imageUrl: thumb,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) =>
                                Container(color: AppColors.surface),
                          ),
                          // Gradients per HTML: from-background via-background/60 to-transparent + side gradient on desktop
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.background.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                          if (isDesktop)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    AppColors.background.withValues(
                                      alpha: 0.55,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          // Content
                          Positioned(
                            left: isDesktop ? 32 : 16,
                            right: isDesktop ? 32 : 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title - HTML: font-black text-2xl / text-5xl
                                Text(
                                  m.name,
                                  maxLines: isDesktop ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isDesktop ? 36 : 20,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isDesktop && m.content != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      m.content!
                                          .replaceAll(RegExp(r'<[^>]*>'), '')
                                          .trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                // Metadata row
                                Row(
                                  children: [
                                    if (rating != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface.withValues(
                                            alpha: 0.85,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 14,
                                              color: Color(0xFFF59E0B),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              rating,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const Text(
                                              ' / 10',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (rating != null)
                                      const SizedBox(width: 8),
                                    Text(
                                      '${m.year}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.10,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Actions - HTML: Xem Ngay (primary) + Danh Sách (glass)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => widget.onTap(m.slug),
                                        icon: const Icon(
                                          Icons.play_arrow_rounded,
                                          size: 18,
                                        ),
                                        label: const Text('Xem Ngay'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: isDesktop ? 14 : 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          elevation: 0,
                                          shadowColor: AppColors.primary
                                              .withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            widget.onAddToList?.call(m.slug),
                                        icon: const Icon(
                                          Icons.add_rounded,
                                          size: 18,
                                        ),
                                        label: const Text('Danh Sách'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.08),
                                          side: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.20,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: isDesktop ? 14 : 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            display.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _current == i ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _current == i ? AppColors.primary : Colors.white24,
                borderRadius: BorderRadius.circular(3),
                boxShadow: _current == i
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
