import 'dart:async';

import 'package:demo/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';

typedef ExListState = ListState<ExampleRecord, ExampleRecordQuery>;

class ComplexListController extends ValueNotifier<ExListState>
    with
        ListCore<ExampleRecord>,
        RecordsLoader<ExampleRecord, ExampleRecordQuery, List<ExampleRecord>>,
        KeysetPagination<ExampleRecord, ExampleRecordQuery, List<ExampleRecord>>,
        HotList<ID, ExampleRecordEvent, ExampleRecord, ExampleRecord> {
  ComplexListController({
    required this.settings,
    required this.repository,
    ExListState? initialState,
    bool initLoad = true, // for testing
  }) : super(initialState ?? ExListState(query: const ExampleRecordQuery())) {
    addListener(_changeListener); // for testing
    initHotList(repository.dbEvents);

    if (initLoad) {
      loadRecords(value.query);
    }
  }

  final SettingsController settings;
  final ExampleRecordRepository repository;

  static const LoadingKey forwardLoadingKey = 'forward_load';

  // For testing
  final streamController = StreamController<ExListState>();
  void _changeListener() => streamController.add(value);

  @override
  void dispose() {
    closeList();
    unawaited(streamController.close());
    super.dispose();
  }

  void reset(ExampleRecordQuery query) {
    value = value.copyWith(query: query, records: null);

    resetController();

    loadRecords(query);
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ExampleRecordQuery query, required LoadingKey loadingKey}) {
    value = value.copyWith(stage: ListStage.loading());
  }

  @override
  Future<List<ExampleRecord>> performLoadQuery({required ExampleRecordQuery query, required LoadingKey loadingKey}) async {
    try {
      return await repository.queryRecords(
        query,
        batchSize: settings.value.batchSize,
        delay: settings.value.responseDelay,
        raiseException: settings.isRaiseException,
      );
    } on TestException {
      value = value.copyWith(stage: ListStage.error());
      throw HandledLoadingException();
    }
  }

  @override
  void putLoadResultToState({required ExampleRecordQuery query, required List<ExampleRecord> loadResult, required LoadingKey loadingKey}) {
    final records = [
      ...value.records,
      ...loadResult,
    ];
    value = value.copyWith(
      records: records,
      stage: loadResult.length < settings.value.batchSize ? ListStage.complete() : ListStage.idle(),
    );
  }

  // KeysetPagination section:

  @override
  ListStage getListStage(LoadingKey loadingKey) => value.stage;

  @override
  ExampleRecordQuery buildNextPageQuery(LoadingKey loadingKey) => value.query.copyWith(weightGt: value.records.last.weight);

  // HotList section:

  @override
  Future<RecordUpdates<ExampleRecord, ID>> expandHotListEvents(List<ExampleRecordEvent> events) async {
    final Iterable<ID> createdIds = events.whereType<ExampleRecordCreatedEvent>().map((event) => event.id);
    final Iterable<ID> updatedIds = events.whereType<ExampleRecordUpdatedEvent>().map((event) => event.id);
    final List<ExampleRecord> retrievedRecords = await repository.getByIds({...createdIds, ...updatedIds});

    return RecordUpdates(
      insertedRecords: retrievedRecords.where((r) => createdIds.contains(r.id)),
      updatedRecords: retrievedRecords.where((r) => updatedIds.contains(r.id)),
      deletedKeys: events.whereType<ExampleRecordDeletedEvent>().map((e) => e.id),
    );
  }

  @override
  ID getDecisionRecordKey(ExampleRecord record) => record.id;

  @override
  bool hasListRecord(ID key) => value.records.map((record) => record.id).contains(key);

  @override
  bool recordFits(ExampleRecord record) {
    if (!value.isInitialized) return false;
    if (value.stage == ListStage.complete()) value.query.fits(record);

    return value.query.copyWith(weightLte: value.records.last.weight).fits(record);
  }

  @override
  Iterable<ExampleRecord> convertDecisionRecords(Set<ExampleRecord> records) => records;

  @override
  void updateHotList(HotListChanges<ExampleRecord, ID> changes) {
    final recordsToRemove = value.records.where((r) => changes.recordKeysToRemove.contains(r.id));

    final resultRecords = List.of(value.records)
      ..removeWhere(recordsToRemove.contains)
      ..insertAll(0, changes.recordsToInsert)
      ..sort(value.query.compareRecords);

    value = value.copyWith(records: resultRecords);
  }
}
