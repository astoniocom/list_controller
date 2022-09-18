import 'dart:async';

import 'package:list_controller/list_controller.dart';
import 'package:meta/meta.dart';

/// The loading strategy by which `KeysetPagination` should work.
enum LoadStrategy {
  /// Loading operations with different loading keys can be performed
  /// simultaneously.
  concurrent,

  /// Loading operations with different loading keys should by performed
  /// one after the other.
  sequential,
}

/// Implements the loading of the next page of records based on previously
/// loaded records.
///
/// In the list of mixins, it should be placed after `RecordsLoader`.
mixin KeysetPagination<Record, Query, LoadResult>
    on RecordsLoader<Record, Query, LoadResult> {
  /// The function must convert the current state of the list into an object
  /// representing the current stage of the list (`ListStage.idle()`,
  /// `ListStage.error()`, `ListStage.loading()`, `ListStage.complete()`).
  @protected
  ListStage getListStage(LoadingKey loadingKey);

  /// Based on `loadingKey`, the function should build a `Query` object that
  /// will be used to load the next page of the list by the
  /// `performLoadingQuery()` function.
  @protected
  Query buildNextPageQuery(LoadingKey loadingKey);

  /// The loading strategy by which `KeysetPagination` is working.
  @visibleForTesting
  @protected
  LoadStrategy get loadStrategy => LoadStrategy.concurrent;

  bool _canLoadNextPage(LoadingKey loadingKey) {
    final listStage = getListStage(loadingKey);

    // Don't include if list is empty here
    return !isRecordsLoading(loadingKey) &&
        (isLoadSucessful(loadingKey) ?? true) == true &&
        listStage != ListStage.complete();
  }

  Future<void> _loadNextPage(LoadingKey loadingKey) async {
    if (actualizeCompleter?.isCompleted == false) {
      // The app should wait updating is finished before building query for
      // getting the next page
      await actualizeCompleter!.future;
    }

    if (!_canLoadNextPage(loadingKey)) {
      return;
    }

    if (loadStrategy == LoadStrategy.sequential && isAnyRecordsLoading()) {
      await waitAllLoadsToComplete();
      if (isListClosed) {
        return;
      }
    }

    final query = buildNextPageQuery(loadingKey);

    loadRecords(query, loadingKey: loadingKey);
  }

  /// Initiates the loading of the next page of records.
  void loadNextPage([LoadingKey loadingKey = RecordsLoader.defaultLoadingKey]) {
    unawaited(_loadNextPage(loadingKey));
  }
}
