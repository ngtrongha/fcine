# Hoàn thiện tính năng "viết sẵn nhưng không dùng được" (Gói #1–#4)

> Cập nhật 17/09/2026. ✅ HOÀN THÀNH TOÀN BỘ 8 TASK — `dart analyze` 0 issue,
> `flutter test` 58/58 pass (gồm test live KKPhim).
> Đã triển khai: nút Tải xuống + bottom-sheet, menu Thử lại/Xoá, storage meter thật,
> OfflineBanner, nút Trailer, fix nút chết, xoá dead code, 7 test mới.

## Vòng 2 — P2 (✅ hoàn thành 17/09/2026, 63/63 pass)

* Cancel download (CancelToken registry + status 'cancelled' + menu Huỷ, xoá file dở dang)
* QuickSearchField nhấn Enter → `/search?q=` (server search đầy đủ)
* Dual-pane Detail desktop (tóm tắt + metadata side panel phải 360px)

## Vòng 3 — Quick win + P3 khả thi (✅ hoàn thành 17/09/2026, 67/67 pass)

* **Real brightness**: `screen_brightness` package — slider/swipe áp độ sáng thật lên màn hình, reset khi đóng player
* **Swipe gesture player** (quick win trong kế hoạch gốc): swipe dọc kiểu YouTube — nửa trái = độ sáng, nửa phải = âm lượng, overlay hiển thị mức khi kéo; swipe ngang tua ±10s đã có sẵn
* **Phụ đề ngoài online player**: "Tải phụ đề từ tệp..." (.srt/.ass/.vtt) qua file_picker, hiển thị tên phụ đề trong settings sheet, tự clear khi đổi tập
* **Safe mode ẩn 18+** (Kids Mode lite): toggle trong Cài Đặt → lọc phim 18+ (theo category/lang "18+") khỏi Home (banner + grid) và Search; fail-soft khi thiếu DI

**Còn lại trong Phase 2+ (cần backend/SDK, chưa làm):**
* Chromecast / AirPlay — cần Cast SDK (placeholder dialog giữ nguyên)
* Download → mp4 remux — cần ffmpeg
* Push tập mới — cần backend cron check `latest`
* Đồng bộ Cloud — đã skip theo yêu cầu

## Mục tiêu

Hoàn thiện Tải xuống end-to-end, gắn OfflineBanner, thêm nút Trailer, sửa các nút chết, dọn dead code.

## Tasks

### Gói A — Download end-to-end (ưu tiên cao)

- [x] **Task 1: Nút "Tải xuống" trên Detail page** — thêm nút (cạnh "Lưu phim", `detail_page.dart:751`) mở bottom-sheet chọn tập + server (chỉ liệt kê tập có `linkM3u8` trực tiếp; tập web resolve được mới cho tải) → gọi `DownloadService.startDownload` (7 field: `_movie.slug/name/posterUrl` + tập + server + m3u8) → Verify: bấm tải → tab "Đã Tải" hiện entry `downloading`, progress tăng theo từng segment
- [x] **Task 2: Menu more_vert trong downloads_tab** — `downloads_tab.dart:29` thay Icon tĩnh bằng `PopupMenuButton`: "Thử lại" (entry `failed` → `startDownload` lại từ `remoteM3u8` đã lưu trong DB), "Xoá" (dispatch `LibraryDeleteDownload` — bloc đã xử lý sẵn tại `library_bloc.dart:63`) → Verify: xoá 1 bản → biến khỏi list; retry entry failed → progress chạy lại
- [x] **Task 3: Storage meter thật** — thêm `DownloadService.totalSizeOnDisk()` (đo recursive thư mục `downloads/`), `storage_meter.dart:10` bỏ công thức fake `count × 0.4GB` / 128GB cứng, dùng FutureBuilder hiển thị GB thực; nút "Quản lý" (`storage_meter.dart:38`) → dispatch `LibraryEvent.tabChanged(2)` → Verify: GB hiển thị = dung lượng thực tế; nút Quản lý nhảy sang tab Đã Tải

