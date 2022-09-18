import 'package:demo/examples/hot_huge_list/hot_huge_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HotHugeListExample should display list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HotHugeListExample(title: 'HotHugeListExample', sources: [])));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('HotHugeListExample should load a chunk of records', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HotHugeListExample(title: 'HotHugeListExample', sources: [])));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byKey(const ValueKey('Shimmer 30')).hitTestable(), 200);

    await tester.pumpAndSettle();

    expect(find.text('Loading...'), findsNothing);
  });

  testWidgets('HotHugeListExample should update title when the edit icon is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HotHugeListExample(title: 'HotHugeListExample', sources: [])));
    await tester.pumpAndSettle();

    final secondTileFinder = find.byType(ListTile).at(1);
    final secondTileText = ((tester.element(secondTileFinder).widget as ListTile).title! as Text).data;
    final editButtonFinder = find.descendant(of: secondTileFinder, matching: find.byIcon(Icons.edit));

    await tester.tap(editButtonFinder);

    await tester.pump();

    final secondTileFinder2 = find.byType(ListTile).at(1);
    final secondTileText2 = ((tester.element(secondTileFinder2).widget as ListTile).title! as Text).data;

    expect(secondTileText2, isNot(secondTileText));
  });
}
