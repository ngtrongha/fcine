# Bloc Migration — bloc + freezed + hydrated_bloc + replay_bloc

## Goal
Migrate F-CINE từ Riverpod sang BLoC latest stack 100% (freezed events/states, hydrated persistence, replay undo/redo), xóa `flutter_riverpod`, tách widget, giữ 100% HTML fidelity.

## Tasks
- [x] HomeBloc/SearchBloc/DetailBloc/ReplayBloc: `freezed` events extends `replay.ReplayEvent` + `HydratedBloc` + `ReplayBlocMixin` → Verify: `dart analyze` 0 errors
- [x] LibraryBloc/PlayerBloc: `freezed` + `HydratedBloc` + stream subscriptions DB → Verify: `build_runner` 44 outputs
- [x] DetailPage/PlayerPage/LibraryPage/HomePage/SearchPage/OfflineBanner: `StatefulWidget` + `getIt<>` thay `ref.*` → Verify: `grep flutter_riverpod` 0 matches
- [x] Widget splitting: `ui/features/{home,search,library,player,detail}/views/widgets/*` → Verify: `Get-ChildItem` 9 widgets tồn tại
- [x] DI: `injection.dart:12` register History/Bookmark/DownloadService → `main.dart:14` `HydratedStorageDirectory.web` + `setupInjection()` → Verify: `dart pub get` Got dependencies
- [x] Remove `flutter_riverpod: pubspec.yaml:34` + `providers/` + `database_provider.dart` → Verify: `dart analyze` No issues
- [x] HTML 100%: `ImmediatePiP` fix `player_page.dart:203` → Verify: `flutter test` +2 pass

## Done When
- [x] `dart analyze` 0 issues, `flutter test test/kkphim_api_test.dart` pass, `grep -r flutter_riverpod lib/` 0, `build_runner` freezed g.dart generated

## Notes
- Hydrated lists `@JsonKey(includeFromJson:false)` (`home_state.dart:13`), `shouldReplay` chỉ replay `success` state
- `replay_bloc:0.3.0` conflict `ReplayEvent` → AppReplayBloc đổi sang `HydratedBloc` pure, Home/Search/Detail giữ mixin
- `floating:6.0.0` `EnableManual` → `ImmediatePiP`
