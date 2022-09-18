import 'package:demo/examples/keyset_pagination_value_notifier_list/keyset_pagination_value_notifier_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('KeysetPaginationValueNotifierListExample should display list and load next page after scroll', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: KeysetPaginationValueNotifierListExample(title: 'KeysetPaginationValueNotifierListExample', sources: [])));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(CircularProgressIndicator), 200, duration: Duration.zero);
    final lastWeight = int.parse(((tester.widgetList(find.byType(ListTile)).last as ListTile).title! as Text).data!);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(CircularProgressIndicator), 200, duration: Duration.zero);
    final lastWeight2 = int.parse(((tester.widgetList(find.byType(ListTile)).last as ListTile).title! as Text).data!);
    expect(lastWeight2, greaterThan(lastWeight));
    await tester.pumpAndSettle();
  });
}
