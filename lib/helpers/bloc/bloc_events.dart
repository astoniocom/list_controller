import 'package:list_controller/list_controller.dart';
import 'package:meta/meta.dart';

/// A base class for list controller events.
abstract class ListEvent {
  /// Abstract const constructor.
  const ListEvent();
}

/// Triggers the resettings of a list controller.
///
/// Usually `ListCore.resetController` function that should be called
/// in the handler.
@immutable
class ResetEvent<Query> extends ListEvent {
  /// Creates a reset event.
  ///
  /// [query] is a new records constraints that the list controller
  /// must work with.
  const ResetEvent({
    required this.query,
  });

  /// New records constraints that the list controller must work with.
  final Query query;

  @override
  int get hashCode => query.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is ResetEvent<Query> && query == other.query;
  }
}

/// Initiates the loading of records.
///
/// Mirrors the `RecordsLoader.loadRecords` function that should be called
/// in the handler.
@immutable
class LoadRecordsEvent<Query> extends ListEvent {
  /// Creates a new [LoadRecordsEvent].
  const LoadRecordsEvent({
    required this.query,
    required this.loadingKey,
  });

  /// Query to perform.
  final Query query;

  /// Key identifying the load.
  final LoadingKey loadingKey;

  @override
  int get hashCode => Object.hash(query, loadingKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is LoadRecordsEvent<Query> &&
        query == other.query &&
        loadingKey == other.loadingKey;
  }
}

/// The event must be called from the overridden function
/// `RecordsLoader.onRecordsLoadStart`. The handler must perform the same
/// actions as those for this function.
@immutable
class RecordsLoadStartEvent<Query> extends ListEvent {
  /// Creates a new [RecordsLoadStartEvent].
  const RecordsLoadStartEvent({
    required this.query,
    required this.loadingKey,
  });

  /// The query that is being executed.
  final Query query;

  /// Key identifying the load.
  final LoadingKey loadingKey;

  @override
  int get hashCode => Object.hash(query, loadingKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is RecordsLoadStartEvent<Query> &&
        query == other.query &&
        loadingKey == other.loadingKey;
  }
}

/// The event can be used when an error occurs in the overridden
/// `RecordsLoader.performLoadQuery` function.
///
/// It should be used to set an error in the list state. Normally,
/// a `HandledLoadingException` should be thrown after this event is called.
@immutable
class LoadingErrorEvent<Query> extends ListEvent {
  /// Creates a new [LoadingErrorEvent].
  const LoadingErrorEvent({
    required this.query,
    required this.loadingKey,
    this.error,
  });

  /// A query, the execution of which failed.
  final Query query;

  /// The object describing the problem that occurred.
  final Object? error;

  /// Key identifying the load.
  final LoadingKey loadingKey;

  @override
  int get hashCode => Object.hash(query, loadingKey, error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is LoadingErrorEvent<Query> &&
        query == other.query &&
        loadingKey == other.loadingKey &&
        error == other.error;
  }
}

/// The event must be called from the overridden function
/// `RecordsLoader.onRecordsLoadCancel`. The handler must perform the same
/// actions as those for this function.
@immutable
class RecordsLoadCancelEvent<Query> extends ListEvent {
  /// Creates a new [RecordsLoadCancelEvent].
  const RecordsLoadCancelEvent({
    required this.query,
    required this.loadingKey,
  });

  /// Request whose execution was canceled.
  final Query query;

  /// Key identifying the load.
  final LoadingKey loadingKey;

  @override
  int get hashCode => Object.hash(query, loadingKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is RecordsLoadCancelEvent<Query> &&
        query == other.query &&
        loadingKey == other.loadingKey;
  }
}

/// The event must be called from the overridden function
/// `RecordsLoader.putLoadResultToState`.
///
/// The handler must perform the same actions as those for this function.
@immutable
class PutLoadResultToStateEvent<Query, LoadResult> extends ListEvent {
  /// Creates a new [PutLoadResultToStateEvent].
  const PutLoadResultToStateEvent({
    required this.query,
    required this.loadingKey,
    required this.loadResult,
  });

  /// The query that was executed.
  final Query query;

  /// Key identifying the load.
  final LoadingKey loadingKey;

  /// The result of the loading, which should be placed in the list state.
  final LoadResult loadResult;

  @override
  int get hashCode => Object.hash(query, loadingKey, loadResult);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is PutLoadResultToStateEvent<Query, LoadResult> &&
        query == other.query &&
        loadingKey == other.loadingKey &&
        loadResult == other.loadResult;
  }
}

/// Triggers the reloading of records in case the previous attempt failed.
///
/// Mirrors the `RecordsLoader.repeatQuery` function that should be called
/// in the handler.
@immutable
class RepeatQueryEvent extends ListEvent {
  /// Creates a new [RepeatQueryEvent] with an optional [loadingKey].
  const RepeatQueryEvent({
    this.loadingKey = RecordsLoader.defaultLoadingKey,
  });

  /// Key identifying the load to repeat.
  final LoadingKey loadingKey;

  @override
  int get hashCode => loadingKey.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is RepeatQueryEvent && loadingKey == other.loadingKey;
  }
}

/// Initiates a rerun of all failed loadings.
@immutable
class RepeatUnsuccessfulQueriesEvent extends ListEvent {
  /// Creates a new [RepeatUnsuccessfulQueriesEvent].
  const RepeatUnsuccessfulQueriesEvent();

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is RepeatUnsuccessfulQueriesEvent;
  }
}

/// Triggers the loading of the next page of records.
///
/// Usually used together with the `KeysetPagination` or `OffsetPagination`
/// mixins and used to call the `KeysetPagination.loadNextPage` or
/// `OffsetPagination.loadPage` functions respectively.
@immutable
class LoadNextPageEvent extends ListEvent {
  /// Creates a new [LoadNextPageEvent].
  const LoadNextPageEvent();

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is LoadNextPageEvent;
  }
}

/// Triggers the loading of the next page of records.
///
/// Usually used together with the `KeysetPagination` or `OffsetPagination`
/// mixins and used to call the `KeysetPagination.loadNextPage` or
/// `OffsetPagination.loadPage` functions respectively.
/// It is used for handling lists that have two or more directions of
/// records to load.
@immutable
class LoadNextPageDirectedEvent extends ListEvent {
  /// Creates a new [LoadNextPageDirectedEvent].
  const LoadNextPageDirectedEvent({required this.loadingKey});

  /// Key identifying the load for the direction.
  final LoadingKey loadingKey;

  @override
  int get hashCode => loadingKey.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is LoadNextPageDirectedEvent && loadingKey == other.loadingKey;
  }
}

/// The event must be called from an overridden function
/// `HotList.updateHotList`. The handler must perform the same actions
/// as for this function.
@immutable
class UpdateHotListEvent<Record, Key> extends ListEvent {
  /// Creates a new [UpdateHotListEvent].
  const UpdateHotListEvent({required this.changes});

  /// Changes that should be reflected in the list state.
  final HotListChanges<Record, Key> changes;

  @override
  int get hashCode => changes.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is UpdateHotListEvent<Record, Key> && changes == other.changes;
  }
}
