import 'package:demo/screens/record_edit_screen.dart';
import 'package:demo/screens/settings_screen.dart';
import 'package:demo/settings.dart';
import 'package:demo/widgets/list_status_indicator.dart';
import 'package:demo/widgets/record_teaser.dart';
import 'package:demo/widgets/search_app_bar.dart';
import 'package:demo/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_datasource/mock_datasource.dart';

const queryText = 'qu';
const testText = 'test text';

Future<void> openSettingsScreenTest(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();

  final settingsBtn = find.byKey(ComplexExampleAppBar.openSettingsBtnKey);
  await tester.tap(settingsBtn);
  await tester.pumpAndSettle();

  final settingsScreen = find.byType(SettingsScreen);
  expect(settingsScreen, findsOneWidget);
}

Future<void> createRecordScreenTest(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();

  final firstTileFinder = find.byType(ListTile).first;
  final lastTileText = ((tester.element(firstTileFinder).widget as ListTile).subtitle! as Text).data!;

  final RegExp regExp = RegExp(r'\d+');
  final String weightText = regExp.firstMatch(lastTileText)!.group(0)!;
  final int oldWeight = int.parse(weightText);

  final createRecordBtn = find.byType(FloatingActionButton);
  await tester.tap(createRecordBtn);
  await tester.pumpAndSettle();

  final recordEditScreen = find.byType(RecordEditScreen);
  expect(recordEditScreen, findsOneWidget);

  await tester.enterText(find.byKey(RecordEditScreen.titleFieldKey), testText);
  await tester.enterText(find.byKey(RecordEditScreen.weightFieldKey), (oldWeight + 1).toString());
  await tester.tap(find.byKey(RecordEditScreen.submitBtnKey));

  await tester.pumpAndSettle();

  expect(find.text(testText), findsOneWidget);
}

Future<void> editRecordScreenTest(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();

  final recordTeaser = find.byType(RecordTeaser);
  await tester.tap(recordTeaser.first);
  await tester.pumpAndSettle();

  final recordEditScreen = find.byType(RecordEditScreen);
  expect(recordEditScreen, findsOneWidget);

  final editScreenWidget = recordEditScreen.first.evaluate();
  expect((editScreenWidget.single.widget as RecordEditScreen).record, isNotNull);

  await tester.enterText(find.byKey(RecordEditScreen.titleFieldKey), testText);

  await tester.tap(find.byKey(RecordEditScreen.submitBtnKey));

  await tester.pumpAndSettle();

  expect(find.text(testText), findsOneWidget);
}

Future<void> updateListOnQuery(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());

  final searchBtn = find.byKey(ComplexExampleAppBar.searchBtnKey);
  await tester.tap(searchBtn);
  await tester.pump();

  final queryInput = find.byKey(SearchField.inputQueryKey);
  await tester.enterText(queryInput, queryText);
  await tester.pumpAndSettle(const Duration(seconds: 3)); // If list is short we have to wait for an extra load

  final recordTeaser = find.byType(RecordTeaser);
  final teaserWidget = recordTeaser.evaluate().first.widget as RecordTeaser;
  expect(teaserWidget.record.title.contains(queryText), isTrue);
}

Future<void> loadRecordsTest(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();
  final teasers = find.byType(RecordTeaser);
  final teasersCount = teasers.evaluate().length;
  expect(teasersCount, greaterThan(5));
}

Future<void> loadRecordsOnScrollTest(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();

  final BuildContext context = tester.element(find.byType(Scaffold));
  context.read<SettingsController>().setResponseDelay(1000);

  // First drag
  await tester.scrollUntilVisible(find.byType(ListStatusIndicator), 100, duration: Duration.zero);

  final teasers1 = find.byType(RecordTeaser);
  final lastRecordId = (teasers1.evaluate().last.widget as RecordTeaser).record.id;

  // Wait for loading
  await tester.pumpAndSettle();

  final teasers2 = find.byType(RecordTeaser);
  final lastRecordId2 = (teasers2.evaluate().last.widget as RecordTeaser).record.id;
  expect(lastRecordId, lessThan(lastRecordId2));
}

