import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/library_page.dart';
import '../pages/settings_page.dart';
import '../pages/detail_page.dart';
import '../pages/player_page.dart';
import '../pages/local_player_page.dart';
import '../widgets/responsive_scaffold.dart';
import '../../core/di/injection.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorVideoKey = GlobalKey<NavigatorState>(debugLabel: 'video');
final _shellNavigatorOnlineKey = GlobalKey<NavigatorState>(debugLabel: 'online');
final _shellNavigatorLibraryKey = GlobalKey<NavigatorState>(debugLabel: 'library');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Tab mở đầu động theo cấu hình đã lưu:
/// - Đã nhập link nguồn phim -> mặc định vào Online (chế độ xem phim).
/// - Chưa có nguồn -> mặc định vào Video (trình phát tự quét).
/// Gọi sau [setupInjection] để [hasConfiguredSource] đọc đúng config.
///
/// Chưa có nguồn phim -> chặn vào các trang online, đá về tab Video.
String? _requireSource(BuildContext context, GoRouterState state) =>
    hasConfiguredSource() ? null : '/';

GoRouter createAppRouter() => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: hasConfiguredSource() ? '/home' : '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ResponsiveScaffold(
          selectedIndex: navigationShell.currentIndex,
          onTabSelected: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
          child: navigationShell,
        );
      },
      branches: [
        // Tab 0 (mặc định): Video trên thiết bị — tự quét + phát.
        StatefulShellBranch(
          navigatorKey: _shellNavigatorVideoKey,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const LocalPlayerPage()),
          ],
        ),
        // Tab 1: Kho online (Home + Search cùng 1 nhánh).
        StatefulShellBranch(
          navigatorKey: _shellNavigatorOnlineKey,
          routes: [
            GoRoute(
              path: '/home',
              redirect: _requireSource,
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/search',
              redirect: _requireSource,
              builder: (context, state) => SearchPage(
                initialKeyword: state.uri.queryParameters['q'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorLibraryKey,
          routes: [
            GoRoute(
              path: '/library',
              redirect: _requireSource,
              builder: (context, state) => const LibraryPage(),
            ),
            // Legacy redirects
            GoRoute(path: '/bookmarks', redirect: (context, state) => '/library'),
            GoRoute(path: '/history', redirect: (context, state) => '/library'),
            GoRoute(path: '/downloads', redirect: (context, state) => '/library'),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [
            GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/movie/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => DetailPage(
        slug: state.pathParameters['slug']!,
        initialSourceId: state.uri.queryParameters['source'],
      ),
    ),
    GoRoute(
      path: '/player',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PlayerPage(
          movie: extra['movie'],
          episode: extra['episode'],
          serverName: extra['serverName'] as String,
          servers: extra['servers'] as List,
        );
      },
    ),
    // Tương thích đường dẫn cũ: /local-player -> tab Video mặc định.
    GoRoute(
      path: '/local-player',
      parentNavigatorKey: _rootNavigatorKey,
      redirect: (context, state) => '/',
    ),
  ],
);
