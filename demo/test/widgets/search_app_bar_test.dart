import 'package:demo/widgets/search_app_bar.dart';
import 'package:demo/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SearchAppBar should display query field', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ComplexExampleAppBar(title: 'test', query: '', sources: const [], onChanged: (_) {})));
    await tester.pumpAndSettle();

    final searchBtn = find.byKey(ComplexExampleAppBar.searchBtnKey);
    await tester.tap(searchBtn);
    await tester.pump();

    final searchField = find.byType(SearchField);
    expect(searchField, findsOneWidget);
  });

  testWidgets('SearchAppBar should hide query field by tap on cross', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ComplexExampleAppBar(title: 'test', query: '', sources: const [], onChanged: (_) {})));

    final searchBtn = find.byKey(ComplexExampleAppBar.searchBtnKey);
    await tester.tap(searchBtn);
    await tester.pump();

    final searchField = find.byType(SearchField);
    expect(searchField, findsOneWidget);

    final queryInput = find.byKey(SearchField.inputQueryKey);
    await tester.enterText(queryInput, 'test');
    await tester.pump();

    final clearBtn1 = find.byKey(SearchField.clearBtnKey);
    await tester.tap(clearBtn1);
    await tester.pumpAndSettle();

    final searchField1 = find.byType(SearchField);
    expect(searchField1, findsNothing);
  });

  testWidgets('SearchAppBar should hide query field by tap on back', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ComplexExampleAppBar(title: 'test', query: '', sources: const [], onChanged: (_) {})));

    final backBtn = find.byKey(ComplexExampleAppBar.backBtnKey);
    expect(backBtn, findsNothing);

    final searchBtn = find.byKey(ComplexExampleAppBar.searchBtnKey);
    await tester.tap(searchBtn);
    await tester.pump();

    final searchField = find.byType(SearchField);
    expect(searchField, findsOneWidget);

    final backBtn1 = find.byKey(ComplexExampleAppBar.backBtnKey);
    expect(backBtn1, findsOneWidget);
    await tester.tap(backBtn1);
    await tester.pumpAndSettle();

    final backBtn2 = find.byKey(ComplexExampleAppBar.backBtnKey);
    expect(backBtn2, findsNothing);
  });
}
