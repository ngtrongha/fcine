import 'package:flutter/material.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/download/download_service.dart';
import '../../../../../core/toast/app_toast.dart';
import '../../../../../domain/entities/episode.dart';
import '../../../../../domain/entities/movie.dart';
import '../../../../../presentation/theme/app_theme.dart';

/// Bottom-sheet chọn server + tập để tải offline.
/// Chỉ cho tải tập có link m3u8 trực tiếp (tập web embed không tải được).
class DownloadSheet extends StatefulWidget {
  final Movie movie;
  final List<EpisodeServer> servers;
  const DownloadSheet({super.key, required this.movie, required this.servers});

  @override
  State<DownloadSheet> createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<DownloadSheet> {
  late int _serverIndex;

  @override
  void initState() {
    super.initState();
    // Ưu tiên server đầu tiên có tập m3u8 tải được.
    _serverIndex = 0;
    for (int i = 0; i < widget.servers.length; i++) {
      if (widget.servers[i].episodes.any((e) => e.hasM3u8)) {
        _serverIndex = i;
        break;
      }
    }
  }

  Download? _statusFor(List<Download> downloads, Episode ep) {
    final server = widget.servers[_serverIndex];
    for (final d in downloads) {
      if (d.movieSlug == widget.movie.slug &&
          d.episodeSlug == ep.slug &&
          d.serverName == server.serverName) {
        return d;
      }
    }
    return null;
  }

  Future<void> _start(Episode ep) async {
    if (!ep.hasM3u8) {
      AppToast.show(
        context,
        message: 'Tập này không có link m3u8 để tải',
        type: ToastType.warning,
      );
      return;
    }
    final server = widget.servers[_serverIndex];
    try {
      await getIt<DownloadService>().startDownload(
        movieSlug: widget.movie.slug,
        movieName: widget.movie.name,
        posterUrl: widget.movie.posterUrl,
        episodeName: ep.name,
        episodeSlug: ep.slug,
        serverName: server.serverName,
        remoteM3u8: ep.m3u8Url!,
      );
      if (mounted) {
        AppToast.show(
          context,
          message: 'Đã thêm vào hàng tải: ${ep.name}',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Lỗi khi thêm tải: $e',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        hoverColor: Colors.white10,
      ),
      child: StreamBuilder<List<Download>>(
        stream: getIt<DownloadService>().watchAll(),
        builder: (context, snap) {
          final downloads = snap.data ?? const <Download>[];
          final server = widget.servers[_serverIndex];
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.download_rounded,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tải xuống - ${widget.movie.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.servers.length > 1)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < widget.servers.length; i++)
                          ChoiceChip(
                            label: Text(widget.servers[i].serverName),
                            selected: _serverIndex == i,
                            onSelected: (_) =>
                                setState(() => _serverIndex = i),
                            labelStyle: TextStyle(
                              color: _serverIndex == i
                                  ? Colors.white
                                  : const Color(0xFFCBD5E1),
                              fontSize: 12,
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: const Color(0xFF1E293B),
                            side: BorderSide(
                              color: _serverIndex == i
                                  ? AppColors.primary
                                  : const Color(0xFF334155),
                            ),
                          ),
                      ],
                    ),
                  if (widget.servers.length > 1) const SizedBox(height: 8),
                  Flexible(
                    child: server.episodes.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Server chưa có tập phim',
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: server.episodes.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, i) {
                              final ep = server.episodes[i];
                              final d = _statusFor(downloads, ep);
                              return _EpisodeRow(
                                episode: ep,
                                download: d,
                                onStart: () => _start(ep),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  final Episode episode;
  final Download? download;
  final VoidCallback onStart;
  const _EpisodeRow({
    required this.episode,
    required this.download,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final d = download;
    final bool completed = d?.status == 'completed';
    final bool downloading = d?.status == 'downloading';
    final bool failed = d?.status == 'failed';

    Widget trailing;
    if (completed) {
      trailing = const Icon(Icons.check_circle, color: Colors.green, size: 20);
    } else if (downloading) {
      final p = (d!.progress / 100).clamp(0.0, 1.0);
      trailing = SizedBox(
        width: 20,
        height: 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: p,
              strokeWidth: 2,
              color: Colors.amber,
              backgroundColor: const Color(0xFF1E293B),
            ),
          ],
        ),
      );
    } else {
      trailing = IconButton(
        onPressed: onStart,
        icon: Icon(
          failed ? Icons.refresh_rounded : Icons.download_rounded,
          color: failed ? Colors.amber : Colors.white70,
          size: 20,
        ),
        tooltip: failed ? 'Thử lại' : 'Tải tập này',
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  completed
                      ? 'Đã tải'
                      : downloading
                          ? 'Đang tải ${d!.progress}%'
                          : failed
                              ? 'Tải lỗi - bấm thử lại'
                              : episode.hasM3u8
                                  ? 'Sẵn sàng tải'
                                  : 'Không có link m3u8',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
