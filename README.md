# F-CINE

Ứng dụng xem phim streaming với giao diện cinematic dark, responsive trên mobile và desktop.

## Screenshots

### Mobile

| Home | Search | Detail | Player | Library | Settings |
|------|--------|--------|--------|---------|----------|
| <img src="docs/screenshots/home_mobile.png" width="200"> | <img src="docs/screenshots/search_mobile.png" width="200"> | <img src="docs/screenshots/detail_mobile.png" width="200"> | <img src="docs/screenshots/player_mobile.png" width="200"> | <img src="docs/screenshots/library_mobile.png" width="200"> | <img src="docs/screenshots/settings_mobile.png" width="200"> |

### Desktop

| Home | Search | Detail | Player | Library | Settings |
|------|--------|--------|--------|---------|----------|
| <img src="docs/screenshots/home_desktop.png" width="300"> | <img src="docs/screenshots/search_desktop.png" width="300"> | <img src="docs/screenshots/detail_desktop.png" width="300"> | <img src="docs/screenshots/player_desktop.png" width="300"> | <img src="docs/screenshots/library_desktop.png" width="300"> | <img src="docs/screenshots/settings_desktop.png" width="300"> |

> **Lưu ý**: Chạy script bên dưới để tự động chụp screenshot thực tế từ app đang chạy.

### Tự động chụp Screenshots

```bash
# Cài dependencies
flutter pub get

# Chụp tất cả (mobile + desktop nếu trên desktop OS)
# Windows PowerShell:
.\tool\screenshot.ps1

# Linux/macOS:
chmod +x tool/screenshot.sh
./tool/screenshot.sh

# Hoặc chỉ mobile:
flutter test integration_test/screenshot_test.dart --name "Capture all screens"

# Chỉ desktop (Windows):
flutter test integration_test/screenshot_test.dart --name "Capture desktop screens" -d windows
```

Screenshots sẽ lưu tại `docs/screenshots/` và tự động hiển thị ở trên.

## Features

- **Trang chủ**: Banner carousel phim mới, phân loại phim (Phim lẻ, Phim bộ, Hoạt hình), tiếp tục xem
- **Tìm kiếm**: Tìm kiếm phim với bộ lọc thể loại, quốc gia, năm, sắp xếp; debounce 400ms, song song nhiều nguồn
- **Chi tiết phim**: Thông tin phim, danh tập, server tabs (VIP/Thường), phim liên quan
- **Xem phim**: Player HLS (media_kit) với tùy chọn chất lượng, tốc độ, phụ đề, skip intro, auto-next episode, PiP
- **Tủ phim**: Lịch sử xem, đánh dấu yêu thích, tải xuống, quản lý dung lượng
- **Responsive**: Layout tối ưu cho mobile (360px+), tablet (720px+), desktop (1024px+) với Sidebar/NavigationRail
- **Dark mode**: Giao diện cinematic dark với hiệu ứng glassmorphism, OLED-friendly
- **Offline-first**: Cache config, cache ảnh (100MB, 7 ngày), banner offline mode
- **Multi-source**: Hỗ trợ KKPhim, NguonC qua Master Config remote (GitHub Gist), tự cập nhật không cần release mới

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.13+ / Dart 3.13+ |
| State Management | BLoC + Freezed + HydratedBloc + ReplayBloc |
| Routing | GoRouter 18.0.0 (Deep link `/movie/:slug/:episode`) |
| HTTP | Dio 5.7.0 (Interceptor, CancelToken, Retry) |
| Database | Drift (SQLite) - watch_history, bookmarks, config_cache |
| Video Player | media_kit + media_kit_video (HLS, header injection) |
| Image Cache | CachedNetworkImage + flutter_cache_manager (100MB limit) |
| DI | GetIt |
| JSONPath | json_path (runtime extractor từ config) |
| Code Gen | build_runner, freezed, json_serializable, drift_dev |
| Window | window_manager (Desktop titlebar, size/position) |

## Architecture

