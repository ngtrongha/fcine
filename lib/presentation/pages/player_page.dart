import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:file_picker/file_picker.dart';
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
import '../../ui/features/player/views/widgets/cast_sheet.dart';
import '../../ui/features/player/views/widgets/episode_drawer.dart';
import '../../ui/features/player/views/widgets/skip_outro_button.dart';
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
      _hasSkippedOutro = false,
      _loadingQualities = false,
      _resolvingStream = false,
      _showEpisodeDrawer = false,
      isPlaying = true,
      _muted = false;
  Timer? hideTimer, saveTimer, _stallTimer;
  final List<StreamSubscription> _playerSubs = [];

  /// Focus node dùng chung cho cả 2 nhánh build (theater/fullscreen) —
  /// giữ phím tắt (F11/ESC/...) sống sót sau khi đổi nhánh, thay vì trông
  /// chờ autofocus của Focus node mới (hay hụt, khiến F11 bật được mà
  /// bấm lại không tắt được).
  final FocusNode _pageFocus = FocusNode();

  /// Stall detection -> tự bỏ qua đoạn ads/đứng hình (xem [StallWatcher]).
  /// [_autoSkipBlocked] = skip không ăn thua 2 lần liên tiếp (mạng yếu
  /// chứ không phải ads) -> dừng hẳn tự skip cho media này.
  final StallWatcher _stallWatcher = StallWatcher();
  DateTime? _mediaOpenedAt;
  int _autoSkipCount = 0;
  bool _autoSkipAds = true;
  bool _autoSkipBlocked = false;
  int _skipFailStreak = 0;
  int _lastSkipLandedMs = 0;

  /// Số giây đứng hình thì tự tua + số giây mỗi lần tua (user chỉnh trong
  /// Settings, mặc định 5s / 15s).
  int _stallWaitSec = 5;
  int _skipSeconds = 15;

  /// Watchdog cuối tập đã chạy cho media này chưa (chống chạy 2 lần).
  /// Reset mỗi lần mở media mới.
  bool _endFired = false;
  static const _kAutoSkipKey = 'auto_skip_stall';
  static const _kStallWaitKey = 'auto_skip_wait_sec';
  static const _kSkipSecondsKey = 'auto_skip_seconds';

  /// URL http(s) của luồng ĐANG phát (để cast lên TV) — null khi phát
  /// file offline trong máy (TV không với tới) hoặc chưa load xong.
  String? _currentStreamUrl;

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

  /// Mốc phát ổn định gần nhất của media hiện tại — dùng để phát hiện
  /// stream tự reset (ads/discontinuity trong HLS làm mpv báo vị trí tụt
  /// sâu) rồi seek trở lại, thay vì coi như xem từ đầu.
  Duration _stablePos = Duration.zero;

  /// Hạn khóa guard: đang có seek/open chủ động (tua, đổi chất lượng/tập,
  /// resume) — vị trí thay đổi trong lúc này không phải reset.
  DateTime _seekLockUntil = DateTime.fromMillisecondsSinceEpoch(0);

  /// Số lần đã tự phục hồi reset trong 1 lần mở media — chặn lặp vô hạn
  /// khi đoạn ads trong luồng lỗi dai dẳng.
  int _recoverCount = 0;

  /// Đang ở chế độ cửa sổ nhỏ (PiP): ẩn toàn bộ controls/overlay để
  /// cửa sổ nhỏ hiện video sạch, giữ nguyên phát tiếng + hình.
  bool _inPip = false;

  /// Swipe dọc: vị trí bắt đầu (quyết định nửa trái=sáng / phải=volume).
  Offset? _verticalDragStartPos;

  /// Overlay mức sáng/âm lượng khi kéo swipe dọc.
  IconData? _gestureOverlayIcon;
  String? _gestureOverlayText;

  /// Phụ đề ngoài đã tải (.srt/.ass) — hiển thị tên trong settings sheet.
  String? _externalSubtitleTitle;
  List<QualityVariant> _qualities = [];
  Tracks? _tracks;
  Track? _currentTrack;
  int _introEndMs = 0;
  int _outroStartMs = 0;
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
    // Phím fullscreen toàn cục (F11/F): ăn kể cả khi Focus tree mất focus.
    HardwareKeyboard.instance.addHandler(_globalKeyHandler);
    _restoreVolume();
    _loadAutoSkipPref();
    _initPlayer();
    _listenPlayer();
    _startSaveTimer();
    _startStallTimer();
    _resetHideTimer();
    _loadQualities();
    _loadIntro();
    _initBrightness();
  }

  /// Đọc switch + thời gian "tự bỏ qua đoạn đứng hình" trong Settings
  /// (mặc định bật, chờ 5s, tua 15s).
  Future<void> _loadAutoSkipPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _autoSkipAds = prefs.getBool(_kAutoSkipKey) ?? true;
        _stallWaitSec = (prefs.getInt(_kStallWaitKey) ?? 5).clamp(3, 20);
        _skipSeconds = (prefs.getInt(_kSkipSecondsKey) ?? 15).clamp(5, 60);
        _stallWatcher.triggerSec = _stallWaitSec;
      });
    } catch (_) {}
  }

  /// Đọc độ sáng hiện tại của app để slider/swipe bắt đầu từ đúng mức.
  Future<void> _initBrightness() async {
    try {
      final v = await ScreenBrightness.instance.application;
      if (mounted) setState(() => _brightness = v.clamp(0.05, 1.0));
    } catch (_) {}
  }

  Future<void> _setScreenBrightness(double v) async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(v);
    } catch (_) {}
  }

  /// Đổi độ sáng từ slider/swipe: cập nhật UI + áp lên màn hình thật.
  void _onBrightnessChanged(double v) {
    final clamped = v.clamp(0.05, 1.0);
    setState(() => _brightness = clamped);
    _setScreenBrightness(clamped);
  }

  void _onVerticalDragStart(DragStartDetails d) {
    _verticalDragStartPos = d.localPosition;
    hideTimer?.cancel();
  }

  /// Swipe dọc kiểu YouTube: nửa trái = độ sáng (thật qua
  /// screen_brightness), nửa phải = âm lượng. Kéo lên = tăng.
  void _onVerticalDragUpdate(DragUpdateDetails d) {
    final start = _verticalDragStartPos;
    if (start == null || !mounted) return;
    final isLeftHalf = start.dx < MediaQuery.of(context).size.width / 2;
    final delta = -d.delta.dy / 200;
    if (isLeftHalf) {
      final v = (_brightness + delta).clamp(0.05, 1.0);
      if ((v - _brightness).abs() < 0.005) return;
      setState(() {
        _brightness = v;
        _gestureOverlayIcon = Icons.brightness_6_rounded;
        _gestureOverlayText = 'Độ sáng ${(v * 100).round()}%';
      });
      _setScreenBrightness(v);
    } else {
      final v = (_volume + delta).clamp(0.0, 1.0);
      if ((v - _volume).abs() < 0.005) return;
      setState(() {
        _volume = v;
        _muted = v == 0;
        _gestureOverlayIcon =
            v == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded;
        _gestureOverlayText =
            v == 0 ? 'Tắt tiếng' : 'Âm lượng ${(v * 100).round()}%';
      });
      player.setVolume(v * 100);
      _persistVolume(v);
    }
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    _verticalDragStartPos = null;
    if (!mounted) return;
    if (_gestureOverlayText != null) {
      setState(() {
        _gestureOverlayIcon = null;
        _gestureOverlayText = null;
      });
    }
    _resetHideTimer();
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
    // open() trong switchQuality reset vị trí về 0 rồi seek lại:
    // khóa guard + reset lượt phục hồi, xong chốt mốc theo vị trí thực.
    _seekLockUntil = DateTime.now().add(const Duration(seconds: 20));
    _recoverCount = 0;
    await QualityService.switchQuality(player, q, position);
    if (!mounted) return;
    _stablePos = player.state.position;
    _seekLockUntil = DateTime.now().add(const Duration(seconds: 3));
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

  /// Tải phụ đề ngoài (.srt/.ass/.vtt) từ tệp và gắn vào player hiện tại.
  Future<void> _loadExternalSubtitle() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'ass', 'ssa', 'vtt'],
    );
    final path = result?.files.single.path;
    if (path == null || !mounted) return;
    final name = path.split(RegExp(r'[\\/]')).last;
    try {
      await player.setSubtitleTrack(
        SubtitleTrack.uri(Uri.file(path).toString(), title: name),
      );
      if (mounted) {
        setState(() => _externalSubtitleTitle = name);
        AppToast.show(
          context,
          message: 'Đã tải phụ đề: $name',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Không tải được phụ đề: $e',
          type: ToastType.error,
        );
      }
    }
  }

  /// Mở sheet Chromecast: tìm TV cùng WiFi, đẩy phim đang xem lên TV,
  /// điều khiển phát/dừng/tua/ngắt ngay trong sheet.
  void _showCastSheet() {
    showCastSheet(
      context,
      videoUrl: _currentStreamUrl ?? '',
      title: '${widget.movie.name} • ${_episode.name}',
      subtitle: _serverName,
      startPosition: position,
      onCastingStarted: () {
        // TV đã nhận phim: tạm dừng máy. Local đang pause (isPlaying=false)
        // nên stall detection tự bỏ qua, không lo tự tua.
        player.pause();
        if (mounted) {
          AppToast.show(
            context,
            message: 'Đang phát trên TV - máy đã tạm dừng',
            type: ToastType.success,
          );
        }
      },
      onCastingStopped: () {},
    );
  }
  /// Nút PiP trên top bar chỉ hiện ở Android (floating chỉ hỗ trợ Android).
  static bool get _showPipButton => !kIsWeb && Platform.isAndroid;

  Future<void> _enterPip() async {    if (!await _floating.isPipAvailable) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Thiết bị không hỗ trợ PiP',
          type: ToastType.info,
        );
      }
      return;
    }
    // Ẩn controls trước để cửa sổ nhỏ chụp khung hình sạch (không dính UI).
    hideTimer?.cancel();
    if (mounted) setState(() => showControls = false);
    final s = await _floating.enable(
      const ImmediatePiP(aspectRatio: Rational(16, 9)),
    );
    if (!mounted) return;
    if (s == PiPStatus.enabled) {
      AppToast.show(
        context,
        message: 'Đã vào chế độ PiP',
        type: ToastType.success,
      );
    } else {
      AppToast.show(
        context,
        message: 'Không vào được PiP - kiểm tra quyền trong cài đặt máy',
        type: ToastType.warning,
      );
    }
  }

  /// Theo dõi trạng thái PiP hệ thống: vào PiP -> ẩn controls; thoát PiP
  /// (bấm X trên cửa sổ nhỏ) -> hiện lại controls để xem tiếp.
  void _onPipStatus(PiPStatus s) {
    if (!mounted) return;
    final inPip = s == PiPStatus.enabled || s == PiPStatus.automatic;
    if (inPip == _inPip) return;
    setState(() {
      _inPip = inPip;
      if (inPip) {
        showControls = false;
        _showEpisodeDrawer = false;
      } else {
        showControls = true;
      }
    });
    if (!inPip) _resetHideTimer();
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
    final outro = await OutroService.load(widget.movie.slug);
    if (mounted) setState(() => _outroStartMs = outro);
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

  Future<void> _setOutroStart(int sec) async {
    final ms = sec * 1000;
    await OutroService.save(widget.movie.slug, ms);
    setState(() => _outroStartMs = ms);
    if (mounted) {
      AppToast.show(
        context,
        message: sec == 0 ? 'Đã xóa outro' : 'Đã lưu outro $sec s',
        type: ToastType.success,
      );
    }
  }

  /// Auto-skip intro MỘT lần duy nhất cho mỗi lần mở media.
  /// Không "re-arm" cờ khi đã qua intro: ads/discontinuity trong HLS làm
  /// vị trí báo về tụt lại vào vùng intro — trước đây kích hoạt skip lần
  /// nữa khiến phim bị yank về mốc intro dù đang xem dở giữa phim, và mọi
  /// phím tua qua đoạn ads đều bị kéo ngược trở lại.
  /// Cờ còn được chốt ngay khi vị trí vượt qua mốc (kể cả chưa từng skip —
  /// vd resume ở phút 20): nếu không, lần đầu tụt vị trí do ads sẽ skip
  /// oan về mốc intro (xem [IntroTick.latch]).
  void _checkSkipIntro() {
    switch (introTickAction(
      introEndMs: _introEndMs,
      hasSkipped: _hasSkippedIntro,
      posMs: position.inMilliseconds,
    )) {
      case IntroTick.none:
        return;
      case IntroTick.latch:
        _hasSkippedIntro = true;
        return;
      case IntroTick.skip:
        break;
    }
    _hasSkippedIntro = true;
    _seekTo(Duration(milliseconds: _introEndMs));
    if (mounted) {
      AppToast.show(
        context,
        message: 'Đã skip intro ${_introEndMs ~/ 1000}s',
        type: ToastType.success,
      );
    }
  }

  /// Bấm nút "Bỏ qua outro": chốt cờ + kết thúc tập như khi xem hết
  /// (chốt sổ resume, chuyển tập kế). Nút hiện khi vào vùng outro —
  /// thay cho toast "bấm để skip" cũ (toast không bấm được).
  Future<void> _skipOutro() async {
    if (_hasSkippedOutro || !mounted) return;
    setState(() => _hasSkippedOutro = true);
    AppToast.show(context, message: 'Đã bỏ qua outro', type: ToastType.info);
    await _finishEpisodeAndNext();
  }

  /// Phím fullscreen toàn cục (F11/F): chạy ở tầng HardwareKeyboard nên
  /// vẫn ăn kể cả khi Focus tree mất focus sau khi chuyển fullscreen.
  /// Trả về true để sự kiện không rơi tiếp xuống Focus bên dưới
  /// (tránh toggle 2 lần thành không đổi gì).
  bool _globalKeyHandler(KeyEvent e) {
    if (e is! KeyDownEvent) return false;
    if (e.logicalKey == LogicalKeyboardKey.f11 ||
        e.logicalKey == LogicalKeyboardKey.keyF) {
      if (!mounted) return false;
      _toggleFullscreen();
      return true;
    }
    return false;
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
    // F11/F xử lý ở global handler (không phụ thuộc focus).
    // ESC thoát fullscreen (chuẩn desktop).
    if (e.logicalKey == LogicalKeyboardKey.escape && isFullscreen) {
      _toggleFullscreen();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyM) {
      setState(() => _muted = !_muted);
      player.setVolume(_muted ? 0 : _volume * 100);
      return KeyEventResult.handled;
    }
    // Skip intro shortcut: I
    if (e.logicalKey == LogicalKeyboardKey.keyI) {
      if (_introEndMs > 0 && position.inMilliseconds < _introEndMs) {
        _hasSkippedIntro = true;
        _seekTo(Duration(milliseconds: _introEndMs));
        if (mounted) {
          AppToast.show(
            context,
            message: 'Đã skip intro ${_introEndMs ~/ 1000}s',
            type: ToastType.success,
          );
        }
      }
      return KeyEventResult.handled;
    }
    // Skip outro shortcut: O
    if (e.logicalKey == LogicalKeyboardKey.keyO) {
      if (_outroStartMs > 0 && position.inMilliseconds < _outroStartMs) {
        _hasSkippedOutro = true;
        _seekTo(Duration(milliseconds: _outroStartMs));
        if (mounted) {
          AppToast.show(
            context,
            message: 'Đã skip outro',
            type: ToastType.success,
          );
        }
      }
      return KeyEventResult.handled;
    }
    // Next episode: N
    if (e.logicalKey == LogicalKeyboardKey.keyN) {
      if (currentIndex + 1 < flatEpisodes.length) {
        _playNext();
      }
      return KeyEventResult.handled;
    }
    // Previous episode: P
    if (e.logicalKey == LogicalKeyboardKey.keyP) {
      if (currentIndex > 0) {
        final prev = flatEpisodes[currentIndex - 1];
        _replaceWith(prev['ep'], prev['server'] as String? ?? _serverName);
      }
      return KeyEventResult.handled;
    }
    // Speed up: ]
    if (e.logicalKey == LogicalKeyboardKey.bracketRight) {
      _changeSpeed();
      return KeyEventResult.handled;
    }
    // Speed down: [
    if (e.logicalKey == LogicalKeyboardKey.bracketLeft) {
      const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
      final idx = speeds.indexOf(playbackSpeed);
      if (idx > 0) {
        final n = speeds[idx - 1];
        player.setRate(n);
        setState(() => playbackSpeed = n);
        if (mounted) {
          AppToast.show(context, message: 'Tốc độ: ${n}x', type: ToastType.info);
        }
      }
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
    // Giữ lại URL đang phát để cast lên TV (file:// thì sheet sẽ báo
    // không cast được).
    _currentStreamUrl = m3u8;
    try {
      // Mở media: khóa guard phát hiện reset TRƯỚC khi open (mpv reset vị
      // trí về 0 bất đồng bộ), rồi reset mốc ổn định/lượt phục hồi.
      _seekLockUntil = DateTime.now().add(const Duration(seconds: 20));
      await player.open(Media(m3u8), play: true);
      _claimActivePlayer();
      _stablePos = Duration.zero;
      _recoverCount = 0;
      // Media mới: reset bộ đếm stall/auto-skip.
      _mediaOpenedAt = DateTime.now();
      _autoSkipCount = 0;
      _autoSkipBlocked = false;
      _skipFailStreak = 0;
      _endFired = false;
      _stallWatcher.reset();
      final resumed = await _seekToResume();
      if (mounted) _stablePos = player.state.position;
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
    // Theo dõi PiP hệ thống để ẩn/hiện controls (xem _onPipStatus).
    _playerSubs.add(_floating.pipStatusStream.listen(_onPipStatus));
    // Giữ subscriptions để cancel ở dispose: media_kit vẫn bắn event
    // sau khi trang đóng (đổi tập/back) gây setState after dispose.
    _playerSubs.add(
      player.stream.position.listen((p) {
        if (!mounted) return;
        setState(() => position = p);
        _trackStreamRestart(p);
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

  /// Timer 1s soi vị trí phát: đứng yên quá lâu giữa phim (điển hình là kẹt
  /// ở đoạn ads chèn trong HLS) -> tự seek qua thay vì bắt user tua tay.
  void _startStallTimer() {
    _stallTimer?.cancel();
    _stallTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkStall(),
    );
  }

  Future<void> _checkStall() async {
    // Mọi nhánh bỏ qua đều reset watcher: mốc "nghi đứng hình" cũ không
    // còn ý nghĩa (trước đây mốc cũ sót lại gây skip oan ngay khi hết lock).
    if (!mounted) return;
    if (!_autoSkipAds || _autoSkipBlocked) {
      _stallWatcher.reset();
      return;
    }
    if (playerError != null || _resolvingStream) {
      _stallWatcher.reset();
      return;
    }
    if (duration.inMilliseconds <= 0) {
      _stallWatcher.reset();
      return;
    }
    // App không ở foreground (nghe nền/tắt màn/có cuộc gọi...): vị trí
    // đứng yên lúc này không phải kẹt ads -> không tính stall.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      _stallWatcher.reset();
      return;
    }
    // Đang seek/open chủ động, hoặc media mới mở chưa ổn định -> bỏ qua.
    if (DateTime.now().isBefore(_seekLockUntil)) {
      _stallWatcher.reset();
      return;
    }
    final openedAt = _mediaOpenedAt;
    if (openedAt == null ||
        DateTime.now().difference(openedAt) < const Duration(seconds: 20)) {
      _stallWatcher.reset();
      return;
    }
    // Chỉ tự skip khi đang phát THẬT. Đang pause (dù user bấm, OS cướp
    // audio-focus hay mpv tự dừng) -> tôn trọng, không skip.
    if (!isPlaying) {
      _stallWatcher.reset();
      return;
    }
    final ms = player.state.position.inMilliseconds;
    final frozenSec = _stallWatcher.tick(ms, DateTime.now());
    // Watchdog cuối tập: còn <=8s mà đứng hình 5s khi đang phát -> stream
    // đã hết nội dung xem được nhưng không bắn completed (playlist thiếu
    // ENDLIST / segment cuối hỏng, đứng ở frame cuối). Coi như hết tập để
    // tự chuyển tập, thay vì đứng im mãi.
    final remainingMs = duration.inMilliseconds - ms;
    if (!_endFired &&
        remainingMs >= 0 &&
        remainingMs <= 8000 &&
        frozenSec >= 5) {
      _endFired = true;
      await _finishEpisodeAndNext();
      return;
    }
    if (frozenSec < _stallWatcher.triggerSec) return;
    if (!shouldAutoSkipStall(
      frozenSec: frozenSec,
      posMs: ms,
      durMs: duration.inMilliseconds,
      autoSkipCount: _autoSkipCount,
      triggerSec: _stallWaitSec,
    )) {
      return;
    }
    // Circuit breaker: lần skip trước đáp xuống mà vị trí hầu như không
    // tiến được rồi lại đứng -> skip không giải quyết gì (mạng yếu chứ
    // không phải ads). 2 lần liên tiếp như vậy thì dừng hẳn tự skip cho
    // media này để khỏi tua mất nội dung.
    if (_autoSkipCount > 0 &&
        isSkipIneffective(posMs: ms, landedMs: _lastSkipLandedMs)) {
      _skipFailStreak++;
      if (_skipFailStreak >= 2) {
        _autoSkipBlocked = true;
        _stallWatcher.reset();
        if (mounted) {
          AppToast.show(
            context,
            message: 'Mạng yếu - đã tắt tự bỏ qua cho tập này',
            type: ToastType.warning,
          );
        }
        return;
      }
    } else {
      _skipFailStreak = 0;
    }
    _autoSkipAd();
  }

  /// Tự seek qua đoạn đứng hình (nghi là ads), mỗi lần [_skipSeconds] giây
  /// (mặc định 15s, user chỉnh trong Settings). Giới hạn số lần trong
  /// [shouldAutoSkipStall] + circuit breaker trong [_checkStall]: ads
  /// thường chỉ vài chục giây; nếu skip rồi mà vẫn đứng (mạng yếu thật)
  /// thì dừng để không tua mất nội dung.
  Future<void> _autoSkipAd() async {
    _autoSkipCount++;
    final target = position + Duration(seconds: _skipSeconds);
    final clamped = target > duration ? duration : target;
    _lastSkipLandedMs = clamped.inMilliseconds;
    await _seekTo(clamped);
    if (mounted) {
      AppToast.show(
        context,
        message: 'Tự bỏ qua đoạn đứng hình (+${_skipSeconds}s)',
        type: ToastType.info,
      );
    }
  }
  Future<void> _saveProgress() {
    // Stream đang ở trạng thái reset/tụt (vị trí kém mốc ổn định >15s):
    // KHÔNG ghi đè tiến trình đã xem tốt bằng vị trí sau reset,
    // nếu không sẽ mất mốc resume đúng (mở lại phim phải xem từ đầu).
    if (shouldSkipSaveOnRegress(
      stableMs: _stablePos.inMilliseconds,
      posMs: position.inMilliseconds,
    )) {
      return Future<void>.value();
    }
    return ProgressService.save(
      movie: widget.movie,
      episode: _episode,
      serverName: _serverName,
      pos: position,
      dur: duration,
    );
  }

  /// Tập vừa xem xong: xóa dòng resume của nó, đồng thời đánh dấu tập KẾ
  /// (vị trí 0) để rail "Tiếp tục xem" đi tới thay vì rớt về tập cũ.
  /// Tập cuối thì chỉ xóa (hết phim -> rời rail).
  Future<void> _onCompleted() async {
    // completed bắn giữa chừng khi stream bị reset (ads/HLS lỗi): vị trí
    // còn xa cuối phim -> không phải hết tập, bỏ qua để không nhảy tập
    // bậy và không xóa tiến trình đang xem dở.
    if (!isGenuineCompletion(
      posMs: position.inMilliseconds,
      durMs: duration.inMilliseconds,
    )) {
      return;
    }
    await _finishEpisodeAndNext();
  }

  /// Kết thúc tập hiện tại: chốt sổ resume + chuyển tập kế.
  /// Được gọi khi hết tập thật (completed), khi user bấm "Bỏ qua outro",
  /// hoặc khi watchdog cuối tập phát hiện stream đứng ở frame cuối mà
  /// không bắn completed (playlist thiếu ENDLIST/segment cuối hỏng).
  Future<void> _finishEpisodeAndNext() async {
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
    _currentStreamUrl = url;
    // Khóa guard TRƯỚC khi open: mpv reset vị trí về 0 bất đồng bộ,
    // tick 0 đến trước dòng reset mốc sẽ bị hiểu nhầm là stream reset.
    _seekLockUntil = DateTime.now().add(const Duration(seconds: 20));
    await player.open(Media(url!), play: true);
    if (!mounted) return;
    // Tập mới = media mới: reset mốc ổn định/lượt phục hồi,
    // reset luôn cờ skip intro/outro của tập cũ.
    _stablePos = Duration.zero;
    _recoverCount = 0;
    _mediaOpenedAt = DateTime.now();
    _autoSkipCount = 0;
    _autoSkipBlocked = false;
    _skipFailStreak = 0;
    _endFired = false;
    _stallWatcher.reset();
    _seekLockUntil = DateTime.now().add(const Duration(seconds: 20));
    // Đổi state sang tập mới: resume/title/drawer/highlight sau này
    // bám đúng tập đang phát (trước đây kẹt ở tập cũ).
    setState(() {
      _episode = ep;
      _serverName = next['server'] as String? ?? _serverName;
      _hasSkippedIntro = false;
      _hasSkippedOutro = false;
      _qualities = [];
      _selectedQualityUrl = null;
      _externalSubtitleTitle = null;
    });
    await _loadQualities(url);
    if (!mounted) return;
    // Tập mới có thể đã xem dở trước đó -> resume luôn.
    final resumed = await _seekToResume();
    if (mounted) _stablePos = player.state.position;
    if (!mounted) return;
    AppToast.show(
      context,
      message: resumed > 0
          ? 'Tập tiếp: ${ep.name} (tiếp tục từ ${formatDuration(Duration(milliseconds: resumed))})'
          : 'Tự động phát tập tiếp: ${ep.name}',
      type: ToastType.info,
    );
  }

  /// Seek chủ động (slider/phím/gesture/skip intro...): khóa guard phát
  /// hiện reset trong lúc seek, rồi chốt mốc ổn định theo vị trí THỰC sau
  /// khi mpv áp xong — tua lùi/tua qua ads của user không bị hiểu nhầm
  /// là stream reset.
  Future<void> _seekTo(Duration target) async {
    _seekLockUntil = DateTime.now().add(const Duration(seconds: 8));
    // Seek chủ động -> mốc đứng hình cũ hết ý nghĩa.
    _stallWatcher.reset();
    await player.seek(target);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) _stablePos = player.state.position;
  }

  /// Phát hiện stream tự reset: vị trí tụt sâu so với mốc ổn định mà không
  /// trong lúc seek chủ động -> seek ngay về mốc ổn định thay vì để phim
  /// chạy lại từ đầu. Tối đa 3 lần mỗi media (xem [shouldRecoverStream]).
  void _trackStreamRestart(Duration p) {
    final locked = DateTime.now().isBefore(_seekLockUntil);
    final ms = p.inMilliseconds;
    if (ms >= _stablePos.inMilliseconds) {
      if (!locked) _stablePos = p;
      return;
    }
    if (!shouldRecoverStream(
      stableMs: _stablePos.inMilliseconds,
      posMs: ms,
      seekLocked: locked,
      recoverCount: _recoverCount,
    )) {
      return;
    }
    _recoverCount++;
    final target = _stablePos;
    _seekLockUntil = DateTime.now().add(const Duration(seconds: 8));
    player.seek(target);
    if (mounted) {
      AppToast.show(
        context,
        message: 'Luồng bị reset - quay lại ${formatDuration(target)}',
        type: ToastType.info,
      );
    }
  }

  void _seekRelative(int s) {
    _seekTo(clampSeek(position, duration, s));
    _resetHideTimer();
  }

  void _togglePlay() {
    isPlaying ? player.pause() : player.play();
    _resetHideTimer();
  }

  static bool get _isDesktop =>
      !kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  void _toggleFullscreen() {
    setState(() => isFullscreen = !isFullscreen);
    if (isFullscreen) {
      if (_isDesktop) {
        windowManager.setFullScreen(true);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    } else {
      if (_isDesktop) {
        windowManager.setFullScreen(false);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
    _resetHideTimer();
    // Đổi nhánh build (theater <-> fullscreen) thay Focus node mới —
    // giữ focus tường minh để phím tắt không chết sau lần F11 đầu.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_pageFocus.hasFocus) _pageFocus.requestFocus();
    });
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
    _stallTimer?.cancel();
    HardwareKeyboard.instance.removeHandler(_globalKeyHandler);
    _pageFocus.dispose();
    for (final s in _playerSubs) {
      s.cancel();
    }
    _playerSubs.clear();
    _saveProgress();
    _persistVolume(_muted ? 0 : _volume);
    if (identical(_activeOnlinePlayer, player)) _activeOnlinePlayer = null;
    try {
      ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
    try {
      player.stop();
    } catch (_) {}
    player.dispose();
    WakelockPlus.disable();
    if (isFullscreen) {
      try {
        windowManager.setFullScreen(false);
      } catch (_) {}
    }
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
      onExternalSubtitleTap: _loadExternalSubtitle,
      externalSubtitleTitle: _externalSubtitleTitle,
      introEndMs: _introEndMs,
      outroStartMs: _outroStartMs,
      onIntroTap: () =>
          showIntroSheet(context, _introEndMs, position, _setIntroEnd),
      onOutroTap: () =>
          showOutroSheet(context, _outroStartMs, position, duration, _setOutroStart),
      onCastTap: _showCastSheet,
      onPipTap: _enterPip,
      onExternalTap: _openExternal,
      onClearIntro: () => _setIntroEnd(0),
      onClearOutro: () => _setOutroStart(0),
    ),
  );
  @override
  Widget build(BuildContext c) {
    if (c.isDesktop && !isFullscreen) return _buildDesktop();
    return Focus(
      focusNode: _pageFocus,
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
                  onVerticalDragStart: _onVerticalDragStart,
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  onVerticalDragEnd: _onVerticalDragEnd,
                  onTap: _resetHideTimer,
                  child: Container(color: Colors.transparent),
                ),
              ),
              if (_gestureOverlayText != null &&
                  playerError == null &&
                  !_inPip)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _gestureOverlayIcon,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _gestureOverlayText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
              if (showControls && playerError == null && !_inPip)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PlayerTopBar(
                    title: '${widget.movie.name} • ${_episode.name}',
                    serverName: _serverName,
                    onBack: () => Navigator.pop(context),
                    onSettings: _showSettingsSheet,
                    onPip: _showPipButton ? _enterPip : null,
                  ),
                ),
              if (showControls && playerError == null && !_inPip)
                Center(
                  child: PlayerCenterControls(
                    brightness: _brightness,
                    onBrightnessChanged: _onBrightnessChanged,
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
              if (showControls && playerError == null && !_inPip)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: PlayerBottomControls(
                    position: position,
                    duration: duration,
                    onSeek: (v) =>
                        _seekTo(Duration(milliseconds: v.toInt())),
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
              if (shouldShowSkipOutro(
                    outroStartMs: _outroStartMs,
                    handled: _hasSkippedOutro,
                    posMs: position.inMilliseconds,
                  ) &&
                  playerError == null &&
                  !_inPip &&
                  !_showEpisodeDrawer)
                Positioned(
                  bottom: 96,
                  right: 16,
                  child: SkipOutroButton(onTap: _skipOutro),
                ),
              if (_showEpisodeDrawer && showControls && !_inPip)
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: EpisodeDrawer(
                    flatEpisodes: flatEpisodes,
                    currentEpisode: _episode,
                    currentServer: _serverName,
                    movieSlug: widget.movie.slug,
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
    focusNode: _pageFocus,
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
      onSeek: (v) => _seekTo(Duration(milliseconds: v.toInt())),
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
      movieSlug: widget.movie.slug,
      onSelectEpisode: (ep, s) async {
        await _replaceWith(ep, s);
      },
      title: _playerTitle(),
      onCast: _showCastSheet,
      onPip: _enterPip,
      onExternal: _openExternal,
      showSkipOutro: shouldShowSkipOutro(
        outroStartMs: _outroStartMs,
        handled: _hasSkippedOutro,
        posMs: position.inMilliseconds,
      ),
      onSkipOutro: _skipOutro,
      muted: _muted,
      onToggleMute: () {
        setState(() => _muted = !_muted);
        player.setVolume(_muted ? 0 : _volume * 100);
      },
    ),
  );
}
