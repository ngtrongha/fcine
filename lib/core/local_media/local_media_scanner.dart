import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_video.dart';

/// Quét video/audio có sẵn trên thiết bị (thư viện media).
///
/// - Không cần thêm dependency native: chỉ dùng `dart:io` + `path_provider`.
/// - Trên Android nếu chưa cấp quyền đọc bộ nhớ, các thư mục công cộng
///   sẽ bị bỏ qua lặng lẽ và trả về những gì quét được + thư mục app.
/// - Hỗ trợ thư mục tùy chọn do user thêm (persist trong SharedPreferences).
class LocalMediaScanner {
  static const _kCustomDirs = 'vlc_scan_custom_dirs';

  static const Set<String> videoExtensions = {
    'mp4', 'mkv', 'avi', 'mov', 'webm', 'm3u8', 'm3u',
    'ts', 'm2ts', 'wmv', 'flv', '3gp', 'mpg', 'mpeg',
    'm4v', '3g2', 'asf', 'vob', 'ogv',
    // audio kèm theo
    'mp3', 'flac', 'wav', 'ogg', 'opus', 'aac', 'm4a',
  };

  /// Quét toàn bộ roots ứng viên + thư mục custom của user.
  /// Trả về danh sách sắp xếp mới nhất trước, tối đa [limit] file.
  Future<List<LocalVideo>> scan({int limit = 2000}) async {
    final roots = await candidateRoots();
    final seen = <String>{};
    final results = <LocalVideo>[];

    for (final root in roots) {
      if (results.length >= limit) break;
      try {
        final dir = Directory(root);
        if (!await dir.exists()) continue;
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (results.length >= limit) break;
          if (entity is! File) continue;
          final filePath = entity.path;
          // Bỏ qua file ẩn / cache / thumbnail hệ thống.
          final base = p.basename(filePath);
          if (base.startsWith('.')) continue;
          if (filePath.contains('/.thumbnails/') ||
              filePath.contains('/.cache/') ||
              filePath.contains('/Android/data/') && filePath.endsWith('.nomedia')) {
            continue;
          }
          final ext = p.extension(filePath).replaceFirst('.', '').toLowerCase();
          if (!videoExtensions.contains(ext)) continue;
          // Bỏ qua file .nomedia và file quá nhỏ (< 100KB, thường là sample/cache).
          try {
            final stat = await entity.stat();
            if (stat.size < 100 * 1024) continue;
            final normalized = p.normalize(filePath);
            if (seen.add(normalized)) {
              results.add(LocalVideo(
                path: filePath,
                name: base,
                extension: ext,
                sizeBytes: stat.size,
                modified: stat.modified,
              ));
            }
          } catch (_) {
            // File bị khóa / USB rút ra giữa chừng -> bỏ qua.
          }
        }
      } catch (_) {
        // Không có quyền đọc thư mục này -> bỏ qua, quét tiếp thư mục khác.
      }
    }

    results.sort((a, b) => b.modified.compareTo(a.modified));
    return results;
  }

  /// Các thư mục ứng viên để quét theo từng nền tảng.
  Future<List<String>> candidateRoots() async {
    final roots = <String>[];

    void add(String? dir) {
      if (dir == null || dir.isEmpty) return;
      final normalized = p.normalize(dir);
      if (!roots.contains(normalized)) roots.add(normalized);
    }

    // 1. Thư mục app (luôn đọc được, gồm cả file đã tải trong app).
    try {
      final doc = await getApplicationDocumentsDirectory();
      add(doc.path);
      add(p.join(doc.path, 'downloads'));
    } catch (_) {}

    // 2. Thư mục custom do user thêm.
    for (final d in await customDirs()) {
      add(d);
    }

    if (Platform.isAndroid) {
      // Bộ nhớ ngoài app-accessible.
      try {
        final extDirs = await getExternalStorageDirectories();
        if (extDirs != null) {
          for (final d in extDirs) {
            add(d.path);
          }
        }
      } catch (_) {}
      // Thư mục công cộng phổ biến (cần quyền READ_MEDIA_VIDEO / storage).
      const publicDirs = [
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Media',
        '/sdcard/Movies',
        '/sdcard/DCIM',
        '/sdcard/Download',
      ];
      for (final d in publicDirs) {
        add(d);
      }
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Thư mục user trên desktop.
      final home = Platform.environment['USERPROFILE'] ??
          Platform.environment['HOME'] ??
          Platform.environment['HOMEPATH'];
      if (home != null && home.isNotEmpty) {
        for (final sub in ['Videos', 'Movies', 'Downloads', 'Music', 'Desktop']) {
          add(p.join(home, sub));
        }
      }
      try {
        final downloads = await getDownloadsDirectory();
        add(downloads?.path);
      } catch (_) {}
    } else if (Platform.isIOS) {
      // iOS sandbox: chỉ quét được trong app.
    }

    // Chỉ giữ thư mục tồn tại để đỡ tốn lần list lỗi.
    final existing = <String>[];
    for (final r in roots) {
      try {
        if (await Directory(r).exists()) existing.add(r);
      } catch (_) {}
    }
    return existing;
  }

  Future<List<String>> customDirs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_kCustomDirs) ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<void> addCustomDir(String dir) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kCustomDirs) ?? [];
    final normalized = p.normalize(dir);
    if (!list.contains(normalized)) {
      list.add(normalized);
      await prefs.setStringList(_kCustomDirs, list);
    }
  }

  Future<void> removeCustomDir(String dir) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kCustomDirs) ?? [];
    list.remove(p.normalize(dir));
    await prefs.setStringList(_kCustomDirs, list);
  }
}
