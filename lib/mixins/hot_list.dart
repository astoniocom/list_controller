import 'dart:async';
import 'package:collection/collection.dart';
import 'package:list_controller/mixins/list_core.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/src/transformers/backpressure/backpressure.dart' // ignore: implementation_imports
    show
        BackpressureStreamTransformer,
        WindowStrategy;

class _BufferCompleterTransformer<T>
    extends BackpressureStreamTransformer<T, List<T>> {
  _BufferCompleterTransformer(Future<dynamic> Function() completer)
      : super(
          WindowStrategy.everyEvent,
          (_) => completer().asStream(),
          onWindowEnd: (List<T> queue) => queue,
          ignoreEmptyWindows: true,
        );
}

extension _CompleteBufferExtensions<T> on Stream<T> {
  Stream<List<T>> bufferCompleter(Future<dynamic> Function() completer) =>
      transform(_BufferCompleterTransformer(completer));
}

/// Contains records to be added to the list and unique identifiers (keys) of
/// records to be removed from the list.
@immutable
class HotListChanges<Record, Key> {
  /// Creates a new HotListChanges object.
  const HotListChanges({
    this.recordsToInsert = const {},
    this.recordKeysToRemove = const {},
  });

  /// List of records to be added to the list.
  final Set<Record> recordsToInsert;

  /// List of unique identifiers of records to be removed from the list.
  final Set<Key> recordKeysToRemove;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final eq = const SetEquality().equals;
    return other is HotListChanges &&
        eq(other.recordsToInsert, recordsToInsert) &&
        eq(other.recordKeysToRemove, recordKeysToRemove);
  }

  @override
  int get hashCode => Object.hash(recordsToInsert, recordKeysToRemove);

  /// Whether this object has no records for adding or removing.
  bool get isEmpty => recordsToInsert.isEmpty && recordKeysToRemove.isEmpty;

  @override
  String toString() => 'HotListChanges(recordsToInsert: $recordsToInsert, '
      'recordsToRemove: $recordKeysToRemove)';
}

/// Describes changes in the data source.
class RecordUpdates<T, Key> {
  /// Creates description of changes in the data source.
  const RecordUpdates({
    this.deletedKeys = const {},
    this.insertedRecords = const {},
    this.updatedRecords = const {},
  });

  /// Creates a [RecordUpdates] object that contains no changes in
  /// the data source.
  @visibleForTesting
  factory RecordUpdates.empty() => const RecordUpdates();

  /// List of keys of deleted records.
  final Iterable<Key> deletedKeys;

  /// List of new records.
  final Iterable<T> insertedRecords;

  /// List of updated records.
  final Iterable<T> updatedRecords;

  /// Whether the data source has no changes.
  bool get isEmpty =>
      deletedKeys.isEmpty && insertedRecords.isEmpty && updatedRecords.isEmpty;
}

