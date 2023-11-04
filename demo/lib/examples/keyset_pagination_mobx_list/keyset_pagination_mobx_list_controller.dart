import 'package:equatable/equatable.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mobx/mobx.dart';

part 'keyset_pagination_mobx_list_controller.g.dart';

class ListQuery extends Equatable {
  const ListQuery({this.weightGt = 0});

  final int weightGt;

  @override
  List<Object?> get props => [weightGt];
}

typedef MobxListState = ListState<int, ListQuery>;

class LoadResult {
  const LoadResult({required this.records, required this.isFinalPage});

  final List<int> records;
  final bool isFinalPage;
}

class PaginationMobxListController = KeysetPaginationMobxListControllerBase with _$KeysetPaginationMobxListController;

abstract class KeysetPaginationMobxListControllerBase
    with Store, ListCore<int>, RecordsLoader<int, ListQuery, LoadResult>, KeysetPagination<int, ListQuery, LoadResult> {
  KeysetPaginationMobxListControllerBase() : super() {
    loadRecords(const ListQuery());
  }

  static const LoadingKey forwardLoadingKey = 'forward_load';

  @observable
  MobxListState state = const MobxListState(query: ListQuery());

  // RecordsLoader section:

  @action
  @override
  void onRecordsLoadStart({required ListQuery query, required LoadingKey loadingKey}) => state = state.copyWith(stage: ListStage.loading());

  @override
  Future<LoadResult> performLoadQuery({required ListQuery query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return LoadResult(
      records: List<int>.generate(20, (i) => query.weightGt + i + 1),
      isFinalPage: query.weightGt >= 80,
    );
  }

  @action
  @override
  void putLoadResultToState({required ListQuery query, required LoadResult loadResult, required LoadingKey loadingKey}) => state = state.copyWith(
        records: [
          ...state.records,
          ...loadResult.records,
        ],
        stage: loadResult.isFinalPage ? ListStage.complete() : ListStage.idle(),
      );

  // KeysetPagination section:

  @override
  ListStage getListStage(LoadingKey loadingKey) => state.stage;

  @override
  ListQuery buildNextPageQuery(LoadingKey loadingKey) => ListQuery(weightGt: state.records.last);
}
