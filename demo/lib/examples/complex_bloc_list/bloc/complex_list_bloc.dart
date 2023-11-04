import 'dart:async';
import 'package:demo/settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';

typedef ExListState = ListState<ExampleRecord, ExampleRecordQuery>;

class ComplexListBloc extends Bloc<ListEvent, ExListState>
    with
        ListCore<ExampleRecord>,
        RecordsLoader<ExampleRecord, ExampleRecordQuery, List<ExampleRecord>>,
        KeysetPagination<ExampleRecord, ExampleRecordQuery, List<ExampleRecord>>,
        HotList<ID, ExampleRecordEvent, ExampleRecord, ExampleRecord> {
  ComplexListBloc({
    required this.settings,
    required this.repository,
    ExListState? initialState,
    this.expandRecordsDelay = Duration.zero,
    bool initLoad = true, // for testing
  }) : super(initialState ?? const ExListState(query: ExampleRecordQuery())) {
    on<ResetEvent<ExampleRecordQuery>>(_onReset);
    on<RecordsLoadStartEvent<ExampleRecordQuery>>(_onRecordsLoadStart);
    on<LoadingErrorEvent<ExampleRecordQuery>>(_onLoadingError);
    on<PutLoadResultToStateEvent<ExampleRecordQuery, List<ExampleRecord>>>(_onPutLoadResultToState);
    on<RepeatQueryEvent>(_onRepeatQuery);
    on<LoadNextPageEvent>(_onLoadNextPage);
    on<UpdateHotListEvent<ExampleRecord, ID>>(_onUpdateHotList);

    initHotList(repository.dbEvents);

    if (initLoad) {
      loadRecords(state.query);
    }
  }

  final ExampleRecordRepository repository;
  final SettingsController settings;
  final Duration expandRecordsDelay; // for testing only

  @override
  Future<void> close() {
    closeList();
    return super.close();
  }

  // RecordsLoader section:

  void _onReset(ResetEvent<ExampleRecordQuery> event, Emitter<ExListState> emit) {
    emit(state.copyWith(
      query: event.query,
      records: null,
    ));

    resetController();

    loadRecords(event.query);
  }

  @override
  void onRecordsLoadStart({required ExampleRecordQuery query, required LoadingKey loadingKey}) =>
      add(RecordsLoadStartEvent(query: query, loadingKey: loadingKey));

  void _onRecordsLoadStart(RecordsLoadStartEvent<ExampleRecordQuery> event, Emitter<ExListState> emit) {
    emit(state.copyWith(stage: ListStage.loading()));
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
      add(LoadingErrorEvent<ExampleRecordQuery>(query: query, loadingKey: loadingKey));
      throw HandledLoadingException();
    }
  }

  void _onLoadingError(LoadingErrorEvent<ExampleRecordQuery> event, Emitter<ExListState> emit) {
    emit(state.copyWith(
      stage: ListStage.error(),
    ));
  }

  @override
  void putLoadResultToState({required ExampleRecordQuery query, required List<ExampleRecord> loadResult, required LoadingKey loadingKey}) =>
      add(PutLoadResultToStateEvent(query: query, loadResult: loadResult, loadingKey: loadingKey));

  void _onPutLoadResultToState(PutLoadResultToStateEvent<ExampleRecordQuery, List<ExampleRecord>> event, Emitter<ExListState> emit) {
    final records = [
      ...state.records,
      ...event.loadResult,
    ];

    emit(state.copyWith(
      records: records,
      stage: event.loadResult.length < settings.value.batchSize ? ListStage.complete() : ListStage.idle(),
    ));
  }

  void _onRepeatQuery(RepeatQueryEvent event, Emitter<ExListState> emit) => repeatQuery();

  // KeysetPagination section:

  void _onLoadNextPage(LoadNextPageEvent event, Emitter<ExListState> emit) {
    loadNextPage();
  }

  @override
  ListStage getListStage(LoadingKey loadingKey) => state.stage;

  @override
  ExampleRecordQuery buildNextPageQuery(LoadingKey loadingKey) {
    if (state.query.revesed) {
      return state.query.copyWith(weightLt: state.records.last.weight);
    } else {
      return state.query.copyWith(weightGt: state.records.last.weight);
    }
  }

  // HotList section:

  @override
  Future<RecordUpdates<ExampleRecord, ID>> expandHotListEvents(List<ExampleRecordEvent> events) async {
    await Future.delayed(expandRecordsDelay);
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
  bool hasListRecord(ID key) => state.records.map((record) => record.id).contains(key);

  @override
  bool recordFits(ExampleRecord record) {
    if (!state.isInitialized) return false;
    if (state.stage == ListStage.complete()) return state.query.fits(record);
    if (!state.query.revesed) {
      return state.query.copyWith(weightLte: state.records.last.weight).fits(record);
    } else {
      return state.query.copyWith(weightGte: state.records.last.weight).fits(record);
    }
  }

  @override
  Iterable<ExampleRecord> convertDecisionRecords(Set<ExampleRecord> records) => records;

  @override
  void updateHotList(HotListChanges<ExampleRecord, ID> changes) => add(UpdateHotListEvent(changes: changes));

  void _onUpdateHotList(UpdateHotListEvent<ExampleRecord, ID> event, Emitter<ExListState> emit) {
    final recordsToRemove = state.records.where((r) => event.changes.recordKeysToRemove.contains(r.id));

    final resultRecords = List.of(state.records)
      ..removeWhere(recordsToRemove.contains)
      ..insertAll(0, event.changes.recordsToInsert)
      ..sort(state.query.compareRecords);

    emit(state.copyWith(records: resultRecords));
  }
}
