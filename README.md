# F-CINE

Ứng dụng xem phim streaming với giao diện cinematic dark, responsive trên mobile và desktop.

## Screenshots

| Mobile | Desktop |
|--------|---------|
| <img src="designs_html/home.png" width="300"> | <img src="designs_html/home_desktop.png" width="600"> |

## Features

- **Trang chủ**: Banner carousel phim mới, phân loại phim, tiếp tục xem
- **Tìm kiếm**: Tìm kiếm phim với bộ lọc thể loại, quốc gia, năm
- **Chi tiết phim**: Thông tin phim, danh tập, phim liên quan
- **Xem phim**: Player HLS với tùy chọn chất lượng, tốc độ, phụ đề, skip intro
- **Tủ phim**: Lịch sử xem, đánh dấu yêu thích, tải xuống
- **Responsive**: Layout tối ưu cho mobile (360px+) và desktop (1024px+)
- **Dark mode**: Giao diện cinematic dark với hiệu ứng glassmorphism

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.13+ / Dart 3.13+ |
| State Management | BLoC + Freezed + HydratedBloc + ReplayBloc |
| Routing | GoRouter 18.0.0 |
| HTTP | Dio 5.7.0 |
| Database | Drift (SQLite) |
| Video Player | media_kit (HLS) |
| Image Cache | CachedNetworkImage |
| DI | GetIt |

## Architecture

```
lib/
├── core/                    # Core utilities
│   ├── cache/               # Image cache manager
│   ├── config/              # Config service & master config
│   ├── database/            # Drift database
│   ├── di/                  # Dependency injection (GetIt)
│   ├── download/            # Download service
│   ├── extractor/           # M3U8 parser
│   ├── network/             # Dio client
│   └── toast/               # Custom toast overlay
├── data/                    # Data layer
│   ├── datasources/         # Remote data source (KKPhim API)
│   ├── models/              # Data models
│   └── repositories/        # Repository implementations
├── domain/                  # Domain layer
│   ├── entities/            # Business entities
│   └── repositories/        # Abstract repositories
├── presentation/            # Presentation layer
│   ├── blocs/               # BLoC state management
│   │   ├── home/            # HomeBloc
│   │   ├── search/          # SearchBloc
│   │   ├── detail/          # DetailBloc
│   │   ├── library/         # LibraryBloc
│   │   ├── player/          # PlayerBloc
│   │   └── replay/          # AppReplayBloc
│   ├── pages/               # Screen widgets
│   ├── router/              # GoRouter config
│   ├── theme/               # App theme & colors
│   └── widgets/             # Shared widgets
└── ui/features/             # Feature widgets (split per feature)
    ├── home/                # Home feature widgets
    ├── search/              # Search feature widgets
    ├── player/              # Player feature widgets
    ├── detail/              # Detail feature widgets
    └── library/             # Library feature widgets
```

## Design System

- **Primary**: `#E50914` (Cinematic Crimson)
- **Background**: `#080B11` (Deep Canvas)
- **Surface**: `#111622` (Elevated Cards)
- **Typography**: Be Vietnam Pro
- **Border Radius**: 4px / 8px / 12px / 16px

Chi tiết tại [DESIGN.md](DESIGN.md)

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
flutter run -d windows    # hoặc -d macos, -d linux
```

### Build

```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## Configuration

App sử dụng `MasterConfig` để cấu hình API endpoints và settings. Xem mẫu tại:

```
assets/config/master_config.sample.json
```

Config được load theo thứ tự: Remote (GitHub Gist) → Drift cache → Assets fallback.

## Commands

```bash
# Phân tích code
dart analyze lib/

# Chạy tests
flutter test

# Tạo lại code generation
dart run build_runner build --delete-conflicting-outputs

# Lint runner
python3.13 .agents/skills/lint-and-validate/scripts/lint_runner.py
```

## License

MIT
