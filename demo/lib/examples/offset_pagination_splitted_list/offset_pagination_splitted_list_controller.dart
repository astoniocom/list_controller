import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';

class PageState {
  PageState({
    this.records = const [],
    this.stage = const IdleListStage(),
  });

  final List<ExampleRecord> records;
  final ListStage stage;
}

class SplittedListState {
  SplittedListState({
    required this.query,
    this.pages = const {},
    this.totalPages = 0,
    this.currentPage = 0,
  });

  final ExampleRecordQuery query;
  final Map<int, PageState> pages;
  final int totalPages;
  final int currentPage;

  SplittedListState copyWith({Map<int, PageState>? pages, int? totalPages, int? currentPage}) {
    return SplittedListState(
      pages: pages ?? this.pages,
      query: query,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class LoadResult {
  const LoadResult({required this.records, required this.totalPages});

  final List<ExampleRecord> records;
  final int totalPages;
}

const pageSize = 22;
const totalRecords = 900;

class OffsetPaginationSplittedListController extends ValueNotifier<SplittedListState>
    with
        ListCore<ExampleRecord>,
        RecordsLoader<ExampleRecord, ExampleRecordQuery, LoadResult>,
        OffsetPagination<ExampleRecord, ExampleRecordQuery, LoadResult, int> {
  OffsetPaginationSplittedListController({
    required this.repository,
    this.ignoreUnfinishedLoadings = false,
  }) : super(SplittedListState(query: const ExampleRecordQuery())) {
    goToPage(0);
  }

  final bool ignoreUnfinishedLoadings;
  final ExampleRecordRepository repository;

  @override
  void dispose() {
    closeList();
    super.dispose();
  }

  void goToPage(int page) {
    if (value.pages[page] == null) {
      loadPage(page);
    }
    value = value.copyWith(
      currentPage: page,
    );
  }

  // RecordsLoader section:

  @override
  void onRecordsLoadStart({required ExampleRecordQuery query, required LoadingKey loadingKey}) {
    assert(query.page != null);

    final newPages = Map.of(value.pages);
    newPages[query.page!] = PageState(stage: ListStage.loading());
    value = value.copyWith(pages: newPages);
  }

  @override
  Future<LoadResult> performLoadQuery({required ExampleRecordQuery query, required LoadingKey loadingKey}) async {
    return LoadResult(
        records: await repository.queryRecords(
          query,
          batchSize: pageSize,
          delay: const Duration(milliseconds: 1500),
        ),
        totalPages: (totalRecords / pageSize).ceil());
  }

  @override
  void putLoadResultToState({required ExampleRecordQuery query, required LoadResult loadResult, required LoadingKey loadingKey}) {
    final newPages = Map.of(value.pages);
    newPages[query.page!] = PageState(
      stage: ListStage.idle(),
      records: loadResult.records,
    );
    value = value.copyWith(pages: newPages, totalPages: loadResult.totalPages);
  }

  /// This function is here to ignoreUnfinishedLoadings.
  @override
  void onRecordsLoadCancel({required ExampleRecordQuery query, required LoadingKey loadingKey}) {
    assert(query.page != null);

    value = value.copyWith(
      pages: Map.of(value.pages)..remove(query.page),
    );
  }

  // OffsetPagination section

  @override
  String offsetToLoadingKey(int offset) => ignoreUnfinishedLoadings ? 'page' : 'page$offset';

  @override
  ExampleRecordQuery buildOffsetQuery(int offset) => value.query.copyWith(page: offset);
}
