import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../ui/features/player/logic/playlist_media.dart';
import '../../../core/local_media/local_media_scanner.dart';
import '../../../core/local_media/local_video.dart';

/// Trình phát Video — hoạt động độc lập, không cần nguồn phim.
///
/// Tính năng:
/// - Media: Mở file (nhiều file), Mở luồng mạng (URL), thêm phụ đề ngoài
/// - Playlist: thêm/xóa/sắp xếp, phát tiếp, lặp (off/all/one), ngẫu nhiên
/// - Phát lại: play/pause/stop/tới/lui, tốc độ, tỉ lệ khung hình, fullscreen
/// - Âm thanh/phụ đề: chọn track, tăng/giảm âm lượng, mute
/// - Phím tắt: Space, ←/→ ±10s, ↑/↓ volume, F fullscreen, M mute, N/P next/prev, L loop
class LocalPlayerPage extends StatefulWidget {
  const LocalPlayerPage({super.key});

  @override
  State<LocalPlayerPage> createState() => _LocalPlayerPageState();
}

class _LocalPlayerPageState extends State<LocalPlayerPage> {
  static const _kPlaylist = 'vlc_playlist';
  static const _kVolume = 'vlc_volume';
  static const _kRate = 'vlc_rate';
  static const _kLoop = 'vlc_loop';

  late final Player _player;
  late final VideoController _videoController;

  List<PlaylistMedia> _playlist = [];
  int _currentIndex = -1;
  LoopMode _loop = LoopMode.off;
  bool _shuffle = false;
  bool _scanning = false;
  String? _scanInfo;
  final LocalMediaScanner _scanner = LocalMediaScanner();

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isFullscreen = false;
  bool _showPlaylist = true;
  bool _muted = false;
  bool _showControlsOverlay = true;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  double _rate = 1.0;
  BoxFit _fit = BoxFit.contain;

  Tracks? _tracks;
  AudioTrack _audioTrack = AudioTrack.auto();
  SubtitleTrack _subtitleTrack = SubtitleTrack.auto();

  String? _error;
  Timer? _hideTimer;
  Timer? _saveTimer;
  final Random _random = Random();

  PlaylistMedia? get _current =>
      (_currentIndex >= 0 && _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    WakelockPlus.enable();
    _restorePrefs().then((_) {
      _listen();
      // Tự quét video có sẵn trên thiết bị (thư viện media).
      _autoScan();
    });
    _startSaveTimer();
  }

