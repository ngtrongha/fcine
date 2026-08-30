import 'package:flutter/material.dart';
import '../../../../../core/database/app_database.dart';

class StorageMeter extends StatelessWidget {
  final List<Download> downloads;
  const StorageMeter({super.key, required this.downloads});

  @override
  Widget build(BuildContext context) {
    final usedGb = downloads.where((d) => d.status == 'completed').length * 0.4;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(children: [
        const Icon(Icons.storage_rounded, color: Color(0xFFE50914), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bộ nhớ Offline: ${usedGb.toStringAsFixed(1)} GB / 128 GB',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (usedGb / 128).clamp(0.0, 1.0),
                backgroundColor: const Color(0xFF1E293B),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFE50914)),
                minHeight: 6,
              ),
            ),
          ]),
        ),
        TextButton(onPressed: () {}, child: const Text('Quản lý', style: TextStyle(color: Color(0xFFE50914), fontSize: 12))),
      ]),
    );
  }
}
