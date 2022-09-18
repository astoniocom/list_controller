import 'package:demo/examples/isolate_loading/isolate_loading_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IsolateLoadingExample extends StatelessWidget {
  const IsolateLoadingExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  static const filteringCheckboxKey = Key('filteringCheckbox');
  static const sortingCheckboxKey = Key('sortingCheckbox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => IsolateLoadingListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<IsolateLoadingListController>().value;
          final listController = context.read<IsolateLoadingListController>();

          return Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    key: filteringCheckboxKey,
                    value: listState.query.filtering,
                    onChanged: (value) => listController.setNewQuery(listState.query.copyWith(filtering: value)),
                  ),
                  const Text('Filtering'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    key: sortingCheckboxKey,
                    value: listState.query.sorting,
                    onChanged: (value) => listController.setNewQuery(listState.query.copyWith(sorting: value)),
                  ),
                  const Text('Sorting'),
                ],
              ),
              Expanded(
                child: Builder(builder: (context) {
                  if (listState.isLoading) return const Center(child: CircularProgressIndicator());

                  return ListView.builder(
                    itemCount: listState.records.length,
                    itemBuilder: (context, index) => ListTile(title: Text('${listState.records[index]}')),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