Future<void> removeRecordIfIdle(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();
  final teasers = find.byType(RecordTeaser);
  final secondTeaser = teasers.at(1);
  final recordToDeleteId = (secondTeaser.evaluate().first.widget as RecordTeaser).record.id;
  final deleteButton = find.descendant(of: secondTeaser, matching: find.byIcon(Icons.delete_outline));
  await tester.tap(deleteButton);
  await tester.pumpAndSettle();

  final teasers2 = find.byType(RecordTeaser);
  final secondTeaser2 = teasers2.at(1);
  final recordToDeleteId2 = (secondTeaser2.evaluate().first.widget as RecordTeaser).record.id;
  expect(recordToDeleteId, isNot(equals(recordToDeleteId2)));
}

Future<void> addRecordIfIdle(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();
  final teasers = find.byType(RecordTeaser);
  final secondTeaser = teasers.at(1);
  final recordToCheck = (secondTeaser.evaluate().first.widget as RecordTeaser).record;

  final BuildContext context = tester.element(secondTeaser);

  await context.read<MockDatabase>().exampleRecordRepository.createRecord(title: testText, weight: recordToCheck.weight - 1);

  await tester.pumpAndSettle();

  final teasers2 = find.byType(RecordTeaser);
  final secondTeaser2 = teasers2.at(1);
  final recordToCheck2 = (secondTeaser2.evaluate().first.widget as RecordTeaser).record;

  expect(recordToCheck2.title, testText);
}

Future<void> updateRecordIfIdle(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();
  final teasers = find.byType(RecordTeaser);
  final secondTeaser = teasers.at(1);
  final recordToUpdate = (secondTeaser.evaluate().first.widget as RecordTeaser).record;

  final BuildContext context = tester.element(secondTeaser);

  await context.read<MockDatabase>().exampleRecordRepository.updateRecord(recordToUpdate.id, title: testText);

  await tester.pumpAndSettle();

  final teasers2 = find.byType(RecordTeaser);
  final secondTeaser2 = teasers2.at(1);
  final recordToCheck2 = (secondTeaser2.evaluate().first.widget as RecordTeaser).record;

  expect(recordToCheck2.title, testText);
}

Future<void> removeRecordAfterLoading(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();

  final BuildContext context = tester.element(find.byType(Scaffold));
  context.read<SettingsController>().setResponseDelay(1500);

  // Scroll to up
  await tester.scrollUntilVisible(find.byType(ListStatusIndicator), 100, duration: Duration.zero);

  final secondTeaser = find.byType(RecordTeaser).at(1);
  final deleteButton = find.descendant(of: secondTeaser, matching: find.byIcon(Icons.delete_outline));
  final recordToCheck = (secondTeaser.evaluate().first.widget as RecordTeaser).record;

  await tester.tap(deleteButton);

  // Loading indicator still should be
  expect(find.byType(ListStatusIndicator), findsOneWidget);

  // It's still loading so teaser should be in list
  await tester.pump(const Duration(milliseconds: 100));
  expect(find.byType(RecordTeaser).evaluate().where((element) => (element.widget as RecordTeaser).record.id == recordToCheck.id), isNotEmpty);

  // Wait until loading indicator disappear
  await tester.pumpAndSettle();
  expect(find.byType(ListStatusIndicator), findsNothing);

  // The teaser shold not be in list
  final recordToCheckId2 = (find.byType(RecordTeaser).at(1).evaluate().first.widget as RecordTeaser).record.id;
  expect(recordToCheck.id, isNot(equals(recordToCheckId2)));
}

