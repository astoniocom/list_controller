@Timeout(Duration(seconds: 2))
library complec_value_notifier_test;

import 'dart:async';
import 'package:demo/examples/complex_value_notifier_list/complex_value_notifier_list_controller.dart';
import 'package:demo/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';

const defaultFetchRecordsDelay = Duration(milliseconds: 30);
const defaultBatchSize = 30;

ComplexListController _defaultControllerBuilder({
  required MockDatabase db,
  Duration fetchDelay = defaultFetchRecordsDelay,
}) {
  return ComplexListController(
    repository: db.exampleRecordRepository,
    settings: SettingsController(
        settings: Settings(
      responseDelay: fetchDelay,
      batchSize: defaultBatchSize, // ignore: avoid_redundant_argument_values
    )),
  );
}

void main() {
  test('ListController should load initial records', () async {
    final db = MockDatabase();
    final listController = _defaultControllerBuilder(db: db);
    final stream = listController.streamController.stream.asBroadcastStream();
    final s1 = await stream.first;
    expect(s1.isLoading, isTrue);
    final s2 = await stream.first;
    expect(s2.isLoading, isFalse);
    expect(s2.records, isNotEmpty);
    listController.dispose();
  });

  group('ListController with records', () {
    late ComplexListController listController;
    late Stream<ExListState> stream;
    late MockDatabase db;

    setUp(() async {
      db = MockDatabase(recodsNum: 100);
      listController = _defaultControllerBuilder(db: db);
      stream = listController.streamController.stream.skipWhile((state) => state.records.isEmpty).asBroadcastStream();
      final state = await stream.first;
      expect(state.isLoading, isFalse);
    });

    tearDown(() => listController.dispose());

    test('should only add records that fits range', () async {
      final lastRecord = listController.value.records.last;

      unawaited(db.controller.transaction(() async {
        await db.exampleRecordRepository.createRecord(title: 'test', weight: 5);
        await db.exampleRecordRepository.createRecord(title: 'test', weight: 6);
        await db.exampleRecordRepository.createRecord(title: 'test', weight: lastRecord.weight + 106);
      }));
      final state = await stream.first;
      expect(state.records.where((element) => element.title == 'test').length, 2);
    });

    test('should update records in list', () async {
      unawaited(db.controller.transaction(() async {
        await db.exampleRecordRepository.updateRecord(3, title: 'test');
        await db.exampleRecordRepository.updateRecord(4, title: 'test');
        await db.exampleRecordRepository.updateRecord(40, title: 'test');
      }));
      final state = await stream.first;
      expect(state.records.where((element) => element.title == 'test').length, 2);
    });

    test('should remove records from list', () async {
      const recordsToDelete = [4, 5];
      expect(listController.value.records.where((element) => recordsToDelete.contains(element.id)).length, recordsToDelete.length);
      unawaited(db.controller.transaction(() async {
        for (final id in recordsToDelete) {
          await db.exampleRecordRepository.deleteRecord(id);
        }
      }));
      final state = await stream.first;
      expect(state.records.where((element) => recordsToDelete.contains(element.id)), isEmpty);
    });

    test('should not add records that do not fit range', () async {
      final lastRecord = listController.value.records.last;
      unawaited(db.controller.transaction(() async {
        await db.exampleRecordRepository.createRecord(title: 'test', weight: lastRecord.weight + 106);
        await db.exampleRecordRepository.createRecord(title: 'test', weight: lastRecord.weight + 107);
      }));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
    });

    test('should not update or add records that do not fit range', () async {
      unawaited(db.controller.transaction(() async {
        await db.exampleRecordRepository.updateRecord(40, title: 'test');
        await db.exampleRecordRepository.updateRecord(41, title: 'test');
      }));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
    });

    test('should not delete records that do not fit range', () async {
      unawaited(db.controller.transaction(() async {
        await db.exampleRecordRepository.deleteRecord(40);
        await db.exampleRecordRepository.deleteRecord(41);
      }));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
    });
  });

  group('ListController without initial load should not', () {
    late ComplexListController listController;
    late Stream<ExListState> stream;
    late MockDatabase db;

    setUp(() {
      db = MockDatabase(recodsNum: 100);
      listController = ComplexListController(
        repository: db.exampleRecordRepository,
        settings: SettingsController(settings: const Settings(responseDelay: defaultFetchRecordsDelay)),
        initLoad: false,
      );
      stream = listController.streamController.stream.asBroadcastStream();
    });

    tearDown(() => listController.dispose());

    test('add record', () async {
      unawaited(db.exampleRecordRepository.createRecord(title: 'test', weight: 1));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
    });

    test('update record', () async {
      unawaited(db.exampleRecordRepository.updateRecord(5, title: 'test'));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
    });

    test('delete record', () async {
      unawaited(db.exampleRecordRepository.deleteRecord(6));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
    });
  });

  group('ListController should wait next page is loaded before', () {
    late ComplexListController listController;
    late Stream<ExListState> stream;
    late MockDatabase db;

    setUp(() async {
      db = MockDatabase(recodsNum: 100);
      listController = _defaultControllerBuilder(db: db, fetchDelay: const Duration(milliseconds: 5));
      stream = listController.streamController.stream.asBroadcastStream();
      var state = await stream.first;
      expect(state.isLoading, isTrue);
      state = await stream.first;
      expect(state.isLoading, isFalse);
      listController.loadNextPage();
      state = await stream.first;
      expect(state.isLoading, isTrue);
    });

    tearDown(() => listController.dispose());

    test('add record to first page', () async {
      unawaited(db.exampleRecordRepository.createRecord(title: 'test', weight: 2));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
      var state = await stream.first;
      expect(state.isLoading, isFalse);
      state = await stream.first;
      expect(state.records.getRange(0, defaultBatchSize).where((element) => element.weight == 2 && element.title == 'test').length, 1);
    });

    test('update record in first page', () async {
      unawaited(db.exampleRecordRepository.updateRecord(7, title: 'test'));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
      var state = await stream.first;
      expect(state.isLoading, isFalse);
      state = await stream.first;
      expect(state.records.getRange(0, defaultBatchSize).where((element) => element.id == 7 && element.title == 'test').length, 1);
    });

    test('delete record from first page', () async {
      unawaited(db.exampleRecordRepository.deleteRecord(8));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
      var state = await stream.first;
      expect(state.isLoading, isFalse);
      state = await stream.first;
      expect(state.records.getRange(0, defaultBatchSize).where((element) => element.id == 8), isEmpty);
    });

    test('add record to being loaded page', () async {
      final record = listController.value.records.last;
      final newWeight = record.weight + 21;
      unawaited(db.exampleRecordRepository.createRecord(title: 'test', weight: newWeight));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
      var state = await stream.first;
      expect(state.isLoading, isFalse);
      state = await stream.first;
      expect(state.records.sublist(defaultBatchSize).where((element) => element.weight == newWeight && element.title == 'test').length, 1);
    });

    test('update record on being loaded page', () async {
      unawaited(db.exampleRecordRepository.updateRecord(defaultBatchSize + 3, title: 'test'));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
      var state = await stream.first;
      expect(state.isLoading, isFalse);
      state = await stream.first;
      expect(state.records.sublist(defaultBatchSize).where((element) => element.id == defaultBatchSize + 3 && element.title == 'test').length, 1);
    });

    test('delete record from being loaded page', () async {
      unawaited(db.exampleRecordRepository.deleteRecord(defaultBatchSize + 3));
      expect(() => stream.timeout(Duration.zero).first, throwsA(const TypeMatcher<TimeoutException>()));
      var state = await stream.first;
      expect(state.isLoading, isFalse);
      state = await stream.first;
      expect(state.records.sublist(defaultBatchSize).where((element) => element.id == defaultBatchSize + 3), isEmpty);
    });
  });

  test('ListController should set hasLoadedAllRecords status when all records is loaded', () async {
    const searchString = 'es';
    final db = MockDatabase();
    final listController = ComplexListController(
      initialState: const ExListState(query: ExampleRecordQuery(contains: searchString)),
      repository: db.exampleRecordRepository,
      settings: SettingsController(settings: const Settings(responseDelay: defaultFetchRecordsDelay)),
    );
    final stream = listController.streamController.stream.asBroadcastStream();
    var state = await stream.first;
    expect(state.isLoading, isTrue);
    state = await stream.first;
    expect(state.isLoading, isFalse);

    while (true) {
      listController.loadNextPage();
      state = await stream.first;
      if (state.stage == ListStage.complete()) break;
    }

    expect(state.stage, ListStage.complete());

    listController.dispose();
  });

  test('ListController should filter records', () async {
    const searchString = 'es';
    final db = MockDatabase();
    final listController = ComplexListController(
      initialState: const ExListState(query: ExampleRecordQuery(contains: searchString)),
      repository: db.exampleRecordRepository,
      settings: SettingsController(settings: const Settings(responseDelay: defaultFetchRecordsDelay)),
    );
    final stream = listController.streamController.stream.asBroadcastStream();
    await stream.where((event) => !event.isLoading).first;
    listController.loadNextPage();
    final state = await stream.where((event) => !event.isLoading).first;
    expect(state.records.where((record) => !record.title.contains(searchString)), isEmpty);
  });

  test('ListController should buffer events', () async {
    final db = MockDatabase(recodsNum: 100);
    final listController = _defaultControllerBuilder(db: db);
    final stream = listController.streamController.stream.asBroadcastStream();
    var state = await stream.first;
    expect(state.isLoading, isTrue);
    state = await stream.first;
    expect(state.isLoading, isFalse);
    unawaited(db.controller.transaction(() async {
      await db.exampleRecordRepository.updateRecord(2, title: 'test');
      await db.exampleRecordRepository.deleteRecord(2);
      final pk = await db.exampleRecordRepository.createRecord(weight: 15, title: 'creation test');
      await db.exampleRecordRepository.updateRecord(pk, title: 'creation test ex');
      await db.exampleRecordRepository.updateRecord(10, title: 'test 10');
      await db.exampleRecordRepository.updateRecord(20, title: 'test 20');
    }));
    state = await stream.first;
    expect(
        state,
        const TypeMatcher<ExListState>()
            .having((p0) => p0.records.where((element) => element.title == 'test 10').length, 'has `test 10`', 1)
            .having((p0) => p0.records.where((element) => element.title == 'creation test ex').length, 'has `creation test ex`', 1)
            .having((p0) => p0.records.where((element) => element.title == 'test 20').length, 'has `test 20`', 1)
            .having((p0) => p0.records.where((element) => element.id == 2), 'has not deleted record', isEmpty));
    listController.dispose();
  });
}
