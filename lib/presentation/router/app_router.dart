import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/library_page.dart';
import '../pages/settings_page.dart';
import '../pages/detail_page.dart';
import '../pages/player_page.dart';
import '../widgets/responsive_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorSearchKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _shellNavigatorLibraryKey = GlobalKey<NavigatorState>(debugLabel: 'library');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
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
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSearchKey,
          routes: [
            GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorLibraryKey,
          routes: [
            GoRoute(path: '/library', builder: (context, state) => const LibraryPage()),
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
      builder: (context, state) => DetailPage(slug: state.pathParameters['slug']!),
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
  ],
);
