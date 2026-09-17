import 'package:flutter/material.dart';
import 'package:fcine/presentation/blocs/search/search_bloc.dart';
import 'package:fcine/presentation/blocs/search/search_event.dart';
import 'package:fcine/presentation/blocs/search/search_state.dart';
import 'package:fcine/presentation/theme/app_theme.dart';
import 'package:fcine/ui/features/search/views/widgets/filter_pill.dart';
import 'package:fcine/ui/features/search/views/widgets/trending_chips.dart';

class MobileSearchSliver extends StatelessWidget {
  final SearchBloc bloc;
  final TextEditingController controller;
  final SearchState state;
  final Map<String, String> categories;
  final Map<String, String> countries;
  final List<String> trendingKeywords;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onKeywordSelected;

  const MobileSearchSliver({
    super.key,
    required this.bloc,
    required this.controller,
    required this.state,
    required this.categories,
    required this.countries,
    required this.trendingKeywords,
    required this.onFilterTap,
    required this.onKeywordSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilter = state.hasFilter;
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background.withValues(alpha: 0.90),
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _SearchField(controller: controller, bloc: bloc, state: state)),
            const SizedBox(width: 12),
            _FilterButton(hasFilter: hasFilter, onTap: onFilterTap),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Column(
          children: [
            TrendingChips(
              keywords: trendingKeywords,
              onSelected: onKeywordSelected,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterPill(
                    label: state.category != null ? categories[state.category]! : 'Hành Động',
                    selected: state.category != null,
                    onTap: onFilterTap,
                  ),
                  const SizedBox(width: 8),
                  FilterPill(
                    label: state.country != null ? countries[state.country]! : 'Âu Mỹ',
                    onTap: onFilterTap,
                  ),
                  const SizedBox(width: 8),
                  FilterPill(label: state.year ?? '2024', onTap: onFilterTap),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final SearchBloc bloc;
  final SearchState state;
  const _SearchField({required this.controller, required this.bloc, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (v) => bloc.add(SearchKeywordChanged(v)),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm phim, diễn viên...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          if (state.keyword.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
              onPressed: () {
                controller.clear();
                bloc.add(const SearchKeywordChanged(''));
              },
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onTap;
  const _FilterButton({required this.hasFilter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: IconButton(
            icon: Icon(Icons.tune_rounded,
                color: hasFilter ? AppColors.primary : Colors.white70, size: 20),
            onPressed: onTap,
          ),
        ),
        if (hasFilter)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
