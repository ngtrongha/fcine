import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/entities.dart';
import 'package:flutter_chrome_cast/enums.dart';

import '../../../../../core/cast/cast_service.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/toast/app_toast.dart';

String _fmt(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// Bottom sheet Chromecast: tìm TV cùng WiFi -> kết nối -> đẩy phim đang
/// xem lên TV -> điều khiển phát/dừng/tua/ngắt ngay trong sheet.
class CastSheet extends StatefulWidget {
  /// URL http(s) m3u8/mp4 đang phát (dùng đúng link local player đang mở).
  final String videoUrl;
  final String title;
  final String subtitle;

  /// Vị trí đang xem trên máy — TV phát tiếp từ đây.
  final Duration startPosition;

  /// Page pause máy + đánh dấu pause chủ động khi TV đã nhận phim.
  final VoidCallback onCastingStarted;

  /// Page bỏ đánh dấu pause khi ngắt kết nối.
  final VoidCallback onCastingStopped;

  const CastSheet({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.subtitle,
    required this.startPosition,
    required this.onCastingStarted,
    required this.onCastingStopped,
  });

  @override
  State<CastSheet> createState() => _CastSheetState();
}

class _CastSheetState extends State<CastSheet> {
  late final CastService _cast = getIt<CastService>();
  bool _busy = false;
  String? _busyMsg;
  String? _error;
  bool _dragging = false;
  double _dragValue = 0;

  @override
  void initState() {
    super.initState();
    _cast.ensureInitialized().then((_) {
      if (mounted) _cast.startDiscovery();
    });
  }

  @override
  void dispose() {
    _cast.stopDiscovery();
    super.dispose();
  }

  Future<void> _connectAndCast(GoogleCastDevice d) async {
    setState(() {
      _busy = true;
      _busyMsg = 'Đang kết nối ${d.friendlyName}...';
      _error = null;
    });
    final ok = await _cast.connect(d);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _busy = false;
        _error = 'Không kết nối được ${d.friendlyName} - kiểm tra cùng WiFi';
      });
      return;
    }
    setState(() => _busyMsg = 'Đang đẩy phim lên TV...');
    final loaded = await _cast.castMovie(
      videoUrl: widget.videoUrl,
      title: widget.title,
      subtitle: widget.subtitle,
      startAt: widget.startPosition,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!loaded) {
      setState(() => _error = 'TV không nhận link này');
      await _cast.disconnect();
      return;
    }
    widget.onCastingStarted();
  }

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    await _cast.disconnect();
    widget.onCastingStopped();
    if (mounted) {
      setState(() => _busy = false);
      AppToast.show(
        context,
        message: 'Đã ngắt TV - bấm phát để xem tiếp trên máy',
        type: ToastType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cast_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Phát lên TV',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (!isCastableUrl(widget.videoUrl))
              _notice(
                Icons.info_outline_rounded,
                'Link này không cast được (phim offline trong máy hoặc định dạng lạ). Hãy phát bản online.',
              )
            else
              StreamBuilder<GoogleCastSession?>(
                stream: _cast.sessionStream(),
                builder: (context, snap) {
                  final session = snap.data;
                  if (session == null) return _deviceList();
                  return _remoteControls(session);
                },
              ),
            if (_busy) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _busyMsg ?? 'Đang xử lý...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              _notice(Icons.error_outline_rounded, _error!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _notice(IconData icon, String text) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _deviceList() => StreamBuilder<List<GoogleCastDevice>>(
    stream: _cast.devicesStream(),
    builder: (context, snap) {
      final devices = snap.data ?? const <GoogleCastDevice>[];
      if (devices.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đang tìm TV/Chromecast cùng WiFi...\nMở phim trên TV rồi đảm bảo 2 máy chung 1 WiFi.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, i) {
            final d = devices[i];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.tv_rounded,
                color: Colors.white70,
              ),
              title: Text(
                d.friendlyName,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              subtitle: (d.modelName?.isNotEmpty ?? false)
                  ? Text(
                      d.modelName!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    )
                  : null,
              trailing: _busy
                  ? null
                  : const Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white54,
                    ),
              onTap: _busy ? null : () => _connectAndCast(d),
            );
          },
        ),
      );
    },
  );

  Widget _remoteControls(GoogleCastSession session) {
    final deviceName = session.device?.friendlyName ?? 'TV';
    return StreamBuilder<GoggleCastMediaStatus?>(
      stream: _cast.mediaStatusStream(),
      builder: (context, snap) {
        final status = snap.data;
        final state = status?.playerState;
        final isPlaying = state == CastMediaPlayerState.playing;
        final isBusy = state == CastMediaPlayerState.buffering ||
            state == CastMediaPlayerState.loading;
        final isError =
            state == CastMediaPlayerState.idle &&
            status?.idleReason == GoogleCastMediaIdleReason.error;
        final dur = status?.mediaInformation?.duration ?? Duration.zero;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.cast_connected_rounded,
                  color: Color(0xFF4ADE80),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đang phát trên $deviceName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isBusy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            if (isError) ...[
              const SizedBox(height: 8),
              _notice(
                Icons.error_outline_rounded,
                'TV không phát được link này (nguồn cần header riêng). Hãy xem trên máy.',
              ),
            ],
            if (dur.inMilliseconds > 0) ...[
              const SizedBox(height: 4),
              StreamBuilder<Duration>(
                stream: _cast.remotePositionStream(),
                builder: (context, posSnap) {
                  final posMs =
                      (posSnap.data ?? Duration.zero).inMilliseconds;
                  final durMs = dur.inMilliseconds;
                  final value = _dragging
                      ? _dragValue.clamp(0, durMs.toDouble()).toDouble()
                      : posMs.clamp(0, durMs).toDouble();
                  return Row(
                    children: [
                      Text(
                        _fmt(Duration(milliseconds: value.toInt())),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: value,
                          max: durMs.toDouble(),
                          onChanged: (v) => setState(() {
                            _dragging = true;
                            _dragValue = v;
                          }),
                          onChangeEnd: (v) {
                            setState(() => _dragging = false);
                            _cast.seek(
                              Duration(milliseconds: v.toInt()),
                            );
                          },
                        ),
                      ),
                      Text(
                        _fmt(dur),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: isPlaying ? 'Tạm dừng trên TV' : 'Phát tiếp trên TV',
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () => isPlaying ? _cast.pause() : _cast.play(),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : _disconnect,
                  icon: const Icon(
                    Icons.cast_connected_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  label: const Text(
                    'Ngắt kết nối',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Mở sheet cast từ trang phát.
void showCastSheet(
  BuildContext context, {
  required String videoUrl,
  required String title,
  required String subtitle,
  required Duration startPosition,
  required VoidCallback onCastingStarted,
  required VoidCallback onCastingStopped,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF111622),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (_) => CastSheet(
      videoUrl: videoUrl,
      title: title,
      subtitle: subtitle,
      startPosition: startPosition,
      onCastingStarted: onCastingStarted,
      onCastingStopped: onCastingStopped,
    ),
  );
}
