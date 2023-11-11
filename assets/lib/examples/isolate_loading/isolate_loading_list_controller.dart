import 'dart:async';
import 'dart:isolate';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';
import 'package:rxdart/rxdart.dart';

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

class _IsolateMessage {
  _IsolateMessage({required this.query, required this.sendPort});

  final ListQuery query;
  final SendPort sendPort;
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

class IsolateLoadingListController extends ValueNotifier<ListState> with ListCore<int>, RecordsLoader<int, ListQuery, List<int>> {
  IsolateLoadingListController() : super(const ListState()) {
    loadRecords(const ListQuery());
  }

  Isolate? _loadingIsolate;

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

  static Future<void> _performLoading(_IsolateMessage message) async {
    final query = message.query;
    final sendPort = message.sendPort;

    // for (int i = 0; i < 10; i++) {
    //   await Future.delayed(const Duration(milliseconds: 1000));
    //   print(i);
    // }

    await Future.delayed(const Duration(milliseconds: 1500));

    var list = List<int>.generate(100, (i) => i + 1)..shuffle();
    if (query.sorting) {
      list.sort();
    }

    if (query.filtering) {
      list = list.where((element) => element % 10 == 0).toList();
    }

    sendPort.send(list);
  }

  @override
  void onRecordsLoadStart({required ListQuery query, required LoadingKey loadingKey}) => value = value.copyWith(
        isLoading: true,
        query: query,
      );

  @override
  Future<List<int>> performLoadQuery({required ListQuery query, required LoadingKey loadingKey}) async {
    final receivePort = ReceivePort();
    final message = _IsolateMessage(query: query, sendPort: receivePort.sendPort);

    _loadingIsolate = await Isolate.spawn(_performLoading, message);

    final completer = Completer<List<int>>();

    final intermediateResultSubscription = receivePort.whereType<List<int>>().listen(completer.complete);

    final result = await completer.future;
    await intermediateResultSubscription.cancel();
    receivePort.close();
    return result;
  }

  @override
  void putLoadResultToState({required ListQuery query, required List<int> loadResult, required LoadingKey loadingKey}) =>
      value = value.copyWith(records: loadResult, isLoading: false);

  @override
  void onRecordsLoadCancel({required ListQuery query, required LoadingKey loadingKey}) {
    _loadingIsolate?.kill();
  }
}