### Gói B — OfflineBanner + Trailer + nút chết

- [x] **Task 4: Gắn OfflineBanner** — thêm vào `responsive_scaffold.dart` (đầu Column của body, cả nhánh mobile lẫn desktop) → Verify: bật máy bay khởi động app → banner vàng "Đang dùng dữ liệu ngoại tuyến (cache)" hiện; nút Thử lại hoạt động; có mạng → ẩn
- [x] **Task 5: Nút Trailer trên Detail** — chỉ hiện khi `_movie.trailerUrl != null`, đặt cạnh row action buttons → `url_launcher` mở external (trailer KKPhim thường là YouTube, KHÔNG dùng media_kit) → Verify: mở phim có trailer → bấm nút → mở được
- [x] **Task 6: Sửa nút chết** — `home_page.dart:325` "Xem tất cả" → `context.push('/library')` (giống `continue_watching_section.dart:46`); `mobile_search_sliver.dart:83` sort pill "Điểm Cao Nhất" → thêm `SearchEvent.sortChanged` truyền `sort_field`/`sort_type` xuống KKPhim datasource; nếu API search không hỗ trợ sort thì xoá pill → Verify: bấm "Xem tất cả" → sang Tủ Phim; bấm sort → kết quả sắp xếp lại (hoặc pill biến mất)

### Gói C — Dọn dẹp + Test

- [x] **Task 7: Xoá dead code** — `lib/presentation/blocs/player/`, `blocs/detail/`, `blocs/replay/` (PlayerBloc, DetailBloc, AppReplayBloc: không đăng ký trong `injection.dart`, không page nào dùng; UI đã dùng state trực tiếp ổn định) + `detail_app_bar.dart` + file `.freezed.dart` tương ứng → Verify: `dart analyze lib/` 0 error/warning, `flutter test` pass
- [x] **Task 8: Bổ sung test** — unit test `DownloadService` (parse m3u8 → rewrite playlist → progress, fake Dio), widget test `downloads_tab` (menu Xoá/Thử lại dispatch đúng event) → Verify: `flutter test` pass

## Done When

- [x] Tải được 1 tập từ Detail → thấy progress → xem lại offline → xoá được khỏi Tủ Phim
- [x] Offline banner hiện khi app dùng cache config
- [x] Không còn nút nào `onPressed: () {}` trong luồng chính
- [x] `dart analyze lib/` sạch + `flutter test` pass

## Notes

- **Không sửa LibraryBloc**: `_onDeleteDownload` đã xử lý xoá (`library_bloc.dart:63`) — chỉ wire UI. Tab sync qua `tabChanged` đã hoạt động 2 chiều (`library_page.dart:47`)
- **Không sửa DownloadService core logic**: parse/rewrite/progress đã đúng; chỉ thêm `totalSizeOnDisk()` + retry entry failed (dùng lại `startDownload` với field từ DB)
- **Trailer**: `trailer_url` đã parse sẵn vào `Movie.trailerUrl` (`domain/entities/movie.dart:19`) — chỉ thêm UI + url_launcher
- **Thứ tự gợi ý**: A → B → C; Task 1-3 song song được với Task 4-6
- **Tuỳ chọn P2 (ĐÃ HOÀN THÀNH 17/09/2026):**
- [x] Cancel download: CancelToken registry + status 'cancelled' + menu Huỷ cho entry đang tải, xoá file dở dang; entry mất token (app restart) → huỷ trực tiếp. +2 test
- [x] QuickSearchField (Home): nhấn Enter → `/search?q=` — tìm kiếm server đầy đủ thay vì chỉ lọc client-side; SearchPage nhận initialKeyword
- [x] Dual-pane Detail desktop: nội dung chính cột trái, tóm tắt + metadata (Quốc gia/Đạo diễn/Diễn viên) side panel phải 360px cuộn riêng
