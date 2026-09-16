import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hiển thị khi app chưa có URL nguồn do user nhập.
/// App lúc này là 1 phần mềm player video thuần túy.
class NoSourcePlaceholder extends StatelessWidget {
  final String title;
  final String message;
  final bool showLibraryHint;

  const NoSourcePlaceholder({
    super.key,
    this.title = 'Chưa có nguồn phim',
    this.message =
        'App đang chạy ở chế độ Player video.\nNhập URL nguồn phim để duyệt kho online, hoặc mở Player để xem file local / luồng mạng.',
    this.showLibraryHint = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF380B0F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE50914)),
              ),
              child: const Icon(
                Icons.play_circle_rounded,
                color: Color(0xFFE50914),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Mở trình phát'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/settings'),
                  icon: const Icon(Icons.add_link_rounded, size: 18),
                  label: const Text(
                    'Nhập URL nguồn',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            if (showLibraryHint) ...[
              const SizedBox(height: 16),
              const Text(
                'Tủ phim & file đã tải vẫn dùng bình thường ở chế độ offline.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
