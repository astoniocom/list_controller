import 'package:demo/examples/filtering_keyset_pagination_value_notifier_list/filtering_keyset_pagination_value_notifier_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilteringKeysetPaginationValueNotifierListExample extends StatelessWidget {
  const FilteringKeysetPaginationValueNotifierListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  static const filteringCheckboxKey = Key('filteringCheckbox');
  static const sortingCheckboxKey = Key('sortingCheckbox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => FilteringKeysetPaginationValueNotifierListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<FilteringKeysetPaginationValueNotifierListController>().value;
          final listController = context.read<FilteringKeysetPaginationValueNotifierListController>();

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
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: listState.records.length,
                      itemBuilder: (context, index) {
                        const recordsLoadThreshold = 1;
                        if (index >= listState.records.length - recordsLoadThreshold) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.read<FilteringKeysetPaginationValueNotifierListController>().loadNextPage();
                          });
                        }

                        return ListTile(title: Text('${listState.records[index]}'));
                      },
                    ),
                    if (listState.isLoading) const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
