import 'dart:convert';

/// 1 item trong playlist của trình phát Video.
class PlaylistMedia {
  final String id;
  final String uri; // http(s)://... hoặc file://... hoặc path local
  final String title;
  final String? subtitleUri; // file phụ đề ngoài đã gắn (nếu có)
  final int lastPositionMs;
  final int durationMs;

  const PlaylistMedia({
    required this.id,
    required this.uri,
    required this.title,
    this.subtitleUri,
    this.lastPositionMs = 0,
    this.durationMs = 0,
  });

  bool get isNetwork =>
      uri.startsWith('http://') || uri.startsWith('https://');

  String get displayName {
    if (title.isNotEmpty) return title;
    try {
      final u = Uri.parse(uri);
      final seg = u.pathSegments.isNotEmpty ? u.pathSegments.last : uri;
      final decoded = Uri.decodeComponent(seg);
      if (decoded.isNotEmpty) return decoded;
    } catch (_) {}
    return uri;
  }

  PlaylistMedia copyWith({
    String? uri,
    String? title,
    String? subtitleUri,
    int? lastPositionMs,
    int? durationMs,
  }) => PlaylistMedia(
    id: id,
    uri: uri ?? this.uri,
    title: title ?? this.title,
    subtitleUri: subtitleUri ?? this.subtitleUri,
    lastPositionMs: lastPositionMs ?? this.lastPositionMs,
    durationMs: durationMs ?? this.durationMs,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'uri': uri,
    'title': title,
    'subtitleUri': subtitleUri,
    'lastPositionMs': lastPositionMs,
    'durationMs': durationMs,
  };

  factory PlaylistMedia.fromJson(Map<String, dynamic> json) => PlaylistMedia(
    id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
    uri: json['uri']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    subtitleUri: json['subtitleUri']?.toString(),
    lastPositionMs: (json['lastPositionMs'] as num?)?.toInt() ?? 0,
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
  );

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Chuẩn hoá input user (link / path) thành uri phát được.
  /// Ném [ArgumentError] với message thân thiện nếu không hợp lệ.
  static String resolveUri(String raw) {
    final input = raw.trim();
    if (input.isEmpty) {
      throw ArgumentError('Vui lòng nhập link hoặc đường dẫn file');
    }
    if (input.startsWith('http://') || input.startsWith('https://')) {
      final uri = Uri.tryParse(input);
      if (uri == null || !uri.hasAuthority) {
        throw ArgumentError('Link http(s) không hợp lệ');
      }
      return input;
    }
    var path = input;
    if ((path.startsWith('"') && path.endsWith('"')) ||
        (path.startsWith("'") && path.endsWith("'"))) {
      path = path.substring(1, path.length - 1);
    }
    if (path.startsWith('file://')) return path;
    // Cho phép path local tồn tại hoặc chưa tồn tại (USB rút ra) vẫn add vào list
    if (path.contains(':') || path.startsWith('/') || path.contains('\\')) {
      // Nếu là Windows path C:\... thì convert sang file uri khi phát,
      // ở đây cứ giữ nguyên path, lúc phát sẽ convert.
      return path;
    }
    final withScheme = 'https://$input';
    final uri = Uri.tryParse(withScheme);
    if (uri != null &&
        uri.hasAuthority &&
        input.contains('.') &&
        !input.contains(' ')) {
      return withScheme;
    }
    throw ArgumentError(
      'Không hiểu input. Dán link http(s) hoặc đường dẫn file đầy đủ.',
    );
  }

  /// Uri thực tế đưa vào media_kit Media.
  static String toPlayable(String uri) {
    final t = uri.trim();
    if (t.startsWith('http://') ||
        t.startsWith('https://') ||
        t.startsWith('file://')) {
      return t;
    }
    // Path local -> file://
    try {
      // Dùng Uri.file để encode đúng tiếng Việt + khoảng trắng
      return Uri.file(t).toString();
    } catch (_) {
      return t;
    }
  }

  static String titleFromUri(String uri) {
    try {
      final playable = toPlayable(uri);
      final u = Uri.parse(playable);
      if (u.pathSegments.isNotEmpty) {
        return Uri.decodeComponent(u.pathSegments.last);
      }
    } catch (_) {}
    return uri;
  }

  static String encodeList(List<PlaylistMedia> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<PlaylistMedia> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => PlaylistMedia.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((e) => e.uri.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}

enum LoopMode { off, all, one }

extension LoopModeX on LoopMode {
  String get label {
    switch (this) {
      case LoopMode.off:
        return 'Không lặp';
      case LoopMode.all:
        return 'Lặp tất cả';
      case LoopMode.one:
        return 'Lặp 1 bài';
    }
  }

  LoopMode get next {
    switch (this) {
      case LoopMode.off:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.one;
      case LoopMode.one:
        return LoopMode.off;
    }
  }
}
