import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/cache/image_cache_manager.dart';
import '../providers/movie_providers.dart';
import '../providers/local_providers.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/movie_card.dart';
import '../widgets/offline_banner.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabTypes = ['latest', 'phim-le', 'phim-bo', 'hoat-hinh'];
  final List<String> tabTitles = ['Mới cập nhật', 'Phim Lẻ', 'Phim Bộ', 'Hoạt Hình'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabTypes.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F-CINE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
          IconButton(icon: const Icon(Icons.download), onPressed: () => context.push('/downloads')),
          IconButton(icon: const Icon(Icons.history), onPressed: () => context.push('/history')),
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () => context.push('/bookmarks')),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFFE50914),
          tabs: [for (final t in tabTitles) Tab(text: t)],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (int i = 0; i < tabTypes.length; i++) _TabContent(type: tabTypes[i], isLatest: i == 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabContent extends ConsumerStatefulWidget {
  final String type;
  final bool isLatest;
  const _TabContent({required this.type, required this.isLatest});

  @override
  ConsumerState<_TabContent> createState() => _TabContentState();
}

class _TabContentState extends ConsumerState<_TabContent> {
  int page = 1;
  List allMovies = [];
  bool isLoadingMore = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPage(1));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      if (!isLoadingMore && hasMore) _loadPage(page + 1);
    }
  }

  Future<void> _loadPage(int p) async {
    if (isLoadingMore) return;
    setState(() => isLoadingMore = true);
    try {
      final repo = ref.read(movieRepositoryProvider);
      final res = widget.isLatest ? await repo.getLatest(page: p) : await repo.getListByType(widget.type, page: p);
      setState(() {
        if (p == 1) {
          allMovies = res.movies;
        } else {
          allMovies = [...allMovies, ...res.movies];
        }
        page = p;
        hasMore = p < res.pagination.totalPages;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() => isLoadingMore = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải trang $p: $e')));
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      page = 1;
      hasMore = true;
    });
    await _loadPage(1);
  }

  @override
  Widget build(BuildContext context) {
    if (allMovies.isEmpty && isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }
    if (allMovies.isEmpty && !isLoadingMore) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Không có dữ liệu'), const SizedBox(height: 12), ElevatedButton(onPressed: () => _loadPage(1), child: const Text('Thử lại'))]));
    }

    final historyAsync = ref.watch(watchHistoryStreamProvider);
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (widget.isLatest)
            historyAsync.when(
              data: (history) {
                if (history.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.fromLTRB(12, 12, 12, 4), child: Text('Tiếp tục xem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      SizedBox(
                        height: 170,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: history.take(10).length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final h = history[i];
                            final progress = h.durationMs > 0 ? (h.positionMs / h.durationMs).clamp(0.0, 1.0) : 0.0;
                            return GestureDetector(
                              onTap: () => context.push('/movie/${h.movieSlug}'),
                              child: SizedBox(
                                width: 110,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: h.posterUrl != null ? CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: h.posterUrl!, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.white10)) : Container(color: Colors.white10, child: const Icon(Icons.movie)),
                                          ),
                                          Positioned(bottom: 0, left: 0, right: 0, child: LinearProgressIndicator(value: progress, minHeight: 3, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.redAccent))),
                                          Positioned(top: 6, left: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)), child: Text(h.episodeName, style: const TextStyle(fontSize: 9, color: Colors.white)))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(h.movieName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                    Text('${(progress * 100).toStringAsFixed(0)}% • ${h.serverName}', style: const TextStyle(fontSize: 9, color: Colors.white54)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 16, color: Colors.white10),
                    ],
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          if (widget.isLatest && allMovies.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: BannerCarousel(movies: allMovies, onTap: (slug) => context.push('/movie/$slug')),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10),
              delegate: SliverChildBuilderDelegate((context, i) {
                if (i >= allMovies.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)));
                }
                final m = allMovies[i];
                return MovieCard(
                  posterUrl: m.posterUrl,
                  name: m.name,
                  year: m.year,
                  quality: m.quality,
                  onTap: () => context.push('/movie/${m.slug}'),
                );
              }, childCount: allMovies.length + (isLoadingMore && hasMore ? 1 : 0)),
            ),
          ),
          if (isLoadingMore && hasMore)
            const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
