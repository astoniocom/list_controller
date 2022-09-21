import 'package:demo/examples/animated_list/animated_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AnimatedListExample should create and diaplay a new record', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AnimatedListExample(title: 'AnimatedListExample', sources: const [])));
    await tester.pumpAndSettle();
    final secondTileFinder = find.byType(ListTile).at(1);
    final secondTileText = ((tester.element(secondTileFinder).widget as ListTile).title! as Text).data;

    final firstTileFinder = find.byType(ListTile).first;
    final createButtonFinder = find.descendant(of: firstTileFinder, matching: find.byIcon(Icons.new_label));

    await tester.tap(createButtonFinder);

    await tester.pumpAndSettle();

    final secondTileFinder2 = find.byType(ListTile).at(1);
    final secondTileText2 = ((tester.element(secondTileFinder2).widget as ListTile).title! as Text).data;

    expect(secondTileText2, isNot(secondTileText));
  });

  testWidgets('AnimatedListExample should update a record', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AnimatedListExample(title: 'AnimatedListExample', sources: const [])));
    await tester.pumpAndSettle();
    final secondTileFinder = find.byType(ListTile).at(1);
    final secondTileText = ((tester.element(secondTileFinder).widget as ListTile).title! as Text).data;
    final editButtonFinder = find.descendant(of: secondTileFinder, matching: find.byIcon(Icons.edit));

    await tester.tap(editButtonFinder);

    await tester.pumpAndSettle();

    final secondTileFinder2 = find.byType(ListTile).at(1);
    final secondTileText2 = ((tester.element(secondTileFinder2).widget as ListTile).title! as Text).data;

    expect(secondTileText2, isNot(secondTileText));
  });

  testWidgets('AnimatedListExample should delete a record', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AnimatedListExample(title: 'AnimatedListExample', sources: const [])));
    await tester.pumpAndSettle();
    final secondTileFinder = find.byType(ListTile).at(1);
    final secondTileText = ((tester.element(secondTileFinder).widget as ListTile).title! as Text).data;
    final createButtonFinder = find.descendant(of: secondTileFinder, matching: find.byIcon(Icons.delete));

    await tester.tap(createButtonFinder);

    await tester.pumpAndSettle();

    final secondTileFinder2 = find.byType(ListTile).at(1);
    final secondTileText2 = ((tester.element(secondTileFinder2).widget as ListTile).title! as Text).data;

    expect(secondTileText2, isNot(secondTileText));
  });
}
