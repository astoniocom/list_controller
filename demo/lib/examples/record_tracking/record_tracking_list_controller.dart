import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_controller/list_controller.dart';

class RecordData {
  RecordData({required this.color, required this.weight, required this.initPosition});
  final Color color;
  final int weight;
  final int initPosition;
}

class RecordCubit extends Cubit<RecordData> {
  RecordCubit(int initPosition)
      : super(RecordData(
          color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
          weight: 1,
          initPosition: initPosition,
        ));

  void increase() => emit(RecordData(weight: state.weight + 1, color: state.color, initPosition: state.initPosition));
}

class RecordTrackingListController extends ValueNotifier<List<RecordCubit>> with ListCore<RecordCubit>, RecordsTracker<RecordCubit, RecordData> {
  RecordTrackingListController()
      : super(List<RecordCubit>.generate(10, (i) {
          return RecordCubit(i);
        }).toList()) {
    registerRecordsToTrack(value);
  }

  @override
  void dispose() {
    for (final record in value) {
      unawaited(record.close());
    }

    closeList();
    super.dispose();
  }

  // RecordsTracker section:

  @override
  Stream<RecordData> buildTrackingStream(Cubit<RecordData> record) => record.stream;

  @override
  void onTrackEventOccur(List<RecordData> updatedRecords) {
    value = List.of(value)..sort((a, b) => b.state.weight.compareTo(a.state.weight));
  }
}
