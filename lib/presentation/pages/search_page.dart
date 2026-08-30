import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/cache/image_cache_manager.dart';
import '../providers/movie_providers.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? debounce;
  String keyword = '';
  List allMovies = [];
  int page = 1;
  int totalPages = 1;
  bool isLoading = false;
  bool isLoadingMore = false;

  // Filters
  String? filterCategory;
  String? filterCountry;
  String? filterYear;
  String? filterType;

  // Recent
  List<String> recentSearches = [];
  static const _historyKey = 'search_history';

  final Map<String, String> categories = {
    '': 'Tất cả',
    'hanh-dong': 'Hành Động',
    'tinh-cam': 'Tình Cảm',
    'hai-huoc': 'Hài Hước',
    'co-trang': 'Cổ Trang',
    'tam-ly': 'Tâm Lý',
    'khoa-hoc': 'Khoa Học',
    'vien-tuong': 'Viễn Tưởng',
    'phieu-luu': 'Phiêu Lưu',
    'kinh-di': 'Kinh Dị',
  };
  final Map<String, String> countries = {
    '': 'Tất cả',
    'han-quoc': 'Hàn Quốc',
    'trung-quoc': 'Trung Quốc',
    'au-my': 'Âu Mỹ',
    'nhat-ban': 'Nhật Bản',
    'thai-lan': 'Thái Lan',
    'viet-nam': 'Việt Nam',
  };
  final Map<String, String> years = {
    '': 'Tất cả',
    '2026': '2026',
    '2025': '2025',
    '2024': '2024',
    '2023': '2023',
    '2022': '2022',
  };
  final Map<String, String> types = {
    '': 'Tất cả',
    'single': 'Phim Lẻ',
    'series': 'Phim Bộ',
    'hoathinh': 'Hoạt Hình',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => recentSearches = prefs.getStringList(_historyKey) ?? []);
  }

  Future<void> _saveRecent(String kw) async {
    if (kw.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    list.remove(kw);
    list.insert(0, kw);
    if (list.length > 10) list.removeLast();
    await prefs.setStringList(_historyKey, list);
    setState(() => recentSearches = list);
  }

  Future<void> _clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() => recentSearches = []);
  }

  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      if (!isLoadingMore && page < totalPages && keyword.isNotEmpty) _loadMore();
    }
  }

  void onChanged(String v) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        keyword = v.trim();
        allMovies = [];
        page = 1;
        totalPages = 1;
      });
      if (keyword.isNotEmpty) {
        _saveRecent(keyword);
        _search(page: 1);
      }
    });
  }

  Future<void> _search({required int page}) async {
    if (keyword.isEmpty) return;
    setState(() {
      if (page == 1) isLoading = true;
      else isLoadingMore = true;
    });
    try {
      final repo = ref.read(movieRepositoryProvider);
      final res = await repo.search(keyword, page: page, category: filterCategory, country: filterCountry, year: filterYear, type: filterType);
      setState(() {
        if (page == 1) {
          allMovies = res.movies;
        } else {
          allMovies = [...allMovies, ...res.movies];
        }
        this.page = page;
        totalPages = res.pagination.totalPages;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
    }
  }

  Future<void> _loadMore() async => _search(page: page + 1);

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bộ lọc nâng cao', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _filterDropdown('Thể loại', categories, filterCategory, (v) => setSheet(() => filterCategory = v.isEmpty ? null : v)),
                _filterDropdown('Quốc gia', countries, filterCountry, (v) => setSheet(() => filterCountry = v.isEmpty ? null : v)),
                _filterDropdown('Năm', years, filterYear, (v) => setSheet(() => filterYear = v.isEmpty ? null : v)),
                _filterDropdown('Loại phim', types, filterType, (v) => setSheet(() => filterType = v.isEmpty ? null : v)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () { setState(() { filterCategory = null; filterCountry = null; filterYear = null; filterType = null; }); Navigator.pop(ctx); if (keyword.isNotEmpty) _search(page: 1); }, child: const Text('Xóa lọc'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () { setState(() {}); Navigator.pop(ctx); if (keyword.isNotEmpty) _search(page: 1); }, child: const Text('Áp dụng'))),
                ]),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _filterDropdown(String label, Map<String, String> items, String? value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value ?? '',
              decoration: InputDecoration(filled: true, fillColor: Colors.white10, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
              dropdownColor: const Color(0xFF2A2A2E),
              items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => onChanged(v ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = filterCategory != null || filterCountry != null || filterYear != null || filterType != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên phim (vd: avengers, naruto)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: keyword.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { controller.clear(); onChanged(''); }) : null,
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.tune, color: hasFilter ? const Color(0xFFE50914) : Colors.white70),
                      onPressed: _openFilterSheet,
                      tooltip: 'Bộ lọc',
                    ),
                    if (hasFilter) Positioned(top: 8, right: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))),
                  ],
                ),
              ],
            ),
          ),
          if (hasFilter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(spacing: 6, children: [
                if (filterCategory != null) InputChip(label: Text(categories[filterCategory] ?? filterCategory!), onDeleted: () => setState(() => filterCategory = null)),
                if (filterCountry != null) InputChip(label: Text(countries[filterCountry] ?? filterCountry!), onDeleted: () => setState(() => filterCountry = null)),
                if (filterYear != null) InputChip(label: Text(filterYear!), onDeleted: () => setState(() => filterYear = null)),
                if (filterType != null) InputChip(label: Text(types[filterType] ?? filterType!), onDeleted: () => setState(() => filterType = null)),
              ]),
            ),
          if (keyword.isNotEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(alignment: Alignment.centerLeft, child: Text('Tìm thấy ${allMovies.length} / $totalPages trang', style: const TextStyle(fontSize: 12, color: Colors.white54))),
            ),
          const SizedBox(height: 6),
          Expanded(
            child: keyword.isEmpty
                ? recentSearches.isEmpty
                    ? const Center(child: Text('Nhập từ khóa để tìm kiếm\nHỗ trợ debounce 400ms + phân trang + bộ lọc', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)))
                    : ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text('Tìm kiếm gần đây', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              TextButton(onPressed: _clearRecent, child: const Text('Xóa', style: TextStyle(fontSize: 12))),
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final kw in recentSearches)
                                  InputChip(
                                    label: Text(kw),
                                    avatar: const Icon(Icons.history, size: 14),
                                    onPressed: () {
                                      controller.text = kw;
                                      onChanged(kw);
                                    },
                                    onDeleted: () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      final list = List<String>.from(recentSearches)..remove(kw);
                                      await prefs.setStringList(_historyKey, list);
                                      setState(() => recentSearches = list);
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Wrap(spacing: 8, children: [
                              for (final s in ['avengers', 'naruto', 'doraemon', 'one piece'])
                                ActionChip(label: Text(s), backgroundColor: Colors.white10, onPressed: () { controller.text = s; onChanged(s); }),
                            ]),
                          ),
                        ],
                      )
                : isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : allMovies.isEmpty
                        ? const Center(child: Text('Không tìm thấy'))
                        : ListView.separated(
                            controller: _scrollController,
                            itemCount: allMovies.length + (isLoadingMore ? 1 : 0),
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                            itemBuilder: (context, i) {
                              if (i >= allMovies.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                              final m = allMovies[i];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CachedNetworkImage(cacheManager: FImageCacheManager.instance, imageUrl: m.posterUrl, width: 50, height: 70, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(width: 50, height: 70, color: Colors.white10, child: const Icon(Icons.broken_image, size: 20))),
                                ),
                                title: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                subtitle: Text('${m.originName} • ${m.year} • ${m.quality ?? ""} • ${m.lang ?? ""}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                                onTap: () => context.push('/movie/${m.slug}'),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
