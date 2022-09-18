import 'package:demo/examples/repeating_queries/repeating_queries_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:list_controller/list_controller.dart';
import 'package:provider/provider.dart';

class RepeatingQueriesExample extends StatelessWidget {
  const RepeatingQueriesExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  static const repeatButtonKey = Key('repeatButtonKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => RepeatingQueriesListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<RepeatingQueriesListController>().value;
          final controller = context.read<RepeatingQueriesListController>();

          return Stack(
            children: [
              ListView.builder(
                itemCount: listState.records.length,
                itemBuilder: (context, index) {
                  const recordsLoadThreshold = 1;
                  if (index >= listState.records.length - recordsLoadThreshold) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.loadNextPage();
                    });
                  }

                  return ListTile(title: Text('${listState.records[index]}'));
                },
              ),
              if (listState.stage == ListStage.error())
                Center(
                    child: Material(
                  color: Colors.red[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error occured'),
                      IconButton(onPressed: controller.repeatQuery, icon: const Icon(Icons.refresh), key: repeatButtonKey),
                    ],
                  ),
                )),
              if (listState.isLoading) const Center(child: CircularProgressIndicator()),
            ],
          );
        }),
      ),
    );
  }
}
