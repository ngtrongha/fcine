import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fcine/core/config/config_service.dart';
import 'package:fcine/core/config/source_refresh_service.dart';
import 'package:fcine/core/database/app_database.dart';
import 'package:fcine/core/di/injection.dart';
import 'package:fcine/presentation/pages/settings_page.dart';

/// Hồi quy lỗi: bấm Xóa trong dialog "Xóa nguồn?" / "Xóa toàn bộ nguồn?"
/// crash go_router ("popped the last page off of the stack") vì nút dialog
/// dùng nhầm context của trang (navigator nhánh chỉ có 1 page).
///
/// Test dựng đúng cấu trúc production: SettingsPage nằm trong
/// StatefulShellBranch, dialog nằm trên root navigator.
Future<void> _setupDiWithOneSource() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    getIt.registerSingleton<AppDatabase>(
      AppDatabase.forTesting(NativeDatabase.memory()),
    );
    getIt.registerSingleton<ConfigService>(
      ConfigService(db: getIt<AppDatabase>(), dio: Dio()),
    );
    getIt.registerLazySingleton<SourceRefreshService>(
      () => SourceRefreshService(getIt<ConfigService>()),
    );
    await getIt<ConfigService>().saveBaseUrl(
      'https://phimapi.com',
      name: 'KKPhim',
    );
    await refreshSources();
  }

GoRouter _shellRouter() {
  return GoRouter(
    initialLocation: '/settings',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => Scaffold(body: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    const Scaffold(body: Text('video-tab')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  tearDown(() async {
    if (getIt.isRegistered<AppDatabase>()) {
      try {
        await getIt<AppDatabase>().close();
      } catch (_) {}
    }
    await getIt.reset();
  });

  testWidgets('Dialog "Xóa nguồn?": bấm Xóa chỉ đóng dialog, không crash',
      (WidgetTester tester) async {
    await _setupDiWithOneSource();
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _shellRouter()),
    );
    await tester.pumpAndSettle();
    // Tile nguồn nằm dưới fold -> cuộn tới mới thấy/tap được.
    await tester.scrollUntilVisible(find.text('KKPhim'), 300);
    await tester.pumpAndSettle();
    expect(find.text('KKPhim'), findsOneWidget);

    // Mở dialog xóa nguồn đầu tiên.
    await tester.tap(find.byTooltip('Xóa nguồn').first);
    await tester.pumpAndSettle();
    expect(find.text('Xóa "KKPhim"?'), findsOneWidget);

    // Bấm Xóa: trước fix sẽ throw go_router assertion.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Xóa'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Dialog đóng, hết nguồn -> tự về tab Video.
    expect(find.text('Xóa "KKPhim"?'), findsNothing);
    expect(find.text('video-tab'), findsOneWidget);
    // Xả Timer 2s của AppToast trước khi dispose.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets(
      'Dialog "Xóa toàn bộ nguồn?": bấm Xóa hết chỉ đóng dialog, không crash',
      (WidgetTester tester) async {
    await _setupDiWithOneSource();
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _shellRouter()),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Xóa toàn bộ nguồn'), 300);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xóa toàn bộ nguồn'));
    await tester.pumpAndSettle();
    expect(find.text('Xóa toàn bộ nguồn?'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Xóa hết'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Xóa toàn bộ nguồn?'), findsNothing);
    expect(find.text('video-tab'), findsOneWidget);
    // Xả Timer 2s của AppToast trước khi dispose.
    await tester.pump(const Duration(seconds: 3));
  });
}
