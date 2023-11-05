import 'dart:async';
import 'dart:math';

import 'package:mock_datasource/brand_color/events.dart';
import 'package:mock_datasource/brand_color/exceptions.dart';
import 'package:mock_datasource/brand_color/models.dart';
import 'package:mock_datasource/brand_color/query.dart';
import 'package:mock_datasource/core/database_controller.dart';
import 'package:mock_datasource/core/exceptions.dart';
import 'package:mock_datasource/core/repository.dart';
import 'package:mock_datasource/core/types.dart';
import 'package:rxdart/rxdart.dart';

class BrandColorRepository
    extends BaseRepository<ID, BrandColor, BrandColorQuery> {
  BrandColorRepository(
      {required int recodsNum, required DatabaseController<ID> controller})
      : _store = List<BrandColor>.generate(
            recodsNum,
            (i) => BrandColor(
                  id: i,
                  color: generateRandomColor(),
                )),
        super(db: controller);

  final List<BrandColor> _store;

  // to simplify examples:
  Stream<BrandColorEvent> get dbEvents =>
      db.events.expand((events) => events).whereType<BrandColorEvent>();

  List<BrandColor> get store => _store;

  static int generateRandomColor() {
    return (Random().nextDouble() * 0xFFFFFF).toInt();
  }

  @override
  Future<List<BrandColor>> getByIds(Iterable<ID> ids) async {
    return _store.where((record) => ids.contains(record.id)).toList();
  }

  @override
  Future<List<BrandColor>> queryRecords(BrandColorQuery? query,
      {Duration? delay,
      int batchSize = 15,
      bool raiseException = false}) async {
    final sortedList = List.of(_store);

    if (delay != null) await Future.delayed(delay);
    if (raiseException) throw TestException();
    if (query != null) {
      sortedList.sort(query.compareRecords);
    }
    return sortedList
        .where((record) => query == null || query.fits(record))
        .take(batchSize)
        .toList();
  }

  Future<ID> createRecord(
      {required int color, bool raiseException = false}) async {
    if (raiseException) throw TestException();
    if (_store.where((element) => element.color == color).isNotEmpty) {
      throw ColorDuplicate();
    }
    final maxPk = _store.isNotEmpty ? _store.map((e) => e.id).reduce(max) : 1;
    final newPk = maxPk + 1;
    _store.add(BrandColor(
      id: newPk,
      color: color,
    ));
    db.notify(BrandColorCreatedEvent(newPk));
    return newPk;
  }

  Future<void> updateRecord(ID id,
      {int? color, bool raiseException = false}) async {
    if (raiseException) throw TestException();

    final record = _store.firstWhere((element) => element.id == id,
        orElse: () => throw RecordDoesNotExist());

    if (_store
        .where((element) => element != record && element.color == color)
        .isNotEmpty) throw ColorDuplicate();
    final storeIndex = _store.indexOf(record);
    _store[storeIndex] = BrandColor(
      id: id,
      color: color ?? record.color,
    );
    db.notify(BrandColorUpdatedEvent(id));
  }

  Future<void> deleteRecord(ID id, {bool raiseException = false}) async {
    if (raiseException) throw TestException();

    final record = _store.firstWhere((element) => element.id == id,
        orElse: () => throw RecordDoesNotExist());

    _store.remove(record);
    db.notify(BrandColorDeletedEvent(id));
  }
}
