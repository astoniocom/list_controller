import 'package:demo/examples/offset_pagination_splitted_list/offset_pagination_splitted_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OffsetPaginationSplittedListExample should display list', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: OffsetPaginationSplittedListExample(title: 'OffsetPaginationSplittedListExample', sources: const [])));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('OffsetPaginationSplittedListExample should switch to another page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: OffsetPaginationSplittedListExample(title: 'OffsetPaginationSplittedListExample', sources: const [])));
    await tester.pumpAndSettle();
    final firstTitle1 = ((tester.widgetList(find.byType(ListTile)).last as ListTile).title! as Text).data!;
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    final firstTitle2 = ((tester.widgetList(find.byType(ListTile)).last as ListTile).title! as Text).data!;
    expect(find.byType(ListTile), findsWidgets);
    expect(firstTitle1, isNot(firstTitle2));
  });
}
