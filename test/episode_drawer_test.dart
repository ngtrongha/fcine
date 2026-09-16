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
  });
}
