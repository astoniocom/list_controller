import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

class ListState {
  const ListState({this.records = const [], this.isLoading = false});

  final List<int> records;
  final bool isLoading;

  ListState copyWith({List<int>? records, bool? isLoading, bool? hasError}) {
    return ListState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LineByLineLoadingListController extends ValueNotifier<ListState> with ListCore<int>, RecordsLoader<int, void, List<int>> {
  LineByLineLoadingListController() : super(const ListState()) {
    loadRecords(null);
  }

  static const Duration loadingDelay = Duration(milliseconds: 500);
  static const int mockRecords = 10;

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required void query, required LoadingKey loadingKey}) => value = value.copyWith(isLoading: true);

  @override
  Future<List<int>> performLoadQuery({required void query, required LoadingKey loadingKey}) async {
    final List<int> result = [];
    for (int i = 1; i <= mockRecords; i++) {
      await Future.delayed(loadingDelay);
      result.add(i);
      if (isListClosed) {
        break;
      }
      value = value.copyWith(records: result);
    }
    return result;
  }

  @override
  void putLoadResultToState({required void query, required List<int> loadResult, required LoadingKey loadingKey}) =>
      value = value.copyWith(records: loadResult, isLoading: false);
}
