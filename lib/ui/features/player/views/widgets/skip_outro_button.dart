import 'package:flutter/material.dart';

/// Nút "Bỏ qua outro" kiểu YouTube/Netflix: hiện khi phát vào vùng outro
/// (user đã đặt mốc), bấm để kết thúc tập và chuyển tập kế.
class SkipOutroButton extends StatelessWidget {
  final VoidCallback onTap;
  const SkipOutroButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bỏ qua outro',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.skip_next_rounded, color: Colors.black, size: 18),
          ],
        ),
      ),
    );
  }
}
