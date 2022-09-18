import 'package:demo/examples/keyset_pagination_statefull_widget/keyset_pagination_statefull_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('KeysetPaginationStatefullWidgetExample should display list and load next page after scroll', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: KeysetPaginationStatefullWidgetExample(title: 'KeysetPaginationStatefullWidgetExample', sources: [])));
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
