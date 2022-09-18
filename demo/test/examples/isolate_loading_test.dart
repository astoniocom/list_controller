@TestOn('!vm')
import 'package:demo/examples/isolate_loading/isolate_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// https://github.com/flutter/flutter/issues/21093

void main() {
  testWidgets('IsolateLoadingExample should display list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: IsolateLoadingExample(title: 'IsolateLoadingExample', sources: [])));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);
    expect(tester.widgetList(finder).length, greaterThanOrEqualTo(3));
  });

  testWidgets('IsolateLoadingExample should display filtered list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: IsolateLoadingExample(title: 'IsolateLoadingExample', sources: [])));
    final filteringCheckboxFinder = find.byKey(IsolateLoadingExample.filteringCheckboxKey);
    await tester.tap(filteringCheckboxFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);
    expect(finder.evaluate().any((e) => int.parse(((e.widget as ListTile).title! as Text).data!) % 10 == 0), isTrue);
  });

  testWidgets('IsolateLoadingExample should display sorted list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: IsolateLoadingExample(title: 'IsolateLoadingExample', sources: [])));
    final sortingCheckboxFinder = find.byKey(IsolateLoadingExample.sortingCheckboxKey);
    await tester.tap(sortingCheckboxFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);

    int previousValue = -9999;
    for (final elem in finder.evaluate()) {
      final elemValue = int.parse(((elem.widget as ListTile).title! as Text).data!);
      expect(previousValue, lessThan(elemValue));
      previousValue = elemValue;
    }
  });
}
