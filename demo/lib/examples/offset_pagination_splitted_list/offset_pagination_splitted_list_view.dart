import 'package:demo/examples/offset_pagination_splitted_list/offset_pagination_splitted_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_database.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';

class OffsetPaginationSplittedListExample extends StatelessWidget {
  OffsetPaginationSplittedListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: MultiProvider(
        providers: [
          Provider(create: (context) => MockDatabase(recodsNum: totalRecords)),
          ChangeNotifierProvider(create: (context) => OffsetPaginationSplittedListController(repository: context.read<MockDatabase>().exampleRecordRepository)),
        ],
        child: Builder(builder: (context) {
          final listState = context.watch<OffsetPaginationSplittedListController>().value;
          final listController = context.read<OffsetPaginationSplittedListController>();
          final currentPage = listState.pages[listState.currentPage];

          return Column(
            children: [
              Expanded(
                  child: currentPage?.stage != ListStage.loading()
                      ? ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            return ListTile(title: Text(currentPage!.records[index].title));
                          },
                          itemCount: currentPage?.records.length ?? 0)
                      : const Center(child: CircularProgressIndicator())),
              if (listState.totalPages > 0)
                NumberPaginator(
                  numberPages: listState.totalPages,
                  onPageChange: (page) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(0);
                    }
                    listController.goToPage(page);
                  },
                  child: const SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        PrevButton(),
                        Expanded(
                          child: NumberContent(),
                        ),
                        NextButton(),
                      ],
                    ),
                  ),
                )
            ],
          );
        }),
      ),
    );
  }
}
