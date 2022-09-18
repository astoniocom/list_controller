import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

@immutable
class ListQuery extends Equatable {
  const ListQuery({
    this.page = 0,
    this.filtering = false,
    this.sorting = false,
  });
  final int page;
  final bool filtering;
  final bool sorting;

  ListQuery copyWith({bool? filtering, bool? sorting, int? page}) {
    return ListQuery(
      filtering: filtering ?? this.filtering,
      sorting: sorting ?? this.sorting,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [page, filtering, sorting];
}

class ListState {
  const ListState({
    this.records = const {},
    this.query = const ListQuery(),
    this.recordsCount = 0,
  });

  final Map<int, List<int>> records;
  final ListQuery query;
  final int recordsCount;

  ListState copyWith({Map<int, List<int>>? records, ListQuery? query, int? recordsCount}) {
    return ListState(
      records: records ?? this.records,
      query: query ?? this.query,
      recordsCount: recordsCount ?? this.recordsCount,
    );
  }
}

class LoadResult {
  LoadResult({required this.totalCount, required this.records});
  final int totalCount;
  final List<int> records;
}

const pageSize = 22;
const totalRecords = 10000;

class HugeListController extends ValueNotifier<ListState>
    with ListCore<int>, RecordsLoader<int, ListQuery, LoadResult>, OffsetPagination<int, ListQuery, LoadResult, int> {
  HugeListController() : super(const ListState()) {
    loadPage(0);
  }

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  void setNewQuery(ListQuery query) {
    value = value.copyWith(query: query, records: {});

    resetController();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ListQuery query, required LoadingKey loadingKey}) {}

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
      totalCount: totalRecords ~/ delta,
    );
  }

  @override
  void putLoadResultToState({required ListQuery query, required LoadResult loadResult, required LoadingKey loadingKey}) {
    final records = Map.of(value.records);
    records[query.page] = loadResult.records;
    value = value.copyWith(records: records, recordsCount: loadResult.totalCount);
  }

  // OffsetPagination section

  @override
  String offsetToLoadingKey(int offset) => 'page$offset';

  @override
  ListQuery buildOffsetQuery(int offset) => value.query.copyWith(page: offset);
}
