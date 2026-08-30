import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fcine/presentation/blocs/search/search_bloc.dart';
import 'package:fcine/presentation/blocs/search/search_event.dart';
import 'package:fcine/presentation/blocs/search/search_state.dart';
import 'package:fcine/presentation/theme/app_theme.dart';

class FilterSheet extends StatelessWidget {
  final SearchBloc bloc;
  final Map<String, String> categories, countries, years, types;
  const FilterSheet({
    super.key,
    required this.bloc,
    required this.categories,
    required this.countries,
    required this.years,
    required this.types,
  });

  static Future<void> show(BuildContext context,
      {required SearchBloc bloc,
      required Map<String, String> categories,
      required Map<String, String> countries,
      required Map<String, String> years,
      required Map<String, String> types}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => FilterSheet(bloc: bloc, categories: categories, countries: countries, years: years, types: types),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<SearchBloc, SearchState>(builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Bộ lọc nâng cao',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              FilterDropdownRow(
                label: 'Thể loại',
                items: categories,
                value: state.category,
                onChanged: (v) => bloc.add(SearchFilterChanged(
                    category: v.isEmpty ? null : v, country: state.country, year: state.year, type: state.type)),
              ),
              FilterDropdownRow(
                label: 'Quốc gia',
                items: countries,
                value: state.country,
                onChanged: (v) => bloc.add(SearchFilterChanged(
                    category: state.category, country: v.isEmpty ? null : v, year: state.year, type: state.type)),
              ),
              FilterDropdownRow(
                label: 'Năm',
                items: years,
                value: state.year,
                onChanged: (v) => bloc.add(SearchFilterChanged(
                    category: state.category, country: state.country, year: v.isEmpty ? null : v, type: state.type)),
              ),
              FilterDropdownRow(
                label: 'Loại phim',
                items: types,
                value: state.type,
                onChanged: (v) => bloc.add(SearchFilterChanged(
                    category: state.category, country: state.country, year: state.year, type: v.isEmpty ? null : v)),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      bloc.add(const SearchFilterChanged());
                      Navigator.pop(context);
                    },
                    child: const Text('Xóa lọc'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Áp dụng'))),
              ]),
            ]),
          ),
        );
      }),
    );
  }
}

class FilterDropdownRow extends StatelessWidget {
  final String label;
  final Map<String, String> items;
  final String? value;
  final ValueChanged<String> onChanged;
  const FilterDropdownRow({super.key, required this.label, required this.items, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value ?? '',
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            dropdownColor: AppColors.surface,
            items: items.entries
                .map((e) => DropdownMenuItem(
                    value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 13))))
                .toList(),
            onChanged: (v) => onChanged(v ?? ''),
          ),
        ),
      ]),
    );
  }
}
