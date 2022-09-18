import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';

class ListState {
  const ListState({
    this.pages = const {},
    this.recordsCount = 0,
    this.query = const ExampleRecordQuery(),
  });

  final Map<int, List<ExampleRecord>> pages;
  final int recordsCount;
  final ExampleRecordQuery query;

  ListState copyWith({Map<int, List<ExampleRecord>>? pages, int? recordsCount, ExampleRecordQuery? query}) {
    return ListState(
      pages: pages ?? this.pages,
      recordsCount: recordsCount ?? this.recordsCount,
      query: query ?? this.query,
    );
  }
}

const pageSize = 12;
const totalRecords = 10000;

class HotHugeListController extends ValueNotifier<ListState>
    with
        ListCore<ExampleRecord>,
        RecordsLoader<ExampleRecord, ExampleRecordQuery, List<ExampleRecord>>,
        OffsetPagination<ExampleRecord, ExampleRecordQuery, List<ExampleRecord>, int>,
        HotList<ID, ExampleRecordEvent, ExampleRecord, ExampleRecord> {
  HotHugeListController({required this.repository, this.cacheSize = 16}) : super(const ListState()) {
    initHotList(repository.dbEvents);
    loadPage(0);
  }

  final ExampleRecordRepository repository;
  final int cacheSize;

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ExampleRecordQuery query, required LoadingKey loadingKey}) {}

  @override
  Future<List<ExampleRecord>> performLoadQuery({required ExampleRecordQuery query, required LoadingKey loadingKey}) async {
    return repository.queryRecords(
      query,
      batchSize: pageSize,
      delay: const Duration(milliseconds: 1500),
    );
  }

  @override
  void putLoadResultToState({required ExampleRecordQuery query, required List<ExampleRecord> loadResult, required LoadingKey loadingKey}) {
    final records = Map.of(value.pages);
    records[query.page!] = loadResult;
    if (records.length > cacheSize) {
      records.remove(records.keys.first);
    }
    value = value.copyWith(pages: records, recordsCount: totalRecords);
  }

  // HotList section:

  @override
  Future<RecordUpdates<ExampleRecord, ID>> expandHotListEvents(List<ExampleRecordEvent> events) async {
    final Iterable<ID> updatedIds = events.whereType<ExampleRecordUpdatedEvent>().map((event) => event.id);

    return RecordUpdates(
      updatedRecords: await repository.getByIds(updatedIds),
    );
  }

  @override
  ID getDecisionRecordKey(ExampleRecord record) => record.id;

  @override
  bool hasListRecord(ID key) => value.pages.values.expand((element) => element).map((record) => record.id).contains(key);

  @override
  bool recordFits(ExampleRecord record) => value.query.fits(record);

  @override
  Iterable<ExampleRecord> convertDecisionRecords(Set<ExampleRecord> records) => records;

  @override
  void updateHotList(HotListChanges<ExampleRecord, ID> changes) {
    final Map<int, List<ExampleRecord>> pages = {};

    for (final pageEntry in value.pages.entries) {
      final recordsToRemove = pageEntry.value.where((r) => changes.recordKeysToRemove.contains(r.id));
      if (recordsToRemove.isEmpty) {
        pages[pageEntry.key] = pageEntry.value;
        continue;
      }

      final recordsToRemoveIds = recordsToRemove.map((e) => e.id);

      final recordsToInsert = changes.recordsToInsert.where((r) => recordsToRemoveIds.contains(r.id));

      pages[pageEntry.key] = List.of(pageEntry.value)
        ..removeWhere(recordsToRemove.contains)
        ..insertAll(0, recordsToInsert)
        ..sort(value.query.compareRecords);
    }

    value = value.copyWith(pages: pages);
  }

  // OffsetPagination section

  @override
  String offsetToLoadingKey(int offset) => 'page$offset';

  @override
  ExampleRecordQuery buildOffsetQuery(int offset) => value.query.copyWith(page: offset);
}
