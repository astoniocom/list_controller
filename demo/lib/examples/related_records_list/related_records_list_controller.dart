import 'dart:async';

import 'package:demo/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';

typedef ExListState = ListState<ExpandedExampleRecord, ExampleRecordQuery>;

class RelatedRecordsListController extends ValueNotifier<ExListState>
    with
        ListCore<ExpandedExampleRecord>,
        RecordsLoader<ExpandedExampleRecord, ExampleRecordQuery, List<ExpandedExampleRecord>>,
        KeysetPagination<ExpandedExampleRecord, ExampleRecordQuery, List<ExpandedExampleRecord>>,
        HotList<ID, ExampleRecordEvent, ExampleRecord, ExpandedExampleRecord> {
  RelatedRecordsListController({
    required this.settings,
    required this.repository,
    ExListState? initialState,
  }) : super(initialState ?? const ExListState(query: ExampleRecordQuery())) {
    initHotList(repository.dbEvents);

    loadRecords(value.query);
  }

  final SettingsController settings;
  final ExampleRecordRepository repository;

  @override
  void dispose() {
    closeList();
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
  Future<List<ExpandedExampleRecord>> performLoadQuery({required ExampleRecordQuery query, required LoadingKey loadingKey}) async {
    try {
      final records = await repository.queryRecords(
        query,
        batchSize: settings.value.batchSize,
        delay: settings.value.responseDelay,
        raiseException: settings.isRaiseException,
      );
      return repository.expandRecords(records);
    } on TestException {
      value = value.copyWith(stage: ListStage.error());
      throw HandledLoadingException();
    }
  }

  @override
  void putLoadResultToState({required ExampleRecordQuery query, required List<ExpandedExampleRecord> loadResult, required LoadingKey loadingKey}) {
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
    if (value.stage == ListStage.complete()) value.query.fits(record);

    return value.query.copyWith(weightLte: value.records.last.weight).fits(record);
  }

  @override
  Future<Iterable<ExpandedExampleRecord>> convertDecisionRecords(Set<ExampleRecord> records) => repository.expandRecords(records);

  @override
  void updateHotList(HotListChanges<ExpandedExampleRecord, ID> changes) {
    final recordsToRemove = value.records.where((r) => changes.recordKeysToRemove.contains(r.id));

    final resultRecords = List.of(value.records)
      ..removeWhere(recordsToRemove.contains)
      ..insertAll(0, changes.recordsToInsert)
      ..sort(value.query.compareRecords);

    value = value.copyWith(records: resultRecords);
  }
}
