import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fcine/core/di/injection.dart';
import 'package:fcine/core/toast/app_toast.dart';
import 'package:fcine/domain/repositories/movie_repository.dart';
import 'package:fcine/presentation/blocs/search/search_bloc.dart';
import 'package:fcine/presentation/blocs/search/search_event.dart';
import 'package:fcine/presentation/blocs/search/search_state.dart';
import 'package:fcine/presentation/theme/app_theme.dart';
import 'package:fcine/presentation/widgets/no_source_placeholder.dart';
import 'package:fcine/presentation/widgets/responsive_layout.dart';
import 'package:fcine/ui/features/search/views/widgets/desktop_sidebar.dart';
import 'package:fcine/ui/features/search/views/widgets/filter_sheet.dart';
import 'package:fcine/ui/features/search/views/widgets/mobile_search_sliver.dart';
import 'package:fcine/ui/features/search/views/widgets/recent_searches_section.dart';
import 'package:fcine/ui/features/search/views/widgets/search_app_bar.dart';
import 'package:fcine/ui/features/search/views/widgets/search_grid.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchBloc _bloc;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Map<String, String> categories = const {
    '': 'Tất cả',
    'hanh-dong': 'Hành Động',
    'tinh-cam': 'Tình Cảm',
    'hai-huoc': 'Hài Hước',
    'co-trang': 'Cổ Trang',
    'tam-ly': 'Tâm Lý',
  };
  final Map<String, String> countries = const {
    '': 'Tất cả',
    'han-quoc': 'Hàn Quốc',
    'trung-quoc': 'Trung Quốc',
    'au-my': 'Âu Mỹ',
    'nhat-ban': 'Nhật Bản',
  };
  final Map<String, String> years = const {
    '': 'Tất cả',
    '2026': '2026',
    '2025': '2025',
    '2024': '2024',
  };
  final Map<String, String> types = const {
    '': 'Tất cả',
    'single': 'Phim Lẻ',
    'series': 'Phim Bộ',
    'hoathinh': 'Hoạt Hình',
  };
  final List<String> trendingKeywords = const [
    'Dune 2',
    'Loki Mùa 2',
    'Oppenheimer',
    'Mai',
    'One Piece',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = SearchBloc(repository: getIt<MovieRepository>());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _bloc.add(const SearchLoadMore());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    _bloc.close();
    super.dispose();
  }

  void _openFilterSheet() => FilterSheet.show(
        context,
        bloc: _bloc,
        categories: categories,
        countries: countries,
        years: years,
        types: types,
      );

  void _onKeywordSelected(String kw) {
    _controller.text = kw;
    _bloc.add(SearchKeywordChanged(kw));
  }

  @override
  Widget build(BuildContext context) {
    if (!hasConfiguredSource()) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: NoSourcePlaceholder(title: 'Tìm kiếm cần nguồn phim')),
      );
    }
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state.status == SearchStatus.failure && state.errorMessage != null) {
            AppToast.show(context, message: state.errorMessage!, type: ToastType.error);
          }
        },
        builder: (context, state) {
          if (context.isDesktop) return _buildDesktop(state);
          return _buildMobile(state);
        },
      ),
    );
  }

  Widget _buildDesktop(SearchState state) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchAppBar(
        controller: _controller,
        onChanged: (v) => _bloc.add(SearchKeywordChanged(v)),
        onFilterTap: _openFilterSheet,
        hasFilter: state.hasFilter,
        keyword: state.keyword,
      ),
      body: Row(
        children: [
          DesktopSidebar(bloc: _bloc, state: state, categories: categories, years: years),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Explore',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
                        Text(
                          state.keyword.isEmpty
                              ? 'Discover the latest blockbusters'
                              : 'Tìm thấy ${state.movies.length} kết quả',
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                SearchGrid(state: state, isDesktop: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(SearchState state) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          MobileSearchSliver(
            bloc: _bloc,
            controller: _controller,
            state: state,
            categories: categories,
            countries: countries,
            trendingKeywords: trendingKeywords,
            onFilterTap: _openFilterSheet,
            onKeywordSelected: _onKeywordSelected,
          ),
          if (state.keyword.isEmpty && state.recentSearches.isNotEmpty)
            RecentSearchesSection(
              bloc: _bloc,
              recentSearches: state.recentSearches,
              currentKeyword: state.keyword,
              onSelect: _onKeywordSelected,
            ),
          if (state.keyword.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text('Tìm thấy ${state.movies.length} kết quả phù hợp',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
          if (state.keyword.isEmpty && state.recentSearches.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                    child: Text('Nhập từ khóa để tìm kiếm',
                        style: TextStyle(color: Colors.white54))),
              ),
            ),
          if (state.status == SearchStatus.loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            )
          else if (state.keyword.isNotEmpty)
            SearchGrid(state: state, isDesktop: false),
        ],
      ),
    );
  }
}
