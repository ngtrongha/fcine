import 'package:flutter/material.dart';
import 'package:fcine/presentation/blocs/search/search_bloc.dart';
import 'package:fcine/presentation/blocs/search/search_event.dart';
import 'package:fcine/presentation/blocs/search/search_state.dart';
import 'package:fcine/presentation/theme/app_theme.dart';

class DesktopSidebar extends StatelessWidget {
  final SearchBloc bloc;
  final SearchState state;
  final Map<String, String> categories;
  final Map<String, String> years;

  const DesktopSidebar({
    super.key,
    required this.bloc,
    required this.state,
    required this.categories,
    required this.years,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.fromLTRB(24, 24, 0, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'GENRES',
              child: Column(
                children: [
                  for (final entry
                      in categories.entries
                          .where((e) => e.key.isNotEmpty)
                          .take(5))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: state.category == entry.key,
                            onChanged: (v) => bloc.add(
                              SearchFilterChanged(
                                category: v == true ? entry.key : null,
                                country: state.country,
                                year: state.year,
                                type: state.type,
                              ),
                            ),
                            activeColor: AppColors.primary,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.20),
                            ),
                          ),
                          Text(
                            entry.value,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'YEAR',
              child: DropdownButtonFormField<String>(
                initialValue: state.year ?? '',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                dropdownColor: AppColors.surface,
                items: years.entries
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(
                          e.value.isEmpty ? 'Tất cả' : e.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => bloc.add(
                  SearchFilterChanged(
                    category: state.category,
                    country: state.country,
                    year: v!.isEmpty ? null : v,
                    type: state.type,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
