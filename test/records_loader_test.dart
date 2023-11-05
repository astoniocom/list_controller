import 'dart:async';
import 'dart:math';

import 'package:list_controller/list_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'records_loader_mock.dart';

class TestException extends Error {}

void main() {
  group('RecordsLoader', () {
    late MockRecordsLoaderController controller;
    setUp(() {
      controller = MockRecordsLoaderController();
    });

    tearDown(() {
      controller.closeList();
    });

    group('[performLoadingQuery]', () {
      test(
          'throws a custom exception then loading completer is completed with '
          '[error] reason', () async {
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: RecordsLoader.defaultLoadingKey))
            .thenThrow(TestException());

        runZonedGuarded(() {
          controller.loadRecords(1);
        }, (error, stack) {});

        await Future.delayed(Duration.zero);

        expect(controller.isAnyRecordsLoading(), isFalse);
        await expectLater(
            controller.getCompleteReason(RecordsLoader.defaultLoadingKey),
            completion(CompleteReason.error));
      });

      test(
          'returns Future with a custom error then loading completer is '
          'completed with [error] reason', () async {
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: RecordsLoader.defaultLoadingKey))
            .thenAnswer((realInvocation) => Future.error(TestException()));

        runZonedGuarded(() {
          controller.loadRecords(1);
        }, (error, stack) {});

        await Future.delayed(Duration.zero);

        expect(controller.isAnyRecordsLoading(), isFalse);
        await expectLater(
            controller.getCompleteReason(RecordsLoader.defaultLoadingKey),
            completion(CompleteReason.error));
      });

      test(
          'throw [HandledLoadingException] then loading completer is completed '
          'with [handledException] reason', () async {
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: RecordsLoader.defaultLoadingKey))
            .thenThrow(HandledLoadingException());

        controller.loadRecords(1);

        await Future.delayed(Duration.zero);

        expect(controller.isLoadSucessful(RecordsLoader.defaultLoadingKey),
            isFalse);
        await expectLater(
            controller.getCompleteReason(RecordsLoader.defaultLoadingKey),
            completion(CompleteReason.handledException));
      });

      test(
          'returns Future with [HandledLoadingException] error then loading '
          'completer is completed with [handledException] reason', () async {
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: RecordsLoader.defaultLoadingKey))
            .thenAnswer(
                (realInvocation) => Future.error(HandledLoadingException()));

        controller.loadRecords(1);

        await Future.delayed(Duration.zero);

        expect(controller.isLoadSucessful(RecordsLoader.defaultLoadingKey),
            isFalse);
        await expectLater(
            controller.getCompleteReason(RecordsLoader.defaultLoadingKey),
            completion(CompleteReason.handledException));
      });

      test(
          'throws [InterruptLoading] then loading completer is completed with '
          '[interrupt] reason', () async {
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: RecordsLoader.defaultLoadingKey))
            .thenAnswer(
                (realInvocation) => Future.error(const InterruptLoading()));

        controller.loadRecords(1);

        await Future.delayed(Duration.zero);

        expect(controller.isLoadSucessful(RecordsLoader.defaultLoadingKey),
            isNull);
        await expectLater(
            controller.getCompleteReason(RecordsLoader.defaultLoadingKey),
            completion(CompleteReason.interrupt));
      });

      test(
          'returns Future with [InterruptLoading] error then loading completer '
          'is completed with [interrupt] reason', () async {
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: RecordsLoader.defaultLoadingKey))
            .thenAnswer(
                (realInvocation) => Future.error(const InterruptLoading()));

        controller.loadRecords(1);

        await Future.delayed(Duration.zero);

        expect(controller.isLoadSucessful(RecordsLoader.defaultLoadingKey),
            isNull);
        await expectLater(
            controller.getCompleteReason(RecordsLoader.defaultLoadingKey),
            completion(CompleteReason.interrupt));
      });
    });

    group('synchronization mechanism', () {
      test(
          'prevents records loading if another load request with the same '
          '[loadingKey] but with different [query] comes in', () async {
        controller
          ..loadRecords(1, loadingKey: 'chunk')
          ..loadRecords(2, loadingKey: 'chunk');

        await Future.delayed(Duration.zero);

        verify(controller.onRecordsLoadStart(
          query: captureThat(anything, named: 'query'),
          loadingKey: 'chunk',
        )).called(2);

        verify(controller.putLoadResultToState(
          query: captureThat(anything, named: 'query'),
          loadResult: captureThat(anything, named: 'loadResult'),
          loadingKey: 'chunk',
        )).called(1);
      });

      test(
          'ignores a new load request with the same [loadingKey] and [query] '
          'as a current load', () async {
        controller
          ..loadRecords(1)
          ..loadRecords(1);

        await Future.delayed(Duration.zero);

        verify(controller.onRecordsLoadStart(
          query: captureThat(anything, named: 'query'),
          loadingKey: RecordsLoader.defaultLoadingKey,
        )).called(1);

        verify(controller.putLoadResultToState(
          query: captureThat(anything, named: 'query'),
          loadResult: captureThat(anything, named: 'loadResult'),
          loadingKey: RecordsLoader.defaultLoadingKey,
        )).called(1);
      });

      test('performs all loading requests if they have different [loadingKey]',
          () async {
        controller
          ..loadRecords(1, loadingKey: 'chunk1')
          ..loadRecords(1, loadingKey: 'chunk2');

        await Future.delayed(Duration.zero);

        verify(controller.onRecordsLoadStart(
          query: captureThat(anything, named: 'query'),
          loadingKey: 'chunk1',
        )).called(1);

        verify(controller.putLoadResultToState(
          query: captureThat(anything, named: 'query'),
          loadResult: captureThat(anything, named: 'loadResult'),
          loadingKey: 'chunk1',
        )).called(1);

        verify(controller.onRecordsLoadStart(
          query: captureThat(anything, named: 'query'),
          loadingKey: 'chunk2',
        )).called(1);

        verify(controller.putLoadResultToState(
          query: captureThat(anything, named: 'query'),
          loadResult: captureThat(anything, named: 'loadResult'),
          loadingKey: 'chunk2',
        )).called(1);
      });
    });

    group('repeats', () {
      test('the last query when [repeatQuery] is called', () async {
        controller.loadRecords(1);

        await Future.delayed(Duration.zero);

        verify(controller.onRecordsLoadStart(
          query: 1,
          loadingKey: RecordsLoader.defaultLoadingKey,
        )).called(1);

        controller.repeatQuery();

        verify(controller.onRecordsLoadStart(
          query: 1,
          loadingKey: RecordsLoader.defaultLoadingKey,
        )).called(1);
      });

      test(
          'all unsuccessful queries when [repeatUnsuccessfulQueries] is called',
          () async {
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: captureThat(anything, named: 'loadingKey')))
            .thenAnswer(
                (realInvocation) => Future.error(HandledLoadingException()));

        controller
          ..loadRecords(1, loadingKey: 'chunk')
          ..loadRecords(1, loadingKey: 'chunk2');

        await Future.delayed(Duration.zero);

        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: captureThat(anything, named: 'loadingKey')))
            .thenAnswer((realInvocation) => Future.delayed(
                    Duration(milliseconds: Random().nextInt(60) + 60))
                .then((value) => [1, 2, 3]));

        controller.repeatUnsuccessfulQueries();

        await Future.delayed(const Duration(milliseconds: 150));

        verify(controller.putLoadResultToState(
          query: captureThat(anything, named: 'query'),
          loadResult: captureThat(anything, named: 'loadResult'),
          loadingKey: captureThat(anything, named: 'loadingKey'),
        )).called(2);
      });
    });

    group('[waitAllLoadsToComplete] completes the returned Future', () {
      test('when all loads are completed', () async {
        controller
          ..loadRecords(1, loadingKey: 'chunk')
          ..loadRecords(1, loadingKey: 'chunk2');

        await expectLater(
            controller.waitAllLoadsToComplete(), completion(isNull));
        expect(controller.isAnyRecordsLoading(), isFalse);
      });

      test(
          'when all loads are completed even if a new loading request is came '
          'after [waitAllLoadsToComplete] was called', () async {
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: captureThat(anything, named: 'loadingKey')))
            .thenAnswer((realInvocation) =>
                Future.delayed(const Duration(milliseconds: 30))
                    .then((value) => [1, 2, 3]));
        controller
          ..loadRecords(1, loadingKey: 'chunk')
          ..loadRecords(1, loadingKey: 'chunk2');

        final completeNotification = controller.waitAllLoadsToComplete();

        controller.loadRecords(1, loadingKey: 'chunk3');

        await expectLater(completeNotification, completion(isNull));
        expect(controller.isAnyRecordsLoading(), isFalse);
      });

      test('when [performLoadQuery] throws [HandledLoadingException]',
          () async {
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: RecordsLoader.defaultLoadingKey))
            .thenAnswer((realInvocation) =>
                Future.delayed(const Duration(milliseconds: 30))
                    .then((value) => throw HandledLoadingException()));

        bool isLoadCompleted = false;
        controller.loadRecords(1);
        await controller
            .waitAllLoadsToComplete()
            .then((value) => isLoadCompleted = true);
        await Future.delayed(const Duration(milliseconds: 40));

        expect(isLoadCompleted, isTrue);
      });

      test(
          'in the order in which the [waitAllLoadsToComplete] function was '
          'called', () async {
        const loadDelay = Duration(milliseconds: 10);
        int finishedLoadings = 0;

        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: captureThat(anything, named: 'loadingKey')))
            .thenAnswer((realInvocation) =>
                Future.delayed(loadDelay).then((value) => [1, 2, 3]));

        Future<void> loadRequest(int order) async {
          // print('enter $order');

          // if (controller.isAnyChunkLoading())
          await controller.waitAllLoadsToComplete();

          // print('start $order');

          expect(order, finishedLoadings);

          controller.loadRecords(1, loadingKey: 'chunk$order');
          // print('finish $order');
          finishedLoadings++;
        }

        unawaited(loadRequest(0));
        unawaited(loadRequest(1));
        unawaited(loadRequest(2));
        unawaited(loadRequest(3));
        unawaited(loadRequest(4));

        await controller.waitAllLoadsToComplete();

        expect(controller.isAnyRecordsLoading(), isFalse);
      });
    });

    group('calls [recordsLoadingCanceled]', () {
      test(
          'if a new load request with the same [loadingKey] but different '
          'query comes in as a current load', () async {
        controller
          ..loadRecords(1)
          ..loadRecords(2)
          ..loadRecords(3);

        await Future.delayed(Duration.zero);

        verify(controller.onRecordsLoadCancel(
          query: captureThat(anything, named: 'query'),
          loadingKey: RecordsLoader.defaultLoadingKey,
        )).called(2);
      });

      test('on [resetController]', () async {
        controller
          ..loadRecords(1)
          ..loadRecords(2)
          ..resetController();

        await Future.delayed(Duration.zero);

        verify(controller.onRecordsLoadCancel(
          query: captureThat(anything, named: 'query'),
          loadingKey: RecordsLoader.defaultLoadingKey,
        )).called(2);
      });

      test('on [closeList]', () async {
        // Same as the previous test, but with more checks.
        when(controller.performLoadQuery(
                query: captureThat(anything, named: 'query'),
                loadingKey: captureThat(anything, named: 'loadingKey')))
            .thenAnswer((realInvocation) =>
                Future.delayed(const Duration(milliseconds: 30))
                    .then((value) => [1, 2, 3]));

        controller
          ..loadRecords(1, loadingKey: 'chunk')
          ..loadRecords(2, loadingKey: 'chunk2');

        await Future.delayed(Duration.zero);

        expect(controller.isRecordsLoading('chunk'), isTrue);
        expect(controller.isRecordsLoading('chunk2'), isTrue);

        controller.closeList();

        await Future.delayed(Duration.zero);

        expect(controller.isRecordsLoading('chunk'), isFalse);
        expect(controller.isRecordsLoading('chunk2'), isFalse);

        verify(controller.onRecordsLoadCancel(
          query: captureThat(anything, named: 'query'),
          loadingKey: 'chunk',
        )).called(1);

        verify(controller.onRecordsLoadCancel(
          query: captureThat(anything, named: 'query'),
          loadingKey: 'chunk2',
        )).called(1);
      });
    });

    test(
        'does not call [putLoadResultToState] if [closeList] was called during '
        '[performLoadQuery]', () async {
      when(controller.performLoadQuery(
              query: captureThat(anything, named: 'query'),
              loadingKey: captureThat(anything, named: 'loadingKey')))
          .thenAnswer((realInvocation) =>
              Future.delayed(const Duration(milliseconds: 30))
                  .then((value) => [1, 2, 3]));
      controller.loadRecords(1, loadingKey: 'chunk');
      await Future.delayed(const Duration(milliseconds: 10));

      controller.closeList();
      await Future.delayed(const Duration(milliseconds: 60));

      verifyNever(controller.putLoadResultToState(
        query: captureThat(anything, named: 'query'),
        loadResult: captureThat(anything, named: 'loadResult'),
        loadingKey: 'chunk',
      ));
    });

    test(
        'does not call [putLoadResultToState] if [resetController] was called '
        'during the loading', () async {
      controller
        ..loadRecords(1)
        ..resetController();

      await Future.delayed(Duration.zero);

      verify(controller.onRecordsLoadStart(
        query: captureThat(anything, named: 'query'),
        loadingKey: RecordsLoader.defaultLoadingKey,
      )).called(1);

      verifyNever(controller.putLoadResultToState(
        query: captureThat(anything, named: 'query'),
        loadResult: captureThat(anything, named: 'loadResult'),
        loadingKey: RecordsLoader.defaultLoadingKey,
      ));
    });

    test('calls [performLoadingQuery] after [loadRecords] calling', () async {
      controller.loadRecords(1);

      await Future.delayed(Duration.zero);

      verify(controller.performLoadQuery(
              query: 1, loadingKey: RecordsLoader.defaultLoadingKey))
          .called(1);
    });

    test(
        '[getCompleteReason] returns Future.value(null) '
        'if the loading specified by the [loadingKe] was not performed',
        () async {
      await expectLater(
        controller.getCompleteReason(''),
        completion(null),
      );
    });
  });
}
