import 'package:demo/examples_db.dart';
import 'package:demo/main.dart';
import 'package:demo/widgets/source_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_with_codeview/widget_with_codeview.dart';

Widget buildScreen() => ExampleApp(examples: examples);

void main() {
  testWidgets('HomeScreen should display list of examples', (WidgetTester tester) async {
    await tester.pumpWidget(buildScreen());
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('HomeScreen should open an example after tapping on example item and code after tapping of code item', (WidgetTester tester) async {
    await tester.pumpWidget(buildScreen());

    final finder = find.byType(ListTile).hitTestable();

    var itemsCount = finder.evaluate().length;
    Widget? lastTestedWidget;

    for (int i = 0; i < itemsCount; i++) {
      final element = finder.at(i).evaluate();

      final containsIsolate = ((element.first.widget as ListTile).title! as Text).data!.contains('Isolate');
      if (element.first.widget != lastTestedWidget && !containsIsolate) {
        await tester.tap(finder.at(i));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Back'), findsOneWidget);

        final sourceButton = find.byType(SourceButton);
        expect(sourceButton, findsOneWidget);
        await tester.tap(sourceButton);
        await tester.pumpAndSettle();
        final codeMenuItems = find.byType(PopupMenuItem<String>);
        final codeMenuItemsCount = codeMenuItems.evaluate().length;

        if (codeMenuItemsCount == 0) {
          expect(find.byType(WidgetWithCodeView), findsOneWidget);
          await tester.pageBack();
          await tester.pumpAndSettle();
        } else {
          for (int m = 0; m < codeMenuItemsCount; m++) {
            if (m > 0) {
              await tester.tap(sourceButton);
              await tester.pumpAndSettle();
            }
            final menuItem = codeMenuItems.at(m);
            await tester.tap(menuItem);
            await tester.pumpAndSettle();
            expect(find.byType(WidgetWithCodeView), findsOneWidget);
            await tester.pageBack();
            await tester.pumpAndSettle();
          }
        }

        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      lastTestedWidget = element.first.widget;

      if (i == 0) {
        final t1 = finder.at(0).evaluate().first.widget;
        for (int a = 0; a < 20; a++) {
          await tester.drag(find.byType(Scrollable), const Offset(0.0, -56));
          await tester.pump();
          final t2 = finder.at(0).evaluate().first.widget;

          if (t1 != t2) {
            i = -1;
            break;
          }
        }
      }

      itemsCount = finder.evaluate().length;
    }
  });

  testWidgets('HomeScreen should open an example after tapping on example and close it without errors', (WidgetTester tester) async {
    await tester.pumpWidget(buildScreen());

    final finder = find.byType(ListTile).hitTestable();

    var itemsCount = finder.evaluate().length;
    Widget? lastTestedWidget;

    for (int i = 0; i < itemsCount; i++) {
      final element = finder.at(i).evaluate();

      final containsIsolate = ((element.first.widget as ListTile).title! as Text).data!.contains('Isolate');
      if (element.first.widget != lastTestedWidget && !containsIsolate) {
        // print((element.first.widget as ListTile).title);
        await tester.tap(finder.at(i));
        await tester.pumpAndSettle();

        expect(find.byTooltip('Back'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      lastTestedWidget = element.first.widget;

      if (i == 0) {
        final t1 = finder.at(0).evaluate().first.widget;
        for (int a = 0; a < 20; a++) {
          await tester.drag(find.byType(Scrollable), const Offset(0.0, -56));
          await tester.pump();
          final t2 = finder.at(0).evaluate().first.widget;

          if (t1 != t2) {
            i = -1;
            break;
          }
        }
      }

      itemsCount = finder.evaluate().length;
    }
  });
}
