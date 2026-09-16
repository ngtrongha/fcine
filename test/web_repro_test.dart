import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/core/config/source_templates.dart';
import 'package:fcine/data/datasources/web_scraper_datasource.dart';

/// Repro với HTML ARCHIVE THẬT (tvshows/page/1/) lưu làm fixture.
/// Giữ test này để khóa preset DooPlay khớp markup thật.
void main() {
  test('parse archive that motchilltv', () async {
    final file = File('test/fixtures/tvshows_page1.html');
    final html = await file.readAsString();
    final src = SourceTemplates.webDooplay(
      baseUrl: 'https://motchilltv.zip',
      name: 'MotChill',
    );
    final dio = Dio(BaseOptions(baseUrl: src.baseUrl, headers: src.headers));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: html),
          );
        },
      ),
    );
    final ds = WebScraperDataSource(dio: dio, source: src);
    final res = await ds.getListByType('phim-bo', page: 1);
    // ignore: avoid_print
    print('MOVIES: ${res.movies.length} PAGES: ${res.pagination.totalPages}');
    for (final m in res.movies.take(3)) {
      // ignore: avoid_print
      print(' - ${m.slug} | ${m.name} | ${m.posterUrl} | ${m.year}');
    }
    expect(res.movies.isNotEmpty, isTrue);
    // Fixture ghi "Page 1 of 7" -> parser phải ra đủ 7 trang.
    expect(res.pagination.totalPages, 7);
  });
}
