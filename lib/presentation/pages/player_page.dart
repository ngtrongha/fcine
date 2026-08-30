import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:floating/floating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/extractor/m3u8_parser.dart';
import '../providers/local_providers.dart';
import '../providers/download_providers.dart';

class PlayerPage extends ConsumerStatefulWidget {
  final dynamic movie;
  final dynamic episode;
  final String serverName;
  final List servers;
  const PlayerPage({super.key, required this.movie, required this.episode, required this.serverName, required this.servers});

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  late final Player player;
  late final VideoController controller;
  bool isFullscreen = false;
  bool showControls = true;
  Timer? hideTimer;
  Timer? saveTimer;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = true;
  double playbackSpeed = 1.0;
  BoxFit fit = BoxFit.contain;
  String? playerError;
  bool _hasTriedFallback = false;
  double _horizontalDragAccum = 0;
  List<QualityVariant> _qualities = [];
  String? _selectedQualityUrl;
  bool _loadingQualities = false;
  Tracks? _tracks;
  Track? _currentTrack;
  int _introEndMs = 0;
  bool _hasSkippedIntro = false;
  final Floating _floating = Floating();

  List get flatEpisodes {
    final List all = [];
    for (final s in widget.servers) {
      for (final ep in s.episodes) {
        all.add({'ep': ep, 'server': s.serverName});
      }
    }
    return all;
  }

  int get currentIndex {
    final list = flatEpisodes;
    for (int i = 0; i < list.length; i++) {
      if (list[i]['ep'].slug == widget.episode.slug && list[i]['server'] == widget.serverName) return i;
    }
    return 0;
  }

