import 'package:fcine/core/config/master_config.dart';
import 'package:fcine/ui/features/home/views/widgets/home_app_bar.dart';
import 'package:fcine/ui/features/home/views/widgets/source_picker_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SourceConfig _src(String id, String name) => SourceConfig(
      id: id,
      name: name,
      enabled: true,
      baseUrl: 'https://$id.test',
      fallbackUrls: const [],
      cdnImage: '',
      headers: const {},
      endpoints: Endpoints(
        latest: Endpoint(path: '/', method: 'GET'),
        search: Endpoint(path: '/', method: 'GET'),
        detail: Endpoint(path: '/', method: 'GET'),
      ),
    );

void main() {
  group('Ánh xạ nav top bar <-> category', () {
    test('Home/Movies/Series map đúng category', () {
      expect(homeCategoryForNavIndex(0), 'Tất Cả');
      expect(homeCategoryForNavIndex(1), 'Phim Lẻ');
      expect(homeCategoryForNavIndex(2), 'Phim Bộ');
    });

    test('Category map ngược đúng tab, chip khác trả -1', () {
      expect(homeNavIndexForCategory('Tất Cả'), 0);
      expect(homeNavIndexForCategory('Phim Lẻ'), 1);
      expect(homeNavIndexForCategory('Phim Bộ'), 2);
      expect(homeNavIndexForCategory('Phim Mới'), -1);
      expect(homeNavIndexForCategory('Hoạt Hình'), -1);
      expect(homeNavIndexForCategory('TV Shows'), -1);
    });
  });

  group('sourceDisplayName', () {
    test('fallback baseUrl khi chưa đặt tên', () {
      expect(sourceDisplayName(_src('a', '')), 'https://a.test');
      expect(sourceDisplayName(_src('b', 'KKPhim')), 'KKPhim');
    });
  });

  group('SourcePickerButton', () {
    testWidgets('hiện tên nguồn đang chọn, bấm mở dropdown đủ nguồn',
        (WidgetTester tester) async {
      final sources = [_src('kk', 'KKPhim'), _src('op', 'OPhim')];
      String? picked;
      var managed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourcePickerButton(
              sources: sources,
              activeSourceId: 'op',
              onSelected: (id) => picked = id,
              onManageSources: () => managed = true,
            ),
          ),
        ),
      );

      expect(find.text('OPhim'), findsOneWidget);
      await tester.tap(find.byType(SourcePickerButton));
      await tester.pumpAndSettle();

      expect(find.text('KKPhim'), findsWidgets);
      expect(find.text('Quản lý nguồn...'), findsOneWidget);

      await tester.tap(find.text('KKPhim').last);
      await tester.pumpAndSettle();
      expect(picked, 'kk');
      expect(managed, isFalse);
    });
  });
}
