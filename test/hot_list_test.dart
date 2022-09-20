import 'dart:async';

import 'package:list_controller/list_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'hot_list_mock.dart';

const operationDuration = Duration(milliseconds: 30);

void main() {
  group('HotList', () {
    late StreamController<RecordEvent> eventController;
    late MockHotListController controller;
    final List<RecordEvent> eventsToCall = [
      const RecordCreatedEvent(1),
      const RecordCreatedEvent(2),
      const RecordCreatedEvent(3)
    ];
    final Set<int> insertedIds = eventsToCall.map((e) => e.id).toSet();

    setUp(() {
      eventController = StreamController<RecordEvent>();
      controller = MockHotListController()
        ..initHotList(eventController.stream)
        ..startLoading();
      eventsToCall.forEach(eventController.add);
    });

    tearDown(() async {
      controller.close();
      eventController.close();
    });

    test(
        'completes update process if an error occurs in the '
        'convertDecisionRecords step', () async {
      bool errorOccured = false;
      controller.hotListEventSubscription!
          .onError((error) => errorOccured = true);

      when(controller.convertDecisionRecords(insertedIds))
          .thenAnswer((realInvocation) => Future.error(Exception()));

      controller.stopLoading();

      await Future.delayed(operationDuration * 2);

      expect(controller.actualizeCompleter!.isCompleted, isTrue);

      expect(errorOccured, isTrue);
    });

    test('buffers events while records are loading', () async {
      await Future.delayed(Duration.zero);

      verifyNever(controller.expandHotListEvents(eventsToCall));

      await controller.stopLoading();

      verify(controller.expandHotListEvents(eventsToCall)).called(1);
    });

    group('continues events processing', () {
      test(
          '(call [convertDecisionRecords]) when controller has not been reset '
          'or closed', () async {
        when(controller.expandHotListEvents(eventsToCall)).thenAnswer(
            (realInvocation) => Future.delayed(operationDuration)
                .then((value) => Future.value(RecordUpdates(
                      insertedRecords: insertedIds,
                      updatedRecords: [],
                      deletedKeys: [],
                    ))));

        await controller.stopLoading();

        verify(controller.expandHotListEvents(eventsToCall)).called(1);

        // controller.resetController();

        await Future.delayed(operationDuration * 2);

        verify(controller.convertDecisionRecords(insertedIds)).called(1);
      });

      test(
          '(calls [updateHotList]) when controller has not been reset or '
          'closed', () async {
        when(controller.convertDecisionRecords(insertedIds)).thenAnswer(
            (realInvocation) =>
                Future.delayed(operationDuration).then((_) => insertedIds));

        controller.stopLoading();

        await untilCalled(controller.convertDecisionRecords(insertedIds));

        // controller.resetController();

        await Future.delayed(operationDuration * 2);

        verify(controller.updateHotList(HotListChanges<int, int>(
          recordsToInsert: insertedIds,
          recordKeysToRemove: const {},
        ))).called(1);
      });
    });

    group('breaks events processing', () {
      test(
          '(does not call [convertDecisionRecords]) when [expandHotListEvents] '
          'returns an empty object', () async {
        when(controller.expandHotListEvents(eventsToCall))
            .thenAnswer((_) => Future.value(RecordUpdates.empty()));

        await controller.stopLoading();

        verifyNever(controller.convertDecisionRecords(insertedIds));
      });

      test(
          '(does not call [convertDecisionRecords]) when controller has been '
          'reset during [expandHotListEvents]', () async {
        when(controller.expandHotListEvents(eventsToCall)).thenAnswer(
            (realInvocation) => Future.delayed(operationDuration)
                .then((value) => Future.value(RecordUpdates(
                      insertedRecords: insertedIds,
                      updatedRecords: [],
                      deletedKeys: [],
                    ))));

        await controller.stopLoading();

        verify(controller.expandHotListEvents(eventsToCall)).called(1);

        controller.resetController();

        await Future.delayed(operationDuration * 2);

        verifyNever(controller.convertDecisionRecords(insertedIds));
      });

      test(
          '(does not call [convertDecisionRecords]) if the list is closed '
          'during [expandHotListEvents]', () async {
        when(controller.expandHotListEvents(eventsToCall)).thenAnswer(
            (realInvocation) => Future.delayed(operationDuration)
                .then((value) => Future.value(RecordUpdates(
                      insertedRecords: insertedIds,
                      updatedRecords: [],
                      deletedKeys: [],
                    ))));

        await controller.stopLoading();

        verify(controller.expandHotListEvents(eventsToCall)).called(1);

        controller.close();

        await Future.delayed(operationDuration * 2);

        verifyNever(controller.convertDecisionRecords(insertedIds));
      });

      test(
          '(does not call [updateHotList]) when controller has been reset '
          'during [convertDecisionRecords]', () async {
        when(controller.convertDecisionRecords(insertedIds)).thenAnswer(
            (realInvocation) =>
                Future.delayed(operationDuration).then((_) => insertedIds));

        controller.stopLoading();

        await untilCalled(controller.convertDecisionRecords({1, 2, 3}));

        controller.resetController();

        await Future.delayed(operationDuration * 2);

        verifyNever(controller.updateHotList(HotListChanges<int, int>(
          recordsToInsert: insertedIds,
          recordKeysToRemove: const {},
        )));
      });

      test(
          '(does not call [updateHotList]) when [convertDecisionRecords] '
          'returned empty object.', () async {
        when(controller.convertDecisionRecords(insertedIds))
            .thenAnswer((_) => Future.value({}));

        await controller.stopLoading();

        verifyNever(controller.updateHotList(HotListChanges<int, int>(
          recordsToInsert: insertedIds,
          recordKeysToRemove: const {},
        )));
      });

      test(
          '(does not call [updateHotList]) if the list is closed during '
          '[convertDecisionRecords]', () async {
        when(controller.convertDecisionRecords(insertedIds)).thenAnswer(
            (realInvocation) => Future.delayed(operationDuration)
                .then((value) => Future.value(insertedIds)));

        await controller.stopLoading();

        verify(controller.convertDecisionRecords(insertedIds)).called(1);

        controller.close();

        await Future.delayed(operationDuration * 2);

        verifyNever(controller.updateHotList(HotListChanges(
          recordKeysToRemove: const {},
          recordsToInsert: insertedIds,
        )));
      });
    });
  });

  test(
      'HotList does not process, but buffers events while the list is being'
      ' actualized', () async {
    final eventController = StreamController<RecordEvent>();
    final stream = eventController.stream.asBroadcastStream();

    final controller = MockHotListController()..initHotList(stream);

    when(controller.convertDecisionRecords({1})).thenAnswer((realInvocation) =>
        Future.delayed(const Duration(milliseconds: 50)).then((value) => {1}));

    eventController.add(const RecordCreatedEvent(1));

    await untilCalled(controller.convertDecisionRecords({1}));

    eventController.add(const RecordCreatedEvent(2));
    await Future.delayed(Duration.zero);

    verifyNever(controller.expandHotListEvents([const RecordCreatedEvent(2)]));

    await untilCalled(controller.updateHotList(
        const HotListChanges(recordKeysToRemove: {}, recordsToInsert: {1})));
    await untilCalled(controller.updateHotList(
        const HotListChanges(recordKeysToRemove: {}, recordsToInsert: {2})));
    eventController.close();
  });

  test(
      'HotList breaks events processing (does not call '
      '[convertDecisionRecords]) when [expandHotListEvents] throws exception.',
      () async {
    bool wasError = false;
    final Completer<void> completer = Completer();
    final eventController = StreamController<RecordEvent>();
    final controller = MockHotListController();
    final eventsToCall = [
      const RecordCreatedEvent(1),
      const RecordCreatedEvent(2),
      const RecordCreatedEvent(3)
    ]..forEach(eventController.add);
    when(controller.expandHotListEvents(eventsToCall)).thenThrow(Exception());

    runZonedGuarded(
      () {
        controller
          ..initHotList(eventController.stream)
          ..startLoading()
          ..stopLoading();
      },
      (error, stack) {
        wasError = true;
        completer.complete();
      },
    );

    await completer.future;
    controller.close();
    eventController.close();

    verifyNever(controller.convertDecisionRecords({1, 2, 3}));
    expect(wasError, isTrue);
    expect(controller.actualizeCompleter!.isCompleted, isTrue);
  });

  group('HotList prepares changes for the list:', () {
    final controller = MockHotListController(store: [1, 2, 3]);

    test(
        'inserted records should be both for removing and addition if they '
        'overlap with the list records for some reason', () {
      final result = controller.filterHotListRecords(
          const RecordUpdates(insertedRecords: {1, 2, 3, 4}));
      expect(
          result,
          const HotListChanges<int, int>(
              recordsToInsert: {1, 2, 3, 4}, recordKeysToRemove: {1, 2, 3}));
    });

    test('updated records should be both for removing and addition', () {
      final result = controller
          .filterHotListRecords(const RecordUpdates(updatedRecords: {1}));
      expect(
          result,
          const HotListChanges<int, int>(
              recordsToInsert: {1}, recordKeysToRemove: {1}));
    });

    test('updated records should not be added unless they fit the list', () {
      final result = controller.filterHotListRecords(
          const RecordUpdates(updatedRecords: {101, 102, 103}));
      expect(
          result,
          const HotListChanges<int, int>(
              recordsToInsert: {}, recordKeysToRemove: {}));
    });

    test(
        'inserted records should be add-only while updated records should be '
        'both for removing and addition', () {
      final result = controller.filterHotListRecords(
          const RecordUpdates(insertedRecords: {4, 5}, updatedRecords: {1, 2}));
      expect(
          result,
          const HotListChanges<int, int>(
              recordsToInsert: {1, 2, 4, 5}, recordKeysToRemove: {1, 2}));
    });

    test(
        'inserted records should not be for addition if they are also in '
        'deleted list', () {
      final result = controller.filterHotListRecords(const RecordUpdates(
          insertedRecords: {4, 5}, updatedRecords: {1, 2}, deletedKeys: {2}));
      expect(
          result,
          const HotListChanges<int, int>(
              recordsToInsert: {1, 4, 5}, recordKeysToRemove: {1, 2}));
    });

    test(
        'inserted entries should not be for addition unless they fit in the '
        'list', () {
      final result = controller.filterHotListRecords(
          const RecordUpdates(insertedRecords: {101, 102, 103}));
      expect(
          result,
          const HotListChanges<int, int>(
              recordsToInsert: {}, recordKeysToRemove: {}));
    });

    test(
        'updated records should not be for addition if they are also in '
        'deleted list', () {
      final result = controller.filterHotListRecords(const RecordUpdates(
          insertedRecords: {4, 5}, updatedRecords: {1, 2}, deletedKeys: {2}));
      expect(
          result,
          const HotListChanges<int, int>(
              recordsToInsert: {1, 4, 5}, recordKeysToRemove: {1, 2}));
    });

    test('deleted records should only be for removing if they are in the list',
        () {
      final result = controller
          .filterHotListRecords(const RecordUpdates(deletedKeys: {1, 2, 3, 4}));
      expect(result,
          const HotListChanges<int, int>(recordKeysToRemove: {1, 2, 3}));
    });

    test('mixed complex case', () {
      final result = controller.filterHotListRecords(const RecordUpdates(
          insertedRecords: {1, 2, 4}, updatedRecords: {1, 3, 4, 5, 6}));
      expect(
          result,
          const HotListChanges<int, int>(
              recordsToInsert: {1, 2, 3, 4, 5, 6},
              recordKeysToRemove: {1, 2, 3}));
    });
  });

  group('HotListChanges', () {
    test(
        '[isEmpty] returns [true] when [recordsToInsert] and '
        '[recordKeysToRemove] are empty', () {
      const changes = HotListChanges();
      expect(changes.isEmpty, isTrue);
    });

    test('[isEmpty] returns [false] when [recordsToInsert] is not empty', () {
      const changes = HotListChanges(recordsToInsert: {1, 2, 3});
      expect(changes.isEmpty, isFalse);
    });

    test('[isEmpty] returns [false] when [recordKeysToRemove] is not empty',
        () {
      const changes = HotListChanges(recordKeysToRemove: {1, 2, 3});
      expect(changes.isEmpty, isFalse);
    });

    test('should be equal to another HotListChanges', () {
      const changes = HotListChanges(
          recordsToInsert: {1, 2, 3}, recordKeysToRemove: {4, 5, 6});
      const changes2 = HotListChanges(
          recordsToInsert: {1, 2, 3}, recordKeysToRemove: {4, 5, 6});
      expect(changes, changes2);
    });

    test('does not return the same hash code as another HotListChanges', () {
      const changes = HotListChanges(
          recordsToInsert: {1, 2, 3}, recordKeysToRemove: {4, 5, 6});
      const changes2 = HotListChanges(
          recordsToInsert: {1, 2, 3}, recordKeysToRemove: {4, 5, 7});
      expect(changes.hashCode, isNot(changes2.hashCode));
    });

    test('returns its representation', () {
      const changes = HotListChanges(
          recordsToInsert: {1, 2, 3}, recordKeysToRemove: {4, 5, 6});
      expect(changes.toString().contains('HotListChanges'), isTrue);
    });
  });

  test('RecordUpdates [isEmpty] returns [true] when the object has not data',
      () {
    const changes = RecordUpdates();
    expect(changes.isEmpty, isTrue);
  });
}
