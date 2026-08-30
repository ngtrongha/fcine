import 'package:flutter/material.dart';
import '../../../../../core/database/app_database.dart';

class DownloadsTab extends StatelessWidget {
  final List<Download> items;
  const DownloadsTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Chưa có bản tải', style: TextStyle(color: Color(0xFF94A3B8))));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final d = items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
          child: Row(children: [
            Icon(d.status == 'completed' ? Icons.check_circle : Icons.downloading, color: d.status == 'completed' ? Colors.green : Colors.amber),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${d.movieName} - ${d.episodeName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${d.serverName} • ${d.progress}%', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              const SizedBox(height: 4),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: d.progress / 100, backgroundColor: const Color(0xFF1E293B), valueColor: AlwaysStoppedAnimation(d.status == 'completed' ? Colors.green : Colors.amber), minHeight: 4)),
            ])),
            const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
          ]),
        );
      },
    );
  }
}
