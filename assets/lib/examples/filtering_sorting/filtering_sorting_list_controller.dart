import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

class ListQuery extends Equatable {
  const ListQuery({this.filtering = false, this.sorting = false});

  final bool filtering;
  final bool sorting;

  ListQuery copyWith({bool? filtering, bool? sorting}) {
    return ListQuery(
      filtering: filtering ?? this.filtering,
      sorting: sorting ?? this.sorting,
    );
  }

  @override
  List<Object?> get props => [filtering, sorting];
}

class ListState {
  const ListState({this.records = const [], this.isLoading = false, this.query = const ListQuery()});

  final List<int> records;
  final bool isLoading;
  final ListQuery query;

  ListState copyWith({List<int>? records, bool? isLoading, ListQuery? query}) {
    return ListState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
    );
  }
}

class FilteringSortingListController extends ValueNotifier<ListState> with ListCore<int>, RecordsLoader<int, ListQuery, List<int>> {
  FilteringSortingListController() : super(const ListState()) {
    loadRecords(const ListQuery());
  }

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  void setNewQuery(ListQuery query) {
    value = value.copyWith(query: query, records: []);

    resetController();

    loadRecords(query);
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ListQuery query, required LoadingKey loadingKey}) => value = value.copyWith(
        isLoading: true,
      );

  @override
  Future<List<int>> performLoadQuery({required ListQuery query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    var list = List<int>.generate(100, (i) => i + 1)..shuffle();
    if (query.sorting) {
      list.sort();
    }

    if (query.filtering) {
      list = list.where((element) => element % 10 == 0).toList();
    }
    return list;
  }

  @override
  void putLoadResultToState({required ListQuery query, required List<int> loadResult, required LoadingKey loadingKey}) =>
      value = value.copyWith(records: loadResult, isLoading: false);
}
