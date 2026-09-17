# Engine nguồn phim dynamic — "bất kỳ web phim nào bỏ vào đều băm ra"

> Cập nhật 17/09/2026. Phạm vi chốt với user: heuristic tự động + AI-assisted fallback,
> TẤT CẢ tính năng (browse/search/category/playback) phải chạy với nguồn web lạ, thêm qua app UI.
> **AI là TUỲ CHỌN**: user cấu hình key thì dùng, không cấu hình thì bỏ qua lặng lẽ — luồng
> heuristic (WebProbe) phải chạy được đầy đủ mà không phụ thuộc AI.
> Không cần Rust — WebProbe đã chạy song song (Future.wait), Dart async đủ.

## Hiện trạng (đã khảo sát)

- `WebProbe` (web_probe.dart:53) — auto-dò đa ứng viên (dooplay/generic/custom paths) × preset selector
  + sitemap fallback — **ĐÃ VIẾT SẴN NHƯNG CHƯA ĐƯỢC GỌI Ở ĐÂU CẢ** (pattern "viết sẵn không dùng").
- Settings `_saveWebSource` (settings_page.dart:154) — vẫn dùng dropdown preset thủ công + probe 1 template.
- `WebScraperDataSource` — băm config-driven nhiều lớp fallback (config → generic → JSON-LD → og:meta),
  search/detail/episode/DooPlay player/m3u8-embed đã hoạt động.
- Heuristic generic còn yếu: fallback cứng `article, .post, div.item`; search URL cứng `/?s=`;
  listByType cứng `/{type}/page/{page}/`.
- Sitemap: `SitemapStore` + `SourceTemplates.webSitemap` sẵn sàng.

## Tasks

### Gói A — Wire WebProbe (ưu tiên cao, chủ yếu nối UI) ✅ HOÀN THÀNH 17/09/2026

- [x] **Task 1: `_saveWebSource` gọi `WebProbe.probe()`** — settings_page.dart:156-211 thay dựng preset + probe 1
  template bằng `WebProbe.probe(url: url, name: name, hint: _webPreset)` (WebProbe đã hỗ trợ `hint`);
  dropdown giữ lại làm "gợi ý preset" (dooplay/generic/auto) → Verify: thêm `motchilltv.zip` không cần chọn preset
  đúng trước — tự dò ra DooPlay, toast "Đã thêm web ... (N phim qua ...)" [đã có sẵn từ session trước]
- [x] **Task 2: Dialog preview trước khi lưu** — sau probe thành công hiện `_WebSourcePreviewDialog` (settings_page.dart):
  tên web, đường dò thắng (`via`), N phim mẫu (poster + tên, grid 3 cột, tối đa 12 — `WebProbeResult.movies` mới thêm),
  nút "Lưu nguồn" / "Hủy" (Hủy không lưu) → Verify: bấm thêm → thấy preview → Lưu → nguồn vào config; Hủy → không lưu
- [x] **Task 3: Unit test WebProbe** — test/web_probe_test.dart: probe dooplay trả config + ≥3 phim; sitemap fallback;
  probe rỗng → `WebProbeException` kèm `tried`; + dynamic generic tests → Verify: `flutter test test/web_probe_test.dart`
  pass (+9) [đã có sẵn từ session trước, đã verify]

### Gói B — Heuristic generic mạnh hơn (không AI)

- [ ] **Task 4: Sibling-structure detection cho `_parseCards`** — web_scraper_datasource.dart:120: khi selector config
  + fallback `article, .post, div.item` đều rỗng → tự tìm nhóm ≥3 element anh em cùng tag/class, mỗi block chứa
  `<a href>` + `<img>` → dùng nhóm đó làm cards; title từ img alt / a[title] → Verify: thêm 1 web lạ không phải DooPlay
  → list trang chủ vẫn ra phim
- [ ] **Task 5: Auto search URL** — lúc thêm nguồn, probe thử pattern search phổ biến tuần tự:
  `?s={keyword}` → `/tim-kiem?keyword={keyword}` → `/search?q={keyword}` → `?keyword={keyword}`; pattern đầu tiên
  ra ≥1 phim được lưu vào `endpoints.search` (mặc định giữ `/?s=`) → Verify: search từ khóa trên web lạ ra kết quả
- [ ] **Task 6: Auto listByType** — probe thử `/{type}/page/{page}/` → `/{type}/` → `/the-lo/{type}/page/{page}/` →
  `/genre/{type}/page/{page}/`; lưu pattern thắng vào `endpoints.listByType` → Verify: duyệt thể loại Phim Bộ trên
  web lạ ra phim

### Gói C — AI-assisted fallback

- [ ] **Task 7: Service `AiConfigGenerator`** — `lib/core/scraper/ai_config_generator.dart`: nhận HTML homepage
  (trim ~25KB đầu + 2 trang list mẫu nếu probe có), gửi tới LLM OpenAI-compatible (base URL + key tự nhập,
  mặc định gợi ý Gemini `generativelanguage.googleapis.com`), prompt trả JSON đúng schema `SourceConfig`
  (selectors + endpoints + pagination) → parse, validate schema, trả `SourceConfig` → Verify: unit test parse prompt
  response fixture → config đúng schema
- [ ] **Task 8: Settings section AI** — settings_page.dart thêm mục "AI phân tích nguồn": nhập Base URL + API key
  (obscureText), persist qua ConfigService (SharedPreferences như nguồn web) → Verify: nhập key → thoát app → mở lại
  còn key
