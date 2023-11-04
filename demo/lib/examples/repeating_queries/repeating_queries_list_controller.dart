import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

class ListQuery extends Equatable {
  const ListQuery({this.weightGt = 0});

  final int weightGt;

  @override
  List<Object?> get props => [weightGt];
}

class LoadResult {
  const LoadResult({required this.records, required this.isFinalPage});

  final List<int> records;
  final bool isFinalPage;
}

typedef ExListState = ListState<int, ListQuery>;

class RepeatingQueriesListController extends ValueNotifier<ExListState>
    with ListCore<int>, RecordsLoader<int, ListQuery, LoadResult>, KeysetPagination<int, ListQuery, LoadResult> {
  RepeatingQueriesListController() : super(const ListState(query: ListQuery())) {
    loadRecords(const ListQuery());
  }

  bool _hadError = false; // to make sure we had at least one error

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ListQuery query, required LoadingKey loadingKey}) => value = value.copyWith(stage: ListStage.loading());

  @override
  Future<LoadResult> performLoadQuery({required ListQuery query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (Random().nextBool() || (query.weightGt > 40 && !_hadError)) {
      _hadError = true;
      if (!isListClosed) {
        value = value.copyWith(stage: ListStage.error());
      }
      throw HandledLoadingException();
    }
    return LoadResult(
      records: List<int>.generate(20, (i) => query.weightGt + i + 1),
      isFinalPage: query.weightGt >= 80,
    );
  }

  @override
  void putLoadResultToState({required ListQuery query, required LoadResult loadResult, required LoadingKey loadingKey}) => value = value.copyWith(
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
  ListQuery buildNextPageQuery(LoadingKey loadingKey) => ListQuery(weightGt: value.records.last);
}
