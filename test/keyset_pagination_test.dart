import 'package:list_controller/list_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'keyset_pagination_mock.dart';

void main() {
  group('KeysetPagination', () {
    late MockKeysetPaginationController controller;
    setUp(() {
      controller = MockKeysetPaginationController();
    });

    tearDown(() {
      controller.closeList();
    });

    test(
        'calls [buildNextPageQuery] and [onRecordsLoadStart] to load the next '
        'page', () async {
      controller.loadNextPage('chunk');

      await Future.delayed(Duration.zero);

      verify(controller.buildNextPageQuery('chunk')).called(1);
      verify(controller.onRecordsLoadStart(query: 1, loadingKey: 'chunk'))
          .called(1);
    });

    test('waits for actualization to complete before requesting the next page',
        () async {
      controller
        ..startActualizing()
        ..loadNextPage('chunk');

      await Future.delayed(Duration.zero);

      verifyNever(controller.buildNextPageQuery('chunk'));

      controller.stopActualizing();

      await Future.delayed(Duration.zero);

      verify(controller.onRecordsLoadStart(query: 1, loadingKey: 'chunk'))
          .called(1);
    });

    test('does not start loading next page if the next page is already loading',
        () async {
      when(controller.isRecordsLoading('chunk'))
          .thenAnswer((realInvocation) => true);

      controller.loadNextPage('chunk');

      await Future.delayed(Duration.zero);

      verifyNever(controller.buildNextPageQuery('chunk'));
    });

    test('does not start loading next page if all records are loaded',
        () async {
      when(controller.getListStage('chunk'))
          .thenAnswer((realInvocation) => ListStage.complete());

      controller.loadNextPage('chunk');

      await Future.delayed(Duration.zero);

      verifyNever(controller.buildNextPageQuery('chunk'));
    });

    test(
        'does not start loading next page if previous load operation is failed',
        () async {
      when(controller.performLoadQuery(
              query: captureThat(anything, named: 'query'),
              loadingKey: 'chunk'))
          .thenAnswer(
              (realInvocation) => Future.error(HandledLoadingException()));

      controller.loadRecords(1);
      await Future.delayed(Duration.zero);

      controller.loadNextPage('chunk');
      await Future.delayed(Duration.zero);

      controller.loadNextPage('chunk');

      await controller.waitAllLoadsToComplete();

      verify(controller.buildNextPageQuery('chunk')).called(1);
    });

    test(
        'waits for completion of all loading operations if strategy is '
        'sequential', () async {
      controller
        ..sequentialLoadStrategy = true
        ..loadNextPage('chunk')
        ..loadNextPage('chunk1');

      verify(controller.buildNextPageQuery('chunk')).called(1);
      verifyNever(controller.buildNextPageQuery('chunk1'));

      await Future.delayed(Duration.zero);

      verify(controller.buildNextPageQuery('chunk1')).called(1);
    });
  });
}
