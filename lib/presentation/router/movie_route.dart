/// Đường dẫn trang chi tiết phim, luôn kèm nguồn đang hiển thị để
/// trang chi tiết ưu tiên đúng nguồn (tránh lệch slug API <-> WEB).
/// Slug được encode để chứa được cả URL tuyệt đối (nguồn sitemap).
/// VD: movieDetailPath('tvshows~abc', 'web-motchilltvzip')
String movieDetailPath(String slug, [String? sourceId]) {
  final enc = Uri.encodeComponent(slug);
  if (sourceId == null || sourceId.isEmpty) return '/movie/$enc';
  return '/movie/$enc?source=${Uri.encodeQueryComponent(sourceId)}';
}
