// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/core/config/master_config.dart';
import 'package:fcine/data/datasources/kkphim_remote_datasource.dart';

void main() {
  test('KKPhim API - verify endpoints from docs', () async {
    // sẽ tạo Dio với baseUrl sau khi load config

    // load sample config manually (without flutter assets)
    final configJson = {
      "version": 2,
      "updatedAt": "2026-08-28T00:00:00Z",
      "sources": [
        {
          "id": "kkphim",
          "name": "KKPhim",
          "enabled": true,
          "baseUrl": "https://phimapi.com",
          "fallbackUrls": ["https://phimapi.com"],
          "cdnImage": "https://phimimg.com",
          "headers": {"accept": "application/json"},
          "endpoints": {
            "latest": {"path": "/danh-sach/phim-moi-cap-nhat?page={page}", "method": "GET"},
            "search": {"path": "/v1/api/tim-kiem?keyword={keyword}&page={page}&limit=24", "method": "GET"},
            "detail": {"path": "/phim/{slug}", "method": "GET"},
            "listByType": {"path": "/v1/api/danh-sach/{type}?page={page}", "method": "GET"}
          },
          "extractors": {},
          "pagination": {"type": "page_number", "param": "page"}
        }
      ],
      "settings": {"searchDebounceMs": 400, "requestTimeoutMs": 8000, "imageCacheMaxMb": 100, "playerHeadersRequired": false}
    };
    final config = MasterConfig.fromJson(configJson);
    final source = config.sources.first;
    final dio = Dio(BaseOptions(baseUrl: source.baseUrl, headers: {'accept': 'application/json'}));
    final ds = KkphimRemoteDataSource(dio: dio, source: source);

    // 1. Latest
    print('--- TEST LATEST ---');
    final latest = await ds.getLatest(page: 1);
    print('latest count: ${latest.movies.length}, total: ${latest.pagination.totalItems}');
    expect(latest.movies.isNotEmpty, true);
    final first = latest.movies.first;
    print('first: ${first.name} / ${first.slug} / ${first.posterUrl}');
    expect(first.slug.isNotEmpty, true);
    expect(first.posterUrl.startsWith('http'), true);

    // 2. Search
    print('--- TEST SEARCH avengers ---');
    final search = await ds.search(keyword: 'avengers', page: 1);
    print('search count: ${search.movies.length}, total: ${search.pagination.totalItems}');
    expect(search.movies.isNotEmpty, true);
    print('search first: ${search.movies.first.name}');

    // 3. Detail
    print('--- TEST DETAIL ---');
    final slug = latest.movies.first.slug;
    print('detail slug: $slug');
    final detail = await ds.getDetail(slug);
    print('detail movie: ${detail.movie.name}, servers: ${detail.servers.length}');
    for (final s in detail.servers) {
      final m3u8 = s.episodes.first.linkM3u8;
      print(' server ${s.serverName}: ${s.episodes.length} eps, first m3u8=${m3u8.length>60 ? m3u8.substring(0,60) : m3u8}...');
    }
    expect(detail.servers.isNotEmpty, true);
    expect(detail.servers.first.episodes.first.linkM3u8.contains('m3u8'), true);

    // 4. List by type
    print('--- TEST LIST BY TYPE phim-le ---');
    final list = await ds.getListByType('phim-le', page: 1);
    print('phim-le count: ${list.movies.length}');
    expect(list.movies.isNotEmpty, true);
  });
}
