import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'core/di/injection.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );

  await setupInjection();
  await _initDesktopWindow();

  runApp(const MyApp());
}

/// Ẩn native title bar trên Windows/Linux để dùng custom title bar
/// vẽ theo theme ([DesktopTitleBar]). Các nền tảng khác giữ nguyên.
Future<void> _initDesktopWindow() async {
  if (kIsWeb) return;
  final p = defaultTargetPlatform;
  if (p != TargetPlatform.windows &&
      p != TargetPlatform.linux &&
      p != TargetPlatform.macOS) {
    return;
  }
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: const Size(1366, 800),
      minimumSize: const Size(960, 600),
      center: true,
      backgroundColor: const Color(0xFF080B11),
      // Chỉ ẩn thanh native nơi có custom bar thay thế.
      titleBarStyle: (p == TargetPlatform.windows || p == TargetPlatform.linux)
          ? TitleBarStyle.hidden
          : TitleBarStyle.normal,
      title: 'F-Cine',
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Tạo 1 lần duy nhất: giữ đúng tab khởi động (Online/Video) suốt vòng đời app.
  late final _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'F-Cine',
      theme: darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
