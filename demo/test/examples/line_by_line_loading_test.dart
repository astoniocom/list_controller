import 'package:demo/examples/line_by_line_loading/line_by_line_loading_list_controller.dart';
import 'package:demo/examples/line_by_line_loading/line_by_line_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LineByLineLoadingExample should load the list line by line', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LineByLineLoadingExample(title: 'LineByLineLoadingExample', sources: [])));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    expect(find.byType(ListTile), findsNothing);

    await tester.pump(LineByLineLoadingListController.loadingDelay);
    expect(find.byType(ListTile), findsOneWidget);

    await tester.pump(LineByLineLoadingListController.loadingDelay);
    expect(find.byType(ListTile), findsNWidgets(2));

    await tester.pumpAndSettle();
  });
}
