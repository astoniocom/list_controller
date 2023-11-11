import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

typedef ExListState = ListState<int, int>;

class LoadResult {
  const LoadResult({required this.records, required this.isFinalPage});

  final List<int> records;
  final bool isFinalPage;
}

class KeysetPaginationValueNotifierListController extends ValueNotifier<ExListState>
    with ListCore<int>, RecordsLoader<int, int, LoadResult>, KeysetPagination<int, int, LoadResult> {
  KeysetPaginationValueNotifierListController() : super(const ExListState(query: 0)) {
    loadRecords(value.query);
  }

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required int query, required LoadingKey loadingKey}) => value = value.copyWith(stage: ListStage.loading());

  @override
  Future<LoadResult> performLoadQuery({required int query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return LoadResult(
      records: List<int>.generate(20, (i) => query + i + 1),
      isFinalPage: query >= 80,
    );
  }

  @override
  void putLoadResultToState({required int query, required LoadResult loadResult, required LoadingKey loadingKey}) => value = value.copyWith(
        records: [
          ...value.records,
          ...loadResult.records,
        ],
        stage: loadResult.isFinalPage ? ListStage.complete() : ListStage.idle(),
      );

  // KeysetPagination section:

  @override
  ListStage getListStage(LoadingKey loadingKey) => value.stage;

  @override
  int buildNextPageQuery(LoadingKey loadingKey) => value.records.last;
}
