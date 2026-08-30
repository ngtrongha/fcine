import 'package:flutter/material.dart';
import 'package:fcine/presentation/theme/app_theme.dart';

class TrendingChips extends StatelessWidget {
  final List<String> keywords;
  final ValueChanged<String> onSelected;

  const TrendingChips({
    super.key,
    required this.keywords,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: keywords.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.20),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.20),
                ),
              ),
              child: const Row(
                children: [
                  Text('🔥', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Text(
                    'Xu Hướng:',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }
          final kw = keywords[i - 1];
          return ActionChip(
            label: Text(
              kw,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            backgroundColor: AppColors.surface,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
            onPressed: () => onSelected(kw),
          );
        },
      ),
    );
  }
}
