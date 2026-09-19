import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/domain/entities/episode.dart';
import 'package:fcine/ui/features/player/views/widgets/episode_drawer.dart';
import 'package:fcine/ui/features/player/views/widgets/player_desktop_theater.dart';

void main() {
  group('EpisodeDrawer Tests', () {
    late List<Map<String, dynamic>> episodes;
    late Episode currentEp;
    const String currentServer = 'VIP 1';

    setUp(() {
      episodes = List.generate(
        30,
        (i) => {
          'ep': Episode(
            name: 'Tập ${i + 1}',
            slug: 'tap-${i + 1}',
            m3u8Url: 'https://example.com/ep$i.m3u8',
          ),
          'server': currentServer,
        },
      );
      currentEp = episodes[15]['ep'] as Episode;
    });

    testWidgets(
      'EpisodeDrawer auto-focuses and highlights the current episode',
      (WidgetTester tester) async {
        dynamic selectedEp;
        String? selectedServer;
        bool closed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: EpisodeDrawer(
                  flatEpisodes: episodes,
                  currentEpisode: currentEp,
                  currentServer: currentServer,
                  movieSlug: 'test-movie',
                  onClose: () => closed = true,
                  onSelect: (ep, s) {
                    selectedEp = ep;
                    selectedServer = s;
                  },
                ),
              ),
            ),
          ),
        );

        // Allow postFrameCallback and animation to complete
        await tester.pumpAndSettle();

        // Verify header title
        expect(find.text('Danh Sách Tập'), findsOneWidget);

        // Verify current episode (Tập 16, index 15) is visible in the viewport because of auto-scroll
        expect(find.text('Tập 16'), findsOneWidget);

        // Tap on close button
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump();
        expect(closed, isTrue);

        // Tap on current episode
        await tester.tap(find.text('Tập 16'));
        await tester.pump();
        expect(selectedEp?.slug, equals('tap-16'));
        expect(selectedServer, equals(currentServer));
      },
    );

    testWidgets(
      'DesktopEpisodeList auto-scrolls and focuses the current episode',
      (WidgetTester tester) async {
        dynamic selectedEp;
        String? selectedServer;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 380,
                height: 400,
                child: DesktopEpisodeList(
                  flatEpisodes: episodes,
                  currentEpisode: currentEp,
                  currentServer: currentServer,
                  movieSlug: 'test-movie',
                  onSelectEpisode: (ep, s) async {
                    selectedEp = ep;
                    selectedServer = s;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Current episode (Tập 16) must be visible in viewport
        expect(find.text('Tập 16'), findsOneWidget);

        await tester.tap(find.text('Tập 16'));
        await tester.pump();
        expect(selectedEp?.slug, equals('tap-16'));
        expect(selectedServer, equals(currentServer));
      },
    );
    testWidgets(
      'DesktopEpisodeList groups episodes by server tabs',
      (WidgetTester tester) async {
        final multi = <Map<String, dynamic>>[
          for (int i = 1; i <= 3; i++)
            {
              'ep': Episode(
                name: 'Tập $i',
                slug: 'tap-$i',
                m3u8Url: 'https://example.com/a$i.m3u8',
              ),
              'server': 'Vietsub #1',
            },
          for (int i = 1; i <= 2; i++)
            {
              'ep': Episode(
                name: 'Tập $i',
                slug: 'tap-$i',
                m3u8Url: 'https://example.com/b$i.m3u8',
              ),
              'server': 'Vietsub #2',
            },
        ];
        String? selectedServer;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 380,
                height: 400,
                child: DesktopEpisodeList(
                  flatEpisodes: multi,
                  currentEpisode: multi[4]['ep'],
                  currentServer: 'Vietsub #2',
                  movieSlug: 'test-movie',
                  onSelectEpisode: (ep, s) async {
                    selectedServer = s;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tab mặc định bám theo server đang phát + hiện số tập mỗi tab.
        expect(find.text('Vietsub #1 (3)'), findsOneWidget);
        expect(find.text('Vietsub #2 (2)'), findsOneWidget);
        // Tab #2 đang chọn nên chỉ hiện 2 tập của nó (Tập 1/2 trùng tên
        // với tab #1 nhưng thuộc server khác).
        expect(find.text('Tập 3'), findsNothing);

        // Chạm tập trong tab đang chọn -> trả đúng server của tab.
        await tester.tap(find.text('Tập 1').first);
        await tester.pump();
        expect(selectedServer, equals('Vietsub #2'));

        // Đổi sang tab #1 -> danh sách lọc theo tab.
        await tester.tap(find.text('Vietsub #1 (3)'));
        await tester.pumpAndSettle();
        expect(find.text('Tập 3'), findsOneWidget);
      },
    );
  });
}
