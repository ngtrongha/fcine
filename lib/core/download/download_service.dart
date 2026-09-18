import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class DownloadService {
  final AppDatabase db;
  final Dio dio;
  DownloadService({required this.db, Dio? dio}) : dio = dio ?? Dio();

  /// CancelToken của các download đang chạy, tra cứu theo entry id.
  final Map<int, CancelToken> _cancelTokens = {};

  Future<Directory> _baseDir() async {
    final doc = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(doc.path, 'downloads'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String> _localDir(String movieSlug, String episodeSlug, String serverName) async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, movieSlug, '${episodeSlug}_$serverName'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  Future<Download> startDownload({
    required String movieSlug,
    required String movieName,
    String? posterUrl,
    required String episodeName,
    required String episodeSlug,
    required String serverName,
    required String remoteM3u8,
  }) async {
    // Tạo entry pending
    final now = DateTime.now();
    final companion = DownloadsCompanion(
      movieSlug: Value(movieSlug),
      movieName: Value(movieName),
      posterUrl: Value(posterUrl),
      episodeName: Value(episodeName),
      episodeSlug: Value(episodeSlug),
      serverName: Value(serverName),
      remoteM3u8: Value(remoteM3u8),
      status: const Value('downloading'),
      progress: const Value(0),
      totalSegments: const Value(0),
      downloadedSegments: const Value(0),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
    await db.upsertDownload(companion);
    final entry = (await db.getDownload(movieSlug, episodeSlug, serverName))!;

    // chạy async download không block
    final token = CancelToken();
    _cancelTokens[entry.id] = token;
    _downloadInBackground(entry, token);
    return entry;
  }

  /// Huỷ download đang chạy: cancel token → loop dừng → xoá file dở dang
  /// + đánh dấu 'cancelled'. Entry không có token (app restart giữa chừng)
  /// → huỷ trực tiếp.
  Future<void> cancelDownload(int id) async {
    final token = _cancelTokens.remove(id);
    if (token != null) {
      token.cancel('user-cancelled');
      return;
    }
    final all = await db.getAllDownloads();
    final entry = all.where((e) => e.id == id).firstOrNull;
    if (entry != null && entry.status == 'downloading') {
      await _cleanupPartial(entry);
      await db.updateDownloadStatus(entry.id, 'cancelled');
    }
  }

  Future<void> _cleanupPartial(Download entry) async {
    try {
      final dirPath = await _localDir(entry.movieSlug, entry.episodeSlug, entry.serverName);
      final dir = Directory(dirPath);
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  Future<void> _downloadInBackground(Download entry, CancelToken token) async {
    try {
      final dirPath = await _localDir(entry.movieSlug, entry.episodeSlug, entry.serverName);
      // 1. Fetch m3u8
      final res = await dio.get(
        entry.remoteM3u8,
        options: Options(responseType: ResponseType.plain),
        cancelToken: token,
      );
      final String content = res.data as String;
      final baseUri = Uri.parse(entry.remoteM3u8);

      // 2. Parse segments và keys
      final lines = content.split('\n');
      final List<String> segmentUrls = [];
      final List<String> keyUrls = [];
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) {
          if (trimmed.startsWith('#EXT-X-KEY')) {
            final uriMatch = RegExp(r'URI="([^"]+)"').firstMatch(trimmed);
            if (uriMatch != null) {
              final keyUri = uriMatch.group(1)!;
              final abs = keyUri.startsWith('http') ? keyUri : baseUri.resolve(keyUri).toString();
              if (!keyUrls.contains(abs)) keyUrls.add(abs);
            }
          }
          continue;
        }
        // segment line (ts, m4s, mp4, etc)
        final abs = trimmed.startsWith('http') ? trimmed : baseUri.resolve(trimmed).toString();
        segmentUrls.add(abs);
      }

      // Nếu là master playlist (chứa #EXT-X-STREAM-INF), thì tải variant đầu tiên
      if (content.contains('#EXT-X-STREAM-INF') && segmentUrls.isNotEmpty) {
        // segmentUrls ở đây thực ra là variant m3u8 urls, tải variant đầu
        final variantUrl = segmentUrls.first;
        final variantRes = await dio.get(
          variantUrl,
          options: Options(responseType: ResponseType.plain),
          cancelToken: token,
        );
        final variantContent = variantRes.data as String;
        final variantBase = Uri.parse(variantUrl);
        segmentUrls.clear();
        for (final line in variantContent.split('\n')) {
          final t = line.trim();
          if (t.isEmpty || t.startsWith('#')) continue;
          final abs = t.startsWith('http') ? t : variantBase.resolve(t).toString();
          segmentUrls.add(abs);
        }
        // ghi đè content để rewrite sau
      await _downloadSegmentsAndRewrite(
        entry: entry,
        dirPath: dirPath,
        originalContent: variantContent,
        segmentUrls: segmentUrls,
        baseUri: variantBase,
        keyUrls: keyUrls,
        token: token,
      );
      return;
    }

    await _downloadSegmentsAndRewrite(
      entry: entry,
      dirPath: dirPath,
      originalContent: content,
      segmentUrls: segmentUrls,
      baseUri: baseUri,
      keyUrls: keyUrls,
      token: token,
    );
  } catch (e) {
    if (e is DioException && CancelToken.isCancel(e)) {
      await _cleanupPartial(entry);
      await db.updateDownloadStatus(entry.id, 'cancelled');
    } else {
      await db.updateDownloadStatus(entry.id, 'failed');
    }
  }
}

  Future<void> _downloadSegmentsAndRewrite({
    required Download entry,
    required String dirPath,
    required String originalContent,
    required List<String> segmentUrls,
    required Uri baseUri,
    required List<String> keyUrls,
    required CancelToken token,
  }) async {
    // cập nhật total
    await (db.update(db.downloads)..where((t) => t.id.equals(entry.id))).write(DownloadsCompanion(totalSegments: Value(segmentUrls.length)));
    // tải keys nếu có
    final Map<String, String> keyMap = {}; // remote -> local filename
    for (final keyUrl in keyUrls) {
      final fileName = p.basename(Uri.parse(keyUrl).path);
      final localPath = p.join(dirPath, fileName);
      try {
        await dio.download(keyUrl, localPath);
        keyMap[keyUrl] = fileName;
      } catch (_) {}
    }

    String newContent = originalContent;
    int downloaded = 0;
    for (final segUrl in segmentUrls) {
      // Segment errors bị nuốt nên phải kiểm tra cancel thủ công,
      // không thì huỷ sẽ bị bỏ qua và loop vẫn chạy hết.
      if (token.isCancelled) {
        throw token.cancelError ??
            DioException.requestCancelled(
              requestOptions: RequestOptions(path: segUrl),
              reason: 'user-cancelled',
            );
      }
      final fileName = p.basename(Uri.parse(segUrl).path.split('?').first);
      final localPath = p.join(dirPath, fileName);
      try {
        await dio.download(segUrl, localPath, options: Options(receiveTimeout: const Duration(seconds: 15)), cancelToken: token);
        newContent = newContent.replaceAll(segUrl, fileName);
      } catch (_) {
        // lỗi 1 segment => tiếp tục, không fail toàn bộ
      }
      downloaded++;
      final progress = ((downloaded / segmentUrls.length) * 100).round();
      await db.updateDownloadProgress(entry.id, progress, downloaded);
      // thay key URIs
      for (final kv in keyMap.entries) {
        newContent = newContent.replaceAll(kv.key, kv.value);
      }
    }

    // lưu local m3u8
    final localM3u8Path = p.join(dirPath, 'index.m3u8');
    final localFile = File(localM3u8Path);
    await localFile.writeAsString(newContent);
    await db.updateDownloadStatus(entry.id, 'completed', localM3u8: localM3u8Path);
  }

  Future<void> deleteDownload(Download d) async {
    try {
      final dirPath = await _localDir(d.movieSlug, d.episodeSlug, d.serverName);
      final dir = Directory(dirPath);
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
    await db.deleteDownload(d.movieSlug, d.episodeSlug, d.serverName);
  }

  /// Tổng dung lượng thực tế trên đĩa của thư mục downloads (bytes).
  Future<int> totalSizeOnDisk() async {
    try {
      final base = await _baseDir();
      if (!await base.exists()) return 0;
      int total = 0;
      await for (final e in base.list(recursive: true, followLinks: false)) {
        if (e is File) {
          try {
            total += await e.length();
          } catch (_) {}
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<String?> getLocalPath(String movieSlug, String episodeSlug, String serverName) async {
    final d = await db.getDownload(movieSlug, episodeSlug, serverName);
    if (d != null && d.status == 'completed' && d.localM3u8 != null) {
      final f = File(d.localM3u8!);
      if (await f.exists()) return d.localM3u8;
    }
    return null;
  }

  Stream<List<Download>> watchAll() => db.watchAllDownloads();
  Future<List<Download>> getAll() => db.getAllDownloads();
}
