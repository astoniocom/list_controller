import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

class ListQuery extends Equatable {
  const ListQuery({this.filtering = false, this.gt = 0});

  final bool filtering;
  final int gt;

  ListQuery copyWith({bool? filtering, bool? sorting, int? gt}) {
    return ListQuery(
      filtering: filtering ?? this.filtering,
      gt: gt ?? this.gt,
    );
  }

  @override
  List<Object?> get props => [filtering, gt];
}

typedef ExListState = ListState<int, ListQuery>;

class LoadResult {
  const LoadResult({required this.records, required this.isFinalPage});

  final List<int> records;
  final bool isFinalPage;
}

class FilteringKeysetPaginationValueNotifierListController extends ValueNotifier<ExListState>
    with ListCore<int>, RecordsLoader<int, ListQuery, LoadResult>, KeysetPagination<int, ListQuery, LoadResult> {
  FilteringKeysetPaginationValueNotifierListController() : super(const ExListState(query: ListQuery())) {
    loadRecords(value.query);
  }

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  void setNewQuery(ListQuery query) {
    value = value.copyWith(query: query, isInitialized: false);

    resetController();

    loadRecords(query);
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ListQuery query, required LoadingKey loadingKey}) => value = value.copyWith(stage: ListStage.loading());

  @override
  Future<LoadResult> performLoadQuery({required ListQuery query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final int delta = query.filtering ? 10 : 1;
    const totalRecords = 80;
    final int recordsPerPage = query.filtering ? 5 : 20;

    return LoadResult(
      records: List<int>.generate(recordsPerPage, (i) => query.gt + (i + 1) * delta).toList(growable: false),
      isFinalPage: query.filtering || query.gt >= totalRecords,
    );
  }

  @override
  void putLoadResultToState({required ListQuery query, required LoadResult loadResult, required LoadingKey loadingKey}) => value = value.copyWith(
        records: [
          if (value.isInitialized) ...value.records,
          ...loadResult.records,
        ],
        stage: loadResult.isFinalPage ? ListStage.complete() : ListStage.idle(),
      );

  // KeysetPagination section:

  @override
  ListStage getListStage(LoadingKey loadingKey) => value.stage;

  @override
  ListQuery buildNextPageQuery(LoadingKey loadingKey) => value.query.copyWith(gt: value.records.last);
}
