import 'package:demo/widgets/list_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_controller/list_controller.dart';

void main() {
  testWidgets('ListStatusIndicator indicates loading', (WidgetTester tester) async {
    await tester.pumpWidget(ListStatusIndicator(listState: ListState(stage: ListStage.loading(), query: null)));
    final loader = find.byType(CircularProgressIndicator);
    expect(loader, findsOneWidget);
  });
  testWidgets('ListStatusIndicator indicates error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ListStatusIndicator(listState: ListState(stage: ListStage.error(), query: null))));
    final loader = find.text('Loading Error');
    expect(loader, findsOneWidget);
  });

  testWidgets('ListStatusIndicator indicates no results', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ListStatusIndicator(listState: ListState(records: const [], stage: ListStage.complete(), query: null))));
    final loader = find.text('No records to display');
    expect(loader, findsOneWidget);
  });

  testWidgets('ListStatusIndicator try again callback', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Material(
            child: ListStatusIndicator(listState: ListState(stage: ListStage.error(), query: null), onRepeat: () => print('repeat'))))); // ignore: avoid_print
    final repeatButton = find.byIcon(Icons.refresh);
    await expectLater(() => tester.tap(repeatButton), prints('repeat\n'));
  });
}
