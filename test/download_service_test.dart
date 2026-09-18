import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:fcine/core/database/app_database.dart';
import 'package:fcine/core/download/download_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Dio giả: trả nội dung theo URL map. m3u8 (responseType plain) có thể
/// cấu hình trả status lỗi để test nhánh failed.
class _FakeAdapter implements HttpClientAdapter {
  final Map<String, List<int>> files;
  final int m3u8Status;
  _FakeAdapter(this.files, {this.m3u8Status = 200});

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final key = options.uri.toString();
    final body = files[key];
    if (body == null) {
      return ResponseBody.fromString('not found', 404);
    }
    if (m3u8Status != 200 && options.responseType == ResponseType.plain) {
      return ResponseBody.fromString('forbidden', m3u8Status);
    }
    return ResponseBody.fromBytes(body, 200);
  }
}

class _FakePathProvider extends PathProviderPlatform {
  final String docsPath;
  _FakePathProvider(this.docsPath);
  @override
  Future<String?> getApplicationDocumentsPath() async => docsPath;
}

/// Dio giả: m3u8 trả ngay, segment treo mãi cho tới khi CancelToken huỷ
/// (test cancel abort download đang chạy).
class _NeverEndingAdapter implements HttpClientAdapter {
  final List<int> playlist;
  final String m3u8Url;
  _NeverEndingAdapter(this.playlist, this.m3u8Url);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.toString() == m3u8Url) {
      return ResponseBody.fromBytes(playlist, 200);
    }
    final c = Completer<ResponseBody>();
    cancelFuture?.then((_) {
      if (!c.isCompleted) {
        c.completeError(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
          ),
        );
      }
    });
    return c.future;
  }
}

String _simplePlaylist(List<String> segments) => [
      '#EXTM3U',
      '#EXT-X-TARGETDURATION:10',
      for (final s in segments) ...['#EXTINF:10.0,', s],
      '#EXT-X-ENDLIST',
    ].join('\n');

Future<Download> _waitForStatus(
  AppDatabase db,
  int id,
  String status, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    final all = await db.getAllDownloads();
    final d = all.where((e) => e.id == id).firstOrNull;
    if (d != null && d.status == status) return d;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail('Timeout đợi status "$status" cho download #$id');
}

