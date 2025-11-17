import 'package:demo/examples/complex_bidirectional_bloc_list/complex_bidirectional_bloc_list_view.dart';
import 'package:demo/widgets/list_status_indicator.dart';
import 'package:demo/widgets/record_teaser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common_list_tests.dart';

Widget buildList() => const MaterialApp(
        home: Material(
      child: ComplexBidirectionalBlocListExample(title: 'ComplexBidirectionalBlocListExample', sources: []),
    ));

void main() {
  testWidgets('ComplexBidirectionalBlocListExample should open settings screen', (WidgetTester tester) => openSettingsScreenTest(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should open create record screen and create record',
      (WidgetTester tester) => createRecordScreenTest(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should open edit record screen and update record',
      (WidgetTester tester) => editRecordScreenTest(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should update list on query', (WidgetTester tester) => updateListOnQuery(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should load records', (WidgetTester tester) => loadRecordsTest(tester, buildList));

  testWidgets(
      'ComplexBidirectionalBlocListExample should load records on scroll to down', (WidgetTester tester) => loadRecordsOnScrollTest(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should load records on scroll to up', (WidgetTester tester) async {
    await tester.pumpWidget(buildList());
    await tester.pumpAndSettle();

    // First drag
    final teasers = find.byType(RecordTeaser);
    await tester.drag(teasers.at(1), const Offset(0, 30000));
    await tester.pump();
    final teasers1 = find.byType(RecordTeaser);
    final lastRecordId = (teasers1.evaluate().first.widget as RecordTeaser).record.id;

    // Wait for loading
    await tester.pumpAndSettle();

    // Second drag
    await tester.drag(teasers1.at(1), const Offset(0, 30000));
    await tester.pump();
    final teasers2 = find.byType(RecordTeaser);
    final lastRecordId2 = (teasers2.evaluate().first.widget as RecordTeaser).record.id;
    expect(lastRecordId, greaterThan(lastRecordId2));

    // Wait for loading
    await tester.pumpAndSettle();
  });

  testWidgets(
      'ComplexBidirectionalBlocListExample should remove record if it is not loading', (WidgetTester tester) => removeRecordIfIdle(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should add record if it is not loading', (WidgetTester tester) => addRecordIfIdle(tester, buildList));

  testWidgets(
      'ComplexBidirectionalBlocListExample should update record if it is not loading', (WidgetTester tester) => updateRecordIfIdle(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should remove record after the list is loaded',
      (WidgetTester tester) => removeRecordAfterLoading(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should add record after the list is loaded',
      (WidgetTester tester) => addRecordAfterLoading(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should update record after the list is loaded',
      (WidgetTester tester) => updateRecordAfterLoading(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should update record after unsuccessful loading operation',
      (WidgetTester tester) => updateRecordAfterLoadError(tester, buildList));

  testWidgets('ComplexBidirectionalBlocListExample should remove records from list if storeSize overwhelmed', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Material(
      child: ComplexBidirectionalBlocListExample(
        title: 'ComplexBidirectionalBlocListExample',
        sources: [],
        storeSize: 60,
      ),
    )));
    await tester.pumpAndSettle();

    final teasers = find.byType(RecordTeaser);
    final secondTeaser = teasers.at(0);
    final firstRecordId = (secondTeaser.evaluate().first.widget as RecordTeaser).record.id;

    await tester.scrollUntilVisible(find.byType(ListStatusIndicator), 100, duration: Duration.zero);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(ListStatusIndicator), 100, duration: Duration.zero);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(ListStatusIndicator), 100, duration: Duration.zero);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byType(ListStatusIndicator), -100, duration: Duration.zero);
    final teasers2 = find.byType(RecordTeaser);
    final secondTeaser2 = teasers2.at(0);
    final firstRecordId2 = (secondTeaser2.evaluate().first.widget as RecordTeaser).record.id;

    await tester.pumpAndSettle();

    expect(firstRecordId, lessThan(firstRecordId2));
  });
}
