import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_event.dart';
import '../blocs/home/home_state.dart';
import '../../ui/features/home/views/widgets/home_app_bar.dart';
import '../../ui/features/home/views/widgets/category_chips.dart';
import '../../ui/features/home/views/widgets/continue_watching_section.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/movie_card.dart';
import '../widgets/no_source_placeholder.dart';
import '../widgets/responsive_layout.dart';
import '../theme/app_theme.dart';
import '../../core/toast/app_toast.dart';
import '../../core/di/injection.dart';
import '../../core/database/app_database.dart';
import '../../core/config/config_service.dart';
import '../../core/config/master_config.dart';
import '../router/movie_route.dart';
import '../../ui/features/home/views/widgets/source_picker_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _bloc;
  late final AppDatabase _db;
  final ScrollController _scrollController = ScrollController();
  List<WatchHistoryData> _history = [];
  String? _activeSourceId;
  late int _loadedConfigVersion;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _db = getIt<AppDatabase>();
    _bloc = HomeBloc()..add(const HomeInitialLoad());
    _loadedConfigVersion = _configVersion();
    _loadActiveSource();
    _scrollController.addListener(_onScroll);
    _db.watchAllHistory().listen((list) {
      if (mounted) setState(() => _history = list);
    });
  }

  int _configVersion() {
    try {
      return getIt<MasterConfig>().version;
    } catch (_) {
      return -1;
    }
  }

  Future<void> _loadActiveSource() async {
    try {
      final id = await getIt<ConfigService>().getActiveSourceId();
      if (mounted) setState(() => _activeSourceId = id);
    } catch (_) {}
  }

  /// Đổi nguồn trên top bar: lưu lựa chọn, rebuild DI (primary mới)
  /// rồi tải lại feed giữ nguyên category.
  Future<void> _onSourceSelected(String id) async {
    if (id == _activeSourceId) return;
    try {
      await getIt<ConfigService>().setActiveSourceId(id);
      await refreshSources();
      _activeSourceId = id;
      _loadedConfigVersion = _configVersion();
      _bloc.add(const HomeRefresh());
      if (mounted) {
        final s = getIt<MasterConfig>()
            .enabledSources
            .where((e) => e.id == id)
            .firstOrNull;
        AppToast.show(
          context,
          message: 'Đã chuyển nguồn: ${s == null ? id : sourceDisplayName(s)}',
          type: ToastType.success,
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Đổi nguồn thất bại: $e',
          type: ToastType.error,
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  void _onSearchCleared() {
    setState(() => _searchQuery = '');
  }

  /// Xây dựng lưới phim với lọc tìm kiếm client-side.
  Widget _buildMovieGrid(BuildContext context, HomeState state, bool isDesktop) {
    // Lọc client-side theo từ khóa tìm kiếm
    final filteredMovies = state.movies
        .where((m) => m.name
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    // Khi đang tìm kiếm, không cần loadingMore (lọc local, không load thêm từ API)
    final showLoadingMore = _searchQuery.isEmpty &&
        state.status == HomeStatus.loadingMore;

    // Tạo delegate riêng để tránh nested parentheses phức tạp
    final delegate = SliverChildBuilderDelegate(
      (context, index) {
        if (index >= filteredMovies.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          );
        }
        final movie = filteredMovies[index];
        return MovieCard(
          posterUrl: movie.posterUrl,
          name: movie.name,
          year: movie.year,
          quality: movie.quality,
          lang: movie.lang,
          voteAverage: movie.voteAverage,
          onTap: () => context.push(
            movieDetailPath(movie.slug, movie.sourceId),
          ),
        );
      },
      childCount: filteredMovies.length + (showLoadingMore ? 1 : 0),
    );

    final grid = SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getAdaptiveCrossAxisCount(context, mobile: 2, tablet: 3, desktop: 5),
        childAspectRatio: getAdaptiveAspectRatio(context, mobile: 0.62, desktop: 0.65),
        crossAxisSpacing: isDesktop ? 16 : 12,
        mainAxisSpacing: isDesktop ? 16 : 12,
      ),
      delegate: delegate,
    );

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 0, isDesktop ? 32 : 16, 24),
      sliver: grid,
    );
  }

  void _onScroll() {
    try {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        _bloc.add(const HomeLoadMore());
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Chưa có nguồn do user nhập → chế độ Player video.
    if (!hasConfiguredSource()) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: HomeAppBar(
          onSearchTap: () => context.push('/search'),
          searchQuery: _searchQuery,
          onSearchChanged: _onSearchChanged,
          onSearchCleared: _onSearchCleared,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await refreshSources();
            if (mounted) setState(() {});
          },
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const Expanded(child: NoSourcePlaceholder()),
                    ContinueWatchingSection(history: _history, isDesktop: context.isDesktop),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Config nguồn đổi version (thêm/xóa nguồn ở tab khác trong khi
    // trang này vẫn sống) -> tải lại feed 1 lần với repository mới.
    // Thay thế vòng retry trong build cũ (vừa thừa vừa có thể lặp vô hạn).
    if (_loadedConfigVersion != _configVersion()) {
      _loadedConfigVersion = _configVersion();
      Future.microtask(() {
        if (mounted) _bloc.add(const HomeRefresh());
      });
    }
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(_searchQuery.isNotEmpty ? 104 : 64),
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) => HomeAppBar(
              onSearchTap: () => context.push('/search'),
              selectedNav: homeNavIndexForCategory(state.selectedCategory),
              onNavSelected: (i) =>
                  _bloc.add(HomeCategoryChanged(homeCategoryForNavIndex(i))),
              sources: getIt<MasterConfig>().enabledSources,
              activeSourceId: _activeSourceId,
              onSourceSelected: _onSourceSelected,
              onManageSources: () => context.go('/settings'),
              searchQuery: _searchQuery,
              onSearchChanged: _onSearchChanged,
              onSearchCleared: _onSearchCleared,
            ),
          ),
        ),
        body: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status == HomeStatus.failure && state.errorMessage != null) {
              AppToast.show(context, message: state.errorMessage!, type: ToastType.error);
            }
          },
          builder: (context, state) {
            final isDesktop = context.isDesktop;

            return RefreshIndicator(
              onRefresh: () async => _bloc.add(const HomeRefresh()),
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 16, isDesktop ? 32 : 16, 0),
                      child: state.status == HomeStatus.loading && state.movies.isEmpty
                          ? Container(height: isDesktop ? 520 : 220, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)), child: const Center(child: CircularProgressIndicator(color: AppColors.primary)))
                          : BannerCarousel(
                              movies: state.movies,
                              onTap: (slug) {
                                final movie = state.movies
                                    .cast<dynamic>()
                                    .firstWhere(
                                      (m) => m.slug == slug,
                                      orElse: () => null,
                                    );
                                context.push(
                                  movieDetailPath(
                                    slug,
                                    movie?.sourceId as String?,
                                  ),
                                );
                              },
                              onAddToList: (slug) async {
                                final movie = state.movies.cast<dynamic>().firstWhere((m) => m.slug == slug, orElse: () => null);
                                if (movie == null) return;
                                final bookmarkRepo = getIt<BookmarkRepository>();
                                await bookmarkRepo.toggleBookmark(movieSlug: movie.slug, movieName: movie.name, posterUrl: movie.posterUrl, year: movie.year, sourceId: movie.sourceId as String?);
                                if (context.mounted) AppToast.show(context, message: 'Đã thêm vào Tủ Phim', type: ToastType.success);
                              },
                            ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CategoryChips(
                        categories: const ['Tất Cả', 'Phim Mới', 'Phim Bộ', 'Phim Lẻ', 'Hoạt Hình', 'TV Shows'],
                        selected: state.selectedCategory,
                        onSelected: (cat) => _bloc.add(HomeCategoryChanged(cat)),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ContinueWatchingSection(history: _history, isDesktop: isDesktop),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 28, isDesktop ? 32 : 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Phim Mới Cập Nhật', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: isDesktop ? 22 : 18)),
                          TextButton(onPressed: () {}, child: const Text('Xem tất cả', style: TextStyle(color: Colors.white54, fontSize: 12))),
                        ],
                      ),
                    ),
                  ),
                  if (state.status == HomeStatus.loading && state.movies.isEmpty)
                    const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: AppColors.primary))))
                  else if (state.status == HomeStatus.failure && state.movies.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off_rounded, color: Color(0xFFE50914), size: 36),
                              const SizedBox(height: 10),
                              const Text(
                                'Không lấy được dữ liệu',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.errorMessage ?? 'Nguồn phim không phản hồi.',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _bloc.add(const HomeRefresh()),
                                    icon: const Icon(Icons.refresh_rounded, size: 16),
                                    label: const Text('Thử lại'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => context.go('/settings'),
                                    icon: const Icon(Icons.settings_rounded, size: 16),
                                    label: const Text('Nguồn phim'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 0, isDesktop ? 32 : 16, 24),
                        sliver: _buildMovieGrid(context, state, isDesktop),
                      ),
                  if (state.status == HomeStatus.loadingMore)
                    const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
