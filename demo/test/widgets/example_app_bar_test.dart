import 'package:demo/models.dart';
import 'package:demo/screens/code_view_screen.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:demo/widgets/source_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('ExampleAppBar should display code preview screen', (WidgetTester tester) async {
    late final GoRouter router = GoRouter(
      initialLocation: '/test',
      routes: <GoRoute>[
        GoRoute(
          path: '/test',
          builder: (BuildContext context, GoRouterState state) => const ExampleAppBar(title: 'test', sources: [
            SourceFile(title: 'Test', codeFile: ''),
            SourceFile(title: 'Test2', codeFile: ''),
          ]),
          routes: [
            GoRoute(
              path: 'code/test',
              builder: (BuildContext context, GoRouterState state) => const CodeViewScreen(filePath: 'no'),
            )
          ],
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    ));
    await tester.pumpAndSettle();

    final codeBtn = find.byType(SourceButton);
    await tester.tap(codeBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test'));
    try {
      await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(milliseconds: 1000));
    } on FlutterError {
      //
    }

    final searchField = find.byType(CodeViewScreen);
    expect(searchField, findsOneWidget);
  });
}
