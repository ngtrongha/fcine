import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:fcine/core/database/app_database.dart';
import 'package:fcine/core/download/download_service.dart';
import 'package:fcine/presentation/blocs/library/library_bloc.dart';
import 'package:fcine/presentation/blocs/library/library_event.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String docsPath;
  _FakePathProvider(this.docsPath);
  @override
  Future<String?> getApplicationDocumentsPath() async => docsPath;
}

void main() {
  setUpAll(() async {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        Directory.systemTemp.createTempSync('fcine_dl_bloc_test_').path,
      ),
    );
  });

  test('LibraryDeleteDownload: bloc xoá DB row (thuần Dart, real IO)', () async {
    final docs = Directory.systemTemp.createTempSync('fcine_dl_bloc_');
    PathProviderPlatform.instance = _FakePathProvider(docs.path);
    addTearDown(() {
      try {
        docs.deleteSync(recursive: true);
      } catch (_) {}
    });

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final svc = DownloadService(db: db);
    await db.upsertDownload(
      DownloadsCompanion.insert(
        movieSlug: 'movie-x',
        movieName: 'Movie X',
        episodeName: 'Tập 1',
        episodeSlug: 'tap-1',
        remoteM3u8: 'https://cdn.test/x/index.m3u8',
        createdAt: DateTime.now(),
      ),
    );
    final entry = (await db.getAllDownloads()).first;
    expect(entry.status, 'pending');

    final bloc = LibraryBloc(db: db, downloadService: svc);
    addTearDown(bloc.close);
    bloc.add(LibraryEvent.deleteDownload(entry));
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(await db.getAllDownloads(), isEmpty);
  });
}
