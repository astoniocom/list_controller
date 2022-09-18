import 'package:demo/examples/record_tracking/record_tracking_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RecordsTrackingExample should reorder records in list after tapping on one of them', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecordsTrackingExample(title: 'RecordsTrackingExample', sources: [])));
    final lastTileFinder = find.byType(ListTile).last;
    final lastTileText = ((tester.element(lastTileFinder).widget as ListTile).title! as Text).data;
    await tester.tap(lastTileFinder);
    await tester.pumpAndSettle();
    final firstTileFinder = find.byType(ListTile).first;
    final firstTileText = ((tester.element(firstTileFinder).widget as ListTile).title! as Text).data;
    expect(firstTileText, lastTileText);
  });
}
