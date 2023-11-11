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
  ///
  /// Typically, this means that the first data retrieval was successful
  /// (even though the data itself might not have been there).
  ///
  /// However, a value of false does not always mean that the list is empty.
  /// List entries may have been set by default or left over from a previous
  /// list lifecycle.
  /// {@endtemplate}
  final bool isInitialized;
}

/// Stores the list state.
@immutable
class ListState<Record, Query> implements ListStateMeta {
  /// Creates a list state.
  const ListState({
    required this.query,
    this.records = const [],
    this.stage = const IdleListStage(),
    this.isInitialized = false,
  });

  /// Stores list records.
  final List<Record> records;

  /// Description of the criteria of the records included in the list.
  final Query query;

  @override
  final ListStage stage;

  /// {@macro list_controller.helpers.ListStateMeta.isInitialized}
  @override
  final bool isInitialized;

  /// Creates a copy of this list state but with the given fields replaced with
  /// the new values.
  ///
  /// If the list is not initialised and [isInitialized] parameter is not
  /// provided and new [records] are being provided,
  /// the initialisation marker will be set automatically. Since this is almost
  /// always the expected behaviour.
  ListState<Record, Query> copyWith({
    List<Record>? records,
    ListStage? stage,
    Query? query,
    bool? isInitialized,
  }) {
    return ListState<Record, Query>(
      records: records ?? this.records,
      stage: stage ?? this.stage,
      query: query ?? this.query,
      isInitialized: isInitialized ?? (this.isInitialized || records != null),
    );
  }

  /// Whether the list is at the stage of loading records.
  bool get isLoading => stage is LoadingListStage;

  @override
  int get hashCode => Object.hash(records, stage, query);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final eq = const ListEquality().equals;
    return other is ListState<Record, Query> &&
        eq(records, other.records) &&
        query == other.query &&
        stage == other.stage;
  }

  /// {@macro list_controller.helpers.ListStateMeta.isEmpty}
  @override
  bool get isEmpty => records.isEmpty;

  @override
  String toString() {
    return 'ListState(isInitialized: $isInitialized, stage: $stage, '
        'recordsLen: ${records.length})';
  }
}
