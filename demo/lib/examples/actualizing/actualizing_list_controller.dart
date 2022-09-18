import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';

typedef ExListState = ListState<ExampleRecord, ExampleRecordQuery>;

class ActualizingListController extends ValueNotifier<ExListState>
    with
        ListCore<ExampleRecord>,
        RecordsLoader<ExampleRecord, ExampleRecordQuery, List<ExampleRecord>>,
        HotList<int, ExampleRecordEvent, ExampleRecord, ExampleRecord> {
  ActualizingListController(this.repository) : super(ExListState(query: const ExampleRecordQuery(weightLte: 100))) {
    loadRecords(value.query);

    initHotList(repository.dbEvents);
  }

  final ExampleRecordRepository repository;

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ExampleRecordQuery query, required LoadingKey? loadingKey}) => value.copyWith(
        stage: ListStage.loading(),
      );

  @override
  Future<List<ExampleRecord>> performLoadQuery({required ExampleRecordQuery query, required LoadingKey loadingKey}) => repository.queryRecords(query);

  @override
  void putLoadResultToState({required ExampleRecordQuery query, required List<ExampleRecord> loadResult, required LoadingKey loadingKey}) {
    value = value.copyWith(
      records: loadResult,
      stage: ListStage.complete(),
    );
  }

  // HotList section:

  @override
  Future<RecordUpdates<ExampleRecord, int>> expandHotListEvents(List<ExampleRecordEvent> events) async {
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
  bool recordFits(ExampleRecord record) => value.query.fits(record);

  @override
  Iterable<ExampleRecord> convertDecisionRecords(Set<ExampleRecord> records) => records;

  @override
  void updateHotList(HotListChanges<ExampleRecord, int> changes) {
    final List<ExampleRecord> newRecordsList = value.records.where((r) => !changes.recordKeysToRemove.contains(r.id)).toList()
      ..insertAll(0, changes.recordsToInsert)
      ..sort(value.query.compareRecords);

    value = value.copyWith(records: newRecordsList);
  }
}
