import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/cache/image_cache_manager.dart';
import '../../core/di/injection.dart';
import '../../core/database/app_database.dart';
import '../../core/config/config_service.dart';
import '../../core/config/master_config.dart';
import '../../core/toast/app_toast.dart';
import '../router/movie_route.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/episode.dart';
import '../../domain/repositories/movie_repository.dart';
import '../widgets/no_source_placeholder.dart';
import '../widgets/responsive_layout.dart';
import '../theme/app_theme.dart';

class DetailPage extends StatefulWidget {
  final String slug;

  /// Nguồn đang hiển thị ở danh sách (truyền qua `?source=`).
  /// Chi tiết ưu tiên nguồn này để tránh lệch slug API <-> WEB.
  final String? initialSourceId;

  const DetailPage({super.key, required this.slug, this.initialSourceId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  bool _loading = true;
  String? _error;
  Movie? _movie;
  List<EpisodeServer> _servers = [];
  int _selectedServerIndex = 0;
  String _selectedSourceId = '';
  bool _isSwitchingSource = false;
  bool _isBookmarked = false;
  bool _bookmarkLoading = false;
  bool _isContentExpanded = false;
  List<Movie> _relatedMovies = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 150;
      if (show != _showTitle) setState(() => _showTitle = show);
    });

    if (!hasConfiguredSource()) {
      _loading = false;
      _error = null;
      return;
    }
    _initAndLoad();
  }

  List<SourceConfig> _enabledSources() {
    try {
      final cfg = getIt<MasterConfig>();
      return cfg.sources.where((s) => s.enabled).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Slug web có dạng `section~slug`, slug API là chuỗi trơn.
  static bool _slugIsWeb(String slug) => slug.contains('~');

  /// Thứ tự thử nguồn: nguồn được chỉ định trước, rồi tới các nguồn
  /// cùng loại với slug (tránh gọi slug API lên nguồn WEB và ngược lại),
  /// cuối cùng là các nguồn còn lại.
  List<String> _orderedSources(String preferred) {
    final enabled = _enabledSources();
    final wantWeb = _slugIsWeb(widget.slug);
    final ids = <String>[];
    void add(String id) {
      if (id.isNotEmpty && !ids.contains(id)) ids.add(id);
    }

    if (enabled.any((s) => s.id == preferred)) add(preferred);
    for (final s in enabled.where((s) => s.isWeb == wantWeb)) {
      add(s.id);
    }
    for (final s in enabled) {
      add(s.id);
    }
    if (ids.isEmpty) ids.add('');
    return ids;
  }

  /// Ưu tiên nguồn: `?source=` (nếu còn bật) -> nguồn đang active
  /// trên top bar -> nguồn cùng loại với slug.
  Future<void> _initAndLoad() async {
    var initial = widget.initialSourceId?.trim() ?? '';
    if (initial.isNotEmpty &&
        !_enabledSources().any((s) => s.id == initial)) {
      initial = '';
    }
    _selectedSourceId = initial;
    if (_selectedSourceId.isEmpty) {
      try {
        final activeId = await getIt<ConfigService>().getActiveSourceId();
        if (!mounted) return;
        if (activeId != null &&
            activeId.isNotEmpty &&
            _enabledSources().any((s) => s.id == activeId)) {
          _selectedSourceId = activeId;
        }
      } catch (_) {}
    }
    if (!mounted) return;
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

  Future<void> _loadDetail({String? sourceId}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = getIt<MovieRepository>();
      final preferred = (sourceId ?? _selectedSourceId).trim();
      // Thử lần lượt các nguồn (ưu tiên nguồn được chỉ định + cùng loại
      // slug) thay vì kẹt ở 1 nguồn sai rồi báo "Không tìm thấy phim".
      final candidates = _orderedSources(preferred);
      Object? lastErr;
      for (final id in candidates) {
        try {
          final data = await repo.getDetail(
            widget.slug,
            sourceId: id.isEmpty ? null : id,
          );
          final bookmark = await getIt<AppDatabase>().getBookmark(widget.slug);

          if (mounted) {
            setState(() {
              _movie = data.movie;
              _servers = data.servers;
              _selectedServerIndex = 0;
              _selectedSourceId = id;
              _isBookmarked = bookmark != null;
              _loading = false;
            });
          }
          _loadRelated(data.movie.type);
          return;
        } catch (e) {
          lastErr = e;
        }
      }
      throw lastErr ?? Exception('Không tải được chi tiết phim');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _friendlyError(e);
          _loading = false;
        });
      }
    }
  }

  /// true khi slug và nguồn đích khác loại (API trơn <-> WEB section~slug).
  /// Thử trực tiếp trường hợp này chỉ ra rác (VD trang chủ WP parse thành
  /// phim "Full" không link), nên bỏ qua để tìm theo tên phim.
  bool _isCrossType(String slug, String targetSourceId) {
    try {
      final src = _enabledSources().where((s) => s.id == targetSourceId).firstOrNull;
      if (src == null) return false;
      return src.isWeb != _slugIsWeb(slug);
    } catch (_) {
      return false;
    }
  }

  Future<void> _switchSource(String sourceId) async {
    if (_selectedSourceId == sourceId || _isSwitchingSource) return;
    setState(() => _isSwitchingSource = true);

    try {
      final repo = getIt<MovieRepository>();

      // 1. Thử tải trực tiếp với slug hiện tại (bỏ qua khi khác loại
      // slug API <-> nguồn WEB: thử trực tiếp chỉ ra phim rác).
      if (!_isCrossType(widget.slug, sourceId)) {
        try {
          final data = await repo.getDetail(widget.slug, sourceId: sourceId);
          if (mounted) {
            setState(() {
              _movie = data.movie;
              _servers = data.servers;
              _selectedSourceId = sourceId;
              _selectedServerIndex = 0;
              _isSwitchingSource = false;
            });
            AppToast.show(
              context,
              message: 'Đã đổi sang nguồn $sourceId',
              type: ToastType.success,
            );
            return;
          }
        } catch (_) {
          // Fallback: tìm kiếm theo tên phim trên nguồn mới
        }
      }

      // 2. Tìm kiếm theo tên phim nếu slug khác nhau
      if (_movie != null && _movie!.name.isNotEmpty) {
        final searchRes = await repo.search(
          _movie!.name,
          sourceId: sourceId,
          limit: 5,
        );
        if (searchRes.movies.isNotEmpty) {
          final matched = searchRes.movies.first;
          final data = await repo.getDetail(matched.slug, sourceId: sourceId);
          if (mounted) {
            setState(() {
              _movie = data.movie;
              _servers = data.servers;
              _selectedSourceId = sourceId;
              _selectedServerIndex = 0;
              _isSwitchingSource = false;
            });
            AppToast.show(
              context,
              message: 'Đã đổi sang nguồn $sourceId',
              type: ToastType.success,
            );
            return;
          }
        }
      }

      if (mounted) {
        setState(() => _isSwitchingSource = false);
        AppToast.show(
          context,
          message: 'Không tìm thấy phim này trên nguồn $sourceId',
          type: ToastType.warning,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSwitchingSource = false);
        AppToast.show(
          context,
          message: 'Lỗi khi đổi nguồn: $e',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _loadRelated(String? type) async {
    try {
      final repo = getIt<MovieRepository>();
      final apiType = _typeMap[type] ?? type ?? 'phim-le';
      final res = await repo.getListByType(
        apiType,
        page: 1,
        sourceId: _selectedSourceId,
      );
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
        await db.addBookmark(
          BookmarksCompanion(
            movieSlug: Value(widget.slug),
            movieName: Value(_movie!.name),
            posterUrl: Value(_movie!.posterUrl),
            year: Value(_movie!.year),
            sourceId: Value(
              _selectedSourceId.isEmpty ? _movie!.sourceId : _selectedSourceId,
            ),
            addedAt: Value(DateTime.now()),
          ),
        );
      }
      if (mounted) {
        setState(() {
          _isBookmarked = !_isBookmarked;
          _bookmarkLoading = false;
        });
        AppToast.show(
          context,
          message: _isBookmarked
              ? 'Đã thêm vào Tủ Phim'
              : 'Đã xóa khỏi Tủ Phim',
          type: ToastType.success,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _bookmarkLoading = false);
    }
  }

  void _playEpisode(Episode ep, String serverName) {
    if (_movie == null) return;
    context.push(
      '/player',
      extra: {
        'movie': _movie,
        'episode': ep,
        'serverName': serverName,
        'servers': _servers,
      },
    );
  }

  Future<void> _onPrimaryPlay() async {
    if (_servers.isEmpty) {
      AppToast.show(
        context,
        message: 'Chưa có tập phim nào khả dụng',
        type: ToastType.warning,
      );
      return;
    }

    final server = _servers.length > _selectedServerIndex
        ? _servers[_selectedServerIndex]
        : _servers.first;
    if (server.episodes.isEmpty) {
      AppToast.show(
        context,
        message: 'Server chưa có tập phim',
        type: ToastType.warning,
      );
      return;
    }

    // Kiểm tra lịch sử xem dở (khớp cả khi mở từ nguồn khác:
    // slug web `section~abc` và slug API trơn `abc` coi như cùng phim).
    try {
      final db = getIt<AppDatabase>();
      final historyList = await db.getAllHistory();
      String base(String s) => s.contains('~') ? s.split('~').last : s;
      final wantBase = base(widget.slug);
      final candidates = historyList
          .where(
            (h) => h.movieSlug == widget.slug || base(h.movieSlug) == wantBase,
          )
          .toList();
      final lastWatched = candidates.firstOrNull;
      if (lastWatched != null) {
        Episode? ep;
        // 1. Đúng tập đã xem (so cả slug đầy đủ lẫn phần base).
        for (final s in _servers) {
          ep = s.episodes
              .where(
                (e) =>
                    e.slug == lastWatched.episodeSlug ||
                    base(e.slug) == base(lastWatched.episodeSlug),
              )
              .firstOrNull;
          if (ep != null) {
            _playEpisode(ep, s.serverName);
            return;
          }
        }
        // 2. Không còn đúng tập (đổi nguồn khác format tập): mở tập cùng tên.
        final allNames = <String, (Episode, String)>{};
        for (final s in _servers) {
          for (final e in s.episodes) {
            allNames.putIfAbsent(e.name, () => (e, s.serverName));
          }
        }
        final sameName = allNames[lastWatched.episodeName];
        if (sameName != null) {
          _playEpisode(sameName.$1, sameName.$2);
          return;
        }
      }
    } catch (_) {}

    _playEpisode(server.episodes.first, server.serverName);
  }

  String _cleanHtml(String? text) {
    if (text == null || text.isEmpty) return '';
    return text
        .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
    if (!hasConfiguredSource() && _movie == null) {
      return const SafeArea(child: NoSourcePlaceholder(title: 'Chi tiết cần nguồn phim'));
    }
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      final sources = _enabledSources();
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white38,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadDetail(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              // Lỗi thường do lệch nguồn (slug API mở bằng nguồn WEB
              // và ngược lại) — cho đổi nguồn ngay tại đây.
              if (sources.length > 1) ...[
                const SizedBox(height: 16),
                const Text(
                  'Thử nguồn khác:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: sources.map((src) {
                    final isSelected = _selectedSourceId == src.id;
                    return InkWell(
                      onTap: _isSwitchingSource
                          ? null
                          : () => _loadDetail(sourceId: src.id),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFF334155),
                          ),
                        ),
                        child: Text(
                          src.name.isEmpty ? src.id : src.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFCBD5E1),
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (_movie == null) return const SizedBox.shrink();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(child: _buildInfoSection(isDesktop)),
        SliverToBoxAdapter(child: _buildSourceAndServerSection(isDesktop)),
        SliverToBoxAdapter(child: _buildEpisodeSection(isDesktop)),
        SliverToBoxAdapter(child: _buildRelatedSection(isDesktop)),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    final poster = _movie?.posterUrl ?? '';
    return SliverAppBar(
      pinned: true,
      backgroundColor: _showTitle
          ? AppColors.background.withValues(alpha: 0.95)
          : Colors.transparent,
      elevation: _showTitle ? 4 : 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.45),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: _showTitle
          ? Text(
              _movie?.name ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.45),
            child: IconButton(
              icon: _isBookmarked
                  ? const Icon(Icons.bookmark_rounded, color: AppColors.primary)
                  : const Icon(
                      Icons.bookmark_border_rounded,
                      color: Colors.white,
                    ),
              onPressed: _toggleBookmark,
            ),
          ),
        ),
      ],
      expandedHeight: 320,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (poster.isNotEmpty)
              CachedNetworkImage(
                cacheManager: FImageCacheManager.instance,
                imageUrl: poster,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(color: AppColors.surface),
              )
            else
              Container(color: AppColors.surface),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black26,
                    Colors.transparent,
                    AppColors.background,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(bool isDesktop) {
    final movie = _movie!;
    final cleanedContent = _cleanHtml(movie.content);
    final rating = movie.voteAverage;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 16,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Card
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: isDesktop ? 150 : 120,
                  height: isDesktop ? 220 : 180,
                  color: AppColors.surfaceVariant,
                  child: movie.posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          cacheManager: FImageCacheManager.instance,
                          imageUrl: movie.posterUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const Center(
                            child: Icon(
                              Icons.movie_rounded,
                              color: Colors.white24,
                              size: 40,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.movie_rounded,
                            color: Colors.white24,
                            size: 40,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    if (movie.originName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        movie.originName,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Badges thông số
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (rating != null && rating > 0)
                          _InfoBadge(
                            label: '★ ${rating.toStringAsFixed(1)}',
                            color: const Color(0xFFF59E0B),
                            textColor: Colors.black,
                          ),
                        if (movie.year > 0) _InfoBadge(label: '${movie.year}'),
                        if (movie.quality != null && movie.quality!.isNotEmpty)
                          _InfoBadge(label: movie.quality!),
                        if (movie.lang != null && movie.lang!.isNotEmpty)
                          _InfoBadge(label: movie.lang!),
                        if (movie.episodeCurrent != null &&
                            movie.episodeCurrent!.isNotEmpty)
                          _InfoBadge(label: movie.episodeCurrent!),
                        if (movie.time != null && movie.time!.isNotEmpty)
                          _InfoBadge(label: movie.time!),
                      ],
                    ),
                    if (movie.categories.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: movie.categories
                            .map((cat) => _GenreChip(label: cat.name))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons: Xem Phim & Tủ Phim
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _onPrimaryPlay,
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: const Text(
                    'XEM PHIM',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: _toggleBookmark,
                  icon: Icon(
                    _isBookmarked
                        ? Icons.bookmark_added_rounded
                        : Icons.bookmark_add_outlined,
                    size: 20,
                    color: _isBookmarked ? AppColors.primary : Colors.white70,
                  ),
                  label: Text(
                    _isBookmarked ? 'Đã lưu' : 'Lưu phim',
                    style: TextStyle(
                      color: _isBookmarked ? AppColors.primary : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(
                      color: _isBookmarked
                          ? AppColors.primary
                          : const Color(0xFF2D3748),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tóm tắt nội dung
          if (cleanedContent.isNotEmpty) ...[
            const Text(
              'Nội Dung Phim',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cleanedContent,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: _isContentExpanded ? null : 3,
              overflow: _isContentExpanded ? null : TextOverflow.ellipsis,
            ),
            if (cleanedContent.length > 120)
              GestureDetector(
                onTap: () =>
                    setState(() => _isContentExpanded = !_isContentExpanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _isContentExpanded ? 'Thu gọn ▲' : 'Xem thêm ▼',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],

          // Đạo diễn, diễn viên, quốc gia
          if (movie.countries.isNotEmpty ||
              movie.directors.isNotEmpty ||
              movie.actors.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (movie.countries.isNotEmpty)
                    _MetadataRow(
                      label: 'Quốc gia',
                      value: movie.countries.map((c) => c.name).join(', '),
                    ),
                  if (movie.directors.isNotEmpty)
                    _MetadataRow(
                      label: 'Đạo diễn',
                      value: movie.directors.join(', '),
                    ),
                  if (movie.actors.isNotEmpty)
                    _MetadataRow(
                      label: 'Diễn viên',
                      value: movie.actors.join(', '),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Bộ chọn Nguồn Dữ Liệu (API Source) & Nguồn Phát / Server
  Widget _buildSourceAndServerSection(bool isDesktop) {
    final masterConfig = getIt.isRegistered<MasterConfig>()
        ? getIt<MasterConfig>()
        : null;
    final enabledSources =
        masterConfig?.sources.where((s) => s.enabled).toList() ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 16,
        vertical: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Nguồn Dữ Liệu (Data Source: KKPhim, NguonC...)
            Row(
              children: [
                const Icon(
                  Icons.cloud_sync_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Nguồn Phim:',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                if (_isSwitchingSource)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: enabledSources.map((src) {
                          final isSelected = _selectedSourceId == src.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => _switchSource(src.id),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFF334155),
                                  ),
                                ),
                                child: Text(
                                  src.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFFCBD5E1),
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Nguồn Phát / Server (Vietsub, Thuyết Minh, Server #1...)
            if (_servers.isNotEmpty) ...[
              const Divider(color: Color(0xFF1E293B), height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.dns_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Server phát:',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _servers.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final s = entry.value;
                          final isSelected = _selectedServerIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                '${s.serverName} (${s.episodes.length})',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedServerIndex = idx),
                              selectedColor: AppColors.primary,
                              backgroundColor: const Color(0xFF1E293B),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : const Color(0xFF334155),
                              ),
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeSection(bool isDesktop) {
    if (_servers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Chưa có danh sách tập phim',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      );
    }

    final currentServer = _servers.length > _selectedServerIndex
        ? _servers[_selectedServerIndex]
        : _servers.first;
    final episodes = currentServer.episodes;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Danh Sách Tập (${episodes.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                currentServer.serverName,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: episodes.map((ep) {
              return SizedBox(
                width: 68,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF334155)),
                    ),
                  ),
                  onPressed: () => _playEpisode(ep, currentServer.serverName),
                  child: Text(
                    ep.name.isNotEmpty
                        ? ep.name
                        : (ep.slug.isNotEmpty ? ep.slug : 'Xem'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedSection(bool isDesktop) {
    if (_relatedMovies.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 16,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phim Liên Quan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _relatedMovies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final m = _relatedMovies[i];
                return GestureDetector(
                  onTap: () => context.push(movieDetailPath(m.slug, m.sourceId)),
                  child: SizedBox(
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: m.posterUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    cacheManager: FImageCacheManager.instance,
                                    imageUrl: m.posterUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => Container(
                                      color: const Color(0xFF1A2130),
                                    ),
                                  )
                                : Container(color: const Color(0xFF1A2130)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  const _InfoBadge({required this.label, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? const Color(0xFFCBD5E1),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  const _GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF131C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23324D)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetadataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              '$label:',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