```
lib/
├── core/                          # Core utilities
│   ├── cache/                     # Image cache manager (FImageCache)
│   ├── config/                    # ConfigService, MasterConfig, SourceTemplates
│   ├── database/                  # Drift database (AppDatabase)
│   ├── di/                        # Dependency injection (GetIt)
│   ├── download/                  # Download service (m3u8 → mp4)
│   ├── extractor/                 # JSONPath extractor, M3U8 parser
│   ├── network/                   # DioClient, interceptors
│   ├── match/                     # MovieMatcher (dedup slug+year)
│   ├── local_media/               # Local media scanner
│   ├── scraper/                   # Web scraper, AI config generator
│   └── toast/                     # Custom toast overlay
├── data/                          # Data layer
│   ├── datasources/
│   │   ├── kkphim_remote_datasource.dart
│   │   ├── nguonc_remote_datasource.dart
│   │   ├── remote_datasource.dart (abstract)
│   │   └── web_scraper_datasource.dart
│   ├── models/                    # MovieModel, EpisodeModel (JSON serializable)
│   └── repositories/              # MovieRepositoryImpl, HistoryRepository, BookmarkRepository
├── domain/                        # Domain layer
│   ├── entities/                  # Movie, Episode, Server, Pagination (pure Dart)
│   └── repositories/              # Abstract repositories
├── presentation/                  # Presentation layer (BLoC + Pages)
│   ├── blocs/
│   │   ├── home/                  # HomeBloc (aggregated feed, banner)
│   │   ├── search/                # SearchBloc (debounce, parallel fetch)
│   │   ├── detail/                # DetailBloc
│   │   ├── library/               # LibraryBloc (history, bookmarks, downloads)
│   │   ├── player/                # PlayerBloc (playlist, position sync)
│   │   └── replay/                # AppReplayBloc (time-travel debug)
│   ├── pages/
│   │   ├── home_page.dart
│   │   ├── search_page.dart
│   │   ├── detail_page.dart
│   │   ├── player_page.dart
│   │   ├── library_page.dart
│   │   ├── local_player_page.dart
│   │   └── settings_page.dart
│   ├── router/                    # AppRouter (GoRouter config)
│   ├── theme/                     # AppTheme (Cinematic Dark, Material 3)
│   └── widgets/                   # Shared widgets (MovieCard, BannerCarousel, OfflineBanner, ResponsiveScaffold)
├── ui/features/                   # Feature-specific widgets (split per feature)
│   ├── home/
│   ├── search/
│   ├── player/
│   ├── detail/
│   └── library/
└── main.dart
```

## Design System

Chi tiết tại [DESIGN.md](DESIGN.md)

| Token | Value | Mô tả |
|-------|-------|-------|
| Primary | `#E50914` | Cinematic Crimson - Play buttons, active tabs |
| Secondary | `#FF5252` | Coral Accent - Live badges, trending |
| Tertiary | `#F59E0B` | Amber Gold - IMDb ratings, VIP badges |
| Background | `#080B11` | Deep Canvas - OLED pitch black |
| Surface | `#111622` | Elevated Cards |
| Surface Variant | `#1A2130` | Interactive Chips |
| On-Surface | `#F1F5F9` | Crisp White/Slate (12:1 contrast) |
| Typography | Be Vietnam Pro | Vietnamese diacritics, geometric |

**Breakpoints:**
- Mobile: `< 720px` → BottomNav, 2-3 cột
- Tablet: `720px - 1023px` → NavigationRail, 3-4 cột
- Desktop: `≥ 1024px` → Sidebar 240px, 5-6 cột, Dual-pane layout

## Getting Started

### Prerequisites

- Flutter SDK 3.13.1+
- Dart SDK 3.13.1+
- Windows/macOS/Linux

### Installation

```bash
# Clone repository
git clone https://github.com/ngtrongha/fcine.git
cd fcine

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run -d windows    # hoặc -d macos, -d linux, -d chrome
```

### Build

