import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/core/cast/cast_service.dart';

void main() {
  group('isCastableUrl', () {
    test('m3u8/mp4 http(s) -> cast được', () {
      expect(
        isCastableUrl('https://cdn.example.com/film/1080/index.m3u8'),
        isTrue,
      );
      expect(
        isCastableUrl('https://cdn.example.com/film.mp4?token=abc'),
        isTrue,
      );
    });

    test('file offline / rỗng / định dạng lạ -> không cast', () {
      expect(isCastableUrl(''), isFalse);
      expect(isCastableUrl('file:///storage/movie.mp4'), isFalse);
      expect(
        isCastableUrl('https://example.com/xem-phim-tap-1'),
        isFalse,
      );
    });
  });

  group('castContentType', () {
    test('m3u8 -> application/x-mpegURL, còn lại mp4', () {
      expect(
        castContentType('https://cdn.example.com/a.m3u8?x=1'),
        'application/x-mpegURL',
      );
      expect(
        castContentType('https://cdn.example.com/a.mp4'),
        'video/mp4',
      );
    });
  });
}
