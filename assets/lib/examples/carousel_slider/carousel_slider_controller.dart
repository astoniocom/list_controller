import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

class CarouselState {
  const CarouselState({
    this.records = const [],
    this.stage = const IdleListStage(),
  });

  final List<int> records;
  final ListStage stage;

  CarouselState copyWith({List<int>? records, ListStage? stage}) {
    return CarouselState(
      records: records ?? this.records,
      stage: stage ?? this.stage,
    );
  }
}

class LoadResult {
  const LoadResult({required this.records, required this.isFinalPage});

  final List<int> records;
  final bool isFinalPage;
}

class CarouselSliderController extends ValueNotifier<CarouselState>
    with ListCore<int>, RecordsLoader<int, int, LoadResult>, KeysetPagination<int, int, LoadResult> {
  CarouselSliderController() : super(const CarouselState()) {
    loadRecords(0);
  }

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required int query, required LoadingKey loadingKey}) => value = value.copyWith(
        stage: ListStage.loading(),
      );

  @override
  Future<LoadResult> performLoadQuery({required int query, required LoadingKey loadingKey}) async {
    await Future.delayed(const Duration(milliseconds: 2200));
    const maxItems = 25;
    const chunkSize = 5;
    if (query >= maxItems) throw const InterruptLoading();
    return LoadResult(
      records: List<int>.generate(chunkSize, (i) => query + i + 1),
      isFinalPage: query >= maxItems - chunkSize,
    );
  }

  @override
  void putLoadResultToState({required int query, required LoadResult loadResult, required LoadingKey loadingKey}) => value = value.copyWith(
        records: [
          ...value.records,
          ...loadResult.records,
        ],
        stage: loadResult.isFinalPage ? ListStage.complete() : ListStage.idle(),
      );

  // KeysetPagination section:

  @override
  ListStage getListStage(LoadingKey loadingKey) => value.stage;

  @override
  int buildNextPageQuery(LoadingKey loadingKey) => value.records.last;
}
