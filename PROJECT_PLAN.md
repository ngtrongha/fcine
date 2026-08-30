# 🎬 F-CINE - KẾ HOẠCH & Ý TƯỞNG PHÁT TRIỂN (BẢN HOÀN CHỈNH v3.0 - HOÀN THÀNH MVP)

> Cập nhật 28/08/2026 v3.0 - Hoàn thành MVP 20 ngày, verified với KKPhim (phimapi.com). Bỏ qua build/run và Đồng bộ Cloud theo yêu cầu.
> Trạng thái: ✅ Giai đoạn 1-4 hoàn thành, ✅ test KKPhim pass, ⏭️ Giai đoạn 5 Cloud Sync đã skip, ⏭️ Build/Run đã skip

---

## 1. Ý TƯỞNG CỐT LÕI (CORE CONCEPT)

*   **Shell App + Remote Master Config:** App không hard-code nguồn. Toàn bộ `baseUrl`, `endpoints`, `JSONPath extractors`, `headers`, `fallback domains` nằm trong 1 file JSON đặt trên GitHub Gist / Cloudflare R2 / Hosting. App tải khi khởi động, cache vào SQLite/Storage.
*   **Zero-UI:** Người dùng chỉ thấy giao diện xem phim hiện đại (Dark Theme), không thấy cài đặt nguồn phức tạp.
*   **Tự phục hồi:** Đổi domain chống chặn, đổi field JSON → chỉ sửa file config trên server, toàn bộ client tự cập nhật, không cần release bản mới.
*   **Chuẩn hóa dữ liệu:** Mọi API thô được `Core Engine` map về 2 model duy nhất: `Movie` và `Episode` để UI không phụ thuộc nguồn.

---

## 2. KIẾN TRÚC & LUỒNG DỮ LIỆU

```
[GitHub Gist / Cloudflare R2]  ──(1. GET Master Config)──▶
┌──────────────────────────────────────────────────────────┐
│ F-Cine Core Engine (Flutter)                             │
│  • ConfigService: tải, validate, cache, fallback         │
│  • ApiService: Dio + interceptor gắn Header động         │
│  • ExtractorService: JSONPath / Regex bóc tách JSON      │
│  • Normalizer: map → Movie / Episode / Server            │
│  • Aggregator: gộp, dedup, sort theo updatedAt          │
└───────────────────────────┬──────────────────────────────┘
                            │ (2. Stream<List<Movie>>)
┌───────────────────────────▼──────────────────────────────┐
│ Presentation (Riverpod + GoRouter)                       │
│  • Home: Aggregated Feed + Banner                        │
│  • Search: Debounce 400ms + parallel fetch all sources   │
│  • Detail: Info + Server Tabs + Episode Grid             │
│  • Player: HLS (m3u8) + Header injection                 │
└───────────────────────────┬──────────────────────────────┘
                            │ (3. Persist)
┌───────────────────────────▼──────────────────────────────┐
│ Local Storage                                            │
│  • Drift (SQLite): watch_history, bookmarks, master_config_cache │
│  • SharedPreferences: settings (aspect ratio, auto-play) │
│  • CachedNetworkImage: poster cache 100MB, 7 ngày        │
└──────────────────────────────────────────────────────────┘
```

### 2.1. Nguyên tắc thiết kế
*   Offline-first: Nếu không tải được config mới → dùng bản cache, báo banner "Đang dùng dữ liệu ngoại tuyến".
*   Fail-soft: Một nguồn lỗi không làm sập toàn bộ Home/Search (dùng `Future.wait` với `eagerError:false`, timeout 8s/nguồn).
*   Header động: `Referer`, `User-Agent`, `Origin` được khai báo trong config, Player tự gắn khi request `.m3u8` và segment `.ts`.

---

## 3. TECH STACK (Flutter 3.13+)

