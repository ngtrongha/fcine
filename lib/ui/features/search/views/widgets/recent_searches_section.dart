import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fcine/presentation/blocs/search/search_bloc.dart';
import 'package:fcine/presentation/blocs/search/search_event.dart';
import 'package:fcine/presentation/theme/app_theme.dart';

class RecentSearchesSection extends StatelessWidget {
  final SearchBloc bloc;
  final List<String> recentSearches;
  final String currentKeyword;
  final ValueChanged<String> onSelect;

  const RecentSearchesSection({
    super.key,
    required this.bloc,
    required this.recentSearches,
    required this.currentKeyword,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tìm kiếm gần đây',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('search_history');
                    bloc.add(const SearchClear());
                  },
                  child: const Text(
                    'Xóa',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kw in recentSearches)
                  InputChip(
                    label: Text(kw),
                    avatar: const Icon(Icons.history_rounded, size: 14),
                    onPressed: () => onSelect(kw),
                    onDeleted: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final list = List<String>.from(recentSearches)..remove(kw);
                      await prefs.setStringList('search_history', list);
                      bloc.add(SearchKeywordChanged(currentKeyword));
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
