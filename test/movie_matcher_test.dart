import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/core/match/movie_matcher.dart';

void main() {
  group('normalizeMovieName', () {
    test('bỏ tag, năm, dấu câu', () {
      expect(
        normalizeMovieName('Ngự Đình Dao (2026) Full Vietsub'),
        'ngự đình dao',
      );
      expect(normalizeMovieName('OK! Let’s Get Divorced'), 'ok let s get divorced');
      expect(normalizeMovieName('  Sinh   Vạn   Vật  '), 'sinh vạn vật');
    });
  });

  group('isSameMovie (chống nhảy sang phim khác khi đổi nguồn)', () {
    test('khớp tên chuẩn', () {
      expect(
        isSameMovie(
          curName: 'Sinh Vạn Vật',
          curOrigin: '',
          curYear: 2025,
          candName: 'Sinh Vạn Vật',
          candOrigin: '',
          candYear: 2025,
        ),
        isTrue,
      );
    });

    test('khớp tên gốc chéo (Việt <-> Anh)', () {
      expect(
        isSameMovie(
          curName: 'Ủ Thì Ly Hôn!',
          curOrigin: "OK! Let's Get Divorced",
          curYear: 2026,
          candName: "OK! Let's Get Divorced",
          candOrigin: '',
          candYear: 2026,
        ),
        isTrue,
      );
    });

    test('KHÔNG khớp 2 phim khác nhau', () {
      expect(
        isSameMovie(
          curName: 'Sinh Vạn Vật',
          curOrigin: '',
          curYear: 2025,
          candName: 'Ủ Thì Ly Hôn!',
          candOrigin: "OK! Let's Get Divorced",
          candYear: 2026,
        ),
        isFalse,
      );
    });

    test('KHÔNG khớp khi tên chứa nhau nhưng quá lệch độ dài', () {
      expect(
        isSameMovie(
          curName: 'Sinh',
          curOrigin: '',
          curYear: 0,
          candName: 'Sinh Vạn Vật Ký Sự Dài Tập',
          candOrigin: '',
          candYear: 0,
        ),
        isFalse,
      );
    });

    test('KHÔNG khớp khi năm lệch (cùng tên khác năm = khác phim)', () {
      expect(
        isSameMovie(
          curName: 'Già Thiên',
          curOrigin: '',
          curYear: 2024,
          candName: 'Già Thiên',
          candOrigin: '',
          candYear: 2026,
        ),
        isFalse,
      );
    });

    test('bỏ qua năm khi 1 bên thiếu', () {
      expect(
        isSameMovie(
          curName: 'Già Thiên',
          curOrigin: '',
          curYear: 0,
          candName: 'Già Thiên',
          candOrigin: '',
          candYear: 2026,
        ),
        isTrue,
      );
    });

    test('ứng viên tên rỗng -> không khớp', () {
      expect(
        isSameMovie(
          curName: 'Sinh Vạn Vật',
          curOrigin: '',
          curYear: 2025,
          candName: '',
          candOrigin: '',
          candYear: 0,
        ),
        isFalse,
      );
    });
  });
}