  Future<void> _restorePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _playlist = PlaylistMedia.decodeList(prefs.getString(_kPlaylist));
      _volume = (prefs.getDouble(_kVolume) ?? 1.0).clamp(0.0, 1.0);
      _rate = (prefs.getDouble(_kRate) ?? 1.0).clamp(0.25, 4.0);
      _loop = LoopMode.values[(prefs.getInt(_kLoop) ?? 0).clamp(
        0,
        LoopMode.values.length - 1,
      )];
    });
    await _player.setVolume(_volume * 100);
    await _player.setRate(_rate);
    // Tự mở bài đầu nếu có playlist cũ (nhớ playlist)
    if (_playlist.isNotEmpty) {
      _currentIndex = 0;
      setState(() {});
    }
  }

  Future<void> _persistPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlaylist, PlaylistMedia.encodeList(_playlist));
  }

  Future<void> _persistSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kVolume, _volume);
    await prefs.setDouble(_kRate, _rate);
    await prefs.setInt(_kLoop, _loop.index);
  }

  /// Tự quét video có sẵn trên thiết bị rồi merge vào playlist (không trùng).
  /// Chạy nền sau khi mở app để tự build thư viện media.
  Future<void> _autoScan() async {
    if (_scanning) return;
    if (mounted) setState(() => _scanning = true);
    try {
      // Xin quyền đọc video/audio trên mobile để quét được thư mục công cộng.
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          await [
            Permission.videos,
            Permission.audio,
            Permission.storage,
          ].request();
        } catch (_) {
          // Thiết bị không hỗ trợ đầy đủ -> vẫn quét những gì đọc được.
        }
      }
      final found = await _scanner.scan();
      if (!mounted) return;
      final existing = _playlist.map((e) => e.uri.toLowerCase()).toSet();
      // Chuẩn hoá thêm dạng file:// để tránh add trùng path đã có.
      final existingPlayable =
          _playlist.map((e) => PlaylistMedia.toPlayable(e.uri).toLowerCase()).toSet();
      final fresh = <PlaylistMedia>[];
      for (final LocalVideo v in found) {
        final playable = PlaylistMedia.toPlayable(v.path).toLowerCase();
        if (existing.contains(v.path.toLowerCase()) ||
            existingPlayable.contains(playable)) {
          continue;
        }
        fresh.add(PlaylistMedia(
          id: PlaylistMedia.newId(),
          uri: v.path,
          title: v.name,
        ));
      }
      setState(() {
        _scanning = false;
        if (fresh.isNotEmpty) {
          _playlist = [..._playlist, ...fresh];
          _currentIndex = _currentIndex == -1 ? 0 : _currentIndex;
          _scanInfo = 'Tự quét: thêm ${fresh.length} video mới';
        } else if (found.isNotEmpty) {
          _scanInfo = 'Đã quét ${found.length} video trên thiết bị';
        } else {
          _scanInfo = _playlist.isEmpty
              ? 'Chưa thấy video nào — bấm + để mở file'
              : 'Không tìm thêm video mới';
        }
      });
      if (fresh.isNotEmpty) await _persistPlaylist();
    } catch (_) {
      if (mounted) {
        setState(() {
          _scanning = false;
          _scanInfo ??= 'Quét tự động bị chặn (thiếu quyền đọc bộ nhớ)';
        });
      }
    }
  }

  Future<void> _addScanFolder() async {
    try {
      final dir = await FilePicker.platform.getDirectoryPath();
      if (dir == null || dir.isEmpty) return;
      await _scanner.addCustomDir(dir);
      _toast('Đã thêm thư mục quét: $dir');
      await _autoScan();
    } catch (e) {
      _toast('Không thêm được thư mục: $e');
    }
  }

  void _listen() {
    _player.stream.playing.listen((v) {
      if (mounted) setState(() => _isPlaying = v);
    });
    _player.stream.position.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.stream.duration.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
          if (d.inMilliseconds > 0) {
            _error = null;
            _isLoading = false;
          }
        });
        _updateCurrentDuration(d);
      }
    });
    _player.stream.completed.listen((done) {
      if (done) _onCompleted();
    });
    _player.stream.error.listen((e) {
      if (mounted && e.isNotEmpty) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    });
    _player.stream.tracks.listen((t) {
      if (mounted) setState(() => _tracks = t);
    });
    _player.stream.track.listen((t) {
      if (mounted) {
        setState(() {
          _audioTrack = t.audio;
          _subtitleTrack = t.subtitle;
        });
      }
    });
    _player.stream.volume.listen((v) {
      if (mounted && !_muted) setState(() => _volume = (v / 100.0).clamp(0.0, 1.0));
    });
  }

  void _startSaveTimer() {
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final cur = _current;
      if (cur == null || _duration.inMilliseconds == 0) return;
      _playlist[_currentIndex] = cur.copyWith(
        lastPositionMs: _position.inMilliseconds,
        durationMs: _duration.inMilliseconds,
      );
      await _persistPlaylist();
    });
  }

  void _updateCurrentDuration(Duration d) {
    final cur = _current;
    if (cur == null) return;
    _playlist[_currentIndex] = cur.copyWith(durationMs: d.inMilliseconds);
    _persistPlaylist();
  }

  // ---------------- Media: mở file / mạng ----------------

  Future<void> _openFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const [
          'mp4', 'mkv', 'avi', 'mov', 'webm', 'm3u8', 'm3u',
          'mp3', 'flac', 'wav', 'ogg', 'ts', 'm2ts', 'wmv',
          'flv', '3gp', 'mpg', 'mpeg',
        ],
      );
      if (result == null) return;
      final items = result.files
          .where((f) => f.path != null && f.path!.isNotEmpty)
          .map(
            (f) => PlaylistMedia(
              id: PlaylistMedia.newId(),
              uri: f.path!,
              title: f.name,
            ),
          )
          .toList();
      if (items.isEmpty) return;
      final startIndex = _playlist.length;
      setState(() => _playlist = [..._playlist, ...items]);
      await _persistPlaylist();
      // Mở là phát ngay file đầu tiên vừa thêm
      await _playAt(startIndex);
    } catch (e) {
      _toast('Không mở được file: $e');
    }
  }

  Future<void> _openNetworkDialog() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: const Text(
          'Mở luồng mạng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dán link http(s) (.mp4 / .m3u8 / .mkv ...)',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'https://.../video.m3u8',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF0B101B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Phát'),
          ),
        ],
      ),
    );
    if (url == null || url.trim().isEmpty) return;
    try {
      final uri = PlaylistMedia.resolveUri(url);
      final item = PlaylistMedia(
        id: PlaylistMedia.newId(),
        uri: uri,
        title: PlaylistMedia.titleFromUri(uri),
      );
      setState(() => _playlist = [..._playlist, item]);
      await _persistPlaylist();
      await _playAt(_playlist.length - 1);
    } catch (e) {
      _toast(e.toString().replaceFirst('Invalid argument(s): ', ''));
    }
  }

  Future<void> _addSubtitle() async {
    final cur = _current;
    if (cur == null) {
      _toast('Hãy phát 1 video trước rồi mới gắn phụ đề');
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['srt', 'vtt', 'ass', 'ssa', 'sub'],
      );
      final path = result?.files.single.path;
      if (path == null) return;
      final uri = Uri.file(path).toString();
      await _player.setSubtitleTrack(SubtitleTrack.uri(uri, title: path.split(RegExp(r'[\\/]')).last));
      setState(() {
        _playlist[_currentIndex] = cur.copyWith(subtitleUri: uri);
      });
      await _persistPlaylist();
      _toast('Đã gắn phụ đề ngoài');
    } catch (e) {
      _toast('Không gắn được phụ đề: $e');
    }
  }

  void _showMediaInfo() {
    final cur = _current;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: const Text('Thông tin media', style: TextStyle(color: Colors.white)),
        content: cur == null
            ? const Text('Chưa có media nào', style: TextStyle(color: Colors.white70))
            : SelectableText(
                'Tên: ${cur.displayName}\n'
                'URI: ${cur.uri}\n'
                'Vị trí: ${_fmt(_position)} / ${_fmt(_duration)}\n'
                'Audio: ${_audioTrack.id} (${_audioTrack.language ?? '-'})\n'
                'Subtitle: ${_subtitleTrack.id}\n'
                'Tốc độ: ${_rate}x  •  Âm lượng: ${(_volume * 100).round()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Đóng')),
        ],
      ),
    );
  }

  // ---------------- Playlist ----------------

  Future<void> _playAt(int index, {bool autoplay = true}) async {
    if (index < 0 || index >= _playlist.length) return;
    final item = _playlist[index];
    setState(() {
      _currentIndex = index;
      _isLoading = true;
      _error = null;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    try {
      final playable = PlaylistMedia.toPlayable(item.uri);
      await _player.open(Media(playable), play: autoplay);
      // Resume nếu có (hỏi tiếp tục)
      if (item.lastPositionMs > 5000 && autoplay) {
        final resumeTo = Duration(milliseconds: item.lastPositionMs);
        await _player.seek(resumeTo);
        _toast('Tiếp tục từ ${_fmt(resumeTo)}');
      }
      if (item.subtitleUri != null && item.subtitleUri!.isNotEmpty) {
        try {
          await _player.setSubtitleTrack(SubtitleTrack.uri(item.subtitleUri!));
        } catch (_) {}
      }
      await _player.setRate(_rate);
      await _player.setVolume(_muted ? 0 : _volume);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Lỗi phát: $e';
          _isLoading = false;
        });
      }
    }
    _resetHideTimer();
  }

  void _onCompleted() {
    if (_loop == LoopMode.one) {
      _playAt(_currentIndex);
      return;
    }
    if (_shuffle && _playlist.length > 1) {
      var next = _currentIndex;
      while (next == _currentIndex) {
        next = _random.nextInt(_playlist.length);
      }
      _playAt(next);
      return;
    }
    if (_currentIndex + 1 < _playlist.length) {
      _playAt(_currentIndex + 1);
      return;
    }
    if (_loop == LoopMode.all && _playlist.isNotEmpty) {
      _playAt(0);
      return;
    }
    // Hết playlist
    setState(() => _isPlaying = false);
  }

  void _playNext() {
    if (_playlist.isEmpty) return;
    if (_shuffle && _playlist.length > 1) {
      var next = _currentIndex;
      while (next == _currentIndex) {
        next = _random.nextInt(_playlist.length);
      }
      _playAt(next);
      return;
    }
    final next = _currentIndex + 1;
    if (next < _playlist.length) {
      _playAt(next);
    } else if (_loop == LoopMode.all) {
      _playAt(0);
    } else {
      _toast('Đã hết playlist');
    }
  }

  void _playPrev() {
    if (_playlist.isEmpty) return;
    // Nếu đang phát >3s thì restart bài hiện tại
    if (_position.inSeconds > 3 && _currentIndex >= 0) {
      _player.seek(Duration.zero);
      return;
    }
    final prev = _currentIndex - 1;
    if (prev >= 0) {
      _playAt(prev);
    } else if (_loop == LoopMode.all && _playlist.isNotEmpty) {
      _playAt(_playlist.length - 1);
    }
  }

  Future<void> _removeAt(int index) async {
    final wasCurrent = index == _currentIndex;
    setState(() {
      _playlist = [..._playlist]..removeAt(index);
      if (_playlist.isEmpty) {
        _currentIndex = -1;
      } else if (index < _currentIndex) {
        _currentIndex--;
      } else if (wasCurrent) {
        _currentIndex = _currentIndex.clamp(0, _playlist.length - 1);
      }
    });
    await _persistPlaylist();
    if (wasCurrent) {
      if (_playlist.isEmpty) {
        await _player.stop();
        setState(() {
          _position = Duration.zero;
          _duration = Duration.zero;
          _error = null;
        });
      } else {
        await _playAt(_currentIndex);
      }
    }
  }

  Future<void> _clearPlaylist() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: const Text('Xóa playlist?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Toàn bộ danh sách phát sẽ bị xóa.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true) return;
    await _player.stop();
    setState(() {
      _playlist = [];
      _currentIndex = -1;
      _position = Duration.zero;
      _duration = Duration.zero;
      _error = null;
    });
    await _persistPlaylist();
  }

  void _move(int index, int delta) {
    final to = index + delta;
    if (index < 0 || to < 0 || to >= _playlist.length) return;
    setState(() {
      final list = [..._playlist];
      final item = list.removeAt(index);
      list.insert(to, item);
      _playlist = list;
      if (_currentIndex == index) {
        _currentIndex = to;
      } else if (_currentIndex == to) {
        _currentIndex = index;
      }
    });
    _persistPlaylist();
  }

  // ---------------- Playback controls ----------------

  void _togglePlay() {
    if (_current == null) {
      if (_playlist.isNotEmpty) {
        _playAt(0);
      } else {
        _openFiles();
      }
      return;
    }
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
    _resetHideTimer();
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() => _position = Duration.zero);
  }

  void _seekRelative(int seconds) {
    if (_duration.inMilliseconds == 0) return;
    final target = _position + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _duration ? _duration : target);
    _player.seek(clamped);
  }

  Future<void> _setVolume(double v) async {
    setState(() {
      _volume = v.clamp(0.0, 1.0);
      _muted = _volume == 0 ? true : false;
    });
    await _player.setVolume(_muted ? 0 : _volume);
    _persistSettings();
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    await _player.setVolume(_muted ? 0 : _volume);
  }

  Future<void> _setRate(double r) async {
    final v = r.clamp(0.25, 4.0);
    setState(() => _rate = v);
    await _player.setRate(v);
    _persistSettings();
  }

  void _cycleFit() {
    setState(() {
      _fit = _fit == BoxFit.contain
          ? BoxFit.cover
          : _fit == BoxFit.cover
              ? BoxFit.fill
              : _fit == BoxFit.fill
                  ? BoxFit.fitWidth
                  : BoxFit.contain;
    });
  }

  String _fitLabel() {
    switch (_fit) {
      case BoxFit.contain:
        return 'Vừa khung';
      case BoxFit.cover:
        return 'Phủ đầy';
      case BoxFit.fill:
        return 'Kéo giãn';
      case BoxFit.fitWidth:
        return 'Rộng';
      default:
        return 'Vừa khung';
    }
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
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

  void _resetHideTimer() {
    _hideTimer?.cancel();
    setState(() => _showControlsOverlay = true);
    if (!_isFullscreen) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) setState(() => _showControlsOverlay = false);
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent e) {
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
      _setVolume((_volume + 0.05).clamp(0.0, 1.0));
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
      _setVolume((_volume - 0.05).clamp(0.0, 1.0));
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyF) {
      _toggleFullscreen();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyM) {
      _toggleMute();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyN) {
      _playNext();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyP) {
      _playPrev();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyL) {
      setState(() => _loop = _loop.next);
      _persistSettings();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.escape && _isFullscreen) {
      _toggleFullscreen();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _saveTimer?.cancel();
    // Lưu vị trí hiện tại
    final cur = _current;
    if (cur != null) {
      _playlist[_currentIndex] = cur.copyWith(
        lastPositionMs: _position.inMilliseconds,
        durationMs: _duration.inMilliseconds,
      );
      _persistPlaylist();
    }
    _player.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= 900;
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: const Color(0xFF080B11),
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
          children: [
            if (!_isFullscreen) _buildToolbar(),
            Expanded(
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(flex: 3, child: _buildVideoArea()),
                        if (_showPlaylist)
                          SizedBox(width: 340, child: _buildPlaylistPanel()),
                      ],
                    )
                  : Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _buildVideoArea(),
                        ),
                        Expanded(child: _buildPlaylistPanel()),
                      ],
                    ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
      ),
    );
  }

  /// Thanh công cụ: mở media + chọn track âm thanh/phụ đề + menu mở rộng.
  Widget _buildToolbar() {
    return Container(
      color: const Color(0xFF111622),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarAction(
              icon: Icons.folder_open_rounded,
              label: 'Mở file',
              primary: true,
              onTap: _openFiles,
            ),
            const SizedBox(width: 8),
            _ToolbarAction(
              icon: Icons.language_rounded,
              label: 'Mở link',
              onTap: _openNetworkDialog,
            ),
            const SizedBox(width: 8),
            _PopupAction(
              icon: Icons.subtitles_rounded,
              label: 'Phụ đề',
              tooltip: 'Chọn / thêm phụ đề',
              items: [
                _menuItem(
                  Icons.subtitles_off_outlined,
                  'Tắt phụ đề',
                  () => _player.setSubtitleTrack(SubtitleTrack.no()),
                ),
                ...(_tracks?.subtitle ?? []).map<PopupMenuEntry<dynamic>>(
                  (t) => PopupMenuItem(
                    child: Text(
                      '${t.title ?? t.language ?? t.id}${t.id == _subtitleTrack.id ? '  ✓' : ''}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () => _player.setSubtitleTrack(t),
                  ),
                ),
                const PopupMenuDivider(),
                _menuItem(Icons.add_rounded, 'Thêm file phụ đề...', _addSubtitle),
              ],
            ),
            const SizedBox(width: 8),
            _PopupAction(
              icon: _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              label: 'Âm thanh',
              tooltip: 'Tắt tiếng / chọn kênh',
              items: [
                _menuItem(
                  _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  _muted ? 'Bật tiếng  (M)' : 'Tắt tiếng  (M)',
                  _toggleMute,
                ),
                ...(_tracks?.audio ?? []).map<PopupMenuEntry<dynamic>>(
                  (t) => PopupMenuItem(
                    child: Text(
                      'Kênh: ${t.language ?? t.id}${t.id == _audioTrack.id ? '  ✓' : ''}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () => _player.setAudioTrack(t),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            _PopupAction(
              icon: Icons.video_settings_rounded,
              label: 'Hình ảnh',
              tooltip: 'Tỉ lệ khung hình / track video',
              items: [
                _menuItem(Icons.aspect_ratio_rounded, 'Tỉ lệ: ${_fitLabel()}', _cycleFit),
                ...(_tracks?.video ?? []).map<PopupMenuEntry<dynamic>>(
                  (t) => PopupMenuItem(
                    child: Text('Video track: ${t.id}', style: const TextStyle(fontSize: 13)),
                    onTap: () => _player.setVideoTrack(t),
                  ),
                ),
                const PopupMenuDivider(),
                _menuItem(Icons.fullscreen_rounded, 'Toàn màn hình  (F)', _toggleFullscreen),
              ],
            ),
            const SizedBox(width: 4),
            PopupMenuButton<dynamic>(
              color: const Color(0xFF1A2130),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tooltip: 'Tùy chọn khác',
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white70, size: 20),
              itemBuilder: (_) => <PopupMenuEntry<dynamic>>[
                _menuItem(Icons.keyboard_rounded, 'Phím tắt', _showShortcuts),
                _menuItem(Icons.info_outline_rounded, 'Thông tin media', _showMediaInfo),
                _menuItem(
                  Icons.playlist_play_rounded,
                  _showPlaylist ? 'Ẩn playlist' : 'Hiện playlist',
                  () => setState(() => _showPlaylist = !_showPlaylist),
                ),
                _menuItem(Icons.delete_sweep_outlined, 'Xóa playlist', _clearPlaylist),
                const PopupMenuDivider(),
                _menuItem(Icons.settings_rounded, 'Nguồn phim...', () => context.go('/settings')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShortcuts() {
    const rows = [
      ('Space', 'Phát / Tạm dừng'),
      ('← / →', 'Lùi / Tới 10 giây'),
      ('↑ / ↓', 'Giảm / Tăng âm lượng'),
      ('F', 'Toàn màn hình'),
      ('M', 'Tắt / Bật tiếng'),
      ('N / P', 'Bài tiếp / Bài trước'),
      ('L', 'Đổi chế độ lặp'),
      ('Esc', 'Thoát toàn màn hình'),
    ];
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: const Text('Phím tắt', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: rows
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2130),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Text(
                          r.$1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(r.$2, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Đóng')),
        ],
      ),
    );
  }

  PopupMenuItem<dynamic> _menuItem(IconData icon, String label, VoidCallback onTap) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    return Container(
      color: Colors.black,
      child: GestureDetector(
        onTap: () {
          if (_isFullscreen) {
            setState(() => _showControlsOverlay = !_showControlsOverlay);
            _resetHideTimer();
          } else {
            _togglePlay();
          }
        },
        onDoubleTap: _toggleFullscreen,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v.abs() < 200) return;
          _seekRelative(v < 0 ? 10 : -10);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Video(
                controller: _videoController,
                fit: _fit,
                controls: NoVideoControls,
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFE50914)),
              ),
            if (_error != null && _current != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
                      const SizedBox(height: 10),
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _playAt(_currentIndex),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Thử lại'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _playNext,
                            icon: const Icon(Icons.skip_next_rounded, size: 16),
                            label: const Text('Bài tiếp', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (_current == null && !_isLoading)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_rounded, color: Color(0xFFE50914), size: 56),
                    SizedBox(height: 10),
                    Text('Video', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text(
                      'Mở file, dán link mạng hoặc thêm thư mục quét\nBấm nút + ở panel playlist để bắt đầu',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
            // Overlay điều khiển khi fullscreen
            if (_isFullscreen && _showControlsOverlay && _current != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: _toggleFullscreen,
                      ),
                      Expanded(
                        child: Text(
                          _current!.displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${_fmt(_position)} / ${_fmt(_duration)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isFullscreen && _showControlsOverlay)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildSeekRow(compact: true),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B101B),
        border: Border(left: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF111622),
            child: Row(
              children: [
                const Icon(Icons.playlist_play_rounded, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Playlist (${_playlist.length})',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      if (_scanning)
                        const Text(
                          'Đang quét video trên thiết bị...',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                        )
                      else if (_scanInfo != null)
                        Text(
                          _scanInfo!,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (_scanning)
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(tooltip: 'Quét lại video trên thiết bị', icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white70), onPressed: _autoScan),
                IconButton(tooltip: 'Thêm thư mục để quét', icon: const Icon(Icons.create_new_folder_outlined, size: 18, color: Colors.white70), onPressed: _addScanFolder),
                IconButton(tooltip: 'Mở file', icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white70), onPressed: _openFiles),
                IconButton(tooltip: 'Mở luồng mạng', icon: const Icon(Icons.language_rounded, size: 18, color: Colors.white70), onPressed: _openNetworkDialog),
                IconButton(tooltip: 'Xóa playlist', icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Colors.white70), onPressed: _playlist.isEmpty ? null : _clearPlaylist),
              ],
            ),
          ),
          Expanded(
            child: _playlist.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _scanning
                          ? const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Color(0xFFE50914)),
                                SizedBox(height: 12),
                                Text(
                                  'Đang quét video trên thiết bị...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                ),
                              ],
                            )
                          : const Text(
                              'Chưa thấy video nào.\nBấm + để mở file, 🌐 để mở link mạng\nHoặc 📁 để thêm thư mục quét.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _playlist.length,
                    itemBuilder: (_, i) {
                      final item = _playlist[i];
                      final selected = i == _currentIndex;
                      return Container(
                        color: selected ? const Color(0xFF380B0F) : Colors.transparent,
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            selected
                                ? (_isPlaying ? Icons.volume_up_rounded : Icons.pause_rounded)
                                : (item.isNetwork ? Icons.language_rounded : Icons.movie_rounded),
                            color: selected ? const Color(0xFFE50914) : const Color(0xFF64748B),
                            size: 20,
                          ),
                          title: Text(
                            item.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected ? Colors.white : const Color(0xFFCBD5E1),
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                          subtitle: item.durationMs > 0
                              ? Text(
                                  _fmt(Duration(milliseconds: item.durationMs)),
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (selected && _isLoading)
                                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                              IconButton(icon: const Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFF64748B)), onPressed: () => _move(i, -1)),
                              IconButton(icon: const Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFF64748B)), onPressed: () => _move(i, 1)),
                              IconButton(icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)), onPressed: () => _removeAt(i)),
                            ],
                          ),
                          onTap: () => _playAt(i),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Thanh điều khiển dưới
  Widget _buildBottomBar() {
    return Container(
      color: const Color(0xFF111622),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSeekRow(),
          const SizedBox(height: 2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IconButton(tooltip: 'Ẩn/hiện playlist', icon: Icon(Icons.playlist_play_rounded, color: _showPlaylist ? const Color(0xFFE50914) : Colors.white70), onPressed: () => setState(() => _showPlaylist = !_showPlaylist)),
                IconButton(tooltip: 'Bài trước (P)', icon: const Icon(Icons.skip_previous_rounded, color: Colors.white), onPressed: _playlist.isEmpty ? null : _playPrev),
                Container(
                  decoration: const BoxDecoration(color: Color(0xFFE50914), shape: BoxShape.circle),
                  child: IconButton(
                    tooltip: 'Phát/Tạm dừng (Space)',
                    icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                    onPressed: _togglePlay,
                  ),
                ),
                IconButton(tooltip: 'Dừng', icon: const Icon(Icons.stop_rounded, color: Colors.white), onPressed: _current == null ? null : _stop),
                IconButton(tooltip: 'Bài tiếp (N)', icon: const Icon(Icons.skip_next_rounded, color: Colors.white), onPressed: _playlist.isEmpty ? null : _playNext),
                IconButton(tooltip: 'Toàn màn hình (F)', icon: Icon(_isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, color: Colors.white70), onPressed: _toggleFullscreen),
                const SizedBox(width: 4),
                _loopButton(),
                IconButton(
                  tooltip: _shuffle ? 'Tắt ngẫu nhiên' : 'Phát ngẫu nhiên',
                  icon: Icon(Icons.shuffle_rounded, color: _shuffle ? const Color(0xFFE50914) : Colors.white70),
                  onPressed: () => setState(() => _shuffle = !_shuffle),
                ),
                const SizedBox(width: 8),
                // Volume
                IconButton(
                  tooltip: 'Tắt/Bật tiếng (M)',
                  icon: Icon(_muted || _volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white70, size: 20),
                  onPressed: _toggleMute,
                ),
                SizedBox(
                  width: 90,
                  child: Slider(value: _volume, min: 0, max: 1, activeColor: Colors.white70, inactiveColor: const Color(0xFF334155), onChanged: _setVolume),
                ),
                const SizedBox(width: 8),
                // Tốc độ
                PopupMenuButton<double>(
                  color: const Color(0xFF1A2130),
                  tooltip: 'Tốc độ phát',
                  onSelected: _setRate,
                  itemBuilder: (_) => [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0]
                      .map((r) => PopupMenuItem(value: r, child: Text('${r}x${r == _rate ? '  ✓' : ''}')))
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFF334155)), borderRadius: BorderRadius.circular(6)),
                    child: Text('${_rate}x', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  color: const Color(0xFF1A2130),
                  tooltip: 'Tỉ lệ khung hình',
                  onSelected: (v) {
                    setState(() {
                      _fit = {
                            'contain': BoxFit.contain,
                            'cover': BoxFit.cover,
                            'fill': BoxFit.fill,
                            'width': BoxFit.fitWidth,
                          }[v] ??
                          BoxFit.contain;
                    });
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'contain', child: Text('Vừa khung')),
                    PopupMenuItem(value: 'cover', child: Text('Phủ đầy')),
                    PopupMenuItem(value: 'fill', child: Text('Kéo giãn')),
                    PopupMenuItem(value: 'width', child: Text('Rộng')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFF334155)), borderRadius: BorderRadius.circular(6)),
                    child: Text(_fitLabel(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loopButton() {
    IconData icon;
    Color color = Colors.white70;
    String tip = 'Lặp: ${_loop.label} (L)';
    switch (_loop) {
      case LoopMode.off:
        icon = Icons.repeat_rounded;
        break;
      case LoopMode.all:
        icon = Icons.repeat_rounded;
        color = const Color(0xFFE50914);
        break;
      case LoopMode.one:
        icon = Icons.repeat_one_rounded;
        color = const Color(0xFFE50914);
        break;
    }
    return IconButton(
      tooltip: tip,
      icon: Icon(icon, color: color),
      onPressed: () {
        setState(() => _loop = _loop.next);
        _persistSettings();
      },
    );
  }

  Widget _buildSeekRow({bool compact = false}) {
    final max = _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0;
    final value = _position.inMilliseconds.clamp(0, max.toInt()).toDouble();
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            _fmt(_position),
            style: TextStyle(color: compact ? Colors.white : const Color(0xFF94A3B8), fontSize: 11),
          ),
        ),
        Expanded(
          child: Slider(
            value: value > max ? max : value,
            max: max,
            activeColor: const Color(0xFFE50914),
            inactiveColor: const Color(0xFF334155),
            onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            _fmt(_duration),
            style: TextStyle(color: compact ? Colors.white : const Color(0xFF94A3B8), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

/// Nút hành động pill trên thanh công cụ (Mở file / Mở link).
class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primary ? const Color(0xFFE50914) : const Color(0xFF1A2130),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: primary ? const Color(0xFFE50914) : const Color(0xFF2D3748),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
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
    );
  }
}

/// Nút dropdown pill trên thanh công cụ (Phụ đề / Âm thanh / Hình ảnh).
class _PopupAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final List<PopupMenuEntry<dynamic>> items;
  const _PopupAction({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      color: const Color(0xFF1A2130),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: tooltip,
      itemBuilder: (_) => items,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2130),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFF2D3748)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}