| Layer | Thư viện đề xuất | Lý do |
| :--- | :--- | :--- |
| State Management | `flutter_riverpod` | Nhẹ, test tốt, hỗ trợ async provider cho aggregator |
| Routing | `go_router` | Deep link `/movie/:id/:episode` cho Resume playback |
| Network | `dio` | Interceptor, cancel token cho search song song |
| JSONPath | `json_path` | Đọc quy tắc `$.data.items[*].title` từ config |
| DB | `drift` (sqlite) | Type-safe, migration tốt hơn sqflite thuần |
| Cache ảnh | `cached_network_image` | Giới hạn cache, placeholder |
| Player | `media_kit` + `media_kit_video` hoặc `better_player_plus` | HLS native, hỗ trợ header, PIP; fallback `video_player` |
| Lưu setting | `shared_preferences` | Nhẹ |
| Env/Config | `flutter_dotenv` (chỉ chứa URL Gist, không chứa key nhạy cảm) | |

---

## 4. CẤU TRÚC THƯ MỤC DỰ KIẾN

```
lib/
├── core/
│   ├── config/        # models MasterConfig, SourceConfig, ExtractorRule
│   ├── network/       # dio_client, interceptors
│   ├── extractor/     # jsonpath_extractor, normalizer
│   ├── error/         # failures, exceptions
│   └── constants/
├── data/
│   ├── datasources/   # remote (api), local (drift, prefs)
│   ├── repositories/  # movie_repository_impl
│   └── models/        # movie_model, episode_model
├── domain/
│   ├── entities/      # Movie, Episode, Server (pure dart)
│   ├── repositories/  # abstract
│   └── usecases/      # get_home_feed, search_movies, get_movie_detail
├── presentation/
│   ├── providers/     # riverpod providers
│   ├── router/        # go_router
│   ├── pages/         # home, search, detail, player, bookmarks, history
│   ├── widgets/       # movie_card, banner, episode_grid, player_controls
│   └── theme/         # dark_theme, text_styles
└── main.dart
assets/
config/
  └── master_config.sample.json  # mẫu để dev/test
```

---

## 5. THIẾT KẾ MASTER CONFIG & API KKPHIM (ĐÃ VERIFY 28/08/2026)

