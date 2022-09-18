import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

class ListQuery extends Equatable {
  const ListQuery({this.filtering = false, this.sorting = false, this.page = 0});

  final bool filtering;
  final bool sorting;
  final int page;

  ListQuery copyWith({bool? filtering, bool? sorting, int? page}) {
    return ListQuery(
      filtering: filtering ?? this.filtering,
      sorting: sorting ?? this.sorting,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [filtering, sorting, page];
}

typedef ExListState = ListState<int, ListQuery>;

class LoadResult {
  const LoadResult({required this.records, required this.totalPages});

  final List<int> records;
  final int totalPages;
}

const pageSize = 22;
const totalRecords = 100;

class OffsetPaginationListController extends ValueNotifier<ExListState>
    with ListCore<int>, RecordsLoader<int, ListQuery, LoadResult>, OffsetPagination<int, ListQuery, LoadResult, int> {
  OffsetPaginationListController() : super(ExListState(query: const ListQuery())) {
    loadRecords(value.query);
  }

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  void loadNextPage() {
    if (value.stage == ListStage.complete()) return;
    final page = (value.records.length / min(pageSize, totalRecords)).ceil();
    loadPage(page);
  }

  void setNewQuery(ListQuery query) {
    value = value.copyWith(query: query, records: null);

    resetController();

    loadRecords(query);
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ListQuery query, required LoadingKey loadingKey}) => value = value.copyWith(stage: ListStage.loading());

  @override
  Future<LoadResult> performLoadQuery({required ListQuery query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final int from = query.page * pageSize;

    assert(totalRecords >= from);

    final int delta = query.filtering ? 10 : 1;
    final int realPageSize = min(pageSize, totalRecords - from);

    return LoadResult(
      records: List<int>.generate(realPageSize, (i) => i * delta)
          .map((e) => (query.sorting ? -1 : 1) * ((query.sorting ? -totalRecords * delta : 0) + e + from * delta))
          .toList(),
      totalPages: (totalRecords / pageSize).ceil(),
    );
  }

  @override
  void putLoadResultToState({required ListQuery query, required LoadResult loadResult, required LoadingKey loadingKey}) {
    // Ideally, add records to a position based on query.page or loadingKey.

    value = value.copyWith(
      records: [
        ...value.records,
        ...loadResult.records,
      ],
      stage: loadResult.totalPages <= query.page + 1 ? ListStage.complete() : ListStage.idle(),
    );
  }

  // OffsetPagination section

  @override
  String offsetToLoadingKey(int offset) => 'page$offset';

  @override
  ListQuery buildOffsetQuery(int offset) => value.query.copyWith(page: offset);
}
