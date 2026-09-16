import 'package:fcine/core/local_media/local_media_scanner.dart';
import 'package:fcine/core/local_media/local_video.dart';
import 'package:fcine/ui/features/player/logic/playlist_media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalVideo', () {
    test('formattedSize hiển thị đúng đơn vị', () {
      LocalVideo v(int bytes) => LocalVideo(
            path: '/tmp/a.mp4',
            name: 'a.mp4',
            extension: 'mp4',
            sizeBytes: bytes,
            modified: DateTime(2026, 1, 1),
          );
      expect(v(500).formattedSize, '500 B');
      expect(v(2048).formattedSize, '2.0 KB');
      expect(v(5 * 1024 * 1024).formattedSize, '5.0 MB');
    });
  });

  group('LocalMediaScanner', () {
    test('nhận diện đủ đuôi video/audio phổ biến', () {
      for (final ext in ['mp4', 'mkv', 'avi', 'mov', 'webm', 'ts', 'flv', 'mp3', 'flac']) {
        expect(LocalMediaScanner.videoExtensions, contains(ext));
      }
      expect(LocalMediaScanner.videoExtensions, isNot(contains('exe')));
      expect(LocalMediaScanner.videoExtensions, isNot(contains('jpg')));
    });
  });

  group('Playlist merge (tự quét không trùng)', () {
    test('dedupe theo uri thường + file://', () {
      final existing = [
        const PlaylistMedia(id: '1', uri: '/storage/video/a.mp4', title: 'a.mp4'),
      ];
      final existingSet = existing.map((e) => e.uri.toLowerCase()).toSet();
      final existingPlayable =
          existing.map((e) => PlaylistMedia.toPlayable(e.uri).toLowerCase()).toSet();

      bool isDup(String path) =>
          existingSet.contains(path.toLowerCase()) ||
          existingPlayable.contains(PlaylistMedia.toPlayable(path).toLowerCase());

      expect(isDup('/storage/video/a.mp4'), isTrue);
      expect(isDup('/storage/video/b.mkv'), isFalse);
    });

    test('encode/decode playlist giữ nguyên dữ liệu', () {
      final items = [
        PlaylistMedia(id: '1', uri: '/a/b.mp4', title: 'b.mp4'),
        const PlaylistMedia(id: '2', uri: 'https://x/y.m3u8', title: 'live'),
      ];
      final restored = PlaylistMedia.decodeList(PlaylistMedia.encodeList(items));
      expect(restored.length, 2);
      expect(restored[0].uri, '/a/b.mp4');
      expect(restored[1].isNetwork, isTrue);
    });
  });
}
