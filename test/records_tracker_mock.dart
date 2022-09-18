import 'dart:async';

import 'package:list_controller/list_controller.dart';
import 'package:mockito/mockito.dart';

class MockRecordsTrackerController extends Mock
    with
        ListCore<StreamController<int>>,
        RecordsTracker<StreamController<int>, int> {
  MockRecordsTrackerController() {
    throwOnMissingStub(this);
  }

  @override
  Stream<int> buildTrackingStream(StreamController<int> record) =>
      record.stream;

  @override
  void onTrackEventOccur(List<int>? updatedRecords) {
    super.noSuchMethod(
      Invocation.method(#onTrackEventOccur, [updatedRecords]),
      returnValueForMissingStub: null,
    );
  }
}
