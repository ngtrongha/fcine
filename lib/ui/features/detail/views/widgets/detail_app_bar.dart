import 'package:flutter/material.dart';
import '../../../../../presentation/theme/app_theme.dart';

class DetailAppBar extends StatelessWidget {
  final bool showTitle;
  final String title;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  const DetailAppBar({super.key, required this.showTitle, required this.title, required this.isBookmarked, required this.onBack, required this.onBookmark});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: showTitle ? AppColors.background.withValues(alpha: 0.95) : Colors.transparent,
      elevation: showTitle ? 4 : 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(backgroundColor: Colors.black.withValues(alpha: 0.30), child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: onBack)),
      ),
      title: showTitle ? Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)) : null,
      actions: [IconButton(icon: isBookmarked ? const Icon(Icons.bookmark_rounded, color: AppColors.primary) : const Icon(Icons.bookmark_border_rounded, color: Colors.white), onPressed: onBookmark)],
    );
  }
}
