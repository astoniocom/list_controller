import 'package:demo/examples/keyset_pagination_value_notifier_list/keyset_pagination_value_notifier_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KeysetPaginationValueNotifierListExample extends StatelessWidget {
  const KeysetPaginationValueNotifierListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => KeysetPaginationValueNotifierListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<KeysetPaginationValueNotifierListController>().value;

          return Stack(
            children: [
              ListView.builder(
                itemCount: listState.records.length,
                itemBuilder: (context, index) {
                  const recordsLoadThreshold = 1;
                  if (index >= listState.records.length - recordsLoadThreshold) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<KeysetPaginationValueNotifierListController>().loadNextPage();
                    });
                  }

                  return ListTile(title: Text('${listState.records[index]}'));
                },
              ),
              if (listState.isLoading) const Center(child: CircularProgressIndicator()),
            ],
          );
        }),
      ),
    );
  }
}
