/// Đường dẫn trang chi tiết phim, luôn kèm nguồn đang hiển thị để
/// trang chi tiết ưu tiên đúng nguồn (tránh lệch slug API <-> WEB).
/// VD: movieDetailPath('tvshows~abc', 'web-motchilltvzip')
String movieDetailPath(String slug, [String? sourceId]) {
  if (sourceId == null || sourceId.isEmpty) return '/movie/$slug';
  return '/movie/$slug?source=${Uri.encodeQueryComponent(sourceId)}';
}
