import 'package:demo/screens/settings_screen.dart';
import 'package:demo/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget buildScreen() => ChangeNotifierProvider(
      create: (_) => SettingsController(),
      child: const MaterialApp(home: SettingsScreen()),
    );

void main() {
  testWidgets('SettingsScreen should update response time in settings object', (WidgetTester tester) async {
    await tester.pumpWidget(buildScreen());
    final BuildContext context = tester.element(find.byType(SettingsScreen));
    final settings = context.read<SettingsController>();

    final initValue = settings.value.responseDelay;
    await tester.drag(find.byKey(SettingsScreen.responseSliderKey), const Offset(50, 0));
    expect(initValue, isNot(equals(settings.value.responseDelay)));
  });

  testWidgets('SettingsScreen should update batch size in settings object', (WidgetTester tester) async {
    await tester.pumpWidget(buildScreen());
    final BuildContext context = tester.element(find.byType(SettingsScreen));
    final settings = context.read<SettingsController>();

    final initValue = settings.value.batchSize;
    await tester.drag(find.byKey(SettingsScreen.batchSizeSliderKey), const Offset(50, 0));
    expect(initValue, isNot(equals(settings.value.batchSize)));
  });

  testWidgets('SettingsScreen should update loading offset to reload in settings object', (WidgetTester tester) async {
    await tester.pumpWidget(buildScreen());
    final BuildContext context = tester.element(find.byType(SettingsScreen));
    final settings = context.read<SettingsController>();

    final initValue = settings.value.recordsLoadThreshold;
    await tester.drag(find.byKey(SettingsScreen.loadThresholdSliderKey), const Offset(50, 0));
    expect(initValue, isNot(equals(settings.value.recordsLoadThreshold)));
  });

  testWidgets('SettingsScreen should update number exceptions to rise in settings object', (WidgetTester tester) async {
    await tester.pumpWidget(buildScreen());
    final BuildContext context = tester.element(find.byType(SettingsScreen));
    final settings = context.read<SettingsController>();

    final initValue = settings.value.exceptionsToThrow;
    await tester.drag(find.byKey(SettingsScreen.exceptionsToThrowSliderKey), const Offset(50, 0));
    expect(initValue, isNot(equals(settings.value.exceptionsToThrow)));
  });
}
