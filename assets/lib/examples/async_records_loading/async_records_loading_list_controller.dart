import 'package:flutter/material.dart';
import 'package:list_controller/list_controller.dart';

class ListState {
  const ListState({this.records = const [], this.isLoading = false});

  final List<int> records;
  final bool isLoading;
}

class AsyncRecordsLoadingListController extends ValueNotifier<ListState> with ListCore<int>, RecordsLoader<int, void, List<int>> {
  AsyncRecordsLoadingListController() : super(const ListState()) {
    loadRecords(null);
  }

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required void query, required LoadingKey loadingKey}) => value = const ListState(isLoading: true);

  @override
  Future<List<int>> performLoadQuery({required void query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return List<int>.generate(100, (i) => i + 1);
  }

  @override
  void putLoadResultToState({required void query, required List<int> loadResult, required LoadingKey loadingKey}) => value = ListState(records: loadResult);
}
