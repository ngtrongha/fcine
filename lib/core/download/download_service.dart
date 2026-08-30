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
    _downloadInBackground(entry);
    return entry;
  }

  Future<void> _downloadInBackground(Download entry) async {
    try {
      final dirPath = await _localDir(entry.movieSlug, entry.episodeSlug, entry.serverName);
      // 1. Fetch m3u8
      final res = await dio.get(entry.remoteM3u8, options: Options(responseType: ResponseType.plain));
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
        final variantRes = await dio.get(variantUrl, options: Options(responseType: ResponseType.plain));
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
      );
    } catch (e) {
      await db.updateDownloadStatus(entry.id, 'failed');
    }
  }

  Future<void> _downloadSegmentsAndRewrite({
    required Download entry,
    required String dirPath,
    required String originalContent,
    required List<String> segmentUrls,
    required Uri baseUri,
    required List<String> keyUrls,
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
      final fileName = p.basename(Uri.parse(segUrl).path.split('?').first);
      final localPath = p.join(dirPath, fileName);
      try {
        await dio.download(segUrl, localPath, options: Options(receiveTimeout: const Duration(seconds: 15)));
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
