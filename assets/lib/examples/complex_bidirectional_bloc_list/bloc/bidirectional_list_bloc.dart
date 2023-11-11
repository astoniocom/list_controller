import 'package:demo/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_state.dart';
import 'package:demo/settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';

typedef BidirectionalListStateEx = BidirectionalListState<ExampleRecord, ExampleRecordQuery>;

class BidirectionalListBloc extends Bloc<ListEvent, BidirectionalListStateEx>
    with
        ListCore<ExampleRecord>,
        RecordsLoader<ExampleRecord, ExampleRecordQuery, List<ExampleRecord>>,
        KeysetPagination<ExampleRecord, ExampleRecordQuery, List<ExampleRecord>>,
        HotList<ID, ExampleRecordEvent, ExampleRecord, ExampleRecord> {
  /// [storeSize] — maximum records to store. Infinite when null. ~max((number of items on screen + itemsThreshold) * 2, batch size * 2)
  BidirectionalListBloc({
    required this.storeSize,
    required this.settings,
    required this.repository,
    required this.firstForwardWeight,
    required ExampleRecordQuery query,
  }) : super(BidirectionalListState(query: query)) {
    on<ResetEvent<ExampleRecordQuery>>(_onReset);
    on<RecordsLoadStartEvent<ExampleRecordQuery>>(_onRecordsLoadStart);
    on<LoadingErrorEvent<ExampleRecordQuery>>(_onLoadingError);
    on<PutLoadResultToStateEvent<ExampleRecordQuery, List<ExampleRecord>>>(_onPutLoadResultToState);
    on<RepeatQueryEvent>(_onRepeatQuery);
    on<LoadNextPageDirectedEvent>(_onLoadNextPage);
    on<UpdateHotListEvent<ExampleRecord, ID>>(_onUpdateHotList);

    initHotList(repository.dbEvents);

    add(ResetEvent<ExampleRecordQuery>(query: query));
  }
  final ExampleRecordRepository repository;
  final SettingsController settings;
  final int? storeSize;
  final int? firstForwardWeight;

  static const LoadingKey forwardLoadingKey = 'forward_load';
  static const LoadingKey backwardLoadingKey = 'backward_load';

  @override
  Future<void> close() {
    closeList();
    return super.close();
  }

  // RecordsLoader section:

  void _onReset(ResetEvent<ExampleRecordQuery> event, Emitter<BidirectionalListStateEx> emit) {
    emit(state.copyWith(
      query: event.query,
      records: [],
      isInitialized: false,
      recordsOffset: 0,
    ));

    resetController();

    loadRecords(event.query, loadingKey: forwardLoadingKey);
  }

  @override
  void onRecordsLoadStart({required ExampleRecordQuery query, required LoadingKey loadingKey}) {
    add(RecordsLoadStartEvent<ExampleRecordQuery>(query: query, loadingKey: loadingKey));
  }

  void _onRecordsLoadStart(RecordsLoadStartEvent<ExampleRecordQuery> event, Emitter<BidirectionalListStateEx> emit) {
    emit(state.copyWith(
      backwardStage: event.loadingKey == backwardLoadingKey ? ListStage.loading() : state.backwardStage,
      forwardStage: event.loadingKey == forwardLoadingKey ? ListStage.loading() : state.forwardStage,
    ));
  }

  @override
  Future<List<ExampleRecord>> performLoadQuery({required ExampleRecordQuery query, required String loadingKey}) async {
    try {
      return await repository.queryRecords(
        !state.isInitialized ? query.copyWith(weightGte: firstForwardWeight) : query,
        batchSize: settings.value.batchSize,
        delay: settings.value.responseDelay,
        raiseException: settings.isRaiseException,
      );
    } on TestException {
      add(LoadingErrorEvent<ExampleRecordQuery>(query: query, loadingKey: loadingKey));
      throw HandledLoadingException();
    }
  }

  void _onLoadingError(LoadingErrorEvent<ExampleRecordQuery> event, Emitter<BidirectionalListStateEx> emit) {
    emit(state.copyWith(
      backwardStage: event.loadingKey == backwardLoadingKey ? ListStage.error() : state.backwardStage,
      forwardStage: event.loadingKey == forwardLoadingKey ? ListStage.error() : state.forwardStage,
    ));
  }

  @override
  void putLoadResultToState({required ExampleRecordQuery query, required List<ExampleRecord> loadResult, required LoadingKey loadingKey}) =>
      add(PutLoadResultToStateEvent(query: query, loadResult: loadResult, loadingKey: loadingKey));

  void _onPutLoadResultToState(PutLoadResultToStateEvent<ExampleRecordQuery, List<ExampleRecord>> event, Emitter<BidirectionalListStateEx> emit) {
    final bool isBackwardResult = event.loadingKey == backwardLoadingKey;
    final bool isForwardResult = event.loadingKey == forwardLoadingKey;
    final bool isEndOfList = event.loadResult.isEmpty || event.loadResult.length < settings.value.batchSize;

    if (isBackwardResult) {
      final newRecords = [...event.loadResult.reversed, ...state.records];

      final bool shouldCutList = storeSize != null && newRecords.length > storeSize!;
      final newRecordList = shouldCutList ? newRecords.sublist(0, storeSize) : newRecords;

      emit(state.copyWith(
        recordsOffset: state.recordsOffset - event.loadResult.length,
        records: newRecordList,
        backwardStage: isEndOfList ? ListStage.complete() : ListStage.idle(),
        forwardStage: shouldCutList ? ListStage.idle() : state.forwardStage,
      ));
      // debugPrint(newRecordList.map((e) => e.weight).join(', '));
    } else if (isForwardResult) {
      final newRecords = [...state.records, ...event.loadResult];
      final bool shouldCutList = storeSize != null && newRecords.length > storeSize!;
      final newRecordList = shouldCutList ? newRecords.sublist(newRecords.length - storeSize!) : newRecords;
      final offset = !state.isInitialized ? -(newRecordList.length ~/ 3) : state.recordsOffset;
      emit(state.copyWith(
        recordsOffset: shouldCutList ? offset + state.listLength + event.loadResult.length - storeSize! : offset,
        records: newRecordList,
        backwardStage: shouldCutList ? ListStage.idle() : state.backwardStage,
        forwardStage: isEndOfList ? ListStage.complete() : ListStage.idle(),
      ));
      // debugPrint(newRecordList.map((e) => e.weight).join(', '));
    }
  }

  void _onRepeatQuery(RepeatQueryEvent event, Emitter<BidirectionalListStateEx> emit) => repeatQuery(event.loadingKey);

  // KaysetPagination section:

  @override
  LoadStrategy get loadStrategy => storeSize != null ? LoadStrategy.sequential : LoadStrategy.concurrent;

  @override
  ListStage getListStage(LoadingKey loadingKey) {
    if (loadingKey == backwardLoadingKey) {
      return state.backwardStage;
    } else if (loadingKey == forwardLoadingKey) {
      return state.forwardStage;
    }

    throw const UnexpectedLoadingKeyException();
  }

  @override
  ExampleRecordQuery buildNextPageQuery(LoadingKey loadingKey) {
    if (loadingKey == backwardLoadingKey) {
      return state.query.copyWith(
        weightLt: state.records.first.weight,
        revesed: true,
      );
    } else if (loadingKey == forwardLoadingKey) {
      return state.query.copyWith(weightGt: state.records.last.weight);
    }

    throw const UnexpectedLoadingKeyException();
  }

  void _onLoadNextPage(LoadNextPageDirectedEvent event, Emitter<BidirectionalListStateEx> emit) {
    loadNextPage(event.loadingKey);
  }

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
  bool hasListRecord(ID key) => state.records.map((record) => record.id).contains(key);

  @override
  bool recordFits(ExampleRecord record) {
    return state.query
        .copyWith(
          weightGte: state.backwardStage == ListStage.complete() ? defInt : state.records.first.weight,
          weightLte: state.forwardStage == ListStage.complete() ? defInt : state.records.last.weight,
        )
        .fits(record);
  }

  @override
  Iterable<ExampleRecord> convertDecisionRecords(Set<ExampleRecord> records) => records;

  @override
  void updateHotList(HotListChanges<ExampleRecord, ID> changes) => add(UpdateHotListEvent(changes: changes));

  void _onUpdateHotList(UpdateHotListEvent<ExampleRecord, ID> event, Emitter<BidirectionalListStateEx> emit) {
    final recordsToRemove = state.records.where((r) => event.changes.recordKeysToRemove.contains(r.id));

    final result = List.of(state.records)
      ..removeWhere(recordsToRemove.contains)
      ..insertAll(0, event.changes.recordsToInsert)
      ..sort(state.query.compareRecords);

    emit(state.copyWith(records: result));
  }
}
