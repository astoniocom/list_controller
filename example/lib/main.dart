import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:list_controller/list_controller.dart';

class ListQuery extends Equatable {
  const ListQuery({this.weightGt = 0});

  final int weightGt;

  @override
  List<Object?> get props => [weightGt];
}

typedef ListStateExample = ListState<int, ListQuery>;

class LoadResult {
  const LoadResult({required this.records, required this.isFinalPage});

  final List<int> records;
  final bool isFinalPage;
}

void main() {
  runApp(const MaterialApp(
    title: 'List Controller Example',
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key}) : super();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with
        ListCore<int>,
        RecordsLoader<int, ListQuery, LoadResult>,
        KeysetPagination<int, ListQuery, LoadResult> {
  ListStateExample state = const ListStateExample(query: ListQuery());

  @override
  void initState() {
    loadRecords(state.query);
    super.initState();
  }

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart(
          {required ListQuery query, required LoadingKey loadingKey}) =>
      setState(() {
        state = state.copyWith(stage: ListStage.loading());
      });

  @override
  Future<LoadResult> performLoadQuery(
      {required ListQuery query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return LoadResult(
      records: List<int>.generate(20, (i) => query.weightGt + i + 1),
      isFinalPage: query.weightGt >= 80,
    );
  }

  @override
  void putLoadResultToState(
          {required ListQuery query,
          required LoadResult loadResult,
          required LoadingKey loadingKey}) =>
      setState(() {
        state = state.copyWith(
          records: [
            ...state.records,
            ...loadResult.records,
          ],
          stage:
              loadResult.isFinalPage ? ListStage.complete() : ListStage.idle(),
        );
      });

  // KeysetPagination section:

  @override
  ListStage getListStage(LoadingKey loadingKey) => state.stage;

  @override
  ListQuery buildNextPageQuery(LoadingKey loadingKey) =>
      ListQuery(weightGt: state.records.last);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Controller Example'),
      ),
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
              return ListTile(title: Text(state.records[index].toString()));
            },
          ),
          if (state.isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
