import 'dart:async';

import 'package:list_controller/list_controller.dart';
import 'package:mockito/mockito.dart';

class MockKeysetPaginationController extends Mock
    with
        ListCore<int>,
        RecordsLoader<int, int?, List<int>?>,
        KeysetPagination<int, int?, List<int>?> {
  MockKeysetPaginationController() {
    throwOnMissingStub(this);
  }

  bool sequentialLoadStrategy = false;

  @override
  LoadStrategy get loadStrategy =>
      sequentialLoadStrategy ? LoadStrategy.sequential : super.loadStrategy;

  void startActualizing() => actualizeCompleter = Completer();

  void stopActualizing() => actualizeCompleter?.complete(null);

  @override
  bool isRecordsLoading(LoadingKey loadingKey, {int? query}) {
    return super.noSuchMethod(
      Invocation.method(#isRecordsLoading, [loadingKey], {#query: query}),
      returnValue: super.isRecordsLoading(loadingKey, query: query),
      returnValueForMissingStub:
          super.isRecordsLoading(loadingKey, query: query),
    ) as bool;
  }

  @override
  int? buildNextPageQuery(LoadingKey loadingKey) {
    return super.noSuchMethod(
      Invocation.method(#buildNextPageQuery, [loadingKey]),
      returnValue: 1,
      returnValueForMissingStub: 1,
    ) as int;
  }

  @override
  ListStage getListStage(LoadingKey loadingKey) {
    final result = ListStage.idle();
    return super.noSuchMethod(
      Invocation.method(#getListStage, [loadingKey]),
      returnValue: result,
      returnValueForMissingStub: result,
    ) as ListStage;
  }

  @override
  Future<List<int>> performLoadQuery(
      {required int? query, required LoadingKey? loadingKey}) {
    final result = Future.value([1, 2, 3]);

    return super.noSuchMethod(
      Invocation.method(
          #performLoadQuery, [], {#query: query, #loadingKey: loadingKey}),
      returnValue: result,
      returnValueForMissingStub: result,
    ) as Future<List<int>>;
  }

  @override
  void onRecordsLoadStart(
      {required int? query, required LoadingKey loadingKey}) {
    super.noSuchMethod(
      Invocation.method(
          #onRecordsLoadStart, [], {#query: query, #loadingKey: loadingKey}),
      returnValueForMissingStub: null,
    );
  }

  @override
  void putLoadResultToState(
      {required int? query,
      required List<int>? loadResult,
      required LoadingKey loadingKey}) {
    super.noSuchMethod(
        Invocation.method(#putLoadResultToState, [], {
          #query: query,
          #loadResult: loadResult,
          #loadingKey: loadingKey,
        }),
        returnValueForMissingStub: null);
  }

  @override
  void onRecordsLoadCancel(
      {required int? query, required LoadingKey loadingKey}) {
    super.onRecordsLoadCancel(query: query, loadingKey: loadingKey);
    super.noSuchMethod(
        Invocation.method(#onRecordsLoadCancel, [], {
          #query: query,
          #loadingKey: loadingKey,
        }),
        returnValueForMissingStub: null);
  }
}
