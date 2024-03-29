import 'package:list_controller/list_controller.dart';
import 'package:test/test.dart';

// ignore_for_file: prefer_const_constructors

void main() {
  test('ResetEvent equality', () {
    expect(ResetEvent(query: 1), ResetEvent(query: 1));
  });

  test('ResetEvent hashCode', () {
    expect(const ResetEvent(query: 1).hashCode,
        isNot(const ResetEvent(query: 2).hashCode));
  });

  test('ResetEvent toString', () {
    expect(const ResetEvent(query: 1).toString(), 'ResetEvent(query: 1)');
  });

  test('LoadRecordsEvent equality', () {
    expect(LoadRecordsEvent(query: 1, loadingKey: ''),
        LoadRecordsEvent(query: 1, loadingKey: ''));
  });

  test('LoadRecordsEvent hashCode', () {
    expect(const LoadRecordsEvent(query: 1, loadingKey: '').hashCode,
        isNot(const LoadRecordsEvent(query: 2, loadingKey: '').hashCode));
  });

  test('ResetEvent toString', () {
    expect(const LoadRecordsEvent(query: 1, loadingKey: 'a').toString(),
        'LoadRecordsEvent(loadingKey: a, query: 1)');
  });

  test('RecordsLoadStartEvent equality', () {
    expect(RecordsLoadStartEvent(query: 1, loadingKey: ''),
        RecordsLoadStartEvent(query: 1, loadingKey: ''));
  });

  test('RecordsLoadStartEvent hashCode', () {
    expect(const RecordsLoadStartEvent(query: 1, loadingKey: '').hashCode,
        isNot(const RecordsLoadStartEvent(query: 2, loadingKey: '').hashCode));
  });

  test('RecordsLoadStartEvent toString', () {
    expect(const RecordsLoadStartEvent(query: 1, loadingKey: 'a').toString(),
        'RecordsLoadStartEvent(loadingKey: a, query: 1)');
  });

  test('RecordsLoadCancelEvent equality', () {
    expect(RecordsLoadCancelEvent(query: 1, loadingKey: ''),
        RecordsLoadCancelEvent(query: 1, loadingKey: ''));
  });

  test('RecordsLoadCancelEvent hashCode', () {
    expect(const RecordsLoadCancelEvent(query: 1, loadingKey: '').hashCode,
        isNot(const RecordsLoadCancelEvent(query: 2, loadingKey: '').hashCode));
  });

  test('RecordsLoadCancelEvent toString', () {
    expect(const RecordsLoadCancelEvent(query: 1, loadingKey: 'a').toString(),
        'RecordsLoadCancelEvent(loadingKey: a, query: 1)');
  });

  test('LoadingErrorEvent equality', () {
    expect(LoadingErrorEvent(query: 1, loadingKey: ''),
        LoadingErrorEvent(query: 1, loadingKey: ''));
  });

  test('LoadingErrorEvent hashCode', () {
    expect(const LoadingErrorEvent(query: 1, loadingKey: '').hashCode,
        isNot(const LoadingErrorEvent(query: 2, loadingKey: '').hashCode));
  });

  test('LoadingErrorEvent toString', () {
    expect(
        const LoadingErrorEvent(query: 1, loadingKey: 'a', error: 'a')
            .toString(),
        'LoadingErrorEvent(loadingKey: a, query: 1, error: a)');
  });

  test('PutLoadResultToStateEvent equality', () {
    expect(
        PutLoadResultToStateEvent(
            query: 1, loadingKey: '', loadResult: const []),
        PutLoadResultToStateEvent(
            query: 1, loadingKey: '', loadResult: const []));
  });

  test('PutLoadResultToStateEvent hashCode', () {
    expect(
        const PutLoadResultToStateEvent(
            query: 1, loadingKey: '', loadResult: []).hashCode,
        isNot(const PutLoadResultToStateEvent(
            query: 2, loadingKey: '', loadResult: []).hashCode));
  });

  test('PutLoadResultToStateEvent toString', () {
    expect(
        const PutLoadResultToStateEvent(
                query: 1, loadingKey: 'a', loadResult: 'a')
            .toString(),
        'PutLoadResultToStateEvent(loadingKey: a, query: 1, loadResult: a)');
  });

  test('UpdateHotListEvent equality', () {
    expect(
        UpdateHotListEvent(
            changes: HotListChanges(
                recordKeysToRemove: const {}, recordsToInsert: const {})),
        UpdateHotListEvent(
            changes: HotListChanges(
                recordKeysToRemove: const {}, recordsToInsert: const {})));
  });

  test('UpdateHotListEvent hashCode', () {
    expect(
        const UpdateHotListEvent(
                changes:
                    HotListChanges(recordKeysToRemove: {}, recordsToInsert: {}))
            .hashCode,
        isNot(const UpdateHotListEvent(
            changes: HotListChanges(
                recordKeysToRemove: {1}, recordsToInsert: {})).hashCode));
  });

  test('UpdateHotListEvent toString', () {
    expect(
        const UpdateHotListEvent(
                changes:
                    HotListChanges(recordKeysToRemove: {}, recordsToInsert: {}))
            .toString(),
        'UpdateHotListEvent(changesCount: HotListChanges(recordsToInsert: {}, '
        'recordsToRemove: {}))');
  });

  test('LoadNextPageEvent equality', () {
    expect(LoadNextPageEvent(), LoadNextPageEvent());
  });

  test('LoadNextPageEvent hashCode', () {
    expect(LoadNextPageEvent().hashCode, LoadNextPageEvent().hashCode);
  });

  test('LoadNextPageEvent toString', () {
    expect(const LoadNextPageEvent().toString(), 'LoadNextPageEvent()');
  });

  test('LoadNextPageDirectedEvent equality', () {
    expect(LoadNextPageDirectedEvent(loadingKey: ''),
        LoadNextPageDirectedEvent(loadingKey: ''));
  });

  test('LoadNextPageDirectedEvent hashCode', () {
    expect(const LoadNextPageDirectedEvent(loadingKey: '').hashCode,
        isNot(const LoadNextPageDirectedEvent(loadingKey: '1').hashCode));
  });

  test('LoadNextPageDirectedEvent toString', () {
    expect(const LoadNextPageDirectedEvent(loadingKey: 'a').toString(),
        'LoadNextPageDirectedEvent(loadingKey: a)');
  });

  test('RepeatQueryEvent equality', () {
    expect(RepeatQueryEvent(loadingKey: ''), RepeatQueryEvent(loadingKey: ''));
  });

  test('RepeatQueryEvent hashCode', () {
    expect(const RepeatQueryEvent(loadingKey: '').hashCode,
        isNot(const RepeatQueryEvent(loadingKey: '1').hashCode));
  });

  test('RepeatQueryEvent toString', () {
    expect(const RepeatQueryEvent(loadingKey: 'a').toString(),
        'RepeatQueryEvent(loadingKey: a)');
  });

  test('RepeatUnsuccessfulQueriesEvent equality', () {
    expect(RepeatUnsuccessfulQueriesEvent(), RepeatUnsuccessfulQueriesEvent());
  });

  test('RepeatUnsuccessfulQueriesEvent hashCode', () {
    expect(RepeatUnsuccessfulQueriesEvent().hashCode,
        RepeatUnsuccessfulQueriesEvent().hashCode);
  });

  test('RepeatUnsuccessfulQueriesEvent toString', () {
    expect(const RepeatUnsuccessfulQueriesEvent().toString(),
        'RepeatUnsuccessfulQueriesEvent()');
  });
}
