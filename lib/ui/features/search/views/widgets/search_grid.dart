import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fcine/core/cache/image_cache_manager.dart';
import 'package:fcine/presentation/blocs/search/search_state.dart';
import 'package:fcine/presentation/theme/app_theme.dart';

class SearchGrid extends StatelessWidget {
  final SearchState state;
  final bool isDesktop;
  const SearchGrid({super.key, required this.state, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    if (state.movies.isEmpty && state.status != SearchStatus.loading && state.keyword.isNotEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Không tìm thấy', style: TextStyle(color: Colors.white54)))),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 12, isDesktop ? 24 : 16, 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: isDesktop ? 16 : 12,
          mainAxisSpacing: isDesktop ? 16 : 12,
        ),
        delegate: SliverChildBuilderDelegate((context, i) {
          if (i >= state.movies.length) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
          }
          final m = state.movies[i];
          return GestureDetector(
            onTap: () => context.push('/movie/${m.slug}'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(fit: StackFit.expand, children: [
                      CachedNetworkImage(
                          cacheManager: FImageCacheManager.instance,
                          imageUrl: m.posterUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(color: AppColors.surface)),
                      Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.90)]))),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.60),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.10))),
                          child: Text(m.quality != null ? '${m.quality} • ${m.lang ?? "Vietsub"}' : 'HD • Vietsub',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.50),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.10))),
                          child: const Icon(Icons.favorite_border_rounded, color: Colors.white70, size: 14),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(m.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Row(children: [
                Text('${m.year}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const Spacer(),
                const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                const SizedBox(width: 2),
                Text(m.voteAverage != null ? m.voteAverage!.toStringAsFixed(1) : '8.0',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ]),
          );
        }, childCount: state.movies.length + (state.status == SearchStatus.loadingMore ? 1 : 0)),
      ),
    );
  }
}
