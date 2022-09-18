import 'package:demo/examples/carousel_slider/carousel_slider_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CarouselSliderExample should display key records cards', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CarouselSliderExample(title: 'CarouselSliderExample', sources: [])));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CarouselCard), findsWidgets);
  });

  testWidgets('CarouselSliderExample should load next chunk of cards', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CarouselSliderExample(title: 'CarouselSliderExample', sources: [])));
    await tester.pumpAndSettle();
    final curcularProgressIndicator = find.byType(CircularProgressIndicator);
    await tester.scrollUntilVisible(curcularProgressIndicator, 200);
    final cardElement = find.ancestor(of: curcularProgressIndicator, matching: find.byType(CarouselCard)).evaluate().first;
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byElementPredicate((element) => element == cardElement), matching: find.byType(Text)), findsOneWidget);
  });
}
