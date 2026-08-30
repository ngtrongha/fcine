import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/detail_page.dart';
import '../pages/bookmarks_page.dart';
import '../pages/player_page.dart';
import '../pages/history_page.dart';
import '../pages/downloads_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
    GoRoute(path: '/bookmarks', builder: (context, state) => const BookmarksPage()),
    GoRoute(path: '/history', builder: (context, state) => const HistoryPage()),
    GoRoute(path: '/downloads', builder: (context, state) => const DownloadsPage()),
    GoRoute(
      path: '/movie/:slug',
      builder: (context, state) => DetailPage(slug: state.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/player',
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
