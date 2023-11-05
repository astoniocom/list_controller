import 'package:collection/collection.dart';
import 'package:list_controller/list_controller.dart';
import 'package:meta/meta.dart';

/// Stores basic information about the list state.
class ListStateMeta {
  /// Creates a description of a list state.
  const ListStateMeta({
    required this.isEmpty,
    required this.stage,
    required this.isInitialized,
  });

  /// {@template list_controller.helpers.ListStateMeta.isEmpty}
  /// Whether the list has no records.
  /// {@endtemplate}
  final bool isEmpty;

  /// {@template list_controller.helpers.ListStateMeta.stage}
  /// Stage the list is at.
  /// {@endtemplate}
  final ListStage stage;

  /// {@template list_controller.helpers.ListStateMeta.isInitialized}
  /// Whether the list is initialized.
  /// {@endtemplate}
  final bool isInitialized;
}

/// Stores the list state.
@immutable
class ListState<Record, Query> implements ListStateMeta {
  /// Creates a list state.
  const ListState({
    required this.query,
    List<Record>? records,
    this.stage = const IdleListStage(),
  }) : recordsStore = records;

  /// Stores list records.
  ///
  /// If the list is not initialized, the value is null. If you want to have an
  /// empty list instead of null, use [records].
  final List<Record>? recordsStore;

  /// Description of the criteria of the records included in the list.
  final Query query;

  @override
  final ListStage stage;

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

  /// {@macro list_controller.helpers.ListStateMeta.isEmpty}
  @override
  bool get isEmpty => records.isEmpty;

  /// {@macro list_controller.helpers.ListStateMeta.isInitialized}
  @override
  bool get isInitialized => recordsStore != null;

  @override
  String toString() {
    return 'ListState(isInitialized: $isInitialized, stage: $stage, '
        'recordsLen: ${records.length})';
  }
}
