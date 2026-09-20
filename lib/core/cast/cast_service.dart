import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/cast_context.dart';
import 'package:flutter_chrome_cast/discovery.dart';
import 'package:flutter_chrome_cast/entities.dart';
import 'package:flutter_chrome_cast/media.dart';
import 'package:flutter_chrome_cast/session.dart';

/// URL này có cast lên TV được không: http(s) + mp4/m3u8.
/// file:// (phim offline trong máy) và link rỗng thì Chromecast không
/// với tới được.
bool isCastableUrl(String url) {
  if (url.isEmpty) return false;
  final u = url.toLowerCase();
  if (!(u.startsWith('http://') || u.startsWith('https://'))) return false;
  final path = u.split('?').first;
  return path.endsWith('.m3u8') || path.endsWith('.mp4');
}

/// Content-Type gửi cho receiver theo đuôi URL.
String castContentType(String url) {
  final path = url.toLowerCase().split('?').first;
  if (path.endsWith('.m3u8')) return 'application/x-mpegURL';
  return 'video/mp4';
}

/// Cast phim đang xem lên Chromecast / Google TV cùng mạng WiFi
/// (native Cast SDK qua flutter_chrome_cast, receiver mặc định của Google,
/// hỗ trợ HLS/m3u8).
///
/// Chỉ hoạt động trên Android/iOS — mọi hàm đều tự no-op ngoài 2 nền tảng
/// này để bản desktop/web không crash (plugin chọn nhầm impl iOS nếu gọi
/// trực tiếp ngoài mobile).
class CastService {
  bool _initialized = false;

  static bool get isSupported {
    if (kIsWeb) return false;
    final p = defaultTargetPlatform;
    return p == TargetPlatform.android || p == TargetPlatform.iOS;
  }

  /// Khởi tạo Cast context (gọi 1 lần, lười khi mở sheet cast).
  Future<void> ensureInitialized() async {
    if (!isSupported || _initialized) return;
    try {
      await GoogleCastContext.instance.setSharedInstanceWithOptions(
        GoogleCastOptions(stopCastingOnAppTerminated: false),
      );
      _initialized = true;
    } catch (_) {}
  }

  Stream<List<GoogleCastDevice>> devicesStream() {
    if (!isSupported) return Stream.value(const <GoogleCastDevice>[]);
    try {
      return GoogleCastDiscoveryManager.instance.devicesStream;
    } catch (_) {
      return Stream.value(const <GoogleCastDevice>[]);
    }
  }

  Future<void> startDiscovery() async {
    if (!isSupported) return;
    try {
      await GoogleCastDiscoveryManager.instance.startDiscovery();
    } catch (_) {}
  }

  Future<void> stopDiscovery() async {
    if (!isSupported) return;
    try {
      await GoogleCastDiscoveryManager.instance.stopDiscovery();
    } catch (_) {}
  }

  Future<bool> connect(GoogleCastDevice device) async {
    if (!isSupported) return false;
    try {
      return await GoogleCastSessionManager.instance.startSessionWithDevice(
        device,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    if (!isSupported) return;
    try {
      await GoogleCastSessionManager.instance.endSessionAndStopCasting();
    } catch (_) {}
  }

  bool get isConnected {
    if (!isSupported) return false;
    try {
      return GoogleCastSessionManager.instance.hasConnectedSession;
    } catch (_) {
      return false;
    }
  }

  Stream<GoogleCastSession?> sessionStream() {
    if (!isSupported) return Stream.value(null);
    try {
      return GoogleCastSessionManager.instance.currentSessionStream;
    } catch (_) {
      return Stream.value(null);
    }
  }

  /// Đẩy phim hiện tại lên TV, bắt đầu từ [startAt].
  /// Một số nguồn yêu cầu header/cookie riêng mà receiver mặc định không
  /// gửi được -> TV sẽ báo lỗi (idle + error), caller hiển thị gợi ý.
  Future<bool> castMovie({
    required String videoUrl,
    required String title,
    required String subtitle,
    required Duration startAt,
  }) async {
    if (!isSupported || !isCastableUrl(videoUrl)) return false;
    try {
      await GoogleCastRemoteMediaClient.instance.loadMedia(
        GoogleCastMediaInformation(
          contentId: videoUrl,
          contentUrl: Uri.parse(videoUrl),
          streamType: CastMediaStreamType.buffered,
          contentType: castContentType(videoUrl),
          metadata: GoogleCastMovieMediaMetadata(
            title: title,
            subtitle: subtitle.isEmpty ? null : subtitle,
          ),
        ),
        autoPlay: true,
        playPosition: startAt,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> play() async {
    try {
      await GoogleCastRemoteMediaClient.instance.play();
    } catch (_) {}
  }

  Future<void> pause() async {
    try {
      await GoogleCastRemoteMediaClient.instance.pause();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await GoogleCastRemoteMediaClient.instance.stop();
    } catch (_) {}
  }

  Future<void> seek(Duration position) async {
    try {
      await GoogleCastRemoteMediaClient.instance.seek(
        GoogleCastMediaSeekOption(position: position),
      );
    } catch (_) {}
  }

  Stream<GoggleCastMediaStatus?> mediaStatusStream() {
    if (!isSupported) return Stream.value(null);
    try {
      return GoogleCastRemoteMediaClient.instance.mediaStatusStream;
    } catch (_) {
      return Stream.value(null);
    }
  }

  Stream<Duration> remotePositionStream() {
    if (!isSupported) return Stream.value(Duration.zero);
    try {
      return GoogleCastRemoteMediaClient.instance.playerPositionStream;
    } catch (_) {
      return Stream.value(Duration.zero);
    }
  }
}
