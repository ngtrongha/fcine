import 'package:fcine/presentation/widgets/desktop_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DesktopTitleBar hiện logo, tên app và 3 nút cửa sổ',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Column(children: [DesktopTitleBar()])),
      ),
    );
    await tester.pump();

    expect(find.text('F-Cine'), findsOneWidget);
    expect(find.byTooltip('Thu nhỏ'), findsOneWidget);
    // Tùy trạng thái maximize: 'Phóng to' hoặc 'Khôi phục'.
    expect(
      find.byTooltip('Phóng to').evaluate().isNotEmpty ||
          find.byTooltip('Khôi phục').evaluate().isNotEmpty,
      isTrue,
    );
    expect(find.byTooltip('Đóng'), findsOneWidget);
  });
}
