import 'package:demo/examples/complex_bloc_list/complex_bloc_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common_list_tests.dart';

Widget buildList() => const MaterialApp(
        home: Material(
      child: ComplexBlocListExample(title: 'ComplexBlocListExample', sources: []),
    ));

void main() {
  testWidgets('ComplexBlocListExample should open settings screen', (WidgetTester tester) => openSettingsScreenTest(tester, buildList));

  testWidgets(
      'ComplexBlocListExample should open create record screen and create record', (WidgetTester tester) => createRecordScreenTest(tester, buildList));

  testWidgets(
      'ComplexBlocListExample should open edit record screen and update record', (WidgetTester tester) => editRecordScreenTest(tester, buildList));

  testWidgets('ComplexBlocListExample should update list on query', (WidgetTester tester) => updateListOnQuery(tester, buildList));

  testWidgets('ComplexBlocListExample should load records', (WidgetTester tester) => loadRecordsTest(tester, buildList));

  testWidgets('ComplexBlocListExample should load records on scroll to down', (WidgetTester tester) => loadRecordsOnScrollTest(tester, buildList));

  testWidgets('ComplexBlocListExample should remove record if it is not loading', (WidgetTester tester) => removeRecordIfIdle(tester, buildList));

  testWidgets('ComplexBlocListExample should add record if it is not loading', (WidgetTester tester) => addRecordIfIdle(tester, buildList));

  testWidgets('ComplexBlocListExample should update record if it is not loading', (WidgetTester tester) => updateRecordIfIdle(tester, buildList));

  testWidgets(
      'ComplexBlocListExample should remove record after the list is loaded', (WidgetTester tester) => removeRecordAfterLoading(tester, buildList));

  testWidgets('ComplexBlocListExample should add record after the list is loaded', (WidgetTester tester) => addRecordAfterLoading(tester, buildList));

  testWidgets(
      'ComplexBlocListExample should update record after the list is loaded', (WidgetTester tester) => updateRecordAfterLoading(tester, buildList));

  testWidgets('ComplexBlocListExample should update record after unsuccessful loading operation',
      (WidgetTester tester) => updateRecordAfterLoadError(tester, buildList));
}
