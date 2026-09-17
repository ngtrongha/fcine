/// So khớp tên phim giữa các nguồn (tránh đổi nguồn nhảy sang phim khác).
library;

/// Chuẩn hóa tên phim: thường chữ, bỏ năm/tag/nhiễu.
String normalizeMovieName(String s) {
  var t = s.toLowerCase().trim();
  t = t.replaceAll(RegExp(r'\(\d{4}\)'), ' ');
  t = t.replaceAll(
    RegExp(
      r'\b(full|vietsub|thuyet minh|thuyết minh|lồng tiếng|long tieng|hd|fhd|4k|cam|tập\s*\d+|tap\s*\d+|t\S*p\s*\d+|phần\s*\d+|phan\s*\d+|phim\s*(bo|bộ|le|lẻ))\b',
    ),
    ' ',
  );
  t = t.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ');
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t;
}

/// true khi 2 bản ghi là cùng 1 phim (so tên + tên gốc chéo nhau + năm).
///
/// [curName]/[curOrigin]/[curYear]: phim đang xem.
/// [candName]/[candOrigin]/[candYear]: ứng viên trên nguồn mới.
bool isSameMovie({
  required String curName,
  required String curOrigin,
  required int curYear,
  required String candName,
  required String candOrigin,
  required int candYear,
}) {
  final cn = normalizeMovieName(curName);
  final co = normalizeMovieName(curOrigin);
  final bn = normalizeMovieName(candName);
  final bo = normalizeMovieName(candOrigin);
  if (bn.isEmpty) return false;

  var nameOk = false;
  if (cn.isNotEmpty && (cn == bn || co == bn)) {
    nameOk = true;
  } else if (bo.isNotEmpty && (cn == bo || (co.isNotEmpty && co == bo))) {
    nameOk = true;
  } else if (cn.isNotEmpty && cn.length >= 4 && bn.length >= 4) {
    // Chứa nhau nhưng phải tương xứng độ dài để khỏi match nhầm
    // ("Sinh" trong "Sinh Vạn Vật" là không đủ).
    final shortLen = cn.length < bn.length ? cn.length : bn.length;
    final longLen = cn.length > bn.length ? cn.length : bn.length;
    if ((cn.contains(bn) || bn.contains(cn)) && longLen / shortLen < 2) {
      nameOk = true;
    }
  }
  if (!nameOk) return false;
  // Năm lệch nhau mà đều rõ ràng -> chắc chắn khác phim.
  if (curYear > 0 && candYear > 0 && curYear != candYear) return false;
  return true;
}
