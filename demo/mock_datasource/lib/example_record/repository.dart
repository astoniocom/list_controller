import 'dart:async';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:mock_datasource/brand_color/query.dart';
import 'package:mock_datasource/brand_color/repository.dart';
import 'package:mock_datasource/core/database_controller.dart';
import 'package:mock_datasource/core/exceptions.dart';
import 'package:mock_datasource/core/repository.dart';
import 'package:mock_datasource/core/types.dart';
import 'package:mock_datasource/example_record/events.dart';
import 'package:mock_datasource/example_record/exceptions.dart';
import 'package:mock_datasource/example_record/models.dart';
import 'package:mock_datasource/example_record/query.dart';
import 'package:rxdart/rxdart.dart';

class ExampleRecordRepository
    extends BaseRepository<ID, ExampleRecord, ExampleRecordQuery> {
  ExampleRecordRepository({
    required int recodsNum,
    required DatabaseController<ID> controller,
    required this.brandColorRepository,
  })  : _store = List<ExampleRecord>.generate(
            recodsNum,
            (i) => ExampleRecord(
                  id: i,
                  title: nouns[Random().nextInt(nouns.length)],
                  weight: i * 10,
                  colorId: brandColorRepository
                      .store[
                          Random().nextInt(brandColorRepository.store.length)]
                      .id,
                )),
        super(db: controller);

  final BrandColorRepository brandColorRepository;
  final List<ExampleRecord> _store;

  // to simplify examples:
  Stream<ExampleRecordEvent> get dbEvents =>
      db.events.expand((events) => events).whereType<ExampleRecordEvent>();

  List<ExampleRecord> get store => _store;

  @override
  Future<List<ExampleRecord>> getByIds(Iterable<ID> ids) async {
    return _store.where((record) => ids.contains(record.id)).toList();
  }

  @override
  Future<List<ExampleRecord>> queryRecords(ExampleRecordQuery? query,
      {Duration? delay,
      int batchSize = 15,
      bool raiseException = false}) async {
    var sortedList = List.of(_store);

    if (delay != null) await Future.delayed(delay);
    if (raiseException) throw TestException();
    if (query != null) {
      sortedList.sort(query.compareRecords);

      if (query.page != null) {
        final int from = query.page! * batchSize;

        sortedList =
            sortedList.sublist(from, min(from + batchSize, sortedList.length));
      }
    }
    return sortedList
        .where((record) => query == null || query.fits(record))
        .take(batchSize)
        .toList();
  }

  Future<ID> createRecord(
      {required String title,
      required int weight,
      bool raiseException = false,
      int? colorId}) async {
    if (raiseException) throw TestException();
    if (_store.where((element) => element.weight == weight).isNotEmpty) {
      throw WeightDuplicate();
    }
    final maxPk = _store.isNotEmpty ? _store.map((e) => e.id).reduce(max) : 1;
    final newPk = maxPk + 1;
    _store.add(ExampleRecord(
      id: newPk,
      title: title,
      weight: weight,
      colorId: colorId,
    ));
    db.notify(ExampleRecordCreatedEvent(newPk));
    return newPk;
  }

  Future<void> updateRecord(ID id,
      {String? title,
      int? weight,
      bool raiseException = false,
      int? Function()? colorId}) async {
    if (raiseException) throw TestException();
    final record = _store.firstWhere((element) => element.id == id,
        orElse: () => throw RecordDoesNotExist());
    if (_store
        .where((element) => element != record && element.weight == weight)
        .isNotEmpty) throw WeightDuplicate();
    final storeIndex = _store.indexOf(record);
    final newRecord = ExampleRecord(
      id: id,
      title: title ?? record.title,
      weight: weight ?? record.weight,
      colorId: colorId != null ? colorId() : record.colorId,
    );

    if (record == newRecord) return;
    _store[storeIndex] = newRecord;

    db.notify(ExampleRecordUpdatedEvent(id));
  }

  Future<void> deleteRecord(ID id, {bool raiseException = false}) async {
    if (raiseException) throw TestException();

    final record = _store.firstWhere((element) => element.id == id,
        orElse: () => throw RecordDoesNotExist());

    _store.remove(record);
    db.notify(ExampleRecordDeletedEvent(id));
  }

  Future<List<ExpandedExampleRecord>> expandRecords(
      Iterable<ExampleRecord> records) async {
    final Iterable<int> colorIds =
        records.map((r) => r.colorId).whereType<int>();
    final colors = await brandColorRepository
        .queryRecords(BrandColorQuery(idIn: colorIds));
    final colorsRegister = {for (final c in colors) c.id: c};
    final List<ExpandedExampleRecord> result = [];
    for (final record in records) {
      final color = colorsRegister[record.colorId];

      result.add(ExpandedExampleRecord(
        id: record.id,
        title: record.title,
        weight: record.weight,
        colorId: record.colorId,
        color: color,
      ));
    }
    return result;
  }
}
