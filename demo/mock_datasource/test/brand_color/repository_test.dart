@Timeout(Duration(seconds: 1))
library brand_color_repository_test;

import 'dart:async';

import 'package:mock_datasource/brand_color/events.dart';
import 'package:mock_datasource/brand_color/query.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:test/test.dart';

void main() {
  group('MockDatabase:', () {
    late MockDatabase db;

    setUp(() {
      db = MockDatabase(recodsNum: 100);
    });

    test('data generation', () {
      expect(db.brandColorRepository.store, isNotEmpty);
    });

    test('getByIds', () async {
      const getPks = {1, 2, 3};
      final records = await db.brandColorRepository.getByIds(getPks);
      expect(records.length, getPks.length);
    });

    test('queryRecords', () async {
      const query = BrandColorQuery();
      final records =
          await db.brandColorRepository.queryRecords(query, batchSize: 10);
      expect(records.length, 10);
    });

    test('createRecord', () async {
      final ID id = await db.brandColorRepository.createRecord(color: 0x111111);

      expect(
          () => db.brandColorRepository.store
              .firstWhere((element) => element.id == id),
          returnsNormally);
    });

    test('createRecord notification', () async {
      unawaited(db.brandColorRepository.createRecord(color: 0x111111));

      expect(db.controller.events.expand((element) => element),
          emits(isA<BrandColorCreatedEvent>()));
    });

    test('updateRecord', () async {
      const newColor = 0x111111;
      const testPk = 5;
      await db.brandColorRepository.updateRecord(testPk, color: newColor);
      final record = await db.brandColorRepository.getRecordByPk(testPk);
      expect(record.color, newColor);
    });

    test('updateRecord notification', () async {
      const newColor = 0x111111;
      const testPk = 5;
      unawaited(db.brandColorRepository.updateRecord(testPk, color: newColor));

      expect(db.controller.events.expand((element) => element),
          emits(BrandColorUpdatedEvent(testPk)));
    });

    test('updateRecord without changes', () async {
      const testPk = 5;
      final testRecord = await db.brandColorRepository.getRecordByPk(testPk);
      await db.brandColorRepository.updateRecord(testPk);
      final record = await db.brandColorRepository.getRecordByPk(testPk);
      expect(record.color, testRecord.color);
    });

    test('deleteRecord', () async {
      const testPk = 5;
      await db.brandColorRepository.deleteRecord(testPk);

      try {
        await db.brandColorRepository.getRecordByPk(testPk);
        fail('record is not deleted');
      } catch (e) {
        expect(e, isA<RecordDoesNotExist>());
      }
    });

    test('deleteRecord notification', () async {
      const testPk = 5;
      unawaited(db.brandColorRepository.deleteRecord(testPk));
      expect(db.controller.events.expand((element) => element),
          emits(BrandColorDeletedEvent(testPk)));
    });

    test('queryRecords delay', () async {
      const query = BrandColorQuery();
      const delay = Duration(milliseconds: 30);
      final stopwatch = Stopwatch()..start();
      await db.brandColorRepository
          .queryRecords(query, batchSize: 10, delay: delay);
      stopwatch.stop();

      expect(stopwatch.elapsed, greaterThanOrEqualTo(delay));
    });

    test('queryRecords test exception', () async {
      const query = BrandColorQuery();

      await expectLater(
          db.brandColorRepository
              .queryRecords(query, batchSize: 10, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('createRecord test exception', () async {
      await expectLater(
          db.brandColorRepository
              .createRecord(color: 0x111111, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('updateRecord test exception', () async {
      await expectLater(
          db.brandColorRepository
              .updateRecord(1, color: 0x111111, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('updateRecord RecordDoesNotExist', () async {
      await expectLater(
          db.brandColorRepository.updateRecord(-1, color: 0x111111),
          throwsA(const TypeMatcher<RecordDoesNotExist>()));
    });

    test('deleteRecord test exception', () async {
      await expectLater(
          db.brandColorRepository.deleteRecord(1, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('deleteRecord RecordDoesNotExist', () async {
      await expectLater(db.brandColorRepository.deleteRecord(-1),
          throwsA(const TypeMatcher<RecordDoesNotExist>()));
    });
  });
}
