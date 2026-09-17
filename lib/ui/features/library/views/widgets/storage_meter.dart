import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/download/download_service.dart';
import '../../../../../presentation/blocs/library/library_bloc.dart';
import '../../../../../presentation/blocs/library/library_event.dart';

/// Tham chiếu dung lượng tối đa cho thanh tiến trình (dung lượng đĩa
/// thiết bị điển hình, không phải giới hạn cứng của app).
const int _kReferenceGb = 128;

String _formatSize(int bytes) {
  final gb = bytes / (1024 * 1024 * 1024);
  if (gb >= 1) return '${gb.toStringAsFixed(1)} GB';
  final mb = bytes / (1024 * 1024);
  if (mb >= 1) return '${mb.toStringAsFixed(0)} MB';
  return '${bytes ~/ 1024} KB';
}

class StorageMeter extends StatelessWidget {
  final List<Download> downloads;
  const StorageMeter({super.key, required this.downloads});

  @override
  Widget build(BuildContext context) {
    final completedCount = downloads.where((d) => d.status == 'completed').length;
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
          child: FutureBuilder<int>(
            future: getIt<DownloadService>().totalSizeOnDisk(),
            builder: (context, snap) {
              final usedBytes = snap.data ?? 0;
              final usedGb = usedBytes / (1024 * 1024 * 1024);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    completedCount == 0
                        ? 'Bộ nhớ Offline: trống'
                        : 'Bộ nhớ Offline: ${_formatSize(usedBytes)} • $completedCount bản',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (usedGb / _kReferenceGb).clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFF1E293B),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFE50914)),
                      minHeight: 6,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        TextButton(
          onPressed: () => context
              .read<LibraryBloc>()
              .add(const LibraryEvent.tabChanged(2)),
          child: const Text('Quản lý', style: TextStyle(color: Color(0xFFE50914), fontSize: 12)),
        ),
      ]),
    );
  }
}
