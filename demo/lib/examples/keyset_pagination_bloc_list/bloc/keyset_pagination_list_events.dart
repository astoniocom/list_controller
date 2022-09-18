import 'package:demo/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_bloc.dart';
import 'package:demo/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_query.dart';

abstract class KeysetPaginationListEvent {
  const KeysetPaginationListEvent();
}

class KeysetPaginationListRecordsLoadStartEvent extends KeysetPaginationListEvent {
  const KeysetPaginationListRecordsLoadStartEvent({required this.query});

  final KeysetPaginationListQuery query;
}

class KeysetPaginationListPutLoadResultToStateEvent extends KeysetPaginationListEvent {
  const KeysetPaginationListPutLoadResultToStateEvent({required this.loadResult});

  final LoadResult loadResult;
}

class KeysetPaginationListLoadNextPageEvent extends KeysetPaginationListEvent {
  const KeysetPaginationListLoadNextPageEvent();
}
