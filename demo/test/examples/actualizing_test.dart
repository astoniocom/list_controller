import 'package:demo/examples/actualizing/actualizing_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ActualizingExample should create and diaplay a new record', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ActualizingExample(title: 'ActualizingExample', sources: const [])));
    await tester.pump();
    final secondTileFinder = find.byType(ListTile).at(1);
    final secondTileText = ((tester.element(secondTileFinder).widget as ListTile).title! as Text).data;

    final firstTileFinder = find.byType(ListTile).first;
    final createButtonFinder = find.descendant(of: firstTileFinder, matching: find.byIcon(Icons.new_label));

    await tester.tap(createButtonFinder);

    await tester.pump();

    final secondTileFinder2 = find.byType(ListTile).at(1);
    final secondTileText2 = ((tester.element(secondTileFinder2).widget as ListTile).title! as Text).data;

    expect(secondTileText2, isNot(secondTileText));
  });

  testWidgets('ActualizingExample should update a record', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ActualizingExample(title: 'ActualizingExample', sources: const [])));
    await tester.pump();
    final secondTileFinder = find.byType(ListTile).at(1);
    final secondTileText = ((tester.element(secondTileFinder).widget as ListTile).title! as Text).data;
    final editButtonFinder = find.descendant(of: secondTileFinder, matching: find.byIcon(Icons.edit));

    await tester.tap(editButtonFinder);

    await tester.pump();

    final secondTileFinder2 = find.byType(ListTile).at(1);
    final secondTileText2 = ((tester.element(secondTileFinder2).widget as ListTile).title! as Text).data;

    expect(secondTileText2, isNot(secondTileText));
  });

  testWidgets('ActualizingExample should delete a record', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ActualizingExample(title: 'ActualizingExample', sources: const [])));
    await tester.pump();
    final secondTileFinder = find.byType(ListTile).at(1);
    final secondTileText = ((tester.element(secondTileFinder).widget as ListTile).title! as Text).data;
    final createButtonFinder = find.descendant(of: secondTileFinder, matching: find.byIcon(Icons.delete));

    await tester.tap(createButtonFinder);

    await tester.pump();

    final secondTileFinder2 = find.byType(ListTile).at(1);
    final secondTileText2 = ((tester.element(secondTileFinder2).widget as ListTile).title! as Text).data;

    expect(secondTileText2, isNot(secondTileText));
  });
}
