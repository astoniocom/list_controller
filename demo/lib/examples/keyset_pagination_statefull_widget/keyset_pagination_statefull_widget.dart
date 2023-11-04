import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:list_controller/list_controller.dart';

class ListQuery extends Equatable {
  const ListQuery({this.weightGt = 0});

  final int weightGt;

  @override
  List<Object?> get props => [weightGt];
}

typedef StatefullListState = ListState<int, ListQuery>;

class LoadResult {
  const LoadResult({required this.records, required this.isFinalPage});

  final List<int> records;
  final bool isFinalPage;
}

class KeysetPaginationStatefullWidgetExample extends StatefulWidget {
  const KeysetPaginationStatefullWidgetExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  State<KeysetPaginationStatefullWidgetExample> createState() => _KeysetPaginationStatefullWidgetExampleState();
}

class _KeysetPaginationStatefullWidgetExampleState extends State<KeysetPaginationStatefullWidgetExample>
    with ListCore<int>, RecordsLoader<int, ListQuery, LoadResult>, KeysetPagination<int, ListQuery, LoadResult> {
  StatefullListState state = const StatefullListState(query: ListQuery());

  @override
  void initState() {
    loadRecords(const ListQuery());
    super.initState();
  }

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: widget.title, sources: widget.sources),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: state.records.length,
            itemBuilder: (context, index) {
              const recordsLoadThreshold = 1;
              if (index >= state.records.length - recordsLoadThreshold) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  loadNextPage();
                });
              }
              return ListTile(title: Text('${state.records[index]}'));
            },
          ),
          if (state.isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ListQuery query, required LoadingKey loadingKey}) => setState(() {
        state = state.copyWith(stage: ListStage.loading());
      });

  @override
  Future<LoadResult> performLoadQuery({required ListQuery query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return LoadResult(
      records: List<int>.generate(20, (i) => query.weightGt + i + 1),
      isFinalPage: query.weightGt >= 80,
    );
  }

  @override
  void putLoadResultToState({required ListQuery query, required LoadResult loadResult, required LoadingKey loadingKey}) => setState(() {
        state = state.copyWith(
          records: [
            ...state.records,
            ...loadResult.records,
          ],
          stage: loadResult.isFinalPage ? ListStage.complete() : ListStage.idle(),
        );
      });

  // KeysetPagination section:

  @override
  ListStage getListStage(LoadingKey loadingKey) => state.stage;

  @override
  ListQuery buildNextPageQuery(LoadingKey loadingKey) => ListQuery(weightGt: state.records.last);
}
