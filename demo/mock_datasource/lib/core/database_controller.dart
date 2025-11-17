import 'dart:async';

import 'package:mock_datasource/core/events.dart';

class DatabaseController<KEY> {
  DatabaseController() {
    // What is the better way to prevent caching of events that occurred before
    // the first subscription to [events].
    _debugSubscription = events.listen((event) {});
  }
  final List<RecordEvent<KEY>> eventBuffer = [];

  final StreamController<List<RecordEvent<KEY>>> eventController =
      StreamController<List<RecordEvent<KEY>>>();

  late Stream<List<RecordEvent<KEY>>> events =
      eventController.stream.asBroadcastStream();

  bool isTransactionActive = false;

  late StreamSubscription<List<RecordEvent<KEY>>> _debugSubscription;

  Future<T> dbTransaction<T>(Future<T> Function() action) {
    return action();
  }

  Future<T> transaction<T>(Future<T> Function() action) async {
    isTransactionActive = true;
    T result;
    try {
      result = await dbTransaction<T>(action);
      if (eventBuffer.isNotEmpty) eventController.add(List.of(eventBuffer));
    } finally {
      isTransactionActive = false;
      eventBuffer.clear();
    }

    return result;
  }

  void notify(RecordEvent<KEY> event) {
    if (isTransactionActive) {
      eventBuffer.add(event);
    } else {
      eventController.add([event]);
    }
  }

  Future<void> close() async {
    await _debugSubscription.cancel();
  }
}
