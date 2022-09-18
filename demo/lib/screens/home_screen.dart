import 'package:demo/models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.examples, super.key});

  final List<Example> examples;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Controller Demo')),
      body: Scrollbar(
        thumbVisibility: true,
        interactive: true,
        child: ListView(
          children: examples
              .map((e) => ListTile(
                    title: Text(e.title),
                    subtitle: Text('${e.description}\nUses: ${e.usedFeatures.join(', ')}'),
                    onTap: () => context.go('/${e.slug}'),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
