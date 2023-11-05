import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

@immutable
class BidirectionalListState<Record, Query> {
  const BidirectionalListState({
    required this.query,
    this.backwardStage = const IdleListStage(),
    this.forwardStage = const IdleListStage(),
    this.recordsOffset = 0,
    List<Record>? records,
  }) : _recordsStore = records;
  /*{
    if (isInitialized && this.records.isEmpty && backwardStage != ListStage.complete() && forwardStage != ListStage.complete()) {
      throw const WrongListStateException('List is empty but has stage marker other than CompleteListStage');
    }
  }*/

  final Query query;
  final List<Record>? _recordsStore;
  final ListStage backwardStage;
  final ListStage forwardStage;
  final int recordsOffset;

  BidirectionalListState<Record, Query> copyWith({
    List<Record>? records = const DefaultList(),
    ListStage? backwardStage,
    ListStage? forwardStage,
    Query? query,
    int? recordsOffset,
  }) {
    return BidirectionalListState<Record, Query>(
      recordsOffset: recordsOffset ?? this.recordsOffset,
      query: query ?? this.query,
      records: records is DefaultList ? _recordsStore : records,
      backwardStage: backwardStage ?? this.backwardStage,
      forwardStage: forwardStage ?? this.forwardStage,
    );
  }

  List<Record> get records => _recordsStore ?? List<Record>.empty();

  bool get isInitialized => _recordsStore != null;

  int get listLength => records.length;

  ListStateMeta get backwardMeta => ListStateMeta(
        stage: backwardStage,
        isEmpty: records.isEmpty && backwardStage == ListStage.complete(),
        isInitialized: isInitialized,
      );

  ListStateMeta get forwardMeta => ListStateMeta(
        stage: forwardStage,
        isEmpty: records.isEmpty && forwardStage == ListStage.complete(),
        isInitialized: isInitialized,
      );

  @override
  String toString() {
    return 'BidirectionalListState(recordsLength: $listLength, cachedLength: ${records.length}, '
        'isInitialized: $isInitialized, backwardStage: $backwardStage, forwardStage: $forwardStage)';
  }
}
