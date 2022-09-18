// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyset_pagination_mobx_list_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$KeysetPaginationMobxListController on KeysetPaginationMobxListControllerBase, Store {
  late final _$stateAtom = Atom(name: 'ListControllerBase.state', context: context);

  @override
  MobxListState get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(MobxListState value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$ListControllerBaseActionController = ActionController(name: 'ListControllerBase', context: context);

  @override
  void onRecordsLoadStart({required ListQuery query, required LoadingKey loadingKey}) {
    final _$actionInfo = _$ListControllerBaseActionController.startAction(name: 'ListControllerBase.loadingStarted');
    try {
      return super.onRecordsLoadStart(query: query, loadingKey: loadingKey);
    } finally {
      _$ListControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void putLoadResultToState({required ListQuery query, required LoadResult loadResult, required LoadingKey loadingKey}) {
    final _$actionInfo = _$ListControllerBaseActionController.startAction(name: 'ListControllerBase.putLoadedRecordsToState');
    try {
      return super.putLoadResultToState(query: query, loadResult: loadResult, loadingKey: loadingKey);
    } finally {
      _$ListControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
