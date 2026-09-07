import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wardrobe/app/app.dart';

void main() {
  testWidgets(
    'Wardrobe app smoke test',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'dark_mode_enabled': false,
      });

      final preferences =
      await SharedPreferences.getInstance();

      await tester.pumpWidget(
        WardrobeApp(
          preferences: preferences,
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('我的衣柜'),
        findsOneWidget,
      );

      expect(
        find.text('搜索衣物'),
        findsOneWidget,
      );

      expect(
        find.text('全部'),
        findsOneWidget,
      );

      expect(
        find.text('羽绒服'),
        findsOneWidget,
      );

      expect(
        find.text('裤子'),
        findsOneWidget,
      );

      expect(
        find.text('黑色羽绒服'),
        findsOneWidget,
      );

      expect(
        find.text('灰色卫衣'),
        findsOneWidget,
      );
    },
  );
}