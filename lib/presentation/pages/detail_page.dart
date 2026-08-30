import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/cache/image_cache_manager.dart';
import '../../core/di/injection.dart';
import '../../core/database/app_database.dart';
import '../../domain/repositories/movie_repository.dart';
import '../widgets/responsive_layout.dart';
import '../theme/app_theme.dart';

class DetailPage extends StatefulWidget {
  final String slug;
  const DetailPage({super.key, required this.slug});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  bool _loading = true;
  String? _error;
  dynamic _movie;
  List _servers = [];
  bool _isBookmarked = false;
  bool _bookmarkLoading = false;
  List _relatedMovies = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 150;
      if (show != _showTitle) setState(() => _showTitle = show);
    });
    _loadDetail();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static const Map<String, String> _typeMap = {
    'series': 'phim-bo',
    'single': 'phim-le',
    'hoathinh': 'hoat-hinh',
    'tvshows': 'tv-shows',
  };

  Future<void> _loadDetail() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = getIt<MovieRepository>();
      final data = await repo.getDetail(widget.slug);
      final bookmark = await getIt<AppDatabase>().getBookmark(widget.slug);
      if (mounted) {
        setState(() {
          _movie = data.movie;
          _servers = data.servers;
          _isBookmarked = bookmark != null;
          _loading = false;
        });
      }
      _loadRelated(data.movie.type);
    } catch (e) {
      if (mounted) setState(() { _error = _friendlyError(e); _loading = false; });
    }
  }

  Future<void> _loadRelated(String? type) async {
    try {
      final repo = getIt<MovieRepository>();
      final apiType = _typeMap[type] ?? type ?? 'phim-le';
      final res = await repo.getListByType(apiType, page: 1);
      if (mounted) setState(() => _relatedMovies = res.movies);
    } catch (_) {}
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('404')) return 'Không tìm thấy phim này.';
    if (s.contains('SocketException') || s.contains('Connection')) {
      return 'Không có kết nối mạng.';
    }
    if (s.contains('Timeout')) return 'Hết thời gian chờ.';
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }

  Future<void> _toggleBookmark() async {
    if (_movie == null || _bookmarkLoading) return;
    setState(() => _bookmarkLoading = true);
    try {
      final db = getIt<AppDatabase>();
      if (_isBookmarked) {
        await db.removeBookmark(widget.slug);
      } else {
        await db.addBookmark(BookmarksCompanion(
          movieSlug: Value(widget.slug),
          movieName: Value(_movie.name ?? ''),
          posterUrl: Value(_movie.posterUrl),
          year: Value(_movie.year),
          addedAt: Value(DateTime.now()),
        ));
      }
      if (mounted) setState(() { _isBookmarked = !_isBookmarked; _bookmarkLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _bookmarkLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(isDesktop),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white38, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.white70, fontSize: 15), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDetail,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ]),
        ),
      );
    }
    if (_movie == null) return const SizedBox.shrink();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(child: _buildInfoSection(isDesktop)),
        SliverToBoxAdapter(child: _buildEpisodeSection(isDesktop)),
        SliverToBoxAdapter(child: _buildRelatedSection(isDesktop)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _showTitle ? AppColors.background.withValues(alpha: 0.95) : Colors.transparent,
      elevation: _showTitle ? 4 : 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.30),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: _showTitle ? Text(_movie.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 16)) : null,
      actions: [
        IconButton(
          icon: _isBookmarked
              ? const Icon(Icons.bookmark_rounded, color: AppColors.primary)
              : const Icon(Icons.bookmark_border_rounded, color: Colors.white),
          onPressed: _toggleBookmark,
        ),
      ],
      expandedHeight: 300,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(fit: StackFit.expand, children: [
          if (_movie.posterUrl.isNotEmpty)
            CachedNetworkImage(
              cacheManager: FImageCacheManager.instance,
              imageUrl: _movie.posterUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => Container(color: const Color(0xFF1A2130)),
            )
          else
            Container(color: const Color(0xFF1A2130)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.background]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildInfoSection(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _movie.posterUrl != null
                ? CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: _movie.posterUrl!, width: 120, height: 180, fit: BoxFit.cover)
                : Container(width: 120, height: 180, color: const Color(0xFF1A2130)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_movie.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              if (_movie.originName != null) ...[
                const SizedBox(height: 4),
                Text(_movie.originName!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ],
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 4, children: [
                if (_movie.year != null) _InfoChip(label: '${_movie.year}'),
                if (_movie.quality != null) _InfoChip(label: _movie.quality!),
                if (_movie.lang != null) _InfoChip(label: _movie.lang!),
                if (_movie.type != null) _InfoChip(label: _movie.type!),
              ]),
              const SizedBox(height: 8),
              if (_movie.content != null && _movie.content!.isNotEmpty)
                Text(_movie.content!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13), maxLines: 5, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _buildEpisodeSection(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Danh Tập', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        for (final server in _servers) ...[
          Text(server.serverName ?? '', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (server.episodes as List).map((ep) {
              return SizedBox(
                width: 64,
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    context.push('/player', extra: {
                      'movie': _movie,
                      'episode': ep,
                      'serverName': server.serverName,
                      'servers': _servers,
                    });
                  },
                  child: Text(ep.name ?? ep.slug ?? '', style: const TextStyle(fontSize: 11)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ]),
    );
  }

  Widget _buildRelatedSection(bool isDesktop) {
    if (_relatedMovies.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Phim Liên Quan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _relatedMovies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final m = _relatedMovies[i];
              return GestureDetector(
                onTap: () => context.push('/movie/${m.slug}'),
                child: SizedBox(
                  width: 130,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: m.posterUrl != null ? CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: m.posterUrl!, fit: BoxFit.cover) : Container(color: const Color(0xFF1A2130)))),
                    const SizedBox(height: 6),
                    Text(m.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
    );
  }
}
