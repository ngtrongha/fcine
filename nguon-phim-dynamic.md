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

### Gói B — Heuristic generic mạnh hơn (không AI) ✅ HOÀN THÀNH 17/09/2026

- [x] **Task 4: Sibling-structure detection cho `_parseCards`** — `WebScraper.siblingCards()` mới (web_scraper.dart):
  tìm nhóm ≥3 element anh em cùng tag+class, mỗi block chứa `<a href>` + `<img>` link khác nhau, bỏ qua
  header/nav/footer/menu; giữ nhóm lớn nhất. Nối vào `_parseCards` (web_scraper_datasource.dart) làm fallback thứ 3
  (config → generic `article,.post,div.item` → siblingCards). Test: `siblingCards` tìm đúng 4 card + loại nav; e2e
  `getLatest` web lạ ra 4 phim → Verify: `flutter test test/web_scraper_test.dart` pass (+14)
- [x] **Task 5: Auto search URL** — `WebProbe._tuneSearch()` (web_probe.dart): sau khi B1 thắng, thử song song pattern
  `/?s=` → `/tim-kiem?keyword=` → `/search?q=` → `/timkiem?keyword=` → `?keyword=` với keyword `tinh` rồi `a`;
  pattern đầu tiên ra ≥1 phim được lưu vào `endpoints.search` (pattern config hiện tại thử trước) → Verify: test
  "probe tự tune search + listByType" chọn đúng `/tim-kiem?keyword={keyword}`
- [x] **Task 6: Auto listByType** — `WebProbe._tuneListByType()` (web_probe.dart): thử song song `/{type}/page/{page}/` →
  `/{type}/` → `/the-lo/...` → `/the-loai/...` → `/genre/...` → `/danh-muc/...` với type=`phim-bo` (qua `typeMap`);
  pattern đầu tiên ra ≥3 phim lưu vào `endpoints.listByType` → Verify: cùng test trên, chọn đúng
  `/the-lo/{type}/page/{page}/`. Nguồn sitemap bỏ qua tune (search/list nội bộ đã chạy)

### Gói C — AI-assisted fallback

- [x] **Task 7: Service `AiConfigGenerator`** — `lib/core/scraper/ai_config_generator.dart`: nhận HTML homepage
  (trim ~28KB head+body), gửi tới LLM OpenAI-compatible (base URL + key tự nhập, model tùy chọn), prompt trả JSON
  đúng schema `SourceConfig` (selectors + endpoints + pagination) → parse, validate schema, trả `SourceConfig`
  → Verify: 6 test `ai_config_generator_test.dart` pass (parse sạch, fence, missing keys, 401, trim lớn)
- [x] **Task 8: Settings section AI** — settings_page.dart thêm card "AI phân tích nguồn (OpenAI-compatible)":
  endpoint/key(obscure)/model, persist qua ConfigService SharedPreferences (_kAiEndpoint/_kAiKey/_kAiModel),
  nút Lưu/Xóa (dialog confirm), hiện `Đã cấu hình ...` khi có key → Verify: nhập key → thoát app → mở lại còn key
- [x] **Task 9: Flow probe fail → AI (optional)** — `_saveWebSource` catch WebProbeException: **chưa cấu hình AI → toast
  lỗi heuristic bình thường**; **đã cấu hình AI → dialog "Thử phân tích bằng AI?"** (nút Hủy thoát bình thường) →
  `_runAiAnalysis()` gọi `AiConfigGenerator.generate` → preview dialog chung → lưu → Verify: không có key lỗi heuristic
  bình thường; có key + parse-tốt sẽ chạy AI fallback

### Gói D — Playback cho web lạ — Task 10 ✅ 17/09/2026

- [x] **Task 10: Mở rộng pattern resolveStream** — web_scraper_datasource.dart:802 chuỗi fallback đầy đủ:
  1) config playerApi (DooPlay/API từ AI) → 2) `scanStreamUrls` → 3) **`playerSetupStreams` mới**
  (web_scraper.dart: JWPlayer/PlayerJS/VideoJS setup block, gỡ escape `\/` + `\u002F`) →
  4) **deep-fetch embed iframe 1 tầng (tối đa 2)**: quét stream + playerSetup trong trang embed →
  trả iframe như fallback cuối → Verify: 4 test "Playback web lạ (Gói D)" trong web_scraper_test.dart pass
  (gỡ escape, Playerjs, deep-fetch iframe ra m3u8, embed rỗng trả iframe fallback)
- [x] **Task 11: AI config cho playback** — prompt Task 7 bổ sung sinh `playerOption`/`playerApi` selectors nếu phát
  hiện được trong HTML (DooPlay/dooplayer v2, iframe pattern); resolveStream đã ưu tiên config sẵn → Verify: web
  DooPlay lạ → player AI-generated vẫn play được qua dooplayer API

### Gói E — Tự re-probe khi nguồn đổi cấu trúc (self-heal, yêu cầu của user 17/09) ✅ HOÀN THÀNH 17/09/2026

- [x] **Task 12: Re-probe khi băm fail** — service mới `SourceRefreshService` (`lib/core/config/source_refresh_service.dart`):
  nhận sourceId → gọi `WebProbe.probe(baseUrl, name, hint: 'auto')` lại (giữ nguyên `id`/`name`/`enabled` cũ) →
  `ConfigService.saveWebSource()` (đã replace-theo-id sẵn, config_service.dart:145) → trả config mới.
  Neo vào `MovieRepositoryImpl._withFallback` (movie_repository_impl.dart:71-74): khi nguồn **web** fail với lỗi
  "Không bóc được..." (config hỏng, khác lỗi network) → gọi refresh → retry request đúng 1 lần với config mới →
  toast "Nguồn {name} đã tự cập nhật cấu trúc". Inject optional vào repository (null = tắt, giữ test đơn giản) →
  Verify: sửa tay 1 selector trong config đã lưu cho sai → mở app browse → tự sửa lại + load được phim, toast hiện
- [x] **Task 13 (P2, tuỳ chọn): Re-probe định kỳ nhẹ** — thêm field `probedAt` (ISO string) vào `SourceConfig`
  (fromJson/toJson/copyWith, master_config.dart:54-163); khi lưu nguồn từ probe → ghi `probedAt = now`. Lúc app start
  (`main.dart:21`): `SourceRefreshService.checkAndReprobeStale()` chạy nền, quét nguồn web có `probedAt` cũ hơn 7 ngày,
  re-probe silent (fail = giữ config cũ). SourceRefreshService: `checkAndReprobeStale()` + `maxFailures=3` + `probeInterval=7 ngày`.

## Done When

- [x] Thêm web phim lạ bất kỳ qua Settings → tự dò (heuristic) hoặc AI fallback (nếu đã cấu hình) → browse + search + thể loại + xem tập chạy được
- [x] Luồng thêm nguồn chạy được đầy đủ KHI KHÔNG cấu hình AI (AI chỉ tăng tỉ lệ khớp, không phải dependency)
- [x] Nguôn web đổi cấu trúc → app tự re-probe sửa config, không cần user xoá thêm lại
- [x] WebProbe + AiConfigGenerator + SourceRefreshService có unit test
- [x] `dart analyze lib/` sạch + `flutter test` pass

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
