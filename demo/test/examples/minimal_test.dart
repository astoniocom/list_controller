import 'package:demo/examples/basic/basic_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BasicExample should display list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BasicExample(title: 'BasicExample', sources: [])));
    final finder = find.byType(ListTile);
    expect(tester.widgetList(finder).length, greaterThanOrEqualTo(3));
  });

  testWidgets('BasicExample should display list of numbers', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BasicExample(title: 'BasicExample', sources: [])));
    final finder = find.byType(ListTile);

    expect(((finder.at(2).evaluate().last.widget as ListTile).title as Text?)?.data, '3');
    expect(((finder.at(3).evaluate().last.widget as ListTile).title as Text?)?.data, '4');
  });
}
