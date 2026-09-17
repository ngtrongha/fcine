import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/core/database/app_database.dart';
import 'package:fcine/data/repositories/history_repository.dart';

WatchHistoryData _row({
  required int id,
  required String movieSlug,
  required String episodeName,
  required DateTime updatedAt,
}) => WatchHistoryData(
  id: id,
  movieSlug: movieSlug,
  movieName: 'Phim $movieSlug',
  posterUrl: null,
  episodeName: episodeName,
  episodeSlug: 'ep-$id',
  serverName: 'Vietsub #2',
  positionMs: 60000,
  durationMs: 2400000,
  updatedAt: updatedAt,
  sourceId: 'web-test',
);

void main() {
  test('latestPerMovie: mỗi phim 1 dòng mới nhất', () {
    final rows = [
      _row(
        id: 1,
        movieSlug: 'tvshows~u-thi-ly-hon',
        episodeName: 'Tập 04',
        updatedAt: DateTime(2026, 1, 2),
      ),
      _row(
        id: 2,
        movieSlug: 'tvshows~u-thi-ly-hon',
        episodeName: 'Tập 01',
        updatedAt: DateTime(2026, 1, 1),
      ),
      _row(
        id: 3,
        movieSlug: 'phim-khac',
        episodeName: 'Tập 02',
        updatedAt: DateTime(2026, 1, 1, 12),
      ),
    ];
    final out = HistoryRepository.latestPerMovie(rows);
    expect(out.length, 2);
    expect(out[0].episodeName, 'Tập 04');
    expect(out[1].movieSlug, 'phim-khac');
  });

  test('latestPerMovie: gộp cả slug cross-source', () {    final rows = [
      _row(
        id: 1,
        movieSlug: 'u-thi-ly-hon',
        episodeName: 'Tập 04',
        updatedAt: DateTime(2026, 1, 3),
      ),
      _row(
        id: 2,
        movieSlug: 'tvshows~u-thi-ly-hon',
        episodeName: 'Tập 01',
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];
    final out = HistoryRepository.latestPerMovie(rows);
    expect(out.length, 1);
    expect(out[0].episodeName, 'Tập 04');
  });
}