> Base URL thực tế: `https://phimapi.com` (docs gốc https://kkphim2.com/api-document)
> Đã test live 28/08/2026 với 3 endpoint: latest / search / detail đều trả về 200

### 5.1. Endpoints KKPhim đã verify

| Chức năng | Endpoint | Params | Response chính |
|-----------|----------|--------|----------------|
| **Phim mới cập nhật** | `GET /danh-sach/phim-moi-cap-nhat` | `page` | `{status, items:[{_id,name,slug,origin_name,poster_url,thumb_url,year,modified.time}], pagination:{totalItems,totalItemsPerPage,currentPage,totalPages}}` |
| **Tìm kiếm (v1)** | `GET /v1/api/tim-kiem` | `keyword, page, limit (10-64)` | `{status:"success", data:{items:[], params:{pagination}, seoOnPage, breadCrumb}}` |
| **Chi tiết phim** | `GET /phim/{slug}` | `slug` | `{status, movie:{name,origin_name,content,thumb_url,poster_url,year,category[],country[],actor[],director[],trailer_url,...}, episodes:[{server_name,server_data:[{name,slug,link_m3u8,link_embed}]}]}` |
| **Danh sách theo loại (v1)** | `GET /v1/api/danh-sach/{type}` | `type=phim-le|phim-bo|hoat-hinh|tv-shows`, `page, category, country, year, sort_field, sort_type` | `{data:{items:[], params:{pagination}}}` |
| **Danh sách (v1) chung** | `GET /v1/api/danh-sach` | `page, limit, category, country, year` | như trên |
| **Home (v1)** | `GET /v1/api/home` | `page` | `{status, items:[], pagination}` |

**Lưu ý ảnh:** `poster_url`/`thumb_url` đôi khi là filename tương đối (vd `c34d0de9...jpg`) → cần prepend `https://phimimg.com/` hoặc `https://phimimg.com/uploads/movies/`. Khi đã là `https://...` thì dùng nguyên. CDN domain lấy từ `APP_DOMAIN_CDN_IMAGE`.

### 5.2. Master Config mẫu (áp dụng ngay cho KKPhim)

```
master_config: {
  version: 2,
  updatedAt: "2026-08-28T00:00:00Z",
  sources: [
    {
      id: "kkphim",
      name: "KKPhim",
      enabled: true,
      baseUrl: "https://phimapi.com",
      fallbackUrls: ["https://phimapi.com"],
      cdnImage: "https://phimimg.com",
      headers: { "accept": "application/json" },
      endpoints: {
        latest:       { path: "/danh-sach/phim-moi-cap-nhat?page={page}", method: "GET" },
        latestV1:     { path: "/v1/api/danh-sach?page={page}", method: "GET" },
        search:       { path: "/v1/api/tim-kiem?keyword={keyword}&page={page}&limit=24", method: "GET" },
        detail:       { path: "/phim/{slug}", method: "GET" },
        listByType:   { path: "/v1/api/danh-sach/{type}?page={page}", method: "GET" }
      },
      extractors: {
        latest: { list: "$.items", id: "$.slug", title: "$.name", poster: "$.poster_url", year: "$.year" },
        search: { list: "$.data.items", pagination: "$.data.params.pagination" },
        detail: { title: "$.movie.name", plot: "$.movie.content", episodes: "$.episodes[*].server_data[*]" },
        stream: { m3u8: "$.episodes[0].server_data[0].link_m3u8", embed: "$.episodes[0].server_data[0].link_embed" }
      },
      pagination: { type: "page_number", param: "page" }
    }
  ],
  settings: {
    searchDebounceMs: 400,
    requestTimeoutMs: 8000,
    imageCacheMaxMb: 100,
    playerHeadersRequired: false
  }
}
```

*   **Giai đoạn đầu:** Implement `KKPhimDataSource` map cứng theo JSON trên (không cần JSONPath runtime), nhưng vẫn giữ field `extractors` trong config để sau này thêm nguồn khác chỉ cần JSONPath mà không sửa code.
*   **Versioning:** App kiểm tra `version` tăng → invalidate cache, tải lại.
*   **Ưu tiên MVP:** Dùng 3 endpoint chính `latest` + `search` + `detail`. `listByType` để làm Home tabs Phim Lẻ/Phim Bộ/Hoạt Hình.

---

## 6. PHÂN TÍCH TÍNH NĂNG

### 6.1. Phase 1 - Bắt buộc (MVP)
| # | Tính năng | Mô tả chi tiết |
|---|-----------|----------------|
| 1 | **Aggregated Feed** | Gộp phim mới từ N nguồn, dedup theo `slug + year`, sort `modifiedTime` DESC, banner 5 phim `hot` |
| 2 | **Global Search** | Debounce 400ms, `Future.wait` song song, cancel token khi gõ tiếp, gộp + gắn nhãn nguồn |
| 3 | **Chi tiết & Tập phim** | Poster, tên gốc, plot, năm, thể loại, Server tabs, Grid tập (1..N), highlight tập đang xem |
| 4 | **Player HLS** | `media_kit` phát m3u8, tự gắn header từ config, auto-play next, seek 10s/30s, fullscreen, Wakelock |
| 5 | **Resume Playback** | Lưu `movieId, episodeId, positionMs, durationMs, updatedAt` mỗi 5s, row "Tiếp tục xem" trên Home |
| 6 | **Bookmarks** | Thêm/xóa yêu thích, màn hình riêng, sync local only |
| 7 | **Offline Fallback** | Cache config + cache ảnh, banner khi offline |

### 6.2. Phase 2+ (Đã chốt hoãn)
| Tính năng | Ghi chú | Ưu tiên |
|-----------|---------|---------|
| **Đồng bộ Cloud** | Firebase/Supabase Auth + Firestore cho history/bookmarks đa thiết bị. Hoãn vì cần backend, auth, conflict resolution | P1 - Phase 5 |
| Download Offline (m3u8 → mp4) | Segment merging, quản lý dung lượng, DRM | P1 |
| Chromecast / AirPlay | Cast SDK | P2 |
| Thuyết minh / Vietsub / Sub selector | Parse `lang` từ extractor | P2 |
| Quality selector (Auto/1080/720) | Nếu nguồn cung cấp nhiều link | P2 |
| Kids Mode / PIN | Lọc `category` 18+ | P3 |
| Push tập mới | Cần backend cron check `latest` | P3 |
| Swipe gesture player | Sáng/âm lượng, tua | Quick win - làm luôn trong Phase 3 nếu kịp |

---

## 7. KẾ HOẠCH TRIỂN KHAI CHI TIẾT (20 NGÀY CÔNG)

```
Giai đoạn 1: Nền tảng & Lõi trích xuất    [█████] ✅ (Ngày 01 - 05) - ConfigService, KKPhim datasource, test live
Giai đoạn 2: Xây dựng Giao diện           [█████] ✅ (Ngày 06 - 10) - Home banner+tabs+infinite, Search debounce, Detail
Giai đoạn 3: Trình phát Video             [█████] ✅ (Ngày 11 - 15) - media_kit, controls, auto-next, lỗi đổi server
Giai đoạn 4: Bộ nhớ cục bộ & Đóng gói     [█████] ✅ (Ngày 16 - 20) - Drift history/bookmarks/cache, OfflineBanner, FImageCache 100MB (build/run skip)
Giai đoạn 5: Mở rộng (Cloud Sync)         [     ] ⏭️ SKIP theo yêu cầu
```

### 🔹 Giai đoạn 1: Nền tảng & Lõi (Ngày 01-05)
*   **Ngày 01:** `flutter create`, setup `analysis_options`, theme tối, Riverpod, GoRouter, Drift. Định nghĩa entities `Movie`, `Episode`, `Server`, `SourceConfig`. Viết `master_config.sample.json`.
*   **Ngày 02:** `ConfigService`: tải Gist, validate `version`, cache Drift, fallback khi offline. Thêm màn hình splash + retry.
*   **Ngày 03-04:** `ExtractorService` + `Normalizer`: parse JSONPath cho `latest/search/detail/stream`. Viết `MovieRepository` gọi Dio qua config. Unit test với 2 nguồn thật (VD OPhim + KKPhim).
*   **Ngày 05:** Kiểm thử aggregator: gộp 2 nguồn, dedup, search song song, log lỗi từng nguồn không crash app. Tiêu chí: Home load <2s với 2 nguồn.

### 🔹 Giai đoạn 2: Giao diện (Ngày 06-10)
*   **Ngày 06:** GoRouter `/`, `/search`, `/movie/:slug`, `/player`. Dark theme, BottomNav, AppBar tìm kiếm.
*   **Ngày 07:** Home: Banner `PageView` auto-scroll 5s, horizontal list "Mới cập nhật", "Phim lẻ", "Phim bộ", pull-to-refresh, CachedNetworkImage (100MB).
*   **Ngày 08:** Search: TextField debounce 400ms, CancelToken, shimmer, empty state, gắn chip nguồn + chất lượng.
*   **Ngày 09-10:** Detail: SliverAppBar poster, info, Server Tabs, Episode Grid (LazyGrid), nút "Xem tiếp" nếu có history. Xử lý server `VIP`/`Thường`.

### 🔹 Giai đoạn 3: Trình phát (Ngày 11-15)
*   **Ngày 11-12:** Tích hợp `media_kit`, truyền `headers` từ config vào `Media` source, test m3u8 có Referer. Fullscreen, Wakelock, ẩn controls sau 3s.
*   **Ngày 13-14:** Controls tùy biến: tua ±10s/±30s, speed 0.5x-2x, aspect Fill/Fit/16:9, khóa xoay, auto-next tập, PiP (nếu hỗ trợ).
*   **Ngày 15:** Xử lý lỗi: link hỏng → banner + nút "Đổi server", mất mạng → retry, timeout → fallback domain từ config.

### 🔹 Giai đoạn 4: Lưu trữ & Đóng gói (Ngày 16-20)
*   **Ngày 16-17:** Drift tables: `watch_history(id, movieSlug, episodeId, position, duration, updatedAt)`, `bookmarks(movieSlug, addedAt)`, `config_cache(json, version)`. Repository + Provider.
*   **Ngày 18:** Nối History ↔ Player: lưu mỗi 5s + khi pause/exit, row "Tiếp tục xem" trên Home, progress bar trên MovieCard. Deep link `/player/:slug/:ep` khôi phục position.
*   **Ngày 19:** Kiểm thử toàn diện: leak memory (player dispose), jank khi scroll (profile mode), offline, đổi domain. Tối ưu `ListView.builder`, `const` widgets.
*   **Ngày 20:** Dọn assets, obfuscate, `flutter build apk --release --split-per-abi`, `flutter build ipa`, viết README hướng dẫn đổi Gist URL.

### 🔹 Giai đoạn 5: Mở rộng (Sau MVP - hoãn Đồng bộ Cloud)
*   Auth (Google/Apple) + Firestore/Supabase: tables `users/{uid}/history`, `bookmarks`. Logic merge: last-write-wins theo `updatedAt`.
*   Download offline, Cast, Push notification.

---

## 8. TIÊU CHÍ NGHIỆM THU (Definition of Done)

*   Home hiển thị <2s với 2 nguồn, search trả về trong 3s (timeout 8s/nguồn).
*   Player phát được m3u8 có header, nhớ vị trí chính xác ±2s.
*   Tắt mạng → app vẫn mở được bằng cache config + hiện banner.
*   Không crash khi 1 nguồn đổi JSON hoặc domain chết.

---

## 9. QUẢN TRỊ RỦI RO

| Rủi ro | Giải pháp |
| :--- | :--- |
| Nguồn đổi cấu trúc JSON | Sửa JSONPath trong Gist, app tự tải, không cần update store |
| Domain bị chặn | `fallbackUrls` trong config, Dio retry tuần tự |
| Hotlink 403 | Khai báo `headers` trong config, player tự gắn |
| Chậm do nhiều ảnh | `cached_network_image` max 100MB + `ListView.builder` + `RepaintBoundary` |
| Search spam API | Debounce 400ms + CancelToken + timeout 8s |
| Player leak | Dispose `Player` trong `dispose()`, test profile |

---

## 10. TRẠNG THÁI HOÀN THÀNH & NEXT STEPS

**Đã hoàn thành (verified 28/08/2026):**
*   `assets/config/master_config.sample.json:1` - KKPhim verified (latest/search/detail/listByType)
*   `lib/core/config/config_service.dart:1` - offline fallback remote→Drift→assets, `lib/presentation/widgets/offline_banner.dart:1`
*   `lib/core/cache/image_cache_manager.dart:1` - FImageCache 300 objects/7 ngày (~100MB)
*   `lib/presentation/pages/player_page.dart:1` - xử lý lỗi m3u8 rỗng/timeout/error với nút Thử lại/Đổi server
*   `dart analyze` 0 error, `flutter test test/kkphim_api_test.dart:1` pass
*   `DESIGN.md:1` - Quy chuẩn thiết kế Cinematic Dark tokens & Material 3 theme đồng bộ

**Đã skip theo yêu cầu:**
*   `flutter run` / `flutter build apk/ipa` (Ngày 19-20)
*   Đồng bộ Cloud Firebase/Supabase (Phase 5)

---

## 11. KẾ HOẠCH BỔ SUNG: GIAO DIỆN DESKTOP & RESPONSIVE (STITCH MCP)

> **Cập nhật 30/08/2026:** Bổ sung trọn bộ thiết kế Desktop (2560x1440 / 1920x1080) vào Stitch Project `projects/2616384555894592776`.

### 11.1. Danh mục màn hình Desktop đã thiết kế trên Stitch MCP

| # | Màn hình | Screen ID (Stitch MCP) | Độ phân giải | Điểm nổi bật kiến trúc Desktop |
|---|----------|------------------------|--------------|--------------------------------|
| 1 | **Desktop Home** | `e984d2c8434146189ea62c263708770d` | 2560 x 2388 | Sidebar cố định 240px, Hero Banner siêu rộng, Lưới phim 6 cột, Row Tiếp tục xem với % progress |
| 2 | **Desktop Movie Detail** | `17d4f76a579e46bfb6b2e5a46cd12769` | 2560 x 3070 | Dual-pane 2 cột: Cột trái phát Trailer/Backdrop + Server tabs + Lưới tập 8 cột; Cột phải thông tin Metadata, Đạo diễn, Diễn viên & Gợi ý |
| 3 | **Desktop Explore & Search** | `08b6d9a3c8784f1b98d82d6ca6695b20` | 2560 x 2634 | Sidebar bộ lọc cố định bên trái (Thể loại, Quốc gia, Năm, Sắp xếp), Ô tìm kiếm tức thì ở trên, Lưới kết quả 5 cột |
| 4 | **Desktop Theater Player** | `2f096a72b7ba4ca9959da32e877d3a46` | 2560 x 2048 | Chế độ rạp chiếu (Theater Mode), Sidebar danh sách tập phim dạng playlist bên phải, phím tắt điều khiển (Space, ←/→, F, M) |
| 5 | **Desktop Library & History** | `1397c9abea4847459ce1b203333abb40` | 2560 x 2546 | Quản lý đa mục (Lịch sử xem, Yêu thích, Đã tải) dạng thẻ Grid 4 cột, nút xóa hàng loạt, đồng hồ đo dung lượng ổ đĩa |
| 6 | **Desktop Settings & Config** | `ea3c0b5c1cf74bba8011348c35716985` | 2560 x 2048 | Dashboard 2 cột: Danh mục cài đặt bên trái, Panel cấu hình Master Config (Latency live 45ms, Test ping nguồn, Quản lý cache) bên phải |

### 11.2. Kiến trúc thích ứng (Responsive UI Framework)
*   **Breakpoints chuẩn:**
    *   `Mobile`: `< 720px` → Dùng Bottom Navigation Bar, lưới 2-3 cột, giao diện kéo trượt 1 cột.
    *   `Tablet`: `720px - 1023px` → Dùng `NavigationRail` thu gọn (icon only), lưới 3-4 cột.
    *   `Desktop`: `>= 1024px` → Dùng Sidebar 240px đầy đủ nhãn, lưới 5-6 cột, Dual-pane Layout.
*   **Điều khiển chuột & Bàn phím:**
    *   Hiệu ứng Hover phát sáng (Card scale + subtle crimson glow).
    *   Shortcuts: `Space` (Play/Pause), `ArrowLeft/Right` (Seek ±10s), `ArrowUp/Down` (Âm lượng), `F` (Fullscreen), `M` (Mute), `/` (Focus Search Bar).
*   **Giai đoạn thực thi tiếp theo:**
    1.  Tạo widget `ResponsiveScaffold` (`lib/presentation/widgets/responsive_scaffold.dart`) tự động chuyển đổi giữa BottomNav và Sidebar.
    2.  Refactor `HomePage`, `DetailPage`, `SearchPage` sử dụng `LayoutBuilder` để áp dụng Dual-pane khi màn hình lớn.
    3.  Tích hợp các phím tắt `HardwareKeyboardListener` vào `PlayerPage`.
