import 'dart:async';
import 'package:list_controller/list_controller.dart';
import 'package:meta/meta.dart';

/// Тип ключа Load key type.
typedef LoadingKey = String;

/// The reason why the loading of the list records is finished.
enum CompleteReason {
  /// The list was reset.
  reset,

  /// Loading records has become irrelevant.
  outOfDate,

  /// Loading of the records was successful.
  normal,

  /// Loading of the records was interrupted.
  interrupt,

  /// Loading of records ended with the expected error.
  handledException,

  /// Loading of records ended with the unexpected error.
  error,
}

class _LoadingOperationDescriber<Query> {
  _LoadingOperationDescriber({required this.query, required this.completer});
  final Query query;
  final Completer<CompleteReason> completer;
  bool? isOperationSuccessful;
}

/// Implements the loading of data for the list from a specified source.
/// Whether it is a local database or a remote server.
mixin RecordsLoader<Record, Query, LoadResult> on ListCore<Record> {
  final Map<LoadingKey, _LoadingOperationDescriber<Query>> _loadingDescribers =
      {};

  /// Default key for loading operations.
  ///
  /// Used if no other `loadingKey` was specified when calling [loadRecords].
  static const LoadingKey defaultLoadingKey = 'default';

  Completer<void>? _loadCompleter;

  /// Called at the beginning of loading.
  ///
  /// Usually, this function should set a loading status in your list state
  /// object (for example, it might be executing `...isLoading = true`).
  @protected
  void onRecordsLoadStart(
      {required Query query, required LoadingKey loadingKey});

  /// The function is responsible for retrieving data from a source.
  ///
  /// If an error occurs during the loading of data, the function must handle
  /// this error (e.g. set error status `...hasError = true` in the list
  /// state object and throw `HandledLoadingException`).
  ///
  /// If it is necessary to interrupt loading for some reason, this can be done
  /// by throwing `InterruptLoading` ([example]()).
  @protected
  Future<LoadResult> performLoadQuery(
      {required Query query, required LoadingKey loadingKey});

  /// The function needs an implementation of adding loaded records to
  /// the list state.
  ///
  /// You may also need to implement resetting the loading status in the list
  /// state object (like `...isLoading = false`).
  @protected
  void putLoadResultToState(
      {required Query query,
      required LoadResult loadResult,
      required LoadingKey loadingKey});

  /// Called in case of a loading cancellation.
  ///
  /// This situation can occur when one data load is interrupted by another
  /// or by closing the controller.
  ///
  /// In this function, you may need to implement resetting of the loading
  /// status in the list state object (like `...isLoading = false`).
  /// The function can also be used when data should be put into the list
  /// in a separate `Isolate` in order to close it.
  @protected
  void onRecordsLoadCancel(
      {required Query query, required LoadingKey loadingKey}) {
    // you can use it to close a thread
  }

  Future<void>? _lastLoadWaiter;

  @override
  Future<void> waitAllLoadsToComplete() {
    if (_lastLoadWaiter == null) {
      _lastLoadWaiter = (_loadCompleter?.isCompleted ?? true)
          ? Future.value()
          : _loadCompleter!.future;
    } else {
      _lastLoadWaiter = _lastLoadWaiter!.then((_) => _loadCompleter!.future);
    }

    return _lastLoadWaiter!.then((value) {
      if (_loadCompleter?.isCompleted ?? true) {
        _lastLoadWaiter = null;
      }
    });
  }

  /// Tells whether the loading of records is identified by the [loadingKey]
  /// and the [query] is currently being executed.
  @visibleForTesting
  @protected
  bool isRecordsLoading(LoadingKey loadingKey, {Query? query}) {
    final loadMeta = _loadingDescribers[loadingKey];

    if (loadMeta == null) {
      return false;
    }

    if (query == null) {
      return !loadMeta.completer.isCompleted;
    } else {
      return !loadMeta.completer.isCompleted && query == loadMeta.query;
    }
  }

  /// Tells whether any records are being loaded at the moment.
  @visibleForTesting
  @protected
  bool isAnyRecordsLoading() {
    return _loadingDescribers.values
        .where((loadDescriber) => !loadDescriber.completer.isCompleted)
        .isNotEmpty;
  }

  /// Indicates whether the loading of the records identified with
  /// the [loadingKey] key has succeeded.
  ///
  /// If there has been no loading with this key, the result is `null`.
  bool? isLoadSucessful(LoadingKey loadingKey) =>
      _loadingDescribers[loadingKey]?.isOperationSuccessful;

  void _notifyCompletedIfNeeded() {
    if (!isAnyRecordsLoading() &&
        _loadCompleter != null &&
        !_loadCompleter!.isCompleted) {
      _loadCompleter?.complete();
    }
  }

  @override
  void resetController() {
    if (_loadingDescribers.entries.isEmpty) return;
    for (final entry in _loadingDescribers.entries
        .where((element) => !element.value.completer.isCompleted)) {
      onRecordsLoadCancel(query: entry.value.query, loadingKey: entry.key);
      entry.value.completer.complete(CompleteReason.reset);
    }
    _loadingDescribers.clear();
    super.resetController();
  }

  /// Returns the reason why the record loading, identified by
  /// the [loadingKey], was completed.
  Future<CompleteReason?> getCompleteReason(LoadingKey loadingKey) {
    return _loadingDescribers[loadingKey] == null
        ? Future.value()
        : _loadingDescribers[loadingKey]!.completer.future;
  }

  void _cancelIfRecordsLoading(LoadingKey loadingKey) {
    final describer = _loadingDescribers[loadingKey];
    if (describer?.completer.isCompleted == false) {
      onRecordsLoadCancel(query: describer!.query, loadingKey: loadingKey);
      describer.completer.complete(CompleteReason.outOfDate);
    }
  }

  @protected
  Future<void> _loadRecords(Query query,
      {required LoadingKey loadingKey}) async {
    if (_loadCompleter == null || _loadCompleter!.isCompleted) {
      _loadCompleter = Completer();
    }

    final curLoadDescriber =
        _LoadingOperationDescriber<Query>(query: query, completer: Completer());
    _loadingDescribers[loadingKey] = curLoadDescriber;
    try {
      final result =
          await performLoadQuery(query: query, loadingKey: loadingKey);

      if (curLoadDescriber.completer.isCompleted) {
        return;
      }

      putLoadResultToState(
          query: query, loadResult: result, loadingKey: loadingKey);

      curLoadDescriber.completer.complete(CompleteReason.normal);
    } catch (e) {
      if (e is InterruptLoading) {
        curLoadDescriber.completer.complete(CompleteReason.interrupt);
        return;
      }

      curLoadDescriber.isOperationSuccessful = false;

      if (e is HandledLoadingException) {
        curLoadDescriber.completer.complete(CompleteReason.handledException);
        return;
      }

      curLoadDescriber.completer.complete(CompleteReason.error);
      rethrow;
    } finally {
      _notifyCompletedIfNeeded();
    }
  }

  /// Initiates a loading of records limited by the [query] and
  /// identified by [loadingKey].
  void loadRecords(Query query, {LoadingKey loadingKey = defaultLoadingKey}) {
    if (isRecordsLoading(loadingKey, query: query)) return;

    onRecordsLoadStart(query: query, loadingKey: loadingKey);

    _cancelIfRecordsLoading(loadingKey);

    unawaited(_loadRecords(query, loadingKey: loadingKey));
  }

  /// Initiates a repeat of a failed loading attempt identified by
  /// the [loadingKey] key.
  void repeatQuery([LoadingKey loadingKey = defaultLoadingKey]) {
    final loadDesciber = _loadingDescribers[loadingKey];
    if (loadDesciber == null) return;
    loadRecords(loadDesciber.query, loadingKey: loadingKey);
  }

  /// Initiates a repeat of all failed loading attempts.
  void repeatUnsuccessfulQueries() {
    // Possible scenarios:
    // 1. Repeat only one unsuccessful key records loading request.
    //    In this case chunk records loading requirest must not be unsuccessful.
    // 2. Repeat all chunk records loading request.
    //    In this case key records loading request must be successful.

    _loadingDescribers.keys
        .where((describerKey) =>
            _loadingDescribers[describerKey]!.isOperationSuccessful == false)
        .forEach(repeatQuery);
  }
}
