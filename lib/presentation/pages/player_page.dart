import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:floating/floating.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/injection.dart';
import '../../core/download/download_service.dart';
import '../../core/extractor/m3u8_parser.dart';
import '../../core/toast/app_toast.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../data/datasources/web_scraper_datasource.dart';
import '../../data/repositories/history_repository.dart';
import '../../ui/features/player/logic/player_logic.dart';
import '../../ui/features/player/views/widgets/episode_drawer.dart';
import '../../ui/features/player/views/widgets/player_bottom_controls.dart';
import '../../ui/features/player/views/widgets/player_center_controls.dart';
import '../../ui/features/player/views/widgets/player_desktop_theater.dart';
import '../../ui/features/player/views/widgets/player_error_overlay.dart';
import '../../ui/features/player/views/widgets/player_settings_sheet.dart';
import '../../ui/features/player/views/widgets/player_top_bar.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';

class PlayerPage extends StatefulWidget {
  final dynamic movie;
  final dynamic episode;
  final String serverName;
  final List servers;
  const PlayerPage({
    super.key,
    required this.movie,
    required this.episode,
    required this.serverName,
    required this.servers,
  });
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  /// Player online đang phát tiếng — mở trang phát mới thì dừng trang cũ,
  /// đảm bảo không bao giờ có 2 tập phát chồng tiếng (kể cả khi stack
  /// navigation kẹt 2 trang do bấm trùng).
  static Player? _activeOnlinePlayer;

  late final Player player;
  late final VideoController controller;
  bool isFullscreen = false,
      showControls = true,
      _hasTriedFallback = false,
      _hasSkippedIntro = false,
      _loadingQualities = false,
      _resolvingStream = false,
      _showEpisodeDrawer = false,
      isPlaying = true,
      _muted = false;
  Timer? hideTimer, saveTimer;
  final List<StreamSubscription> _playerSubs = [];

  /// Tập + server ĐANG phát (khác widget.episode/widget.serverName sau
  /// khi tự động chuyển tập — widget không đổi vì không push trang mới).
  /// Mọi lưu resume/tra cứu history đều dùng 2 field này.
  late dynamic _episode;
  late String _serverName;

