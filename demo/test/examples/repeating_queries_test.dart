@Timeout(Duration(seconds: 2))
library repeating_queries_test;

import 'package:demo/examples/repeating_queries/repeating_queries_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('QueriesRepeatingExample should repeat list loading when repeat button is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RepeatingQueriesExample(title: 'QueriesRepeatingExample', sources: [])));
    await tester.pumpAndSettle();

    int repeatingCount = 0;

    Future<void> repeatFinder() async {
      while (true) {
        final repeatBtnFinder = find.byKey(RepeatingQueriesExample.repeatButtonKey);
        if (tester.widgetList(repeatBtnFinder).isNotEmpty) {
          repeatingCount++;
          await tester.tap(repeatBtnFinder);
          await tester.pumpAndSettle();
        } else {
          break;
        }
      }
    }

    await repeatFinder();

    for (int i = 0; i <= 3; i++) {
      await tester.scrollUntilVisible(find.byType(CircularProgressIndicator), 200);
      await tester.pumpAndSettle();
      await repeatFinder();
    }

    expect(repeatingCount, greaterThan(0));
  });
}
