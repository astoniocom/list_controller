import 'package:demo/examples/filtering_keyset_pagination_value_notifier_list/filtering_keyset_pagination_value_notifier_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FilteringKeysetPaginationValueNotifierListExample should display list and load next page after scroll', (WidgetTester tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: FilteringKeysetPaginationValueNotifierListExample(title: 'FilteringKeysetPaginationValueNotifierListExample', sources: [])));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(CircularProgressIndicator), 200, duration: Duration.zero);
    final lastWeight = int.parse(((tester.widgetList(find.byType(ListTile)).last as ListTile).title! as Text).data!);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(CircularProgressIndicator), 200, duration: Duration.zero);
    final lastWeight2 = int.parse(((tester.widgetList(find.byType(ListTile)).last as ListTile).title! as Text).data!);
    expect(lastWeight2, greaterThan(lastWeight));
    await tester.pumpAndSettle();
  });

  testWidgets('FilteringKeysetPaginationValueNotifierListExample should display filtered list', (WidgetTester tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: FilteringKeysetPaginationValueNotifierListExample(title: 'FilteringKeysetPaginationValueNotifierListExample', sources: [])));
    final filteringCheckboxFinder = find.byKey(FilteringKeysetPaginationValueNotifierListExample.filteringCheckboxKey);
    await tester.tap(filteringCheckboxFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);
    expect(finder.evaluate().any((e) => int.parse(((e.widget as ListTile).title! as Text).data!) % 10 == 0), isTrue);
  });
}
