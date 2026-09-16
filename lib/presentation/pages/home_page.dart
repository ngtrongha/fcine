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
import '../../domain/repositories/movie_repository.dart';
import '../../ui/features/home/views/widgets/source_picker_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc _bloc;
  late final AppDatabase _db;
  final ScrollController _scrollController = ScrollController();
  List<WatchHistoryData> _history = [];
  String? _activeSourceId;

  @override
  void initState() {
    super.initState();
    final repo = getIt<MovieRepository>();
    _db = getIt<AppDatabase>();
    _bloc = HomeBloc(repository: repo)..add(const HomeInitialLoad());
    _loadActiveSource();
    _scrollController.addListener(_onScroll);
    _db.watchAllHistory().listen((list) {
      if (mounted) setState(() => _history = list);
    });
  }

  Future<void> _loadActiveSource() async {
    try {
      final id = await getIt<ConfigService>().getActiveSourceId();
      if (mounted) setState(() => _activeSourceId = id);
    } catch (_) {}
  }

  /// Đổi nguồn trên top bar: lưu lựa chọn, rebuild DI (primary mới),
  /// dựng lại bloc với repository mới rồi tải lại feed giữ nguyên category.
  Future<void> _onSourceSelected(String id) async {
    if (id == _activeSourceId) return;
    try {
      await getIt<ConfigService>().setActiveSourceId(id);
      await refreshSources();
      await _recreateBloc();
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

  Future<void> _recreateBloc() async {
    final category = _bloc.state.selectedCategory;
    final old = _bloc;
    try {
      await old.clear();
    } catch (_) {}
    await old.close();
    if (!mounted) return;
    try {
      _activeSourceId = await getIt<ConfigService>().getActiveSourceId();
    } catch (_) {}
    _bloc = HomeBloc(repository: getIt<MovieRepository>())
      ..add(HomeCategoryChanged(category));
    setState(() {});
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
        appBar: HomeAppBar(onSearchTap: () => context.push('/search')),
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
    // Vừa thêm nguồn sau khi ở chế độ player-only → tải lại.
    if (_bloc.state.status == HomeStatus.failure && _bloc.state.movies.isEmpty) {
      Future.microtask(() {
        if (mounted) _bloc.add(const HomeInitialLoad());
      });
    }
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
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
                              onTap: (slug) => context.push('/movie/$slug'),
                              onAddToList: (slug) async {
                                final movie = state.movies.cast<dynamic>().firstWhere((m) => m.slug == slug, orElse: () => null);
                                if (movie == null) return;
                                final bookmarkRepo = getIt<BookmarkRepository>();
                                await bookmarkRepo.toggleBookmark(movieSlug: movie.slug, movieName: movie.name, posterUrl: movie.posterUrl, year: movie.year);
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
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: getAdaptiveCrossAxisCount(context, mobile: 2, tablet: 3, desktop: 5),
                          childAspectRatio: getAdaptiveAspectRatio(context, mobile: 0.62, desktop: 0.65),
                          crossAxisSpacing: isDesktop ? 16 : 12,
                          mainAxisSpacing: isDesktop ? 16 : 12,
                        ),
                        delegate: SliverChildBuilderDelegate((context, i) {
                          if (i >= state.movies.length) {
                            return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)));
                          }
                          final m = state.movies[i];
                          return MovieCard(
                            posterUrl: m.posterUrl,
                            name: m.name,
                            year: m.year,
                            quality: m.quality,
                            lang: m.lang,
                            voteAverage: m.voteAverage,
                            onTap: () => context.push('/movie/${m.slug}'),
                          );
                        }, childCount: state.movies.length + (state.status == HomeStatus.loadingMore ? 1 : 0)),
                      ),
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
