import 'package:demo/examples/huge_list/huge_list_controller.dart';
import 'package:demo/examples/huge_list/huge_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HugeListExample should display list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HugeListExample(title: 'HugeListExample', sources: [])));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('HugeListExample should load a chunk of records', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HugeListExample(title: 'HugeListExample', sources: [])));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byKey(const ValueKey('Shimmer ${pageSize + 1}')).hitTestable(), 200);

    await tester.pumpAndSettle();

    expect(find.text('Loading...'), findsNothing);
  });

  testWidgets('HugeListExample should display filtered list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HugeListExample(title: 'HugeListExample', sources: [])));
    await tester.pumpAndSettle();
    final filteringCheckboxFinder = find.byKey(HugeListExample.filteringCheckboxKey);
    await tester.tap(filteringCheckboxFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);
    expect(
        finder.evaluate().any((e) {
          final itemNumber = (((e.widget as ListTile).title! as Text).data!).replaceFirst('Item ', '');
          return int.parse(itemNumber) % 10 == 0;
        }),
        isTrue);
  });

  testWidgets('HugeListExample should display sorted list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HugeListExample(title: 'HugeListExample', sources: [])));
    await tester.pumpAndSettle();
    final sortingCheckboxFinder = find.byKey(HugeListExample.sortingCheckboxKey);
    await tester.tap(sortingCheckboxFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);

    int previousValue = 999999;
    for (final elem in finder.evaluate()) {
      final itemNumber = (((elem.widget as ListTile).title! as Text).data!).replaceFirst('Item ', '');
      final elemValue = int.parse(itemNumber);
      expect(previousValue, greaterThan(elemValue));
      previousValue = elemValue;
    }
  });
}