/// Implements the updating (actualization) of individual list entries.
mixin HotList<Key, Event, DecisionRecord, Record> on ListCore<Record> {
  /// Subscribing for changes in the data source.
  @visibleForTesting
  StreamSubscription<HotListChanges<Record, Key>>? hotListEventSubscription;

  /// Converts an `Event` notification list into an `RecordUpdates` object
  /// containing the lists of created, updated and deleted entries.
  ///
  /// The entries of this object will be used to make decisions about
  /// including specific entries in the list. The `Event` list included
  /// in the function is formed from the events that occurred during the
  /// time the records were loaded from the data source. If no data was loaded,
  /// there will be only one item in this list.
  @protected
  FutureOr<RecordUpdates<DecisionRecord, Key>> expandHotListEvents(
      List<Event> events);

  /// Must return unique key for the Raw object
  @protected
  Key getDecisionRecordKey(DecisionRecord record);

  /// The function should tell if the current list contains a record with
  /// the unique identifier `Key`.
  @protected
  bool hasListRecord(Key key);

  /// The function should tell if the [record] is suitable for being
  /// added to the list.
  @protected
  bool recordFits(DecisionRecord record);

  /// The function should convert the list of [DecisionRecord] into
  /// a list of [Record]
  @protected
  FutureOr<Iterable<Record>> convertDecisionRecords(
      Set<DecisionRecord> records);

  /// Called when the list of records needs to be modified.
  ///
  /// Changes are described by the [HotListChanges] object that contains
  /// records to be added to the list and unique identifiers (keys) of
  /// records to be removed from the list.
  @protected
  void updateHotList(HotListChanges<Record, Key> changes);

  int? _curReplaceOperationId;

  /// Must be called in the constructor
  void initHotList(Stream<Event> changes) {
    _curReplaceOperationId = replaceOperationId;
    hotListEventSubscription = changes
        .bufferCompleter(() async => Future.wait([
              waitAllLoadsToComplete(),
              if (actualizeCompleter?.isCompleted == false)
                actualizeCompleter!.future,
            ]))
        .asyncMap((event) async {
      // At this point, no loading or actualizing operations are performed
      // because of bufferCompleter.
      _curReplaceOperationId = replaceOperationId;
      actualizeCompleter = Completer();

      try {
        return expandHotListEvents(event);
      } catch (e) {
        actualizeCompleter?.complete();
        rethrow;
      }
    }).where((event) {
      final cancelChain =
          _curReplaceOperationId != replaceOperationId || event.isEmpty;
      if (cancelChain) {
        actualizeCompleter?.complete();
      }
      return !cancelChain;
    }).asyncMap((RecordUpdates<DecisionRecord, Key> updates) async {
      final changes = filterHotListRecords(updates);
      try {
        return HotListChanges(
          recordsToInsert:
              Set.of(await convertDecisionRecords(changes.recordsToInsert)),
          recordKeysToRemove: changes.recordKeysToRemove,
        );
      } catch (e) {
        actualizeCompleter?.complete();
        rethrow;
      }
    }).where((HotListChanges<Record, Key> event) {
      final cancelChain =
          _curReplaceOperationId != replaceOperationId || event.isEmpty;
      if (cancelChain) {
        actualizeCompleter?.complete();
      }
      return !cancelChain;
    }).listen((changes) {
      actualizeCompleter?.complete();
      updateHotList(changes);
    });
  }

  DecisionRecord? _findRecordOrNull(Iterable<DecisionRecord> source, Key key) {
    return source
        .firstWhereOrNull((record) => getDecisionRecordKey(record) == key);
  }

  /// Decides which records should be removed from the list and which
  /// should be added.
  @visibleForTesting
  HotListChanges<DecisionRecord, Key> filterHotListRecords(
      RecordUpdates<DecisionRecord, Key> change) {
    final Set<Key> recordsToRemove =
        Set.of(change.deletedKeys.where(hasListRecord));
    final Set<DecisionRecord> rawRecordsToInsert = {};

    for (final r in change.insertedRecords.where(recordFits)) {
      final Key decisionRecordKey = getDecisionRecordKey(r);

      if (change.deletedKeys.contains(decisionRecordKey)) continue;

      if (hasListRecord(decisionRecordKey)) {
        recordsToRemove.add(decisionRecordKey);
      }
      rawRecordsToInsert.add(r);
    }

    for (final r in change.updatedRecords) {
      final Key decisionRecordKey = getDecisionRecordKey(r);

      if (change.deletedKeys.contains(decisionRecordKey)) continue;

      if (recordFits(r)) {
        final DecisionRecord? desigionRecord =
            _findRecordOrNull(rawRecordsToInsert, decisionRecordKey);

        if (desigionRecord != null) rawRecordsToInsert.remove(desigionRecord);

        rawRecordsToInsert.add(r);
      }

      if (hasListRecord(decisionRecordKey)) {
        recordsToRemove.add(decisionRecordKey);
      }
    }
    return HotListChanges<DecisionRecord, Key>(
      recordsToInsert: rawRecordsToInsert,
      recordKeysToRemove: recordsToRemove,
    );
  }

  /// Stops processing changes in the data source.
  void stopHotList() {
    unawaited(hotListEventSubscription?.cancel());
    if (actualizeCompleter?.isCompleted == false) {
      actualizeCompleter!.complete();
    }
  }

  @override
  void closeList() {
    stopHotList();
    super.closeList();
  }
}