```bash
# Windows (MSIX)
flutter build windows --release
# Tạo installer: .\windows\installer\install-msix.ps1

# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

## Configuration

App sử dụng `MasterConfig` để cấu hình API endpoints và settings từ remote source.

**Config load order:** Remote (GitHub Gist) → Drift cache → Assets fallback (`assets/config/master_config.sample.json`)

### Master Config Structure

```json
{
  "version": 2,
  "updatedAt": "2026-08-28T00:00:00Z",
  "sources": [
    {
      "id": "kkphim",
      "name": "KKPhim",
      "enabled": true,
      "baseUrl": "https://phimapi.com",
      "fallbackUrls": ["https://phimapi.com"],
      "cdnImage": "https://phimimg.com",
      "headers": { "accept": "application/json" },
      "endpoints": { ... },
      "extractors": { ... },
      "pagination": { "type": "page_number", "param": "page" }
    }
  ],
  "settings": {
    "searchDebounceMs": 400,
    "requestTimeoutMs": 8000,
    "imageCacheMaxMb": 100,
    "playerHeadersRequired": false
  }
}
```

Xem mẫu đầy đủ tại: `assets/config/master_config.sample.json`

### Cách deploy config

1. Tạo file JSON theo cấu trúc trên
2. Upload lên GitHub Gist (Public)
3. Cập nhật `CONFIG_GIST_URL` trong `ConfigService` hoặc qua environment variable
4. App sẽ tự tải khi khởi động, cache vào SQLite, fallback khi offline

## Commands

```bash
# Phân tích code
dart analyze lib/

# Chạy tests
flutter test

# Chạy test cụ thể
flutter test test/kkphim_api_test.dart

# Tạo lại code generation
dart run build_runner build --delete-conflicting-outputs

# Lint runner (custom)
python3.13 .agents/skills/lint-and-validate/scripts/lint_runner.py

# Watch mode cho development
dart run build_runner watch --delete-conflicting-outputs
```

## Project Structure Details

### Core Services

| File | Mô tả |
|------|-------|
| `lib/core/config/config_service.dart` | Load config từ Gist, validate version, cache Drift, fallback offline |
| `lib/core/extractor/json_path.dart` | Runtime JSONPath extractor từ MasterConfig |
| `lib/core/extractor/m3u8_parser.dart` | Parse m3u8, extract quality variants |
| `lib/core/match/movie_matcher.dart` | Dedup phim theo slug+year, merge sources |
| `lib/core/cache/image_cache_manager.dart` | FImageCache 300 objects / 7 ngày (~100MB) |
| `lib/core/database/app_database.dart` | Drift tables: watch_history, bookmarks, config_cache |
| `lib/core/download/download_service.dart` | Download m3u8 segments, merge mp4 |

### Presentation (BLoC)

| Bloc | Trạng thái | Sự kiện chính |
|------|------------|---------------|
| `HomeBloc` | `HomeState` (feed, banner, continueWatching) | `LoadFeed`, `RefreshFeed`, `LoadMore` |
| `SearchBloc` | `SearchState` (results, suggestions, filters) | `SearchQueryChanged`, `FilterChanged`, `LoadMore` |
| `DetailBloc` | `DetailState` (movie, episodes, servers) | `LoadDetail`, `SelectServer`, `SelectEpisode` |
| `LibraryBloc` | `LibraryState` (history, bookmarks, downloads) | `LoadHistory`, `ToggleBookmark`, `DeleteHistory` |
| `PlayerBloc` | `PlayerState` (playlist, position, settings) | `Play`, `Pause`, `Seek`, `NextEpisode`, `ChangeSpeed` |

### Responsive Widgets

- `ResponsiveScaffold` - Tự chuyển BottomNav / NavigationRail / Sidebar
- `ResponsiveLayout` - LayoutBuilder cho dual-pane (desktop)
- `DesktopSidebar` - Sidebar cố định 240px với hover effect
- `DesktopTitleBar` - Custom titlebar cho Windows/macOS/Linux

## Testing

```bash
# Unit tests
flutter test test/kkphim_api_test.dart
flutter test test/movie_matcher_test.dart
flutter test test/web_scraper_test.dart

# Widget tests
flutter test test/home_bloc_fresh_repo_test.dart
flutter test test/detail_page_test.dart
flutter test test/player_page_test.dart

# Integration tests (cần device/emulator)
flutter test integration_test/app_test.dart
```

## CI/CD

GitHub Actions workflows:
- `.github/workflows/build.yml` - Build & test trên Windows/macOS/Linux
- `.github/workflows/release.yml` - Tạo release MSIX, DMG, AppImage

## License

MIT

## Credits

- **API Source**: [KKPhim](https://phimapi.com) (phimapi.com)
- **Design**: Stitch MCP (Google) - Project `projects/2616384555894592776`
- **Icons**: Material Icons, Custom app icon
- **Font**: Be Vietnam Pro (Google Fonts)

---

**F-Cine** - Xem phim không giới hạn, giao diện rạp chiếu tại nhà 🎬