import 'dart:async';

import 'package:list_controller/list_controller.dart';
import 'package:mockito/mockito.dart';

class MockRecordsLoaderController extends Mock
    with ListCore<int>, RecordsLoader<int, int?, List<int>?> {
  MockRecordsLoaderController() {
    throwOnMissingStub(this);
  }

  @override
  void onRecordsLoadStart(
      {required int? query, required LoadingKey? loadingKey}) {
    super.noSuchMethod(
        Invocation.method(#onRecordsLoadStart, [], {
          #query: query,
          #loadingKey: loadingKey,
        }),
        returnValueForMissingStub: null);
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
  void putLoadResultToState(
      {required int? query,
      required List<int>? loadResult,
      required LoadingKey? loadingKey}) {
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