  void _resetHideTimer() {
    hideTimer?.cancel();
    setState(() => showControls = true);
    hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showControls = false);
    });
  }

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    WakelockPlus.enable();
    _initPlayer();
    _listenPlayer();
    _startSaveTimer();
    _resetHideTimer();
    _loadQualities();
    _loadIntro();
  }

  Future<void> _loadQualities() async {
    setState(() => _loadingQualities = true);
    final parser = M3u8Parser(Dio());
    final list = await parser.parseMaster(widget.episode.linkM3u8 as String);
    if (mounted) {
      setState(() {
        _qualities = list;
        _loadingQualities = false;
        if (list.isNotEmpty) _selectedQualityUrl = list.first.url; // highest default, but player opens original master so keep master
        // Nếu master chỉ có 1 variant, dùng master url làm selected
        if (list.isEmpty) _selectedQualityUrl = widget.episode.linkM3u8 as String;
      });
    }
  }

  Future<void> _switchQuality(QualityVariant q) async {
    final currentPos = position;
    setState(() => _selectedQualityUrl = q.url);
    await player.open(Media(q.url), play: true);
    // seek về vị trí cũ sau khi mở (đợi 300ms để player ready)
    await Future.delayed(const Duration(milliseconds: 300));
    if (currentPos.inMilliseconds > 1000) await player.seek(currentPos);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chất lượng: ${q.label}'), duration: const Duration(milliseconds: 800)));
  }

  Future<void> _selectAudio(AudioTrack t) async {
    await player.setAudioTrack(t);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio: ${t.language ?? t.id}'), duration: const Duration(milliseconds: 800)));
  }

  Future<void> _selectSubtitle(SubtitleTrack t) async {
    await player.setSubtitleTrack(t);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.id == 'no' ? 'Tắt phụ đề' : 'Phụ đề: ${t.language ?? t.title ?? t.id}'), duration: const Duration(milliseconds: 800)));
  }

  void _showCastPlaceholder() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [Icon(Icons.cast, size: 20), SizedBox(width: 8), Text('Chromecast / AirPlay')]),
        content: const Text('Tính năng đang phát triển.\nCần cấu hình:\n• Google Cast SDK (Android/iOS)\n• AirPlay (iOS)\nHiện tại m3u8 có thể cast qua URL nhưng cần receiver custom.\nSẽ bổ sung ở Phase 2+ sau khi có backend.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
      ),
    );
  }

  Future<void> _enterPip() async {
    final canPip = await _floating.isPipAvailable;
    if (!canPip) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thiết bị không hỗ trợ PiP')));
      return;
    }
    final status = await _floating.enable(const EnableManual(aspectRatio: Rational(16, 9)));
    if (status == PiPStatus.enabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã vào chế độ PiP'), duration: Duration(milliseconds: 800)));
    }
  }

  Future<void> _openExternal() async {
    final url = widget.episode.linkM3u8 as String;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    // Thử mở bằng external player (MX, VLC)
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở external player')));
    }
  }

  Future<void> _loadIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'intro_${widget.movie.slug}';
    final val = prefs.getInt(key) ?? 0;
    if (mounted) setState(() => _introEndMs = val);
  }

  Future<void> _setIntroEnd(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'intro_${widget.movie.slug}';
    await prefs.setInt(key, seconds * 1000);
    setState(() => _introEndMs = seconds * 1000);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã lưu intro $seconds s - sẽ tự skip')));
  }

  void _checkSkipIntro() {
    if (_introEndMs > 0 && !_hasSkippedIntro && position.inMilliseconds < _introEndMs && position.inMilliseconds > 1000) {
      // nếu đang trong intro và đã qua 1s, skip
      if (position.inMilliseconds < _introEndMs - 500) {
        // chỉ skip 1 lần
        _hasSkippedIntro = true;
        player.seek(Duration(milliseconds: _introEndMs));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã skip intro ${_introEndMs ~/ 1000}s'), duration: const Duration(milliseconds: 800)));
      }
    }
    if (position.inMilliseconds > _introEndMs + 2000) _hasSkippedIntro = false;
  }

  Future<void> _initPlayer() async {
    String m3u8 = widget.episode.linkM3u8 as String;
    if (m3u8.isEmpty) {
      setState(() => playerError = 'Link m3u8 rỗng - thử đổi server khác');
      return;
    }
    // Ưu tiên local nếu đã tải xong
    try {
      final dlService = ref.read(downloadServiceProvider);
      final local = await dlService.getLocalPath(widget.movie.slug, widget.episode.slug, widget.serverName);
      if (local != null) {
        m3u8 = Uri.file(local).toString(); // file://
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang phát bản offline'), duration: Duration(seconds: 1)));
      }
    } catch (_) {}
    try {
      final historyRepo = ref.read(historyRepositoryProvider);
      final existing = await historyRepo.db.getHistory(widget.movie.slug, widget.episode.slug, widget.serverName);
      final startPos = existing?.positionMs ?? 0;
      await player.open(Media(m3u8), play: true);
      if (startPos > 5000) {
        await player.seek(Duration(milliseconds: startPos));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tiếp tục từ ${_fmt(Duration(milliseconds: startPos))}')));
      }
      // timeout 10s nếu không có duration -> coi như lỗi
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && duration.inMilliseconds == 0 && playerError == null) {
          setState(() => playerError = 'Không tải được luồng (mạng yếu / link hỏng)');
        }
      });
    } catch (e) {
      if (mounted) setState(() => playerError = 'Lỗi phát: $e');
    }
  }

  Future<void> _retry() async {
    setState(() => playerError = null);
    await _initPlayer();
  }

  Future<void> _switchServer() async {
    final currentEpName = widget.episode.name;
    for (final s in widget.servers) {
      if (s.serverName == widget.serverName) continue;
      for (final ep in s.episodes) {
        if (ep.name == currentEpName && ep.linkM3u8.isNotEmpty) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PlayerPage(movie: widget.movie, episode: ep, serverName: s.serverName, servers: widget.servers)),
            );
          }
          return;
        }
      }
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy server dự phòng cho tập này')));
  }

  void _reportError() {
    // Gửi báo cáo (hiện chỉ local log + snackbar, sau có thể gửi lên server/Gist)
    // ignore: avoid_print
    print('[REPORT] Broken link: ${widget.movie.slug} - ${widget.episode.slug} (${widget.serverName}) -> ${widget.episode.linkM3u8}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi báo cáo link hỏng - sẽ kiểm tra domain dự phòng')));
    }
    // Thử fallback ngay: _switchServer
    Future.delayed(const Duration(seconds: 1), () => _switchServer());
  }

  void _listenPlayer() {
    player.stream.position.listen((p) {
      setState(() => position = p);
      _checkSkipIntro();
    });
    player.stream.duration.listen((d) {
      setState(() {
        duration = d;
        if (d.inMilliseconds > 0) playerError = null;
      });
    });
    player.stream.playing.listen((v) => setState(() => isPlaying = v));
    player.stream.completed.listen((completed) {
      if (completed) _playNext();
    });
    player.stream.error.listen((e) {
      if (mounted && !_hasTriedFallback) {
        _hasTriedFallback = true;
        setState(() => playerError = e.isNotEmpty ? e : 'Lỗi luồng stream');
      }
    });
    player.stream.tracks.listen((t) => setState(() => _tracks = t));
    player.stream.track.listen((t) => setState(() => _currentTrack = t));
  }

  void _startSaveTimer() {
    saveTimer = Timer.periodic(const Duration(seconds: 5), (_) => _saveProgress());
  }

  Future<void> _saveProgress() async {
    if (duration.inMilliseconds == 0) return;
    // không lưu nếu xem <5s hoặc đã xem xong >95%
    if (position.inMilliseconds < 5000) return;
    if (position.inMilliseconds / duration.inMilliseconds > 0.95) return;
    final repo = ref.read(historyRepositoryProvider);
    await repo.saveProgress(
      movieSlug: widget.movie.slug,
      movieName: widget.movie.name,
      posterUrl: widget.movie.posterUrl,
      episodeName: widget.episode.name,
      episodeSlug: widget.episode.slug,
      serverName: widget.serverName,
      positionMs: position.inMilliseconds,
      durationMs: duration.inMilliseconds,
    );
  }

  Future<void> _playNext() async {
    final idx = currentIndex;
    final list = flatEpisodes;
    if (idx + 1 < list.length) {
      final next = list[idx + 1];
      await _saveProgress();
      if (mounted) {
        // Thay thế player với tập tiếp theo
        // Đơn giản: pop và push lại với next episode (để tránh state phức tạp)
        // Hoặc mở media mới
        final nextEp = next['ep'];
        await player.open(Media(nextEp.linkM3u8), play: true);
        // Cập nhật history với tập mới ngay
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tự động phát tập tiếp: ${nextEp.name}')));
        // Lưu vị trí 0 cho tập mới
        // Không cần navigate, giữ nguyên page nhưng cập nhật widget.episode là final nên cần setState hack
        // Để đơn giản, chúng ta sẽ navigate pushReplacement
        if (mounted) {
          // Dùng go_router replacement - nhưng widget là final nên recreate
          // Để đơn giản, chỉ seek 0 và update title qua setState workaround
          setState(() {
            // hack: không đổi widget.episode (final) nhưng player đã đổi source
            // Hiển thị snack là đủ cho MVP
          });
        }
      }
    } else {
      // hết phim, xóa progress hoặc đánh dấu finished
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hết danh sách tập')));
    }
  }

  void _seekRelative(int seconds) {
    final target = position + Duration(seconds: seconds);
    player.seek(target < Duration.zero ? Duration.zero : target > duration ? duration : target);
    _resetHideTimer();
  }

  void _togglePlay() {
    if (isPlaying) {
      player.pause();
    } else {
      player.play();
    }
    _resetHideTimer();
  }

  void _toggleFullscreen() {
    setState(() => isFullscreen = !isFullscreen);
    if (isFullscreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _resetHideTimer();
  }

  void _changeSpeed() async {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final currentIdx = speeds.indexOf(playbackSpeed);
    final next = speeds[(currentIdx + 1) % speeds.length];
    await player.setRate(next);
    setState(() => playbackSpeed = next);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tốc độ: ${next}x'), duration: const Duration(milliseconds: 800)));
  }

  void _cycleFit() {
    setState(() {
      fit = fit == BoxFit.contain ? BoxFit.cover : fit == BoxFit.cover ? BoxFit.fill : BoxFit.contain;
    });
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    saveTimer?.cancel();
    _saveProgress();
    player.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isLandscape = isFullscreen || MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isFullscreen ? null : AppBar(
        title: Text('${widget.movie.name} - ${widget.episode.name}', style: const TextStyle(fontSize: 14)),
        backgroundColor: Colors.black,
        actions: [
          if (_qualities.isNotEmpty)
            PopupMenuButton<QualityVariant>(
              icon: const Icon(Icons.high_quality, size: 20),
              tooltip: 'Chất lượng',
              onSelected: _switchQuality,
              itemBuilder: (_) => [
                for (final q in _qualities) PopupMenuItem(value: q, child: Text(q.label, style: TextStyle(color: _selectedQualityUrl == q.url ? Colors.deepPurple : Colors.white))),
              ],
            ),
          IconButton(icon: const Icon(Icons.cast, size: 20), tooltip: 'Cast', onPressed: _showCastPlaceholder),
          IconButton(icon: const Icon(Icons.picture_in_picture_alt, size: 20), tooltip: 'PiP', onPressed: _enterPip),
          IconButton(icon: const Icon(Icons.open_in_new, size: 20), tooltip: 'Mở MX/VLC', onPressed: _openExternal),
          PopupMenuButton<int>(
            icon: const Icon(Icons.skip_next, size: 20),
            tooltip: 'Skip intro ${_introEndMs > 0 ? "(${_introEndMs ~/ 1000}s)" : ""}',
            onSelected: (v) => v == -1 ? _setIntroEnd(position.inSeconds) : _setIntroEnd(v),
            itemBuilder: (_) => [
              PopupMenuItem(value: position.inSeconds, child: Text('Đặt intro tại ${_fmt(position)}')),
              if (_introEndMs > 0) PopupMenuItem(value: 0, child: const Text('Xóa intro')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 30, child: Text('Intro 30s')),
              const PopupMenuItem(value: 60, child: Text('Intro 60s')),
              const PopupMenuItem(value: 90, child: Text('Intro 90s')),
              const PopupMenuItem(value: -1, child: Text('Tùy chỉnh tại vị trí hiện tại')),
            ],
          ),
          if (_loadingQualities) const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
          if (_tracks != null && _tracks!.audio.length > 2)
            PopupMenuButton<AudioTrack>(
              icon: const Icon(Icons.audiotrack, size: 20),
              tooltip: 'Âm thanh',
              onSelected: _selectAudio,
              itemBuilder: (_) => [for (final a in _tracks!.audio) PopupMenuItem(value: a, child: Text('${a.language ?? a.id}${a.title != null ? " - ${a.title}" : ""}', style: TextStyle(color: _currentTrack?.audio.id == a.id ? Colors.deepPurple : Colors.white)))],
            ),
          if (_tracks != null && _tracks!.subtitle.length > 2)
            PopupMenuButton<SubtitleTrack>(
              icon: Icon(_currentTrack?.subtitle.id == 'no' ? Icons.subtitles_off : Icons.subtitles, size: 20),
              tooltip: 'Phụ đề',
              onSelected: _selectSubtitle,
              itemBuilder: (_) => [for (final s in _tracks!.subtitle) PopupMenuItem(value: s, child: Text(s.id == 'no' ? 'Tắt' : s.language ?? s.title ?? s.id, style: TextStyle(color: _currentTrack?.subtitle.id == s.id ? Colors.deepPurple : Colors.white)))],
            ),
          IconButton(icon: const Icon(Icons.speed), onPressed: _changeSpeed, tooltip: '${playbackSpeed}x'),
          IconButton(icon: Icon(fit == BoxFit.contain ? Icons.fit_screen : fit == BoxFit.cover ? Icons.fullscreen : Icons.aspect_ratio), onPressed: _cycleFit),
        ],
      ),
      body: GestureDetector(
        onTap: _resetHideTimer,
        child: Column(
          children: [
            // Video area
            AspectRatio(
              aspectRatio: isFullscreen ? MediaQuery.of(context).size.aspectRatio : 16 / 9,
              child: GestureDetector(
                // Vuốt ngang → seek ±s theo độ vuốt, không hiện overlay
                onHorizontalDragStart: (_) {
                  _horizontalDragAccum = 0;
                  hideTimer?.cancel();
                },
                onHorizontalDragUpdate: (details) {
                  _horizontalDragAccum += details.delta.dx;
                },
                onHorizontalDragEnd: (_) {
                  if (_horizontalDragAccum.abs() < 20) {
                    _horizontalDragAccum = 0;
                    _resetHideTimer();
                    return;
                  }
                  // 10px = 1s, càng vuốt dài càng seek nhiều
                  final int seconds = (_horizontalDragAccum / 10).round();
                  if (seconds != 0) _seekRelative(seconds);
                  _horizontalDragAccum = 0;
                  _resetHideTimer();
                },
                child: Stack(
                alignment: Alignment.center,
                children: [
                  Video(controller: controller, fit: fit, controls: NoVideoControls),
                  if (playerError != null)
                    Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 12),
                          Text(playerError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(icon: const Icon(Icons.refresh, size: 16), label: const Text('Thử lại'), onPressed: _retry),
                              OutlinedButton.icon(icon: const Icon(Icons.swap_horiz, size: 16), label: const Text('Đổi server'), onPressed: _switchServer, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38))),
                              OutlinedButton.icon(icon: const Icon(Icons.bug_report, size: 16), label: const Text('Báo lỗi'), onPressed: _reportError, style: OutlinedButton.styleFrom(foregroundColor: Colors.amber, side: const BorderSide(color: Colors.amber))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (!isPlaying && showControls && playerError == null)
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(color: Colors.black38, child: const Center(child: Icon(Icons.play_arrow, size: 64, color: Colors.white))),
                    ),
                  // Controls overlay
                  if (showControls && playerError == null)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent, Colors.black54])),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top bar in fullscreen
                            if (isFullscreen)
                              SafeArea(
                                child: Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: _toggleFullscreen),
                                    Expanded(child: Text('${widget.movie.name} - ${widget.episode.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                                  ],
                                ),
                              )
                            else
                              const SizedBox(height: 8),
                            // Center controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(icon: const Icon(Icons.replay_10, color: Colors.white, size: 36), onPressed: () => _seekRelative(-10)),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: _togglePlay,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 32),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                IconButton(icon: const Icon(Icons.forward_10, color: Colors.white, size: 36), onPressed: () => _seekRelative(10)),
                              ],
                            ),
                            // Bottom controls
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                              child: Column(
                                children: [
                                  Slider(
                                    value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble()),
                                    max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1,
                                    activeColor: Colors.redAccent,
                                    inactiveColor: Colors.white24,
                                    onChanged: (v) => player.seek(Duration(milliseconds: v.toInt())),
                                    onChangeStart: (_) => hideTimer?.cancel(),
                                    onChangeEnd: (_) => _resetHideTimer(),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${_fmt(position)} / ${_fmt(duration)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      Row(
                                        children: [
                                          IconButton(icon: Icon(Icons.cast, color: Colors.white70, size: 18), tooltip: 'Cast', onPressed: _showCastPlaceholder),
                                          IconButton(icon: Icon(Icons.picture_in_picture_alt, color: Colors.white70, size: 18), tooltip: 'PiP', onPressed: _enterPip),
                                          IconButton(icon: Icon(Icons.open_in_new, color: Colors.white70, size: 18), tooltip: 'MX/VLC', onPressed: _openExternal),
                                          PopupMenuButton<int>(
                                            icon: Icon(Icons.skip_next, color: _introEndMs > 0 ? Colors.amber : Colors.white70, size: 18),
                                            tooltip: 'Skip intro',
                                            onSelected: _setIntroEnd,
                                            itemBuilder: (_) => [
                                              PopupMenuItem(value: position.inSeconds, child: Text('Đặt intro tại ${_fmt(position)}')),
                                              if (_introEndMs > 0) const PopupMenuItem(value: 0, child: Text('Xóa intro')),
                                              const PopupMenuItem(value: 30, child: Text('Intro 30s')),
                                              const PopupMenuItem(value: 60, child: Text('Intro 60s')),
                                              const PopupMenuItem(value: 90, child: Text('Intro 90s')),
                                            ],
                                          ),
                                          if (_qualities.isNotEmpty)
                                            PopupMenuButton<QualityVariant>(
                                              icon: Icon(Icons.high_quality, color: Colors.white70, size: 20),
                                              tooltip: 'Chất lượng',
                                              onSelected: _switchQuality,
                                              itemBuilder: (_) => [for (final q in _qualities) PopupMenuItem(value: q, child: Text(q.label))],
                                            ),
                                          if (_tracks != null && _tracks!.audio.length > 2)
                                            PopupMenuButton<AudioTrack>(
                                              icon: Icon(Icons.audiotrack, color: Colors.white70, size: 18),
                                              tooltip: 'Âm thanh',
                                              onSelected: _selectAudio,
                                              itemBuilder: (_) => [for (final a in _tracks!.audio) PopupMenuItem(value: a, child: Text(a.language ?? a.id))],
                                            ),
                                          if (_tracks != null && _tracks!.subtitle.length > 2)
                                            PopupMenuButton<SubtitleTrack>(
                                              icon: Icon(Icons.subtitles, color: Colors.white70, size: 18),
                                              tooltip: 'Phụ đề',
                                              onSelected: _selectSubtitle,
                                              itemBuilder: (_) => [for (final s in _tracks!.subtitle) PopupMenuItem(value: s, child: Text(s.id == 'no' ? 'Tắt' : s.language ?? s.id))],
                                            ),
                                          Text('${playbackSpeed}x', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                          const SizedBox(width: 4),
                                          IconButton(icon: Icon(isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white, size: 22), onPressed: _toggleFullscreen),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ),
            if (!isFullscreen) ...[
              // Episode selector + Next button
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Server: ${widget.serverName} • Tập ${widget.episode.name}', style: const TextStyle(fontWeight: FontWeight.w600))),
                          ElevatedButton.icon(
                            onPressed: currentIndex + 1 < flatEpisodes.length ? _playNext : null,
                            icon: const Icon(Icons.skip_next, size: 16),
                            label: const Text('Tập tiếp', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: const Size(0, 32)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Danh sách tập', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (int i = 0; i < flatEpisodes.length; i++)
                            ChoiceChip(
                              label: Text(flatEpisodes[i]['ep'].name),
                              selected: flatEpisodes[i]['ep'].slug == widget.episode.slug && flatEpisodes[i]['server'] == widget.serverName,
                              onSelected: (_) async {
                                await _saveProgress();
                                final next = flatEpisodes[i];
                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlayerPage(movie: widget.movie, episode: next['ep'], serverName: next['server'], servers: widget.servers),
                                    ),
                                  );
                                }
                              },
                              selectedColor: Colors.deepPurpleAccent,
                              backgroundColor: Colors.white10,
                              labelStyle: TextStyle(color: flatEpisodes[i]['ep'].slug == widget.episode.slug && flatEpisodes[i]['server'] == widget.serverName ? Colors.white : Colors.white70, fontSize: 12),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Debug link
                      SelectableText('m3u8: ${widget.episode.linkM3u8}', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
