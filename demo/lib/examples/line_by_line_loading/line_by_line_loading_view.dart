import 'package:demo/examples/line_by_line_loading/line_by_line_loading_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LineByLineLoadingExample extends StatelessWidget {
  const LineByLineLoadingExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => LineByLineLoadingListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<LineByLineLoadingListController>().value;

          return Stack(
            children: [
              ListView.builder(
                itemCount: listState.records.length,
                itemBuilder: (context, index) => ListTile(title: Text('${listState.records[index]}')),
              ),
              if (listState.isLoading) const Center(child: CircularProgressIndicator()),
            ],
          );
        }),
      ),
    );
  }
}
