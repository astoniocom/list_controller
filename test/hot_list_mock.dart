import 'dart:async';

import 'package:list_controller/list_controller.dart';
import 'package:mockito/mockito.dart';

abstract class RecordEvent {
  const RecordEvent(this.id);

  final int id;
}

class RecordCreatedEvent extends RecordEvent {
  const RecordCreatedEvent(int id) : super(id);
}

class RecordUpdatedEvent extends RecordEvent {
  const RecordUpdatedEvent(int id) : super(id);
}

class RecordDeletedEvent extends RecordEvent {
  const RecordDeletedEvent(int id) : super(id);
}

class MockHotListController extends Mock
    with ListCore<int>, HotList<int, RecordEvent, int, int> {
  MockHotListController({List<int>? store}) {
    _store = store;
    throwOnMissingStub(this);
  }

  List<int>? _store;
  Completer<void>? loadingCompletter;

  @override
  Future<Iterable<int>> convertDecisionRecords(Set<int> records) {
    final result = Future.value(records.toList());
    return super.noSuchMethod(
        Invocation.method(#convertDecisionRecords, [records]),
        returnValue: result,
        returnValueForMissingStub: result) as Future<Iterable<int>>;
  }

  @override
  Future<RecordUpdates<int, int>> expandHotListEvents(
      List<RecordEvent> events) {
    final result = Future.value(RecordUpdates(
      insertedRecords: events.whereType<RecordCreatedEvent>().map((e) => e.id),
      updatedRecords: events.whereType<RecordUpdatedEvent>().map((e) => e.id),
      deletedKeys: events.whereType<RecordDeletedEvent>().map((e) => e.id),
    ));

    return super.noSuchMethod(
      Invocation.method(#expandHotListEvents, [events]),
      returnValue: result,
      returnValueForMissingStub: result,
    ) as Future<RecordUpdates<int, int>>;
  }

  @override
  int getDecisionRecordKey(int record) {
    return record;
  }

  @override
  bool hasListRecord(int key) {
    return _store?.contains(key) ?? false;
  }

  @override
  bool recordFits(int record) {
    return record < 100;
  }

  @override
  void updateHotList(HotListChanges<int, int> changes) {
    super.noSuchMethod(Invocation.method(#updateHotList, [changes]),
        returnValueForMissingStub: null);
  }

  void close() {
    closeList();
  }

  @override
  Future<void> waitAllLoadsToComplete() {
    return loadingCompletter?.future ?? (Future.value());
  }

  void startLoading() {
    loadingCompletter = Completer();
    // await Future.delayed(Duration.zero);
  }

  Future<void> stopLoading() async {
    await Future.delayed(Duration.zero);
    if (loadingCompletter == null) {
      throw Exception('Call startLoading before stopLoading');
    }
    loadingCompletter!.complete(null);
    await Future.delayed(Duration.zero);
  }
}
