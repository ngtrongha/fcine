import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/movie.dart';

/// Chế độ an toàn: ẩn phim 18+ khỏi Home/Search (lọc client-side).
/// Lưu setting qua SharedPreferences.
class SafeModeService {
  static const _kKey = 'safe_mode_enabled';

  Future<bool> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> save(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kKey, enabled);
    } catch (_) {}
  }

  /// Phim 18+ được nhận diện qua category/lang chứa "18+".
  static bool isSafe(Movie m) {
    if (m.lang != null && m.lang!.toLowerCase().contains('18+')) {
      return false;
    }
    for (final c in m.categories) {
      final n = c.name.toLowerCase();
      if (n.contains('18+') || n.contains('phim 18')) return false;
    }
    return true;
  }

  /// Lọc danh sách phim khi safe mode bật.
  static List<Movie> filter(Iterable<Movie> movies, bool enabled) {
    if (!enabled) return movies.toList();
    return movies.where(isSafe).toList();
  }
}
