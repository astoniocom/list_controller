import 'package:collection/collection.dart';
import 'package:list_controller/list_controller.dart';
import 'package:meta/meta.dart';

/// Stores basic information about the list state.
@immutable
class ListStateMeta {
  /// Creates a description of a list state.
  ListStateMeta({
    required this.isEmpty,
    required this.stage,
    required this.isInitialized,
  }) {
    if (isInitialized && isEmpty && stage != ListStage.complete()) {
      throw const WrongListStateException(
          'List is empty but has stage marker other than CompleteListStage');
    }
  }

  /// Whether the list has no records.
  final bool isEmpty;

  /// Stage the list is at.
  final ListStage stage;

  /// Whether the list is initialized.
  final bool isInitialized;
}

/// Stores the list state.
@immutable
class ListState<Record, Query> extends ListStateMeta {
  /// Creates a list state.
  ListState({
    required this.query,
    List<Record>? records,
    ListStage stage = const IdleListStage(),
  })  : recordsStore = records,
        super(
          stage: stage,
          isInitialized: records != null,
          isEmpty: records?.isEmpty ?? true,
        );

  /// Stores list records.
  ///
  /// If the list is not initialized, the value is null. If you want to have an
  /// empty list instead of null, use [records].
  final List<Record>? recordsStore;

  /// Description of the criteria of the records included in the list.
  final Query query;

  /// Creates a copy of this list state but with the given fields replaced with
  /// the new values.
  ListState<Record, Query> copyWith({
    List<Record>? records = const DefaultList(),
    ListStage? stage,
    Query? query,
  }) {
    return ListState<Record, Query>(
      records: records is DefaultList ? recordsStore : records,
      stage: stage ?? this.stage,
      query: query ?? this.query,
    );
  }

  /// Returns the list of records.
  List<Record> get records => recordsStore ?? List<Record>.empty();

  /// Whether the list is at the stage of loading records.
  bool get isLoading => stage is LoadingListStage;

  @override
  int get hashCode => Object.hash(
      recordsStore != null ? recordsStore!.hashCode : null, stage, query);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final eq = const ListEquality().equals;
    return other is ListState<Record, Query> &&
        eq(recordsStore, other.recordsStore) &&
        query == other.query &&
        stage == other.stage;
  }

  @override
  String toString() {
    return 'ListState(isInitialized=$isInitialized, stage=$stage, '
        'recordsLen=${records.length})';
  }
}
