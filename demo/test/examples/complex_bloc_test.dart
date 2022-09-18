@Timeout(Duration(seconds: 2))

import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:demo/examples/complex_bloc_list/bloc/complex_list_bloc.dart';
import 'package:demo/settings.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:test/test.dart';

const testRecordTitle = 'test';
const defaultFetchRecordsDelay = Duration(milliseconds: 30);

const defaultBatchSize = 30;

ComplexListBloc _defaultBlocBuilder({
  required MockDatabase db,
  Duration fetchDelay = defaultFetchRecordsDelay,
  Duration expandRecordsDelay = Duration.zero,
  bool initLoad = true,
}) {
  return ComplexListBloc(
    repository: db.exampleRecordRepository,
    settings: SettingsController(
        settings: Settings(
      responseDelay: fetchDelay,
      batchSize: defaultBatchSize, // ignore: avoid_redundant_argument_values
    )),
    expandRecordsDelay: expandRecordsDelay,
    initLoad: initLoad,
  );
}

void main() {
  blocTest<ComplexListBloc, dynamic>(
    'ListBloc should load initial records',
    build: () => _defaultBlocBuilder(db: MockDatabase(recodsNum: 100), fetchDelay: Duration.zero),
    act: (bloc) async {},
    expect: () => [
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoaded', isFalse).having((p0) => p0.records.isNotEmpty, 'records.isNotEmpty', isTrue),
    ],
  );

  group('ListBloc with records', () {
    late MockDatabase db;

    setUp(() async {
      db = MockDatabase(recodsNum: 100);
    });

    blocTest<ComplexListBloc, dynamic>(
      'should only add records that fits range',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        final state = await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        final lastRecord = state.records.last;
        db.exampleRecordRepository.db.transaction(() async {
          await db.exampleRecordRepository.createRecord(title: testRecordTitle, weight: 5);
          await db.exampleRecordRepository.createRecord(title: testRecordTitle, weight: 6);
          await db.exampleRecordRepository.createRecord(title: testRecordTitle, weight: lastRecord.weight + 106);
        });
        await bloc.stream.first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) {
          return p0.records.where((element) => element.title == testRecordTitle).length;
        }, 'records', 2),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'should update records in list',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        db.exampleRecordRepository.db.transaction(() async {
          await db.exampleRecordRepository.updateRecord(3, title: testRecordTitle);
          await db.exampleRecordRepository.updateRecord(4, title: testRecordTitle);
          await db.exampleRecordRepository.updateRecord(40, title: testRecordTitle);
        });
        await bloc.stream.first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.records.where((element) => element.title == testRecordTitle).length, 'records', 2),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'should update records in list two times',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        db.exampleRecordRepository.db.transaction(() async {
          await db.exampleRecordRepository.updateRecord(3, title: testRecordTitle);
        });
        await bloc.stream.first;
        db.exampleRecordRepository.db.transaction(() async {
          await db.exampleRecordRepository.updateRecord(4, title: testRecordTitle);
        });
        await bloc.stream.first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.records.where((element) => element.title == testRecordTitle).length, 'records', 1),
        const TypeMatcher<ExListState>().having((p0) => p0.records.where((element) => element.title == testRecordTitle).length, 'records', 2),
      ],
    );

    const recordsToDelete = [4, 5];
    blocTest<ComplexListBloc, dynamic>(
      'should remove records from list',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        db.exampleRecordRepository.db.transaction(() async {
          for (final id in recordsToDelete) {
            await db.exampleRecordRepository.deleteRecord(id);
          }
        });
        await bloc.stream.first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>()
            .having((p0) => p0.isLoading, 'isLoading', isFalse)
            .having((p0) => p0.records.where((element) => recordsToDelete.contains(element.id)).length, 'recordsToDelete', recordsToDelete.length),
        const TypeMatcher<ExListState>().having((p0) => p0.records.where((element) => recordsToDelete.contains(element.id)), 'records', isEmpty),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'should not add records that do not fit range',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        final state = await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        final lastRecord = state.records.last;
        db.exampleRecordRepository.db.transaction(() async {
          await db.exampleRecordRepository.createRecord(title: testRecordTitle, weight: lastRecord.weight + 106);
          await db.exampleRecordRepository.createRecord(title: testRecordTitle, weight: lastRecord.weight + 107);
        });
        await Future.delayed(defaultFetchRecordsDelay);
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'should not update or add records that do not fit range',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        db.exampleRecordRepository.db.transaction(() async {
          await db.exampleRecordRepository.updateRecord(40, title: testRecordTitle);
          await db.exampleRecordRepository.updateRecord(41, title: testRecordTitle);
        });
        await Future.delayed(defaultFetchRecordsDelay);
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'should not delete records that do not fit range',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        db.exampleRecordRepository.db.transaction(() async {
          await db.exampleRecordRepository.deleteRecord(40);
          await db.exampleRecordRepository.deleteRecord(41);
        });
        await Future.delayed(defaultFetchRecordsDelay);
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      ],
    );
  });

  group('ListBloc without records should not', () {
    late MockDatabase db;

    setUp(() async {
      db = MockDatabase(recodsNum: 100);
    });

    blocTest<ComplexListBloc, dynamic>(
      'add record',
      build: () => _defaultBlocBuilder(db: db, initLoad: false),
      act: (bloc) async {
        db.exampleRecordRepository.createRecord(title: testRecordTitle, weight: 1);

        await Future.delayed(defaultFetchRecordsDelay);
      },
      expect: () => [],
    );

    blocTest<ComplexListBloc, dynamic>(
      'update record',
      build: () => _defaultBlocBuilder(db: db, initLoad: false),
      act: (bloc) async {
        db.exampleRecordRepository.updateRecord(5, title: testRecordTitle);
        await Future.delayed(defaultFetchRecordsDelay);
      },
      expect: () => [],
    );

    blocTest<ComplexListBloc, dynamic>(
      'delete record',
      build: () => _defaultBlocBuilder(db: db, initLoad: false),
      act: (bloc) async {
        db.exampleRecordRepository.deleteRecord(6);
        await Future.delayed(defaultFetchRecordsDelay);
      },
      expect: () => [],
    );
  });

  group('ListBloc should wait next page is loaded before', () {
    late MockDatabase db;

    setUp(() {
      db = MockDatabase(recodsNum: 100);
    });

    Future<void> actWhileSecondPageLoading(ComplexListBloc bloc, Function() action) async {
      await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
      bloc.loadNextPage();
      await bloc.stream.where((event) => event.isLoading).first; // Loading is started

      action();

      await bloc.stream.first; // loaded second page
      await bloc.stream.first; // record updated
    }

    final statesTillSecondPageLoaded = [
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue).having((p0) => p0.records, 'records.isEmpty', isNotEmpty),
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
    ];

    blocTest<ComplexListBloc, dynamic>(
      'add record to first page',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async => actWhileSecondPageLoading(bloc, () => db.exampleRecordRepository.createRecord(title: testRecordTitle, weight: 2)),
      expect: () => [
        ...statesTillSecondPageLoaded,
        const TypeMatcher<ExListState>().having(
            (p0) => p0.records.getRange(0, defaultBatchSize).where((element) => element.weight == 2 && element.title == testRecordTitle).length,
            'hasRecord',
            1),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'update record in first page',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async => actWhileSecondPageLoading(bloc, () => db.exampleRecordRepository.updateRecord(7, title: testRecordTitle)),
      expect: () => [
        ...statesTillSecondPageLoaded,
        const TypeMatcher<ExListState>().having(
            (p0) => p0.records.getRange(0, defaultBatchSize).where((element) => element.id == 7 && element.title == testRecordTitle).length, 'hasRecord', 1),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'delete record from first page',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async => actWhileSecondPageLoading(bloc, () => db.exampleRecordRepository.deleteRecord(8)),
      expect: () => [
        ...statesTillSecondPageLoaded,
        const TypeMatcher<ExListState>().having((p0) => p0.records.getRange(0, defaultBatchSize).where((element) => element.id == 8), 'hasRecord', isEmpty),
      ],
    );

    late int newWeight;
    blocTest<ComplexListBloc, dynamic>(
      'add record to being loaded page',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async => actWhileSecondPageLoading(bloc, () {
        final record = bloc.state.records.last;
        newWeight = record.weight + 21;
        db.exampleRecordRepository.createRecord(title: testRecordTitle, weight: newWeight);
      }),
      expect: () => [
        ...statesTillSecondPageLoaded,
        const TypeMatcher<ExListState>().having(
            (p0) => p0.records.sublist(defaultBatchSize).where((element) => element.weight == newWeight && element.title == testRecordTitle).length,
            'hasRecord',
            1),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'update record on being loaded page',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async => actWhileSecondPageLoading(bloc, () => db.exampleRecordRepository.updateRecord(defaultBatchSize + 3, title: testRecordTitle)),
      expect: () => [
        ...statesTillSecondPageLoaded,
        const TypeMatcher<ExListState>().having(
            (p0) => p0.records
                .getRange(defaultBatchSize + 1, defaultBatchSize * 2)
                .where((element) => element.id == defaultBatchSize + 3 && element.title == testRecordTitle)
                .length,
            'hasRecord',
            1),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'delete record from being loaded page',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async => actWhileSecondPageLoading(bloc, () => db.exampleRecordRepository.deleteRecord(defaultBatchSize + 3)),
      expect: () => [
        ...statesTillSecondPageLoaded,
        const TypeMatcher<ExListState>()
            .having((p0) => p0.records.sublist(defaultBatchSize + 1).where((element) => element.id == defaultBatchSize + 3), 'hasRecord', isEmpty),
      ],
    );
  });

  late List<TypeMatcher<ExListState>> pageStates;
  blocTest<ComplexListBloc, dynamic>(
    'ListBloc should set hasLoadedAllRecords status when all records is loaded',
    setUp: () => pageStates = [],
    build: () {
      final db = MockDatabase(recodsNum: 100);
      return ComplexListBloc(
        initialState: ExListState(query: const ExampleRecordQuery(contains: 'e')),
        repository: db.exampleRecordRepository,
        settings: SettingsController(settings: const Settings(responseDelay: defaultFetchRecordsDelay)),
      );
    },
    act: (bloc) async {
      await bloc.stream.where((event) => !event.isLoading).first;
      while (true) {
        bloc.loadNextPage();
        await bloc.stream.first;
        final state = await bloc.stream.first;
        pageStates.add(const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()));
        if (state.stage != ListStage.complete()) {
          pageStates.add(const TypeMatcher<ExListState>().having((p0) => p0.stage, 'hasLoadedAllRecords', ListStage.idle()));
        } else {
          break;
        }
      }
    },
    expect: () => [
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      ...pageStates,
      const TypeMatcher<ExListState>().having((p0) => p0.stage, 'hasLoadedAllRecords', ListStage.complete()),
    ],
  );

  const searchString = 'es';
  blocTest<ComplexListBloc, dynamic>(
    'ListBloc should filter records',
    build: () {
      final db = MockDatabase();
      return ComplexListBloc(
        initialState: ExListState(query: const ExampleRecordQuery(contains: searchString)),
        repository: db.exampleRecordRepository,
        settings: SettingsController(settings: const Settings(responseDelay: defaultFetchRecordsDelay)),
      );
    },
    act: (bloc) async {
      await bloc.stream.where((event) => !event.isLoading).first;
      bloc.loadNextPage();
      await bloc.stream.where((event) => !event.isLoading).first;
    },
    expect: () => [
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
      const TypeMatcher<ExListState>()
          .having((p0) => p0.isLoading, 'isLoading', isFalse)
          .having((p0) => p0.records.where((record) => !record.title.contains(searchString)), '`$searchString` in each record', isEmpty),
    ],
  );

  late MockDatabase db;
  blocTest<ComplexListBloc, dynamic>(
    'ListBloc should buffer events',
    setUp: () => db = MockDatabase(recodsNum: 100),
    build: () => _defaultBlocBuilder(db: db),
    act: (bloc) async {
      await bloc.stream.where((event) => !event.isLoading).first;
      db.controller.transaction(() async {
        await db.exampleRecordRepository.updateRecord(2, title: testRecordTitle);
        await db.exampleRecordRepository.deleteRecord(2);
        final pk = await db.exampleRecordRepository.createRecord(weight: 15, title: 'creation test');
        await db.exampleRecordRepository.updateRecord(pk, title: 'creation test ex');
        await db.exampleRecordRepository.updateRecord(10, title: 'test 10');
        await db.exampleRecordRepository.updateRecord(bloc.state.records.last.id + 3, title: 'test 20');
      });
      await bloc.stream.first;
    },
    expect: () => [
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
      const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      const TypeMatcher<ExListState>()
          .having((p0) => p0.records.where((element) => element.title == 'test 10').length, 'test 10', 1)
          .having((p0) => p0.records.where((element) => element.title == 'creation test ex').length, 'creation test ex', 1)
          .having((p0) => p0.records.where((element) => element.title == 'test 20'), 'test 20', isEmpty)
          .having((p0) => p0.records.where((element) => element.id == 2), 'pk2', isEmpty),
    ],
  );

  group('ListBloc should', () {
    late MockDatabase db;

    setUp(() {
      db = MockDatabase(recodsNum: 100);
    });

    blocTest<ComplexListBloc, dynamic>(
      'cancel getting records if a new getting records request comes in',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        bloc.add(const ResetEvent(query: ExampleRecordQuery()));
        await bloc.stream.where((event) => !event.isLoading).first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'ignore loading next page of records event if it comes in during list being loaded',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => event.isLoading).first;
        bloc.loadNextPage();
        await bloc.stream.where((event) => !event.isLoading).first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse)
      ],
      // errors: () => [isA<WrongListStateException>()],
    );

    blocTest<ComplexListBloc, dynamic>(
      'finish getting records before processing records updated event',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await Future.delayed(defaultFetchRecordsDelay ~/ 2);
        await db.exampleRecordRepository.updateRecord(0, title: testRecordTitle);
        await bloc.stream.where((event) => !event.isLoading).first;
        await bloc.stream.first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.records[0].title, 'records[0].title', testRecordTitle),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'cancel getting next page of records if a new getting records request comes in',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        bloc.loadNextPage(); // Load next page
        await bloc.stream.where((event) => event.isLoading).first;
        bloc.add(const ResetEvent(query: ExampleRecordQuery())); // While next page is loading initiate the list replacing
        await bloc.stream.where((event) => !event.isLoading).first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()),
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      ],
    );
    blocTest<ComplexListBloc, dynamic>(
      'ignore all load next page of records events if it comes in during list being loaded',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => event.isLoading).first;

        bloc.loadNextPage();
        await Future.delayed(defaultFetchRecordsDelay ~/ 5);
        bloc.loadNextPage();
        await Future.delayed(defaultFetchRecordsDelay ~/ 5);
        bloc.loadNextPage();

        await bloc.stream.where((event) => !event.isLoading).first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse)
      ],
      // errors: () => [isA<WrongListStateException>()],
    );

    blocTest<ComplexListBloc, dynamic>(
      'ignore all load next page of records events if it comes in during getting next page of records',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first;
        bloc.loadNextPage();
        await bloc.stream.where((event) => event.isLoading).first;

        bloc.loadNextPage();
        await Future.delayed(defaultFetchRecordsDelay ~/ 5);
        bloc.loadNextPage();
        await Future.delayed(defaultFetchRecordsDelay ~/ 5);
        bloc.loadNextPage();

        await bloc.stream.where((event) => !event.isLoading).first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse)
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'finish getting next page of records before processing record updated event',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        bloc.loadNextPage(); // Load next page
        await bloc.stream.where((event) => event.isLoading).first;
        await db.exampleRecordRepository.updateRecord(0, title: testRecordTitle);
        await bloc.stream.where((event) => !event.isLoading).first;
        await bloc.stream.first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()),
        const TypeMatcher<ExListState>()
            .having((p0) => p0.isLoading, 'isLoading', isFalse)
            .having((p0) => p0.records[0].title, 'title', isNot(testRecordTitle)),
        const TypeMatcher<ExListState>().having((p0) => p0.records[0].title, 'records[0].title', testRecordTitle),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'cancel record updating if getting records request comes in',
      build: () => _defaultBlocBuilder(db: db, expandRecordsDelay: defaultFetchRecordsDelay ~/ 2),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        await db.exampleRecordRepository.updateRecord(0, title: testRecordTitle);
        await Future.delayed(Duration.zero); // Give time to start the record update process chain
        bloc.add(const ResetEvent(query: ExampleRecordQuery()));
        await bloc.stream.where((event) => !event.isInitialized).first; // Wait for list is loaded
        await bloc.stream.where((event) => event.stage == ListStage.idle()).first; // Wait for list is loaded
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()),
        const TypeMatcher<ExListState>().having((p0) => p0.records.isNotEmpty, 'isNotEmpty', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isInitialized, 'stage', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()),
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.idle()),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'finish records updating before getting next page of records',
      build: () => _defaultBlocBuilder(db: db, expandRecordsDelay: defaultFetchRecordsDelay ~/ 2),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded
        db.exampleRecordRepository.updateRecord(0, title: testRecordTitle);
        await Future.delayed(defaultFetchRecordsDelay ~/ 3); // Be sure updating in progress
        bloc.loadNextPage();
        await bloc.stream.where((event) => event.isLoading).first;
        await bloc.stream.where((event) => !event.isLoading).first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.records[0].title, 'records[0].title', testRecordTitle),
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
      ],
    );

    // test('finish records updating before processing a new record updating request', () async {});

    blocTest<ComplexListBloc, dynamic>(
      'buffer events while list is being loaded',
      build: () => _defaultBlocBuilder(db: db, expandRecordsDelay: defaultFetchRecordsDelay ~/ 2),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Ensure list is loaded
        bloc.loadNextPage();
        await bloc.stream.where((event) => event.isLoading).first;
        db.exampleRecordRepository
          ..updateRecord(0, title: testRecordTitle)
          ..updateRecord(1, title: testRecordTitle);
        await bloc.stream.where((event) => !event.isLoading).first;
        await bloc.stream.first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()),
        const TypeMatcher<ExListState>()
            .having((p0) => p0.isLoading, 'isLoading', isFalse)
            .having((p0) => p0.records[0].title, 'records[0].title', isNot(equals(testRecordTitle)))
            .having((p0) => p0.records[1].title, 'records[1].title', isNot(equals(testRecordTitle))),
        const TypeMatcher<ExListState>()
            .having((p0) => p0.records[0].title, 'records[0].title', testRecordTitle)
            .having((p0) => p0.records[1].title, 'records[1].title', testRecordTitle),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'not buffer events if list is loaded',
      build: () => _defaultBlocBuilder(db: db, expandRecordsDelay: defaultFetchRecordsDelay ~/ 2),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Ensure list is loaded
        bloc.loadNextPage();
        await bloc.stream.where((event) => !event.isLoading).first;
        db.controller.transaction(() async {
          await db.exampleRecordRepository.updateRecord(0, title: testRecordTitle);
          await db.exampleRecordRepository.updateRecord(1, title: testRecordTitle);
        });
        await bloc.stream.first;
        // await bloc.stream.where((event) => !event.isLoading).first;
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()),
        const TypeMatcher<ExListState>()
            .having((p0) => p0.isLoading, 'isLoading', isFalse)
            .having((p0) => p0.records[0].title, 'records[0].title', isNot(equals(testRecordTitle)))
            .having((p0) => p0.records[1].title, 'records[1].title', isNot(equals(testRecordTitle))),
        const TypeMatcher<ExListState>()
            .having((p0) => p0.records[0].title, 'records[0].title', testRecordTitle)
            .having((p0) => p0.records[1].title, 'records[1].title', testRecordTitle),
      ],
    );

    blocTest<ComplexListBloc, dynamic>(
      'buffer events while load records operations are being processed',
      build: () => _defaultBlocBuilder(db: db, expandRecordsDelay: defaultFetchRecordsDelay ~/ 2),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Ensure list is loaded
        bloc.loadNextPage();
        await bloc.stream.where((event) => event.isLoading).first;
        await db.exampleRecordRepository.updateRecord(0, title: testRecordTitle);
        await db.exampleRecordRepository.updateRecord(1, title: testRecordTitle);
        await bloc.stream.where((event) => !event.isLoading).first;
        await bloc.stream.first; // records updated
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.stage.runtimeType, 'stage', LoadingListStage),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.stage, 'stage', ListStage.loading()),
        const TypeMatcher<ExListState>()
            .having((p0) => p0.isLoading, 'isLoading', isFalse)
            .having((p0) => p0.records[0].title, 'records[0].title', isNot(equals(testRecordTitle)))
            .having((p0) => p0.records[1].title, 'records[1].title', isNot(equals(testRecordTitle))),
        const TypeMatcher<ExListState>()
            .having((p0) => p0.records[0].title, 'records[0].title', testRecordTitle)
            .having((p0) => p0.records[1].title, 'records[1].title', testRecordTitle),
      ],
    );

    int? deletedRecordId;
    blocTest<ComplexListBloc, dynamic>(
      'should update record after unsuccessful loading operation',
      build: () => _defaultBlocBuilder(db: db),
      act: (bloc) async {
        await bloc.stream.where((event) => !event.isLoading).first; // Wait for list is loaded

        bloc.settings.setExceptionsToRaise(1);
        bloc.loadNextPage();

        await bloc.stream.where((event) => !event.isLoading).first;

        deletedRecordId = bloc.state.records.last.id;
        await db.exampleRecordRepository.deleteRecord(deletedRecordId!);

        await bloc.stream.first;

        // expect(bloc.state.records.where((element) => element.id == idToDelete), findsNothing);
      },
      expect: () => [
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isTrue),
        const TypeMatcher<ExListState>().having((p0) => p0.isLoading, 'isLoading', isFalse),
        const TypeMatcher<ExListState>().having((p0) => p0.records.where((element) => element.id == deletedRecordId), 'hasDeletedRecord', isEmpty),
      ],
    );
  });
}
