import 'dart:async';

import 'package:mock_datasource/mock_datasource.dart';
import 'package:test/test.dart';

void main() {
  group('MockDatabase:', () {
    late MockDatabase db;

    setUp(() {
      db = MockDatabase(recodsNum: 100);
    });

    test('data generation', () {
      expect(db.exampleRecordRepository.store, isNotEmpty);
    });

    test('getByIds', () async {
      const getPks = {1, 2, 3};
      final records = await db.exampleRecordRepository.getByIds(getPks);
      expect(records.length, getPks.length);
    });

    test('queryRecords', () async {
      const query = ExampleRecordQuery(weightGte: 10);
      final records =
          await db.exampleRecordRepository.queryRecords(query, batchSize: 10);
      expect(records.length, 10);
      expect(records[0].weight, 10);
      expect(records[0].weight, lessThan(records[9].weight));
    });

    test('queryRecords reversed', () async {
      const query = ExampleRecordQuery(weightGte: 10, revesed: true);
      final records =
          await db.exampleRecordRepository.queryRecords(query, batchSize: 10);
      expect(records[0].weight, greaterThan(records[9].weight));
    });

    test('createRecord', () async {
      final ID id = await db.exampleRecordRepository
          .createRecord(title: 'test', weight: 5);

      expect(
          () => db.exampleRecordRepository.store
              .firstWhere((element) => element.id == id),
          returnsNormally);
    });

    test('createRecord notification', () {
      unawaited(
          db.exampleRecordRepository.createRecord(title: 'test', weight: 5));

      expect(db.controller.events.expand((element) => element),
          emits(isA<ExampleRecordCreatedEvent>()));
    });

    test('create record with weight duplicity should throw exception',
        () async {
      final existingRecord =
          (await db.exampleRecordRepository.getByIds([1])).first;
      expect(
          () => db.exampleRecordRepository
              .createRecord(title: 'test', weight: existingRecord.weight),
          throwsA(const TypeMatcher<WeightDuplicate>()));
    });

    test('updateRecord', () async {
      const newTitle = 'newTitle';
      const newWeight = 11;
      const testPk = 10;
      unawaited(db.exampleRecordRepository
          .updateRecord(testPk, title: newTitle, weight: newWeight));

      final record = await db.exampleRecordRepository.getRecordByPk(testPk);
      expect(record.title, newTitle);
      expect(record.weight, newWeight);
    });

    test('updateRecord notification', () {
      const newTitle = 'newTitle';
      const newWeight = 11;
      const testPk = 10;
      unawaited(db.exampleRecordRepository
          .updateRecord(testPk, title: newTitle, weight: newWeight));

      expect(db.controller.events.expand((element) => element),
          emits(ExampleRecordUpdatedEvent(testPk)));
    });

    test('updateRecord without changes', () async {
      const testPk = 10;
      final testRecord = await db.exampleRecordRepository.getRecordByPk(testPk);
      await db.exampleRecordRepository.updateRecord(testPk);
      final record = await db.exampleRecordRepository.getRecordByPk(testPk);
      expect(record.title, testRecord.title);
      expect(record.weight, testRecord.weight);
    });

    test('deleteRecord', () async {
      const testPk = 10;
      await db.exampleRecordRepository.deleteRecord(testPk);

      try {
        await db.exampleRecordRepository.getRecordByPk(testPk);
        fail('record is not deleted');
        // ignore: avoid_catches_without_on_clauses Ignore to test the exception type.
      } catch (e) {
        expect(e, isA<RecordDoesNotExist>());
      }
    });

    test('deleteRecord notification', () {
      const testPk = 10;
      unawaited(db.exampleRecordRepository.deleteRecord(testPk));
      expect(db.exampleRecordRepository.db.events.expand((element) => element),
          emits(ExampleRecordDeletedEvent(testPk)));
    });

    test('queryRecords delay', () async {
      const query = ExampleRecordQuery();
      const delay = Duration(milliseconds: 30);
      final stopwatch = Stopwatch()..start();
      await db.exampleRecordRepository
          .queryRecords(query, batchSize: 10, delay: delay);
      stopwatch.stop();

      expect(stopwatch.elapsed, greaterThanOrEqualTo(delay));
    });

    test('queryRecords test exception', () async {
      const query = ExampleRecordQuery();

      await expectLater(
          db.exampleRecordRepository
              .queryRecords(query, batchSize: 10, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('queryRecords by page', () async {
      const query = ExampleRecordQuery(page: 1);
      final result =
          await db.exampleRecordRepository.queryRecords(query, batchSize: 10);

      expect(result.length, 10);
      expect(result.first.id, greaterThanOrEqualTo(10));
    });

    test('createRecord test exception', () async {
      await expectLater(
          db.exampleRecordRepository
              .createRecord(title: 'test', weight: 1, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('updateRecord test exception', () async {
      await expectLater(
          db.exampleRecordRepository
              .updateRecord(1, title: 'test', weight: 1, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('updateRecord RecordDoesNotExist', () async {
      await expectLater(
          db.exampleRecordRepository.updateRecord(-1, title: 'test', weight: 1),
          throwsA(const TypeMatcher<RecordDoesNotExist>()));
    });

    test('deleteRecord test exception', () async {
      await expectLater(
          db.exampleRecordRepository.deleteRecord(1, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('deleteRecord RecordDoesNotExist', () async {
      await expectLater(db.exampleRecordRepository.deleteRecord(-1),
          throwsA(const TypeMatcher<RecordDoesNotExist>()));
    });

    test('expandRecord', () async {
      const query = ExampleRecordQuery(weightGte: 10);
      final records =
          await db.exampleRecordRepository.queryRecords(query, batchSize: 10);
      final expandedRecords =
          await db.exampleRecordRepository.expandRecords(records);
      expect(expandedRecords.first.color, isNotNull);
    });
  });
}
