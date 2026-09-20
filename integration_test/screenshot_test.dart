// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fcine/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('F-Cine Screenshots', () {
    testWidgets('Capture all mobile screens', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await _ensureScreenshotsDir();

      // 1. Home Screen
      await _takeScreenshot(tester, 'home_mobile.png');
      print('✓ Home screen captured');

      // 2. Navigate to Search
      await _tapSearchIcon(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _takeScreenshot(tester, 'search_mobile.png');
      print('✓ Search screen captured');

      // 3. Navigate to Detail (tap first movie)
      await _tapFirstMovie(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _takeScreenshot(tester, 'detail_mobile.png');
      print('✓ Detail screen captured');

      // 4. Navigate to Player (tap first episode)
      await _tapFirstEpisode(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await _takeScreenshot(tester, 'player_mobile.png');
      print('✓ Player screen captured');

      // 5. Back to Home, then Library
      await tester.pageBack();
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _tapLibraryTab(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _takeScreenshot(tester, 'library_mobile.png');
      print('✓ Library screen captured');

      // 6. Settings
      await _tapSettingsTab(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _takeScreenshot(tester, 'settings_mobile.png');
      print('✓ Settings screen captured');

      print('\n✅ All mobile screenshots saved to docs/screenshots/');
    });

    testWidgets('Capture desktop screens (if desktop)', (WidgetTester tester) async {
      // Only run on desktop platforms
      if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
        print('Skipping desktop screenshots on ${Platform.operatingSystem}');
        return;
      }

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Resize to desktop size using view
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await _ensureScreenshotsDir();

      await _takeScreenshot(tester, 'home_desktop.png');
      print('✓ Desktop Home captured');

      await _tapSearchIcon(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _takeScreenshot(tester, 'search_desktop.png');
      print('✓ Desktop Search captured');

      await _tapFirstMovie(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _takeScreenshot(tester, 'detail_desktop.png');
      print('✓ Desktop Detail captured');

      await _tapFirstEpisode(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await _takeScreenshot(tester, 'player_desktop.png');
      print('✓ Desktop Player captured');

      await tester.pageBack();
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _tapLibraryTab(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _takeScreenshot(tester, 'library_desktop.png');
      print('✓ Desktop Library captured');

      await _tapSettingsTab(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _takeScreenshot(tester, 'settings_desktop.png');
      print('✓ Desktop Settings captured');

      print('\n✅ All desktop screenshots saved to docs/screenshots/');
    });
  });
}

Future<void> _ensureScreenshotsDir() async {
  final screenshotDir = Directory('docs/screenshots');
  if (!await screenshotDir.exists()) {
    await screenshotDir.create(recursive: true);
  }
}

Future<void> _takeScreenshot(WidgetTester tester, String filename) async {
  await _ensureScreenshotsDir();

  // Use the binding's screenshot capability
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  final image = await binding.takeScreenshot(filename);
  final file = File('docs/screenshots/$filename');
  await file.writeAsBytes(image);
}

Future<void> _tapSearchIcon(WidgetTester tester) async {
  // Tap search icon in AppBar
  final searchIcon = find.byIcon(Icons.search);
  if (searchIcon.evaluate().isNotEmpty) {
    await tester.tap(searchIcon);
    return;
  }
  // Fallback: tap search field
  final searchField = find.byType(TextField);
  if (searchField.evaluate().isNotEmpty) {
    await tester.tap(searchField);
  }
}

Future<void> _tapFirstMovie(WidgetTester tester) async {
  // Try to find MovieCard widgets
  final movieCards = find.byKey(const Key('movie_card'));
  if (movieCards.evaluate().isNotEmpty) {
    await tester.tap(movieCards.first);
    return;
  }
  
  // Fallback: find any GestureDetector in a GridView
  final gridItems = find.descendant(
    of: find.byType(GridView),
    matching: find.byType(GestureDetector),
  );
  if (gridItems.evaluate().isNotEmpty) {
    await tester.tap(gridItems.first);
    return;
  }
  
  // Last resort: tap center of first GridView
  final gridView = find.byType(GridView);
  if (gridView.evaluate().isNotEmpty) {
    await tester.tapAt(tester.getCenter(gridView.first));
  }
}

Future<void> _tapFirstEpisode(WidgetTester tester) async {
  // Try to find episode buttons (usually in a GridView/ListView)
  final episodeButtons = find.byKey(const Key('episode_button'));
  if (episodeButtons.evaluate().isNotEmpty) {
    await tester.tap(episodeButtons.first);
    return;
  }
  
  // Fallback: look for text that looks like episode numbers
  final episodeTexts = find.byWidgetPredicate((widget) {
    if (widget is Text) {
      final text = widget.data ?? '';
      return RegExp(r'^\d+$').hasMatch(text.trim());
    }
    return false;
  });
  if (episodeTexts.evaluate().isNotEmpty) {
    await tester.tap(episodeTexts.first);
    return;
  }
  
  // Last resort: tap first tap-able widget in a GridView/ListView on detail page
  final listViews = find.byType(ListView);
  if (listViews.evaluate().isNotEmpty) {
    final listView = listViews.first;
    final children = find.descendant(of: listView, matching: find.byType(GestureDetector));
    if (children.evaluate().isNotEmpty) {
      await tester.tap(children.first);
    }
  }
}

Future<void> _tapLibraryTab(WidgetTester tester) async {
  // Tap Library tab (video_library icon)
  final libraryTab = find.byIcon(Icons.video_library_outlined);
  if (libraryTab.evaluate().isNotEmpty) {
    await tester.tap(libraryTab);
    return;
  }
  
  // Fallback: tap by tooltip or index
  final libraryTooltip = find.byTooltip('Thư viện');
  if (libraryTooltip.evaluate().isNotEmpty) {
    await tester.tap(libraryTooltip);
    return;
  }
  
  // Last resort: tap BottomNavigationBar at index 2
  final bottomNav = find.byType(BottomNavigationBar);
  if (bottomNav.evaluate().isNotEmpty) {
    final renderBox = tester.renderObject<RenderBox>(bottomNav);
    final size = renderBox.size;
    await tester.tapAt(Offset(size.width * 0.5, size.height / 2));
  }
}

Future<void> _tapSettingsTab(WidgetTester tester) async {
  // Tap Settings tab (settings icon)
  final settingsTab = find.byIcon(Icons.settings_outlined);
  if (settingsTab.evaluate().isNotEmpty) {
    await tester.tap(settingsTab);
    return;
  }
  
  // Fallback: tap by tooltip
  final settingsTooltip = find.byTooltip('Cài đặt');
  if (settingsTooltip.evaluate().isNotEmpty) {
    await tester.tap(settingsTooltip);
    return;
  }
  
  // Last resort: tap BottomNavigationBar at index 3
  final bottomNav = find.byType(BottomNavigationBar);
  if (bottomNav.evaluate().isNotEmpty) {
    final renderBox = tester.renderObject<RenderBox>(bottomNav);
    final size = renderBox.size;
    await tester.tapAt(Offset(size.width * 0.75, size.height / 2));
  }
}