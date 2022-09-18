import 'package:demo/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_events.dart';
import 'package:demo/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_controller/list_controller.dart';

class LoadResult {
  const LoadResult({required this.records, required this.isFinalPage});

  final List<int> records;
  final bool isFinalPage;
}

typedef KeysetPaginationListState = ListState<int, KeysetPaginationListQuery>;

class KeysetPaginationListController extends Bloc<KeysetPaginationListEvent, KeysetPaginationListState>
    with ListCore<int>, RecordsLoader<int, KeysetPaginationListQuery, LoadResult>, KeysetPagination<int, KeysetPaginationListQuery, LoadResult> {
  KeysetPaginationListController() : super(KeysetPaginationListState(query: const KeysetPaginationListQuery())) {
    on<KeysetPaginationListRecordsLoadStartEvent>(_onRecordsLoadStart);
    on<KeysetPaginationListPutLoadResultToStateEvent>(_onPutLoadResultToState);
    on<KeysetPaginationListLoadNextPageEvent>(_onLoadNextPage);

    loadRecords(state.query);
  }

  static const LoadingKey forwardLoadingKey = 'forward_load';

  @override
  Future<void> close() {
    closeList();
    return super.close();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required KeysetPaginationListQuery query, required LoadingKey loadingKey}) =>
      add(KeysetPaginationListRecordsLoadStartEvent(query: query));

  void _onRecordsLoadStart(KeysetPaginationListRecordsLoadStartEvent event, Emitter<KeysetPaginationListState> emit) {
    emit(state.copyWith(stage: ListStage.loading()));
  }

  @override
  Future<LoadResult> performLoadQuery({required KeysetPaginationListQuery query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return LoadResult(
      records: List<int>.generate(20, (i) => query.weightGt + i + 1),
      isFinalPage: query.weightGt >= 80,
    );
  }

  @override
  void putLoadResultToState({required KeysetPaginationListQuery query, required LoadResult loadResult, required LoadingKey loadingKey}) {
    add(KeysetPaginationListPutLoadResultToStateEvent(loadResult: loadResult));
  }

  void _onPutLoadResultToState(KeysetPaginationListPutLoadResultToStateEvent event, Emitter<KeysetPaginationListState> emit) {
    final records = [
      ...state.records,
      ...event.loadResult.records,
    ];

    emit(state.copyWith(
      records: records,
      stage: event.loadResult.isFinalPage ? ListStage.complete() : ListStage.idle(),
    ));
  }

  // KeysetPagination section:

  void _onLoadNextPage(KeysetPaginationListLoadNextPageEvent event, Emitter<KeysetPaginationListState> emit) => loadNextPage();

  @override
  ListStage getListStage(LoadingKey loadingKey) => state.stage;

  @override
  KeysetPaginationListQuery buildNextPageQuery(LoadingKey loadingKey) => KeysetPaginationListQuery(weightGt: state.records.last);
}
