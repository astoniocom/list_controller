import 'package:demo/examples/offset_pagination_list/offset_pagination_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OffsetPaginationListExample extends StatelessWidget {
  const OffsetPaginationListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  static const filteringCheckboxKey = Key('filteringCheckbox');
  static const sortingCheckboxKey = Key('sortingCheckbox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => OffsetPaginationListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<OffsetPaginationListController>().value;
          final listController = context.read<OffsetPaginationListController>();

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
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: listState.records.length,
                      itemBuilder: (context, index) {
                        const recordsLoadThreshold = 1;
                        if (index >= listState.records.length - recordsLoadThreshold) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            listController.loadNextPage();
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
