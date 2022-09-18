import 'package:demo/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SearchField should call onChanged when edit', (WidgetTester tester) async {
    String testValue = '';
    await tester.pumpWidget(MaterialApp(home: Material(child: SearchField(onChanged: (value) => testValue = value, query: '', onClear: () {}))));

    final queryInput = find.byKey(SearchField.inputQueryKey);
    await tester.enterText(queryInput, 'test');
    expect(testValue, 'test');
  });

  testWidgets('SearchField should call onClear', (WidgetTester tester) async {
    bool clearWasCalled = false;
    await tester.pumpWidget(MaterialApp(home: Material(child: SearchField(onChanged: (_) {}, query: '', onClear: () => clearWasCalled = true))));

    final clearBtn = find.byKey(SearchField.clearBtnKey);
    expect(clearBtn, findsNothing);

    final queryInput = find.byKey(SearchField.inputQueryKey);
    await tester.enterText(queryInput, 'test');
    await tester.pump();

    final clearBtn1 = find.byKey(SearchField.clearBtnKey);
    await tester.tap(clearBtn1);

    expect(clearWasCalled, true);
  });
}
