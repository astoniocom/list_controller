import 'package:demo/examples/filtering_sorting/filtering_sorting_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilteringSortingExample extends StatelessWidget {
  const FilteringSortingExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  static const filteringCheckboxKey = Key('filteringCheckbox');
  static const sortingCheckboxKey = Key('sortingCheckbox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => FilteringSortingListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<FilteringSortingListController>().value;
          final listController = context.read<FilteringSortingListController>();

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