Future<void> addRecordAfterLoading(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();

  final BuildContext rootContext = tester.element(find.byType(Scaffold));
  rootContext.read<SettingsController>().setResponseDelay(1000);

  // Scroll to up
  await tester.scrollUntilVisible(find.byType(ListStatusIndicator), 100, duration: Duration.zero);

  // Create a new record, that should appear instead of checked one
  final secondTeaser = find.byType(RecordTeaser).at(1);
  final recordToCheck = (secondTeaser.evaluate().first.widget as RecordTeaser).record;

  final BuildContext teaserContext = tester.element(secondTeaser);

  await teaserContext.read<MockDatabase>().exampleRecordRepository.createRecord(title: testText, weight: recordToCheck.weight - 1);
  await tester.pump();

  // Loading indicator still should be
  expect(find.byType(ListStatusIndicator), findsOneWidget);

  // Wait until loading indicator disappear
  await tester.pumpAndSettle();
  expect(find.byType(ListStatusIndicator), findsNothing);

  // The teaser should be new one before an old
  bool foundNewRecord = false;
  bool secordRecordCorrect = false;
  for (final recordTitle in find.byType(RecordTeaser).evaluate().map((e) => (e.widget as RecordTeaser).record.title)) {
    if (!foundNewRecord && recordTitle == testText) {
      foundNewRecord = true;
    } else if (foundNewRecord) {
      if (recordTitle == recordToCheck.title) {
        secordRecordCorrect = true;
      }
      break;
    }
  }
  expect(foundNewRecord, isTrue);
  expect(secordRecordCorrect, isTrue);
}

Future<void> updateRecordAfterLoading(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();

  final BuildContext rootContext = tester.element(find.byType(Scaffold));
  rootContext.read<SettingsController>().setResponseDelay(1000);

  // Scroll to up
  await tester.scrollUntilVisible(find.byType(ListStatusIndicator), 100, duration: Duration.zero);

  // Update record
  final secondTeaser = find.byType(RecordTeaser).at(1);
  final recordToCheck = (secondTeaser.evaluate().first.widget as RecordTeaser).record;

  final BuildContext teaserContext = tester.element(secondTeaser);

  await teaserContext.read<MockDatabase>().exampleRecordRepository.updateRecord(recordToCheck.id, title: testText);
  await tester.pump();

  // Loading indicator still should be
  expect(find.byType(ListStatusIndicator), findsOneWidget);

  // It's still loading so teaser shold be in list
  await tester.pump(const Duration(milliseconds: 100));
  expect(
      find
          .byType(RecordTeaser)
          .evaluate()
          .map((e) => (e.widget as RecordTeaser).record)
          .where((record) => record.id == recordToCheck.id && record.title == recordToCheck.title),
      isNotEmpty);

  // Wait until loading indicator disappear
  await tester.pumpAndSettle();
  expect(find.byType(ListStatusIndicator), findsNothing);

  // The teaser shold be new one
  expect((find.byType(RecordTeaser).evaluate().map((e) => (e.widget as RecordTeaser).record).where((record) => record.id == recordToCheck.id).first).title,
      testText);
}

Future<void> updateRecordAfterLoadError(WidgetTester tester, Widget Function() builder) async {
  await tester.pumpWidget(builder());
  await tester.pumpAndSettle();

  final BuildContext rootContext = tester.element(find.byType(Scaffold));
  rootContext.read<SettingsController>().setExceptionsToRaise(1);

  // Scroll to up
  await tester.scrollUntilVisible(find.byType(ListStatusIndicator), 100, duration: Duration.zero);
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.refresh), findsOneWidget);

  final teasers = find.byType(RecordTeaser);
  final secondTeaser = teasers.at(1);
  final recordToDeleteId = (secondTeaser.evaluate().first.widget as RecordTeaser).record.id;
  final deleteButton = find.descendant(of: secondTeaser, matching: find.byIcon(Icons.delete_outline));
  await tester.tap(deleteButton);
  await tester.pumpAndSettle();

  final teasers2 = find.byType(RecordTeaser);
  final secondTeaser2 = teasers2.at(1);
  final recordToDeleteId2 = (secondTeaser2.evaluate().first.widget as RecordTeaser).record.id;
  expect(recordToDeleteId, isNot(equals(recordToDeleteId2)));
}
