import 'package:demo/examples/complex_value_notifier_list/complex_value_notifier_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common_list_tests.dart';

Widget buildList() => const MaterialApp(
        home: Material(
      child: ComplexValueNotifierListExample(title: 'ComplexValueNotifierListExample', sources: []),
    ));

void main() {
  testWidgets('ComplexValueNotifierListExample should open settings screen', (WidgetTester tester) async => openSettingsScreenTest(tester, buildList));

  testWidgets('ComplexValueNotifierListExample should open create record screen and create record',
      (WidgetTester tester) async => createRecordScreenTest(tester, buildList));

  testWidgets('ComplexValueNotifierListExample should open edit record screen and update record',
      (WidgetTester tester) async => editRecordScreenTest(tester, buildList));

  testWidgets('ComplexValueNotifierListExample should update list on query', (WidgetTester tester) async => updateListOnQuery(tester, buildList));

  testWidgets('ComplexValueNotifierListExample should load records', (WidgetTester tester) async => loadRecordsTest(tester, buildList));

  testWidgets(
      'ComplexValueNotifierListExample should load records on scroll to down', (WidgetTester tester) async => loadRecordsOnScrollTest(tester, buildList));

  testWidgets(
      'ComplexValueNotifierListExample should remove record if it is not loading', (WidgetTester tester) async => removeRecordIfIdle(tester, buildList));

  testWidgets('ComplexValueNotifierListExample should add record if it is not loading', (WidgetTester tester) async => addRecordIfIdle(tester, buildList));

  testWidgets(
      'ComplexValueNotifierListExample should update record if it is not loading', (WidgetTester tester) async => updateRecordIfIdle(tester, buildList));

  testWidgets('ComplexValueNotifierListExample should remove record after the list is loaded',
      (WidgetTester tester) async => removeRecordAfterLoading(tester, buildList));

  testWidgets(
      'ComplexValueNotifierListExample should add record after the list is loaded', (WidgetTester tester) async => addRecordAfterLoading(tester, buildList));

  testWidgets('ComplexValueNotifierListExample should update record after the list is loaded',
      (WidgetTester tester) async => updateRecordAfterLoading(tester, buildList));

  testWidgets('ComplexValueNotifierListExample should update record after unsuccessful loading operation',
      (WidgetTester tester) async => updateRecordAfterLoadError(tester, buildList));
}
