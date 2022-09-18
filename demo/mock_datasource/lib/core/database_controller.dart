import 'dart:async';

import 'package:mock_datasource/core/events.dart';

class DatabaseController<KEY> {
  final List<RecordEvent<KEY>> eventBuffer = [];

  final StreamController<List<RecordEvent<KEY>>> eventController =
      StreamController<List<RecordEvent<KEY>>>();

  late Stream<List<RecordEvent<KEY>>> events =
      eventController.stream.asBroadcastStream();

  bool isTransactionActive = false;

  Future<T> dbTransaction<T>(Future<T> Function() action) async {
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
}
