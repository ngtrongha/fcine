import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fcine/core/database/app_database.dart';
import 'package:fcine/core/di/injection.dart';
import 'package:fcine/core/download/download_service.dart';
import 'package:fcine/presentation/blocs/library/library_bloc.dart';
import 'package:fcine/presentation/blocs/library/library_event.dart';
import 'package:fcine/presentation/blocs/library/library_state.dart';
import 'package:fcine/ui/features/library/views/widgets/downloads_tab.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String docsPath;
  _FakePathProvider(this.docsPath);
  @override
  Future<String?> getApplicationDocumentsPath() async => docsPath;
}

/// Dio giả chặn mọi request thật (test không được gọi mạng).
class _FakeAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('blocked', 404);
  }
}

Future<Download> _seed(AppDatabase db, {required String status}) async {
  await db.upsertDownload(
    DownloadsCompanion(
      movieSlug: const Value('movie-x'),
      movieName: const Value('Movie X'),
      posterUrl: const Value(null),
      episodeName: const Value('Tập 1'),
      episodeSlug: const Value('tap-1'),
      serverName: const Value('Vietsub'),
      remoteM3u8: const Value('https://cdn.test/x/index.m3u8'),
      status: Value(status),
      progress: Value(status == 'completed' ? 100 : 30),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ),
  );
  return (await db.getAllDownloads()).first;
}

/// Toast auto-dismiss sau 2s bằng Timer — bơm fake time qua mốc đó để
/// test kết thúc không còn pending timer (invariant của flutter_test).
Future<void> _drainToastTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
}

void main() {
  late Directory tempDocs;

  setUpAll(() async {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        Directory.systemTemp.createTempSync('fcine_dl_tab_test_').path,
      ),
    );
  });

  setUp(() {
    tempDocs = Directory.systemTemp.createTempSync('fcine_dl_tab_');
    PathProviderPlatform.instance = _FakePathProvider(tempDocs.path);
  });

  tearDown(() {
    try {
      tempDocs.deleteSync(recursive: true);
    } catch (_) {}
  });

  Widget wrap(LibraryBloc bloc) {
    return BlocProvider.value(
      value: bloc,
      child: MaterialApp(
        home: Scaffold(
          body: BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) => DownloadsTab(items: state.downloads),
          ),
        ),
      ),
    );
  }

  testWidgets('Bản tải completed: menu có Tải lại + Xóa; Xóa dispatch xoá + toast', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final svc = DownloadService(db: db);
    await _seed(db, status: 'completed');

    final bloc = LibraryBloc(db: db, downloadService: svc)
      ..add(const LibraryEvent.started());
    // addTearDown chạy ngược: bloc đóng trước (huỷ stream), rồi db.
    addTearDown(() async {
      await db.close();
    });
    addTearDown(() {
      bloc.close();
    });

    await tester.pumpWidget(wrap(bloc));
    await tester.pump();
    expect(find.text('Movie X - Tập 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Tải lại'), findsOneWidget);
    expect(find.text('Xóa'), findsOneWidget);

    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();

    // Xác nhận dispatch: toast hiện (event đã đi qua bloc). Xoá DB row
    // thực tế đã verify bằng test thuần Dart (library_delete_download_test)
    // vì handler dùng real I/O không hoàn thành trong FakeAsync zone.
    expect(find.text('Đã xóa bản tải: Tập 1'), findsOneWidget);
    await _drainToastTimers(tester);
  });

  testWidgets('Bản tải failed: Tải lại restart download, UI chuyển sang đang tải', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final dio = Dio()..httpClientAdapter = _FakeAdapter();
    final svc = DownloadService(db: db, dio: dio);
    // _retry dùng getIt<DownloadService>() → phải đăng ký instance test.
    await getIt.reset();
    getIt.registerSingleton<DownloadService>(svc);
    addTearDown(getIt.reset);
    await _seed(db, status: 'failed');

    final bloc = LibraryBloc(db: db, downloadService: svc)
      ..add(const LibraryEvent.started());
    addTearDown(bloc.close);

    await tester.pumpWidget(wrap(bloc));
    await tester.pump();
    // UI render text gộp "ServerName • Tải lỗi" → dùng textContaining.
    expect(find.textContaining('Tải lỗi'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tải lại'));
    await tester.pumpAndSettle();

    // startDownload upsert status 'downloading' → DB stream → bloc → UI.
    // Row đang tải hiển thị "ServerName • 0%" (progress từ upsert = 0).
    expect(find.text('Đã thêm lại vào hàng tải: Tập 1'), findsOneWidget);
    expect(bloc.state.downloads.first.status, 'downloading');
    expect(find.textContaining('0%'), findsOneWidget);
    expect(find.textContaining('Tải lỗi'), findsNothing);
    await _drainToastTimers(tester);
  });
}