  /// Chung key với tab Video để 2 trình phát đồng bộ âm lượng thiết bị.
  static const _kVolumeKey = 'vlc_volume';
  Duration position = Duration.zero, duration = Duration.zero;
  double playbackSpeed = 1.0,
      _horizontalDragAccum = 0,
      _volume = 1,
      _brightness = 0.6;
  BoxFit fit = BoxFit.contain;
  String? playerError, _selectedQualityUrl;
  List<QualityVariant> _qualities = [];
  Tracks? _tracks;
  Track? _currentTrack;
  int _introEndMs = 0;
  final Floating _floating = Floating();
  final Map<String, String> _streamCache = {};
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
    final l = flatEpisodes;
    for (int i = 0; i < l.length; i++) {
      if (l[i]['ep'].slug == _episode.slug &&
          l[i]['server'] == _serverName) {
        return i;
      }
    }
    return 0;
  }

  void _resetHideTimer() {
    hideTimer?.cancel();
    setState(() => showControls = true);
    if (_showEpisodeDrawer) return;
    hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showControls = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _episode = widget.episode;
    _serverName = widget.serverName;
    player = Player();
    controller = VideoController(player);
    WakelockPlus.enable();
    _restoreVolume();
    _initPlayer();
    _listenPlayer();
    _startSaveTimer();
    _resetHideTimer();
    _loadQualities();
    _loadIntro();
  }

  /// Khôi phục âm lượng đã lưu (chung với tab Video) rồi đẩy vào player,
  /// để mở phim mới không bị reset về 100%.
  Future<void> _restoreVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = (prefs.getDouble(_kVolumeKey) ?? 1.0).clamp(0.0, 1.0);
      if (!mounted) return;
      setState(() {
        _volume = v;
        _muted = v == 0;
      });
      await player.setVolume(v * 100);
    } catch (_) {}
  }

  Future<void> _persistVolume(double v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kVolumeKey, v.clamp(0.0, 1.0));
    } catch (_) {}
  }

  Future<void> _loadQualities([String? url]) async {
    final m3u8 = url ?? (_episode.linkM3u8 as String? ?? '');
    if (m3u8.isEmpty || !m3u8.contains('.m3u8')) return;
    setState(() => _loadingQualities = true);
    try {
      final list = await QualityService.load(m3u8);
      if (!mounted) return;
      setState(() {
        _qualities = list;
        _loadingQualities = false;
        _selectedQualityUrl = list.isNotEmpty ? list.first.url : m3u8;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingQualities = false);
    }
  }

  Future<void> _switchQuality(QualityVariant q) async {
    setState(() => _selectedQualityUrl = q.url);
    await QualityService.switchQuality(player, q, position);
    if (!mounted) return;
    AppToast.show(
      context,
      message: 'Chất lượng: ${q.label}',
      type: ToastType.info,
    );
  }

  Future<void> _selectAudio(AudioTrack t) async {
    await player.setAudioTrack(t);
    if (!mounted) return;
    AppToast.show(
      context,
      message: 'Audio: ${t.language ?? t.id}',
      type: ToastType.info,
    );
  }

  Future<void> _selectSubtitle(SubtitleTrack t) async {
    await player.setSubtitleTrack(t);
    if (!mounted) return;
    AppToast.show(
      context,
      message: t.id == 'no'
          ? 'Tắt phụ đề'
          : 'Phụ đề: ${t.language ?? t.title ?? t.id}',
      type: ToastType.info,
    );
  }

  void _showCastPlaceholder() => showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cast, size: 20),
          SizedBox(width: 8),
          Text('Chromecast / AirPlay'),
        ],
      ),
      content: const Text(
        'Tính năng đang phát triển.\nCần Google Cast SDK / AirPlay. m3u8 có thể cast qua URL nhưng cần receiver custom.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
  Future<void> _enterPip() async {
    if (!await _floating.isPipAvailable) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Thiết bị không hỗ trợ PiP',
          type: ToastType.info,
        );
      }
      return;
    }
    final s = await _floating.enable(
      const ImmediatePiP(aspectRatio: Rational(16, 9)),
    );
    if (s == PiPStatus.enabled && mounted) {
      AppToast.show(
        context,
        message: 'Đã vào chế độ PiP',
        type: ToastType.success,
      );
    }
  }

  Future<void> _openExternal() async {
    final url = _episode.linkM3u8 as String;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (mounted) {
      AppToast.show(
        context,
        message: 'Không thể mở external player',
        type: ToastType.warning,
      );
    }
  }

  Future<void> _loadIntro() async {
    final v = await IntroService.load(widget.movie.slug);
    if (mounted) setState(() => _introEndMs = v);
  }

  Future<void> _setIntroEnd(int sec) async {
    final ms = sec * 1000;
    await IntroService.save(widget.movie.slug, ms);
    setState(() => _introEndMs = ms);
    if (mounted) {
      AppToast.show(
        context,
        message: sec == 0 ? 'Đã xóa intro' : 'Đã lưu intro $sec s',
        type: ToastType.success,
      );
    }
  }

  void _checkSkipIntro() {
    if (!shouldSkipIntro(
      introEndMs: _introEndMs,
      hasSkipped: _hasSkippedIntro,
      pos: position,
    )) {
      if (position.inMilliseconds > _introEndMs + 2000) {
        _hasSkippedIntro = false;
      }
      return;
    }
    _hasSkippedIntro = true;
    player.seek(Duration(milliseconds: _introEndMs));
    if (mounted) {
      AppToast.show(
        context,
        message: 'Đã skip intro ${_introEndMs ~/ 1000}s',
        type: ToastType.success,
      );
    }
  }

  KeyEventResult _handleKey(KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.space) {
      _togglePlay();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _seekRelative(-10);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
      _seekRelative(10);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
      final v = (_volume + 0.05).clamp(0.0, 1.0);
      setState(() => _volume = v);
      player.setVolume(v * 100);
      _persistVolume(v);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
      final v = (_volume - 0.05).clamp(0.0, 1.0);
      setState(() => _volume = v);
      player.setVolume(v * 100);
      _persistVolume(v);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyF) {
      _toggleFullscreen();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyM) {
      setState(() => _muted = !_muted);
      player.setVolume(_muted ? 0 : _volume * 100);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Datasource web của phim đang xem (null với nguồn API).
  WebScraperDataSource? _webSource() {
    try {
      final sid = (widget.movie as dynamic)?.sourceId?.toString();
      if (sid == null || sid.isEmpty) return null;
      final ds = getIt<Map<String, RemoteDataSource>>()[sid];
      return ds is WebScraperDataSource ? ds : null;
    } catch (_) {
      return null;
    }
  }

  /// URL phát được của 1 tập (cache + resolve lazy cho nguồn web).
  Future<String?> _resolveEpisodeUrl(dynamic ep, String server) async {
    try {
      final direct = (ep.linkM3u8 as String?) ?? '';
      if (direct.isNotEmpty) return direct;
      final web = _webSource();
      final page = (ep.slug as String?) ?? '';
      if (web == null || page.isEmpty) return null;
      final key = '$server::$page';
      if (_streamCache.containsKey(key)) return _streamCache[key];
      final r = await web.resolveStream(page, serverName: server);
      final url = r.m3u8 ?? r.embed;
      if (url != null && url.isNotEmpty) _streamCache[key] = url;
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<void> _initPlayer() async {
    String m3u8 = (_episode.linkM3u8 as String?) ?? '';
    // Nguồn web: tập chỉ có URL trang tập -> băm lấy link phát (lazy).
    if (m3u8.isEmpty) {
      final web = _webSource();
      final page = (_episode.slug as String?) ?? '';
      if (web == null || page.isEmpty) {
        setState(() => playerError = 'Link m3u8 rỗng - thử đổi server khác');
        return;
      }
      setState(() {
        _resolvingStream = true;
        playerError = null;
      });
      final url = await _resolveEpisodeUrl(_episode, _serverName);
      if (!mounted) return;
      setState(() => _resolvingStream = false);
      if (url == null || url.isEmpty) {
        setState(
          () => playerError = 'Không bóc được link phát - thử đổi server khác',
        );
        return;
      }
      m3u8 = url;
      await _loadQualities(m3u8);
    }
    try {
      final local = await getIt<DownloadService>().getLocalPath(
        widget.movie.slug,
        _episode.slug,
        _serverName,
      );
      if (local != null) {
        m3u8 = Uri.file(local).toString();
        if (mounted) {
          AppToast.show(
            context,
            message: 'Đang phát bản offline',
            type: ToastType.info,
          );
        }
      }
    } catch (_) {}
    try {
      await player.open(Media(m3u8), play: true);
      _claimActivePlayer();
      final resumed = await _seekToResume();
      if (resumed > 0 && mounted) {
        AppToast.show(
          context,
          message:
              'Tiếp tục từ ${formatDuration(Duration(milliseconds: resumed))}',
          type: ToastType.success,
        );
      }
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && duration.inMilliseconds == 0 && playerError == null) {
          setState(
            () => playerError = 'Không tải được luồng (mạng yếu / link hỏng)',
          );
        }
      });
    } catch (e) {
      if (mounted) setState(() => playerError = 'Lỗi phát: $e');
    }
  }

  /// Nhận quyền phát độc quyền: dừng player của trang phát online khác
  /// (nếu còn sống trong stack do bấm trùng) để không chồng tiếng 2 tập.
  void _claimActivePlayer() {
    final prev = _activeOnlinePlayer;
    _activeOnlinePlayer = player;
    if (prev != null && !identical(prev, player)) {
      try {
        prev.pause();
      } catch (_) {}
    }
  }
  /// Đợi media load xong (có duration) — seek trước lúc này bị mpv nuốt
  /// nên toast "Tiếp tục từ ..." hiện mà video vẫn chạy từ đầu.
  Future<bool> _waitForDuration(Duration timeout) async {
    if (duration.inMilliseconds > 0) return true;
    if (duration.inMilliseconds > 0) return true;
    try {
      await player.stream.duration
          .firstWhere((d) => d.inMilliseconds > 0)
          .timeout(timeout);
      return true;
    } catch (_) {
      return duration.inMilliseconds > 0;
    }
  }

  /// Tìm mốc resume của tập đang phát và seek tới đó (sau khi load xong).
  /// Trả về mốc ms nếu đã seek, 0 nếu xem từ đầu.
  Future<int> _seekToResume() async {
    int start = 0;
    try {
      final historyDb = getIt<HistoryRepository>().db;
      final ex = await historyDb.getHistory(
        widget.movie.slug,
        _episode.slug,
        _serverName,
      );
      start = ex?.positionMs ?? 0;
      // Không khớp exact (đổi tên server / mở từ nguồn khác cùng slug tập):
      // dùng lại vị trí của cùng tập đó thay vì xem từ đầu.
      if (start <= 5000) {
        try {
          String base(String s) => s.contains('~') ? s.split('~').last : s;
          final wantMovie = base(widget.movie.slug as String? ?? '');
          final rows = await historyDb.getAllHistory();
          final sameEp = rows
              .where(
                (h) =>
                    (h.movieSlug == widget.movie.slug ||
                        base(h.movieSlug) == wantMovie) &&
                    h.episodeSlug == _episode.slug &&
                    h.positionMs > 5000,
              )
              .firstOrNull;
          if (sameEp != null) start = sameEp.positionMs;
        } catch (_) {}
      }
    } catch (_) {
      return 0;
    }
    if (start <= 5000 || !mounted) return 0;
    final loaded = await _waitForDuration(const Duration(seconds: 15));
    if (!mounted || !loaded) return 0;
    try {
      await player.seek(Duration(milliseconds: start));
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return 0;
      // mpv đôi khi nuốt seek đầu tiên ngay sau khi load -> kiểm tra + thử lại.
      try {
        final pos = player.state.position.inMilliseconds;
        if ((pos - start).abs() > 5000) {
          await player.seek(Duration(milliseconds: start));
        }
      } catch (_) {}
      return start;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _retry() async {
    setState(() => playerError = null);
    await _initPlayer();
  }

  /// Chuyển trang phát (drawer/theater/đổi server): chặn bấm trùng khi
  /// trang cũ chưa kịp rời stack, tránh kẹt 2 player cùng phát.
  bool _isLeaving = false;

  Future<void> _replaceWith(dynamic ep, String server) async {
    if (_isLeaving) return;
    _isLeaving = true;
    await _saveProgress();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerPage(
          movie: widget.movie,
          episode: ep,
          serverName: server,
          servers: widget.servers,
        ),
      ),
    );
  }
  Future<void> _switchServer() async {
    if (_isLeaving) return;
    _isLeaving = true;
    final cur = _episode.name;
    final web = _webSource();
    for (final s in widget.servers) {
      if (s.serverName == _serverName) continue;
      for (final ep in s.episodes) {
        final hasUrl = ((ep.linkM3u8 as String?) ?? '').isNotEmpty;
        final webPlayable = web != null &&
            (((ep.slug as String?) ?? '').isNotEmpty) &&
            ep.name == cur;
        if (ep.name == cur && (hasUrl || webPlayable)) {
          await _saveProgress();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerPage(
                movie: widget.movie,
                episode: ep,
                serverName: s.serverName,
                servers: widget.servers,
              ),
            ),
          );
          return;
        }
      }
    }
    _isLeaving = false;
    if (!mounted) return;
    AppToast.show(
      context,
      message: 'Không tìm thấy server dự phòng cho tập này',
      type: ToastType.warning,
    );
  }

  void _reportError() {
    if (kDebugMode) {
      print(
        '[REPORT] Broken link: ${widget.movie.slug} - ${_episode.slug} ($_serverName) -> '
        '${_episode.linkM3u8}',
      );
    }
    if (mounted) {
      AppToast.show(
        context,
        message: 'Đã gửi báo cáo link hỏng - sẽ kiểm tra domain dự phòng',
        type: ToastType.success,
      );
    }
    Future.delayed(const Duration(seconds: 1), () => _switchServer());
  }

  void _listenPlayer() {
    // Giữ subscriptions để cancel ở dispose: media_kit vẫn bắn event
    // sau khi trang đóng (đổi tập/back) gây setState after dispose.
    _playerSubs.add(
      player.stream.position.listen((p) {
        if (!mounted) return;
        setState(() => position = p);
        _checkSkipIntro();
      }),
    );
    _playerSubs.add(
      player.stream.duration.listen(
        (d) {
          if (!mounted) return;
          setState(() {
            duration = d;
            if (d.inMilliseconds > 0) playerError = null;
          });
        },
      ),
    );
    _playerSubs.add(
      player.stream.playing.listen((v) {
        if (!mounted) return;
        setState(() => isPlaying = v);
      }),
    );
    _playerSubs.add(
      player.stream.completed.listen((c) {
        if (c && mounted) _onCompleted();
      }),
    );
    _playerSubs.add(
      player.stream.error.listen((e) {
        if (mounted && !_hasTriedFallback) {
          _hasTriedFallback = true;
          setState(() => playerError = e.isNotEmpty ? e : 'Lỗi luồng stream');
        }
      }),
    );
    _playerSubs.add(
      player.stream.tracks.listen((t) {
        if (!mounted) return;
        setState(() => _tracks = t);
      }),
    );
    _playerSubs.add(
      player.stream.track.listen((t) {
        if (!mounted) return;
        setState(() => _currentTrack = t);
      }),
    );
    // Đồng bộ slider với volume thực của player (thang mpv 0-100):
    // thay đổi từ phím cứng/OSD/mpv đều phản ánh lên UI + lưu lại.
    _playerSubs.add(
      player.stream.volume.listen((v) {
        if (!mounted || _muted) return;
        final nv = (v / 100.0).clamp(0.0, 1.0);
        if ((nv - _volume).abs() < 0.005) return;
        setState(() => _volume = nv);
        _persistVolume(nv);
      }),
    );
  }

  void _startSaveTimer() => saveTimer = Timer.periodic(
    const Duration(seconds: 5),
    (_) => _saveProgress(),
  );
  Future<void> _saveProgress() => ProgressService.save(
    movie: widget.movie,
    episode: _episode,
    serverName: _serverName,
    pos: position,
    dur: duration,
  );

  /// Tập vừa xem xong: xóa dòng resume của nó, đồng thời đánh dấu tập KẾ
  /// (vị trí 0) để rail "Tiếp tục xem" đi tới thay vì rớt về tập cũ.
  /// Tập cuối thì chỉ xóa (hết phim -> rời rail).
  Future<void> _onCompleted() async {
    if (duration.inMilliseconds <= 0) return;
    try {
      final repo = getIt<HistoryRepository>();
      dynamic src;
      try {
        src = (widget.movie as dynamic).sourceId;
      } catch (_) {
        src = null;
      }
      final sourceId = src is String && src.isNotEmpty ? src : null;
      final idx = currentIndex, list = flatEpisodes;
      if (idx + 1 < list.length) {
        final next = list[idx + 1];
        final nEp = next['ep'];
        final nServer = next['server'] as String? ?? _serverName;
        final existing = await repo.db.getHistory(
          widget.movie.slug,
          nEp.slug,
          nServer,
        );
        // Giữ mốc cũ nếu tập kế đã xem dở (không ghi đè về 0).
        if (existing == null || existing.positionMs <= 0) {
          await repo.saveProgress(
            movieSlug: widget.movie.slug,
            movieName: widget.movie.name,
            posterUrl: widget.movie.posterUrl,
            episodeName: nEp.name,
            episodeSlug: nEp.slug,
            serverName: nServer,
            positionMs: 0,
            durationMs: 0,
            sourceId: sourceId,
          );
        }
      }
      await repo.deleteProgress(
        widget.movie.slug,
        _episode.slug,
        _serverName,
      );
    } catch (_) {}
    await _playNext();
  }

  Future<void> _playNext() async {
    final idx = currentIndex, list = flatEpisodes;
    if (idx + 1 >= list.length) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Đã hết danh sách tập',
        type: ToastType.success,
      );
      return;
    }
    final next = list[idx + 1];
    await _saveProgress();
    if (!mounted) return;
    final ep = next['ep'];
    final url =
        await _resolveEpisodeUrl(ep, next['server'] as String? ?? '');
    if ((url ?? '').isEmpty) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Không bóc được link tập tiếp',
        type: ToastType.warning,
      );
      return;
    }
    await player.open(Media(url!), play: true);
    if (!mounted) return;
    // Đổi state sang tập mới: resume/title/drawer/highlight sau này
    // bám đúng tập đang phát (trước đây kẹt ở tập cũ).
    setState(() {
      _episode = ep;
      _serverName = next['server'] as String? ?? _serverName;
      _hasSkippedIntro = false;
      _qualities = [];
      _selectedQualityUrl = null;
    });
    await _loadQualities(url);
    if (!mounted) return;
    // Tập mới có thể đã xem dở trước đó -> resume luôn.
    final resumed = await _seekToResume();
    if (!mounted) return;
    AppToast.show(
      context,
      message: resumed > 0
          ? 'Tập tiếp: ${ep.name} (tiếp tục từ ${formatDuration(Duration(milliseconds: resumed))})'
          : 'Tự động phát tập tiếp: ${ep.name}',
      type: ToastType.info,
    );
  }

  void _seekRelative(int s) {
    player.seek(clampSeek(position, duration, s));
    _resetHideTimer();
  }

  void _togglePlay() {
    isPlaying ? player.pause() : player.play();
    _resetHideTimer();
  }

  void _toggleFullscreen() {
    setState(() => isFullscreen = !isFullscreen);
    if (isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _resetHideTimer();
  }

  Future<void> _changeSpeed() async {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final n = speeds[(speeds.indexOf(playbackSpeed) + 1) % speeds.length];
    await player.setRate(n);
    setState(() => playbackSpeed = n);
    if (mounted) {
      AppToast.show(context, message: 'Tốc độ: ${n}x', type: ToastType.info);
    }
  }

  void _cycleFit() => setState(
    () => fit = fit == BoxFit.contain
        ? BoxFit.cover
        : fit == BoxFit.cover
        ? BoxFit.fill
        : BoxFit.contain,
  );
  @override
  void dispose() {
    hideTimer?.cancel();
    saveTimer?.cancel();
    for (final s in _playerSubs) {
      s.cancel();
    }
    _playerSubs.clear();
    _saveProgress();
    _persistVolume(_muted ? 0 : _volume);
    if (identical(_activeOnlinePlayer, player)) _activeOnlinePlayer = null;
    try {
      player.stop();
    } catch (_) {}
    player.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showSettingsSheet() => showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => PlayerSettingsSheet(
      playbackSpeed: playbackSpeed,
      onChangeSpeed: _changeSpeed,
      fit: fit,
      onCycleFit: _cycleFit,
      muted: _muted,
      onToggleMute: () {
        setState(() => _muted = !_muted);
        player.setVolume(_muted ? 0 : _volume * 100);
      },
      loadingQualities: _loadingQualities,
      qualities: _qualities,
      onQualityTap: () => showQualitySheet(
        context,
        _qualities,
        _selectedQualityUrl,
        _switchQuality,
      ),
      tracks: _tracks,
      currentTrack: _currentTrack,
      onAudioTap: () =>
          showAudioSheet(context, _tracks!, _currentTrack, _selectAudio),
      onSubtitleTap: () =>
          showSubtitleSheet(context, _tracks!, _currentTrack, _selectSubtitle),
      introEndMs: _introEndMs,
      onIntroTap: () =>
          showIntroSheet(context, _introEndMs, position, _setIntroEnd),
      onCastTap: _showCastPlaceholder,
      onPipTap: _enterPip,
      onExternalTap: _openExternal,
      onClearIntro: () => _setIntroEnd(0),
    ),
  );
  @override
  Widget build(BuildContext c) {
    if (c.isDesktop && !isFullscreen) return _buildDesktop();
    return Focus(
      autofocus: true,
      onKeyEvent: (n, e) => _handleKey(e),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _resetHideTimer,
          child: Stack(
            children: [
              Positioned.fill(
                child: Video(
                  controller: controller,
                  fit: fit,
                  controls: NoVideoControls,
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (_) {
                    _horizontalDragAccum = 0;
                    hideTimer?.cancel();
                  },
                  onHorizontalDragUpdate: (d) =>
                      _horizontalDragAccum += d.delta.dx,
                  onHorizontalDragEnd: (_) {
                    if (_horizontalDragAccum.abs() < 20) {
                      _horizontalDragAccum = 0;
                      _resetHideTimer();
                      return;
                    }
                    final sec = (_horizontalDragAccum / 10).round();
                    if (sec != 0) _seekRelative(sec);
                    _horizontalDragAccum = 0;
                    _resetHideTimer();
                  },
                  onTap: _resetHideTimer,
                  child: Container(color: Colors.transparent),
                ),
              ),
              if (playerError != null)
                Positioned.fill(
                  child: PlayerErrorOverlay(
                    message: playerError!,
                    onRetry: _retry,
                    onSwitchServer: _switchServer,
                    onReport: _reportError,
                  ),
                ),
              if (_resolvingStream && playerError == null)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFFE50914),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Đang bóc link phát...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (showControls && playerError == null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PlayerTopBar(
                    title: '${widget.movie.name} • ${_episode.name}',
                    serverName: _serverName,
                    onBack: () => Navigator.pop(context),
                    onSettings: _showSettingsSheet,
                  ),
                ),
              if (showControls && playerError == null)
                Center(
                  child: PlayerCenterControls(
                    brightness: _brightness,
                    onBrightnessChanged: (v) => setState(() => _brightness = v),
                    isPlaying: isPlaying,
                    onTogglePlay: _togglePlay,
                    onSeekBack: () => _seekRelative(-10),
                    onSeekForward: () => _seekRelative(10),
                    volume: _volume,
                    muted: _muted,
                    onVolumeChanged: (v) {
                      setState(() => _volume = v);
                      setState(() => _muted = v == 0);
                      player.setVolume(v * 100);
                      _persistVolume(v);
                    },
                  ),
                ),
              if (showControls && playerError == null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: PlayerBottomControls(
                    position: position,
                    duration: duration,
                    onSeek: (v) =>
                        player.seek(Duration(milliseconds: v.toInt())),
                    onSeekStart: () => hideTimer?.cancel(),
                    onSeekEnd: _resetHideTimer,
                    hasNext: currentIndex + 1 < flatEpisodes.length,
                    onNext: _playNext,
                    loadingQualities: _loadingQualities,
                    qualities: _qualities,
                    selectedQualityUrl: _selectedQualityUrl,
                    onQualityTap: () => showQualitySheet(
                      context,
                      _qualities,
                      _selectedQualityUrl,
                      _switchQuality,
                    ),
                    onToggleEpisodeDrawer: () {
                      setState(() {
                        _showEpisodeDrawer = !_showEpisodeDrawer;
                        if (_showEpisodeDrawer) {
                          hideTimer?.cancel();
                        } else {
                          _resetHideTimer();
                        }
                      });
                    },
                    isFullscreen: isFullscreen,
                    onToggleFullscreen: _toggleFullscreen,
                  ),
                ),
              if (_showEpisodeDrawer && showControls)
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: EpisodeDrawer(
                    flatEpisodes: flatEpisodes,
                    currentEpisode: _episode,
                    currentServer: _serverName,
                    onClose: () {
                      setState(() => _showEpisodeDrawer = false);
                      _resetHideTimer();
                    },
                    onSelect: (ep, s) async {
                      await _replaceWith(ep, s);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tiêu đề player: "Tên phim - Tập 1/Full - Vietsub/Thuyết minh".
  /// Bỏ qua phần rỗng để không thừa dấu "-" (VD tập lỗi thiếu tên).
  String _playerTitle() {
    String part(dynamic v) {
      try {
        final s = v?.toString().trim() ?? '';
        return s == 'null' ? '' : s;
      } catch (_) {
        return '';
      }
    }

    final parts = <String>[
      part(widget.movie.name),
      part(_episode.name),
      part(_serverName),
    ].where((e) => e.isNotEmpty).toList();
    return parts.join(' - ');
  }

  Widget _buildDesktop() => Focus(
    autofocus: true,
    onKeyEvent: (n, e) => _handleKey(e),
    child: PlayerDesktopTheater(
      controller: controller,
      fit: fit,
      error: playerError,
      onRetry: _retry,
      onSwitchServer: _switchServer,
      onReport: _reportError,
      position: position,
      duration: duration,
      onSeek: (v) => player.seek(Duration(milliseconds: v.toInt())),
      isPlaying: isPlaying,
      onTogglePlay: _togglePlay,
      onSeekBack: () => _seekRelative(-10),
      onSeekForward: () => _seekRelative(10),
      qualities: _qualities,
      onQualitySelected: (q) => _switchQuality(q as QualityVariant),
      onChangeSpeed: _changeSpeed,
      onCycleFit: _cycleFit,
      isFullscreen: isFullscreen,
      onToggleFullscreen: _toggleFullscreen,
      flatEpisodes: flatEpisodes,
      currentEpisode: _episode,
      currentServer: _serverName,
      onSelectEpisode: (ep, s) async {
        await _replaceWith(ep, s);
      },
      title: _playerTitle(),
      onCast: _showCastPlaceholder,
      onPip: _enterPip,
      onExternal: _openExternal,
      muted: _muted,
      onToggleMute: () {
        setState(() => _muted = !_muted);
        player.setVolume(_muted ? 0 : _volume * 100);
      },
    ),
  );
}
