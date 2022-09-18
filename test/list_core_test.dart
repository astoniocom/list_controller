import 'dart:async';

import 'package:test/test.dart';

import 'list_core_mock.dart';

void main() {
  test('ListCore [waitAllLoasdToComplete] returns a Future', () async {
    final controller = MockCoreController();
    expect(
        controller.waitAllLoadsToComplete(), const TypeMatcher<Future<void>>());
    controller.closeList();
  });

  test('ListCore increments [initOperationId] on [resetController] call',
      () async {
    final controller = MockCoreController();

    final initOperationId = controller.replaceOperationId;

    controller.resetController();

    expect(controller.replaceOperationId, greaterThan(initOperationId));
  });
}
