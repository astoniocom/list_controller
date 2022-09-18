import 'package:demo/screens/record_edit_screen.dart';
import 'package:demo/settings.dart';
import 'package:demo/widgets/record_teaser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('RecordTeaser display', (WidgetTester tester) async {
    const mockRecord = ExampleRecord(id: 1, title: 'test title', weight: 15);
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider(create: (context) => MockDatabase()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: const MaterialApp(home: Material(child: RecordTeaser(mockRecord))),
    ));
    final title = find.text('test title');
    final weight = find.text('weight: 15');
    expect(title, findsOneWidget);
    expect(weight, findsOneWidget);
  });

  testWidgets('RecordTeaser opens record edit screen on tap',
      (WidgetTester tester) async {
    const mockRecord = ExampleRecord(id: 1, title: 'test title', weight: 15);
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider(create: (context) => MockDatabase()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: const MaterialApp(home: Material(child: RecordTeaser(mockRecord))),
    ));
    final teaser = find.byType(RecordTeaser);
    await tester.tap(teaser);
    await tester.pumpAndSettle();
    final editScreen = find.byType(RecordEditScreen);
    expect(editScreen, findsOneWidget);
  });

  testWidgets('RecordTeaser deletes record on delete icon tap',
      (WidgetTester tester) async {
    final db = MockDatabase();
    final record = await db.exampleRecordRepository.getRecordByPk(11);

    await tester.pumpWidget(MultiProvider(providers: [
      Provider.value(value: db),
      ChangeNotifierProvider(create: (_) => SettingsController()),
    ], child: MaterialApp(home: Material(child: RecordTeaser(record)))));
    final teaser = find.byType(RecordTeaser);
    final deleteButton = find.descendant(
        of: teaser, matching: find.byIcon(Icons.delete_outline));
    await tester.tap(deleteButton);
    await tester.pump();
    expect(() => db.exampleRecordRepository.getRecordByPk(11),
        throwsA(const TypeMatcher<RecordDoesNotExist>()));
  });
}
