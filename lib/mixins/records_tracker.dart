import 'dart:async';
import 'package:async/async.dart' show StreamGroup;
import 'package:list_controller/mixins/list_core.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// Tracks changes of individual records in the list.
///
/// The records must be able to provide a `Stream` for tracking (as records,
/// for example, `Cubit`s from package `Bloc` can be used). When the list
/// is changed, the new records must be registered for tracking by calling
/// [registerRecordsToTrack].
mixin RecordsTracker<Record, Update> on ListCore<Record> {
  StreamSubscription<List<Update>>? _trackerListener;

  /// The interval of time during which record events will be collected
  /// before [onTrackEventOccur] is called.
  @protected
  @visibleForTesting
  Duration get trackingPeriod => Duration.zero;

  /// The function should return a `Stream` of [record] updates.
  @protected
  Stream<Update> buildTrackingStream(Record record);

  /// Called when there were changes in the records.
  ///
  /// [updatedRecords] contains a list of changes during [trackingPeriod].
  @protected
  void onTrackEventOccur(List<Update> updatedRecords);

  /// Creates a thread, each event of which initiates the end of collecting
  /// events from the list records and calling the [onTrackEventOccur] function.
  @protected
  Stream<void> buildBufferStream(Stream<Update> eventStream) {
    return eventStream
        .cast()
        .mergeWith([Stream.value(null)]).debounceTime(trackingPeriod);
  }

  /// Registers records that should to be tracked for changes.
  @protected
  @visibleForTesting
  void registerRecordsToTrack(List<Record> records) {
    final mergedTrackingStreams =
        StreamGroup.merge(records.map(buildTrackingStream)).asBroadcastStream();
    final bufferStream = buildBufferStream(mergedTrackingStreams);
    stopTracking();
    _trackerListener = mergedTrackingStreams
        .buffer(bufferStream)
        .where((event) => event.isNotEmpty)
        .listen(onTrackEventOccur);
  }

  /// Stops records tracking.
  void stopTracking() {
    unawaited(_trackerListener?.cancel());
  }

  @override
  void closeList() {
    stopTracking();
    super.closeList();
  }
}
