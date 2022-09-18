import 'package:demo/examples/async_records_loading/async_records_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RecordsLoadingExample should display list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AsyncRecordsLoadingExample(title: 'RecordsLoadingExample', sources: [])));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);
    expect(tester.widgetList(finder).length, greaterThanOrEqualTo(3));
  });

  testWidgets('RecordsLoadingExample should display list of numbers', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AsyncRecordsLoadingExample(title: 'RecordsLoadingExample', sources: [])));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.byType(ListTile);
    expect(((finder.at(2).evaluate().last.widget as ListTile).title as Text?)?.data, '3');
    expect(((finder.at(3).evaluate().last.widget as ListTile).title as Text?)?.data, '4');
  });
}
