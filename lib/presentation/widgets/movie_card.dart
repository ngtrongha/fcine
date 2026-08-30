import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/cache/image_cache_manager.dart';
import '../theme/app_theme.dart';

class MovieCard extends StatefulWidget {
  final String posterUrl;
  final String name;
  final int year;
  final String? quality;
  final String? lang;
  final double? voteAverage;
  final VoidCallback onTap;
  final double? progress;

  const MovieCard({
    super.key,
    required this.posterUrl,
    required this.name,
    required this.year,
    this.quality,
    this.lang,
    this.voteAverage,
    required this.onTap,
    this.progress,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _hovered = false;

  String get _qualityLabel {
    final q = widget.quality ?? 'HD';
    final lang = widget.lang;
    if (lang != null && lang.isNotEmpty) {
      // HTML shows "HD • Vietsub" or "4K • Vietsub"
      final is4K =
          q.toLowerCase().contains('4k') || q.toLowerCase().contains('uhd');
      final base = is4K ? '4K' : 'HD';
      // Simplify: if lang contains Vietsub, show Vietsub
      if (lang.toLowerCase().contains('vietsub')) return '$base • Vietsub';
      if (lang.toLowerCase().contains('thuyết')) return '$base • TM';
      return base;
    }
    return q;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(
          0,
          _hovered && isDesktop ? -4 : 0,
          0,
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _hovered && isDesktop
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    boxShadow: _hovered && isDesktop
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          cacheManager: FImageCacheManager.instance,
                          imageUrl: widget.posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.surface),
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                        // Hover scale (desktop)
                        // Top-left quality badge - HTML: bg-primary
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: Text(
                              _qualityLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        // Bottom-right IMDb badge - HTML: bg-black/70 backdrop-blur-md text-tertiary
                        if (widget.voteAverage != null &&
                            widget.voteAverage! > 0)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.70),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 10,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.voteAverage!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Color(0xFFF59E0B),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (widget.progress != null && widget.progress! > 0)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),
                              child: LinearProgressIndicator(
                                value: widget.progress,
                                minHeight: 3,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.20,
                                ),
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.year}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
