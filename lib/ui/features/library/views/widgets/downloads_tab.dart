import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/download/download_service.dart';
import '../../../../../core/toast/app_toast.dart';
import '../../../../../presentation/blocs/library/library_bloc.dart';
import '../../../../../presentation/blocs/library/library_event.dart';
class DownloadsTab extends StatelessWidget {
  final List<Download> items;
  const DownloadsTab({super.key, required this.items});

  void _retry(BuildContext context, Download d) {
    try {
      getIt<DownloadService>().startDownload(
        movieSlug: d.movieSlug,
        movieName: d.movieName,
        posterUrl: d.posterUrl,
        episodeName: d.episodeName,
        episodeSlug: d.episodeSlug,
        serverName: d.serverName,
        remoteM3u8: d.remoteM3u8,
      );
      AppToast.show(
        context,
        message: 'Đã thêm lại vào hàng tải: ${d.episodeName}',
        type: ToastType.success,
      );
    } catch (e) {
      AppToast.show(
        context,
        message: 'Lỗi khi thử lại: $e',
        type: ToastType.error,
      );
    }
  }

  void _delete(BuildContext context, Download d) {
    context.read<LibraryBloc>().add(LibraryEvent.deleteDownload(d));
    AppToast.show(
      context,
      message: 'Đã xóa bản tải: ${d.episodeName}',
      type: ToastType.success,
    );
  }

  void _cancel(BuildContext context, Download d) {
    getIt<DownloadService>().cancelDownload(d.id);
    AppToast.show(
      context,
      message: 'Đã huỷ tải: ${d.episodeName}',
      type: ToastType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Chưa có bản tải', style: TextStyle(color: Color(0xFF94A3B8))));
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final d = items[i];
        final failed = d.status == 'failed';
        final cancelled = d.status == 'cancelled';
        final completed = d.status == 'completed';
        final active = !completed && !failed && !cancelled;
        final Color statusColor = completed
            ? Colors.green
            : failed
                ? Colors.red
                : cancelled
                    ? const Color(0xFF94A3B8)
                    : Colors.amber;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF111622), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
          child: Row(children: [
            Icon(completed ? Icons.check_circle : (failed ? Icons.error_outline : (cancelled ? Icons.cancel : Icons.downloading)), color: statusColor),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${d.movieName} - ${d.episodeName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${d.serverName} • ${completed ? 'Đã tải' : failed ? 'Tải lỗi' : cancelled ? 'Đã huỷ' : '${d.progress}%'}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              const SizedBox(height: 4),
              if (active) ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: d.progress / 100, backgroundColor: const Color(0xFF1E293B), valueColor: AlwaysStoppedAnimation(statusColor), minHeight: 4)),
            ])),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
              tooltip: 'Tuỳ chọn',
              color: const Color(0xFF1E293B),
              onSelected: (action) {
                if (action == 'retry') _retry(context, d);
                if (action == 'cancel') _cancel(context, d);
                if (action == 'delete') _delete(context, d);
              },
              itemBuilder: (_) => [
                if (!active)
                  const PopupMenuItem(
                    value: 'retry',
                    height: 40,
                    child: Row(children: [
                      Icon(Icons.refresh_rounded, color: Colors.amber, size: 18),
                      SizedBox(width: 10),
                      Text('Tải lại', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ]),
                  ),
                if (active)
                  const PopupMenuItem(
                    value: 'cancel',
                    height: 40,
                    child: Row(children: [
                      Icon(Icons.cancel_outlined, color: Color(0xFF94A3B8), size: 18),
                      SizedBox(width: 10),
                      Text('Huỷ', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ]),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  height: 40,
                  child: Row(children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                    SizedBox(width: 10),
                    Text('Xóa', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ]),
                ),
              ],
            ),
          ]),
        );
      },
    );
  }
}