- [ ] **Task 9: Flow probe fail → AI (optional)** — `_saveWebSource`: khi `WebProbe.probe()` ném
  `WebProbeException`: **chưa cấu hình AI → bỏ qua lặng lẽ**, chỉ toast lỗi heuristic như hiện tại
  (không chặn, không bắt buộc nhập key); **đã cấu hình AI → dialog "Thử phân tích bằng AI?"** (nút Hủy vẫn thoát
  bình thường) → loading → fetch homepage + gọi AI → preview (Task 2 dùng lại) → lưu → Verify: 1) chưa có key: thêm
  web heuristic-fail → toast lỗi, luồng thêm nguồn vẫn dùng được; 2) có key + web JS-render → AI sinh selectors →
  browse chạy được

### Gói D — Playback cho web lạ

- [ ] **Task 10: Mở rộng pattern resolveStream** — web_scraper_datasource.dart:525 thêm 2 bước vào chuỗi fallback:
  JWPlayer setup block trong inline script (`jwplayer(...).setup({file:"...m3u8"})`) và player host phổ biến
  (`/player/`, `/embed/` URL chứa .m3u8); thứ tự: config (DooPlay API / playerApi từ AI) → direct scan → JW block →
  iframe embed → Verify: xem được 1 tập từ web lạ (m3u8 trực tiếp hoặc embed)
- [ ] **Task 11: AI config cho playback** — prompt Task 7 bổ sung sinh `playerOption`/`playerApi` selectors nếu phát
  hiện được trong HTML (DooPlay/dooplayer v2, iframe pattern); resolveStream đã ưu tiên config sẵn → Verify: web
  DooPlay lạ → player AI-generated vẫn play được qua dooplayer API

### Gói E — Tự re-probe khi nguồn đổi cấu trúc (self-heal, yêu cầu của user 17/09)

- [ ] **Task 12: Re-probe khi băm fail** — service mới `SourceRefreshService` (`lib/core/config/source_refresh_service.dart`):
  nhận sourceId → gọi `WebProbe.probe(baseUrl, name, hint: 'auto')` lại (giữ nguyên `id`/`name`/`enabled` cũ) →
  `ConfigService.saveWebSource()` (đã replace-theo-id sẵn, config_service.dart:145) → trả config mới.
  Neo vào `MovieRepositoryImpl._withFallback` (movie_repository_impl.dart:38-64): khi nguồn **web** fail với lỗi
  "Không bóc được..." (config hỏng, khác lỗi network) → gọi refresh → retry request đúng 1 lần với config mới →
  toast "Nguồn {name} đã tự cập nhật cấu trúc". Inject optional vào repository (null = tắt, giữ test đơn giản) →
  Verify: sửa tay 1 selector trong config đã lưu cho sai → mở app browse → tự sửa lại + load được phim, toast hiện
- [ ] **Task 13 (P2, tuỳ chọn): Re-probe định kỳ nhẹ** — thêm field `probedAt` (ISO string) vào `SourceConfig`
  (fromJson/toJson, master_config.dart:90); khi lưu nguồn từ probe → ghi `probedAt = now`. Lúc app start: nguồn web
  có `probedAt` cũ hơn 7 ngày → probe nền silent (fail = giữ config cũ, bỏ qua lặng lẽ) → Verify: đổi `probedAt`
  trong JSON về cũ → khởi động lại → config refresh (kiểm log)

## Done When

- [ ] Thêm web phim lạ bất kỳ qua Settings → tự dò (heuristic) hoặc AI fallback (nếu đã cấu hình) → browse + search + thể loại + xem tập chạy được
- [ ] Luồng thêm nguồn chạy được đầy đủ KHI KHÔNG cấu hình AI (AI chỉ tăng tỉ lệ khớp, không phải dependency)
- [ ] Nguôn web đổi cấu trúc → app tự re-probe sửa config, không cần user xoá thêm lại
- [ ] WebProbe + AiConfigGenerator có unit test
- [ ] `dart analyze lib/` sạch + `flutter test` pass

## Notes

- **Không sửa nguồn API** (KKPhim/Nguonc) — chỉ đụng nhánh `sourceType: 'web'`.
- **Thứ tự gợi ý**: A → B → D → C (AI để sau vì cần key + là phần phức tạp nhất; A+B+D đã xử lý ~80% web VN).
- **Hạn chế chấp nhận được**: web SPA render JS thuần không SSR vẫn ngoài khả năng heuristic — AI fallback hoặc
  báo lỗi rõ (WebProbeException đã có message phù hợp).
- **Không hard-code key AI** trong app — user tự nhập, chỉ gợi ý provider mặc định.
- **CSS selectors: chỉ ràng buộc CSS3** (kết quả nghiên cứu 17/09/2026) — không thêm package scraper ngoài nào:
  `dart_web_scraper` (không có auto-detect), `flutter_ai_scrapper` (conflict platform + Flutter version) đều loại.
- **Re-probe giữ id nguồn cũ** — bookmark/history liên kết theo sourceId, không được mất khi tự cập nhật.
- **Tuỳ chọn P2** (nếu còn thời gian): probe song song search+listByType cùng lúc khi thêm nguồn; Task 13 re-probe định kỳ.
