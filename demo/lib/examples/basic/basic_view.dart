import 'package:demo/examples/basic/basic_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasicExample extends StatelessWidget {
  const BasicExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => BasicListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<BasicListController>().value;
          return ListView.builder(
            itemCount: listState.length,
            itemBuilder: (context, index) => ListTile(title: Text('${listState[index]}')),
          );
        }),
      ),
    );
  }
}
