import 'dart:async';

import 'package:demo/screens/record_edit_screen.dart';
import 'package:demo/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:provider/provider.dart';

Widget buildScreen(MockDatabase db, [ExampleRecord? record]) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsController()),
          Provider.value(value: db),
        ],
        child: Builder(builder: (context) {
          return MaterialApp(
              home: RecordEditScreen(
            record: record,
            settings: context.read<SettingsController>(),
            db: db,
          ));
        }));

void main() {
  testWidgets('RecordEditScreen should autogenerate title', (WidgetTester tester) async {
    final db = MockDatabase();
    await tester.pumpWidget(buildScreen(db));

    final autogenerateIcon = find.bySemanticsLabel('Autogenerate title');
    await tester.tap(autogenerateIcon);

    final titleInput = find.byKey(RecordEditScreen.titleFieldKey);

    final generatedTitle = (titleInput.evaluate().single.widget as TextFormField).controller!.text;
    expect(generatedTitle, isNot(''));

    await tester.tap(autogenerateIcon);

    final generatedTitle2 = (titleInput.evaluate().single.widget as TextFormField).controller!.text;
    expect(generatedTitle, isNot(equals(generatedTitle2)));
  });

  testWidgets('RecordEditScreen should create a new record', (WidgetTester tester) async {
    final db = MockDatabase();
    await tester.pumpWidget(buildScreen(db));

    final autogenerateIcon = find.byKey(RecordEditScreen.autogenTitleBtnKey);
    await tester.tap(autogenerateIcon);

    final weightInput = find.byKey(RecordEditScreen.weightFieldKey);
    await tester.enterText(weightInput, '5');

    final submit = find.byKey(RecordEditScreen.submitBtnKey);

    unawaited(expectLater(
        db.controller.events
            .expand((element) => element)
            .asyncMap((recordEvent) => db.exampleRecordRepository.getRecordByPk(recordEvent.id))
            .map((record) => record.weight),
        emits(5)));

    await tester.tap(submit);
  });

  testWidgets('RecordEditScreen should update existing record', (WidgetTester tester) async {
    final db = MockDatabase();
    final testRecord = await db.exampleRecordRepository.getRecordByPk(10);
    await tester.pumpWidget(buildScreen(db, testRecord));

    final autogenerateIcon = find.byKey(RecordEditScreen.autogenTitleBtnKey);
    await tester.tap(autogenerateIcon);

    final weightInput = find.byKey(RecordEditScreen.weightFieldKey);
    await tester.enterText(weightInput, '${testRecord.weight + 1}');

    final stream = db.controller.events.expand((element) => element).asyncMap((recordEvent) => db.exampleRecordRepository.getRecordByPk(recordEvent.id));
    unawaited(expectLater(stream.map((record) => record.weight), emits(testRecord.weight + 1)));
    unawaited(expectLater(stream.map((record) => record.title == testRecord.title), emits(false)));

    final submit = find.byKey(RecordEditScreen.submitBtnKey);
    await tester.tap(submit);
  });

  testWidgets('RecordEditScreen should display record does not exist snackbar', (WidgetTester tester) async {
    final db = MockDatabase();
    final testRecord = await db.exampleRecordRepository.getRecordByPk(10);
    await tester.pumpWidget(buildScreen(db, testRecord));

    await db.exampleRecordRepository.deleteRecord(testRecord.id);

    final submit = find.byKey(RecordEditScreen.submitBtnKey);
    await tester.tap(submit);
    await tester.pump();

    final snackbar = find.byKey(RecordEditScreen.recordDeosNotExistSnackbarKey);
    expect(snackbar, findsOneWidget);
  });

  testWidgets('RecordEditScreen should display message is not unique snackbar', (WidgetTester tester) async {
    final db = MockDatabase();
    final testRecord = await db.exampleRecordRepository.getRecordByPk(20);
    await tester.pumpWidget(buildScreen(db));

    final autogenerateIcon = find.byKey(RecordEditScreen.autogenTitleBtnKey);
    await tester.tap(autogenerateIcon);

    final weightInput = find.byKey(RecordEditScreen.weightFieldKey);
    await tester.enterText(weightInput, testRecord.weight.toString());

    final submit = find.byKey(RecordEditScreen.submitBtnKey);
    await tester.tap(submit);
    await tester.pump();

    final snackbar = find.byKey(RecordEditScreen.weightNotUniqueSnackbarKey);
    expect(snackbar, findsOneWidget);
  });
}
