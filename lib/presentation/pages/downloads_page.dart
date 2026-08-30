import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/download_providers.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tải xuống')),
      body: downloadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('Chưa có tập nào được tải\nChọn "Tải" ở trang chi tiết', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)));
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, i) {
              final d = list[i];
              final isCompleted = d.status == 'completed';
              final isDownloading = d.status == 'downloading';
              final isFailed = d.status == 'failed';
              return ListTile(
                leading: Icon(isCompleted ? Icons.check_circle : isDownloading ? Icons.downloading : Icons.error, color: isCompleted ? Colors.green : isDownloading ? Colors.amber : Colors.redAccent),
                title: Text('${d.movieName} - ${d.episodeName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${d.serverName} • ${d.status} • ${d.progress}%', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: d.progress / 100, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(isCompleted ? Colors.green : isFailed ? Colors.red : Colors.amber)),
                  if (d.totalSegments > 0) Text('${d.downloadedSegments}/${d.totalSegments} segments', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                ]),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (isCompleted)
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill, color: Colors.deepPurpleAccent),
                      onPressed: () async {
                        // Mở player với local file
                        final file = File(d.localM3u8!);
                        if (!await file.exists()) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File local không tồn tại')));
                          return;
                        }
                        // Tạm: đi tới detail rồi người dùng tự chọn tập, hoặc mở player trực tiếp cần movie object
                        // Ở đây chỉ báo đường dẫn
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Local: ${d.localM3u8}')));
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white54, size: 20),
                    onPressed: () async {
                      final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Xóa bản tải?'), content: Text('${d.episodeName}'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa'))]));
                      if (ok == true) {
                        final service = ref.read(downloadServiceProvider);
                        await service.deleteDownload(d);
                      }
                    },
                  ),
                ]),
                onTap: () => context.push('/movie/${d.movieSlug}'),
              );
            },
          );
        },
      ),
    );
  }
}
