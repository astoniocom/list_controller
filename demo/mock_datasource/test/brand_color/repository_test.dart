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
          db.controller.events
              .expand((element) => element)
              .where((event) => event is RecordCreatedEvent<ID>)
              .map((event) => event.id),
          emits(id));
      expect(
          () => db.brandColorRepository.store
              .firstWhere((element) => element.id == id),
          returnsNormally);
    });

    test('updateRecord', () async {
      const newColor = 0x111111;
      const testPk = 5;
      await db.brandColorRepository.updateRecord(testPk, color: newColor);
      expect(
          db.controller.events
              .expand((element) => element)
              .where((event) => event is RecordUpdatedEvent<ID>)
              .map((event) => event.id),
          emits(testPk));
      final record = await db.brandColorRepository.getRecordByPk(testPk);
      expect(record.color, newColor);
    });

    test('updateRecord without changes', () async {
      const testPk = 5;
      final testRecord = await db.brandColorRepository.getRecordByPk(testPk);
      await db.brandColorRepository.updateRecord(testPk);
      expect(
          db.controller.events
              .expand((element) => element)
              .where((event) => event is RecordUpdatedEvent<ID>)
              .map((event) => event.id),
          emits(testPk));
      final record = await db.brandColorRepository.getRecordByPk(testPk);
      expect(record.color, testRecord.color);
    });

    test('deleteRecord', () async {
      const testPk = 5;
      await db.brandColorRepository.deleteRecord(testPk);
      expect(
          db.brandColorRepository.db.events
              .expand((element) => element)
              .where((event) => event is RecordDeletedEvent<ID>)
              .map((event) => event.id),
          emits(testPk));

      try {
        await db.brandColorRepository.getRecordByPk(testPk);
        fail('record is not deleted');
      } catch (e) {
        expect(e, isA<RecordDoesNotExist>());
      }
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

      expectLater(
          db.brandColorRepository
              .queryRecords(query, batchSize: 10, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('createRecord test exception', () async {
      expectLater(
          db.brandColorRepository
              .createRecord(color: 0x111111, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('updateRecord test exception', () async {
      expectLater(
          db.brandColorRepository
              .updateRecord(1, color: 0x111111, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('updateRecord RecordDoesNotExist', () async {
      expectLater(db.brandColorRepository.updateRecord(-1, color: 0x111111),
          throwsA(const TypeMatcher<RecordDoesNotExist>()));
    });

    test('deleteRecord test exception', () async {
      expectLater(db.brandColorRepository.deleteRecord(1, raiseException: true),
          throwsA(const TypeMatcher<TestException>()));
    });

    test('deleteRecord RecordDoesNotExist', () async {
      expectLater(db.brandColorRepository.deleteRecord(-1),
          throwsA(const TypeMatcher<RecordDoesNotExist>()));
    });
  });
}
