import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

@immutable
class BidirectionalListState<Record, Query> {
  const BidirectionalListState({
    required this.query,
    this.backwardStage = const IdleListStage(),
    this.forwardStage = const IdleListStage(),
    this.recordsOffset = 0,
    this.records = const [],
    this.isInitialized = false,
  });
  /*{
    if (isInitialized && this.records.isEmpty && backwardStage != ListStage.complete() && forwardStage != ListStage.complete()) {
      throw const WrongListStateException('List is empty but has stage marker other than CompleteListStage');
    }
  }*/

  final Query query;
  final List<Record> records;
  final ListStage backwardStage;
  final ListStage forwardStage;
  final int recordsOffset;
  final bool isInitialized;

  BidirectionalListState<Record, Query> copyWith({
    List<Record>? records,
    ListStage? backwardStage,
    ListStage? forwardStage,
    Query? query,
    int? recordsOffset,
    bool? isInitialized,
  }) {
    return BidirectionalListState<Record, Query>(
      recordsOffset: recordsOffset ?? this.recordsOffset,
      query: query ?? this.query,
      records: records ?? this.records,
      backwardStage: backwardStage ?? this.backwardStage,
      forwardStage: forwardStage ?? this.forwardStage,
      isInitialized: isInitialized ?? (this.isInitialized || records != null),
    );
  }

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
        'isInitialized: $isInitialized, backwardStage: $backwardStage, forwardStage: $forwardStage, '
        'recordsOffset: $recordsOffset)';
  }
}
