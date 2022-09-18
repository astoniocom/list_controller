import 'package:demo/examples/filtering_sorting/filtering_sorting_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FilteringSortingExample should display list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FilteringSortingExample(title: 'FilteringSortingExample', sources: [])));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);
    expect(tester.widgetList(finder).length, greaterThanOrEqualTo(3));
  });

  testWidgets('FilteringSortingExample should display filtered list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FilteringSortingExample(title: 'FilteringSortingExample', sources: [])));
    final filteringCheckboxFinder = find.byKey(FilteringSortingExample.filteringCheckboxKey);
    await tester.tap(filteringCheckboxFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);
    expect(finder.evaluate().any((e) => int.parse(((e.widget as ListTile).title! as Text).data!) % 10 == 0), isTrue);
  });

  testWidgets('FilteringSortingExample should display sorted list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FilteringSortingExample(title: 'FilteringSortingExample', sources: [])));
    final sortingCheckboxFinder = find.byKey(FilteringSortingExample.sortingCheckboxKey);
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