void main() {
  late Directory tempDocs;

  setUp(() {
    tempDocs = Directory.systemTemp.createTempSync('fcine_dl_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDocs.path);
  });

  tearDown(() {
    try {
      tempDocs.deleteSync(recursive: true);
    } catch (_) {}
  });

  AppDatabase buildDb() => AppDatabase.forTesting(NativeDatabase.memory());

  test('Tải playlist đơn: hoàn thành, rewrite m3u8 về file local, progress 100', () async {
    final db = buildDb();
    addTearDown(db.close);
    const m3u8Url = 'https://cdn.test/v/index.m3u8';
    final playlist = _simplePlaylist(['seg1.ts', 'seg2.ts', 'seg3.ts']);
    final svc = DownloadService(
      db: db,
      dio: Dio()..httpClientAdapter = _FakeAdapter({
        m3u8Url: utf8.encode(playlist),
        'https://cdn.test/v/seg1.ts': [1, 2, 3],
        'https://cdn.test/v/seg2.ts': [4, 5, 6],
        'https://cdn.test/v/seg3.ts': [7, 8, 9],
      }),
    );

    final entry = await svc.startDownload(
      movieSlug: 'movie-a',
      movieName: 'Movie A',
      posterUrl: 'p.jpg',
      episodeName: 'Tập 1',
      episodeSlug: 'tap-1',
      serverName: 'Vietsub',
      remoteM3u8: m3u8Url,
    );
    expect(entry.status, 'downloading');
    expect(entry.id, greaterThan(0));

    final done = await _waitForStatus(db, entry.id, 'completed');
    expect(done.progress, 100);
    expect(done.downloadedSegments, 3);
    expect(done.totalSegments, 3);
    expect(done.localM3u8, isNotNull);

    final localFile = File(done.localM3u8!);
    expect(localFile.existsSync(), isTrue);
    final content = localFile.readAsStringSync();
    expect(content, contains('seg1.ts'));
    expect(content, contains('seg3.ts'));
    expect(content, isNot(contains('https://cdn.test/v/seg1.ts')));

    expect(File(p.join(done.localM3u8!, '..', 'seg1.ts')).existsSync(), isTrue);
    expect(await svc.totalSizeOnDisk(), greaterThan(0));
    expect(await svc.getLocalPath('movie-a', 'tap-1', 'Vietsub'), isNotNull);
  });

  test('Master playlist: tải variant đầu tiên và rewrite segment variant', () async {
    final db = buildDb();
    addTearDown(db.close);
    const masterUrl = 'https://cdn.test/m/master.m3u8';
    const variantUrl = 'https://cdn.test/m/720p.m3u8';
    const master = '#EXTM3U\n#EXT-X-STREAM-INF:BANDWIDTH=1280000\n720p.m3u8\n';
    final variant = _simplePlaylist(['v1.ts', 'v2.ts']);
    final svc = DownloadService(
      db: db,
      dio: Dio()..httpClientAdapter = _FakeAdapter({
        masterUrl: utf8.encode(master),
        variantUrl: utf8.encode(variant),
        'https://cdn.test/m/v1.ts': [1],
        'https://cdn.test/m/v2.ts': [2],
      }),
    );

    final entry = await svc.startDownload(
      movieSlug: 'movie-b',
      movieName: 'Movie B',
      posterUrl: null,
      episodeName: 'Full',
      episodeSlug: 'full',
      serverName: 'Vietsub',
      remoteM3u8: masterUrl,
    );

    final done = await _waitForStatus(db, entry.id, 'completed');
    expect(done.progress, 100);
    expect(done.totalSegments, 2);

    final content = File(done.localM3u8!).readAsStringSync();
    expect(content, contains('v1.ts'));
    expect(content, isNot(contains('https://cdn.test/m/v1.ts')));
  });

  test('m3u8 trả lỗi: entry chuyển sang failed', () async {
    final db = buildDb();
    addTearDown(db.close);
    const m3u8Url = 'https://cdn.test/broken.m3u8';
    final svc = DownloadService(
      db: db,
      dio: Dio()..httpClientAdapter = _FakeAdapter({}, m3u8Status: 403),
    );

    final entry = await svc.startDownload(
      movieSlug: 'movie-c',
      movieName: 'Movie C',
      posterUrl: null,
      episodeName: 'Tập 1',
      episodeSlug: 'tap-1',
      serverName: 'Vietsub',
      remoteM3u8: m3u8Url,
    );

    final failed = await _waitForStatus(db, entry.id, 'failed');
    expect(failed.localM3u8, isNull);
  });

  test('Huỷ download đang chạy: abort segment, xoá file dở, status cancelled', () async {
    final db = buildDb();
    addTearDown(db.close);
    const m3u8Url = 'https://cdn.test/v/index.m3u8';
    final playlist = _simplePlaylist(['seg1.ts', 'seg2.ts', 'seg3.ts']);
    final svc = DownloadService(
      db: db,
      dio: Dio()..httpClientAdapter = _NeverEndingAdapter(utf8.encode(playlist), m3u8Url),
    );

    final entry = await svc.startDownload(
      movieSlug: 'movie-e',
      movieName: 'Movie E',
      posterUrl: null,
      episodeName: 'Tập 1',
      episodeSlug: 'tap-1',
      serverName: 'Vietsub',
      remoteM3u8: m3u8Url,
    );

    // Cho download kẹt ở segment đầu rồi huỷ.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await svc.cancelDownload(entry.id);

    final cancelled = await _waitForStatus(db, entry.id, 'cancelled');
    expect(cancelled.localM3u8, isNull);
    expect(await svc.getLocalPath('movie-e', 'tap-1', 'Vietsub'), isNull);
  });

  test('Huỷ entry downloading không còn token (app restart): status cancelled', () async {
    final db = buildDb();
    addTearDown(db.close);
    final svc = DownloadService(db: db);
    await db.upsertDownload(
      DownloadsCompanion(
        movieSlug: const Value('movie-f'),
        movieName: const Value('Movie F'),
        posterUrl: const Value(null),
        episodeName: const Value('Tập 1'),
        episodeSlug: const Value('tap-1'),
        serverName: const Value('Vietsub'),
        remoteM3u8: const Value('https://cdn.test/f.m3u8'),
        status: const Value('downloading'),
        progress: const Value(50),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final entry = (await db.getAllDownloads()).first;

    await svc.cancelDownload(entry.id);

    final cancelled = await _waitForStatus(db, entry.id, 'cancelled');
    expect(cancelled.status, 'cancelled');
  });

  test('deleteDownload: xoá file trên đĩa + xoá DB row', () async {
    final db = buildDb();
    addTearDown(db.close);
    const m3u8Url = 'https://cdn.test/v/index.m3u8';
    final playlist = _simplePlaylist(['seg1.ts']);
    final svc = DownloadService(
      db: db,
      dio: Dio()..httpClientAdapter = _FakeAdapter({
        m3u8Url: utf8.encode(playlist),
        'https://cdn.test/v/seg1.ts': [1, 2, 3],
      }),
    );

    final entry = await svc.startDownload(
      movieSlug: 'movie-d',
      movieName: 'Movie D',
      posterUrl: null,
      episodeName: 'Tập 1',
      episodeSlug: 'tap-1',
      serverName: 'Vietsub',
      remoteM3u8: m3u8Url,
    );
    await _waitForStatus(db, entry.id, 'completed');

    final before = await svc.totalSizeOnDisk();
    expect(before, greaterThan(0));

    final all = await db.getAllDownloads();
    await svc.deleteDownload(all.first);

    expect(await db.getAllDownloads(), isEmpty);
    expect(await svc.totalSizeOnDisk(), 0);
    expect(await svc.getLocalPath('movie-d', 'tap-1', 'Vietsub'), isNull);
  });
}
