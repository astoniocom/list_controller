import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'records_tracker_mock.dart';

void main() {
  group('StreamsTracker', () {
    late List<StreamController<int>> records;
    late MockRecordsTrackerController controller;
    setUp(() {
      records = [StreamController<int>(), StreamController<int>()];
      controller = MockRecordsTrackerController()
        ..registerRecordsToTrack(records);
    });

    tearDown(() async {
      controller.closeList();

      for (final r in records) {
        r.close();
      }
    });

    test('calls [eventOcure] on record change', () async {
      records[0].add(1);
      await Future.delayed(
          controller.trackingPeriod + const Duration(milliseconds: 50));
      verify(controller.onTrackEventOccur([1])).called(1);
    });

    test('buffers events and call [eventOcure] once on record changes',
        () async {
      records[0].add(1);
      await Future.delayed(Duration.zero);
      records[0].add(2);
      await Future.delayed(
          controller.trackingPeriod + const Duration(milliseconds: 50));
      verify(controller.onTrackEventOccur([1, 2])).called(1);
    });

    test('stops tracking records after calling [stopTracking]', () async {
      controller.stopTracking();
      records[0].add(1);
      await Future.delayed(
          controller.trackingPeriod + const Duration(milliseconds: 50));
      verifyNever(controller.onTrackEventOccur(captureThat(anything)));
    });
  });
}
