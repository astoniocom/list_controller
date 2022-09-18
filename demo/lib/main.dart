import 'package:demo/examples_db.dart';
import 'package:demo/models.dart';
import 'package:demo/screens/code_view_screen.dart';
import 'package:demo/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(ExampleApp(examples: examples));
}

class ExampleApp extends StatelessWidget {
  ExampleApp({required this.examples, super.key});

  final List<Example> examples;

  late final GoRouter _router = GoRouter(routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => HomeScreen(examples: examples),
      routes: examples
          .map((e) => GoRoute(
                path: e.slug,
                builder: (BuildContext context, GoRouterState state) => e.builder(e, context),
                routes: e.sources
                    .map((e) => GoRoute(
                          path: 'code/${e.slug}',
                          builder: (BuildContext context, GoRouterState state) => CodeViewScreen(filePath: e.codeFile),
                        ))
                    .toList(),
              ))
          .toList(),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'List Controller Examples',
      theme: ThemeData(
        useMaterial3: true,
      ),
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
