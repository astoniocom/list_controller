import 'dart:async';

import 'package:meta/meta.dart';

/// Provides basic functionality for the other parts of the list controller
/// (mixins), as well as the ability to synchronize actions between them.
///
/// In the list of mixins of the controller, this mixin must go first.
mixin ListCore<Record> {
  /// Completer to indicate that the list is being actualized.
  @visibleForTesting
  @protected
  Completer<void>? actualizeCompleter;

  /// Indicates that the [closeList] function has been called.
  bool isListClosed = false;

  /// Returns Future, which completes either immediately if there are no other
  /// loads, or upon completion of all loads.
  Future<void> waitAllLoadsToComplete() {
    return Future.value();
  }

  /// The identifier of the current list.
  ///
  /// Each time [resetController] function is called, it is incremented by 1.
  int replaceOperationId = 0;

  /// Stops all processes in the list controller.
  @mustCallSuper
  void closeList() {
    resetController();
    isListClosed = true;
  }

  /// Interrupts all processes occurring in the list controller: of loading
  /// and updating records.
  void resetController() {
    replaceOperationId++;
  }
}
