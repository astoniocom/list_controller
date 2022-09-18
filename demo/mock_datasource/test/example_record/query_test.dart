import 'package:mock_datasource/mock_datasource.dart';
import 'package:test/test.dart';

void main() {
  test('ExampleRecordQuery: equality', () {
    expect(
        // ignore: prefer_const_constructors
        ExampleRecordQuery(
          contains: 'test',
          weightGt: 1,
          weightLt: 2,
          weightGte: 3,
          weightLte: 4,
          revesed: true,
        ),
        // ignore: prefer_const_constructors
        ExampleRecordQuery(
          contains: 'test',
          weightGt: 1,
          weightLt: 2,
          weightGte: 3,
          weightLte: 4,
          revesed: true,
        ));
  });

  test('ExampleRecordQuery: copyWith', () {
    const query = ExampleRecordQuery();
    final copiedQuery = query.copyWith(
      contains: 'test',
      weightGt: 1,
      weightLt: 2,
      weightGte: 3,
      weightLte: 4,
      revesed: false,
    );
    expect(copiedQuery.contains, 'test');
    expect(copiedQuery.weightGt, 1);
    expect(copiedQuery.weightLt, 2);
    expect(copiedQuery.weightGte, 3);
    expect(copiedQuery.weightLte, 4);
    expect(copiedQuery.revesed, isFalse);

    final copiedQuery2 = query.copyWith(
      weightGt: null,
      weightLt: null,
      weightGte: null,
      weightLte: null,
    );

    expect(copiedQuery2.weightGt, isNull);
    expect(copiedQuery2.weightLt, isNull);
    expect(copiedQuery2.weightGte, isNull);
    expect(copiedQuery2.weightLte, isNull);
  });

  test('ExampleRecordQuery: fits, weightGt', () {
    const testVal = 5;
    const query = ExampleRecordQuery(weightGt: testVal);
    const record = ExampleRecord(id: 0, title: '', weight: testVal + 1);
    expect(query.fits(record), true);

    const record1 = ExampleRecord(id: 0, title: '', weight: testVal);
    expect(query.fits(record1), false);

    const record2 = ExampleRecord(id: 0, title: '', weight: testVal - 1);
    expect(query.fits(record2), false);
  });

  test('ExampleRecordQuery: fits, weightLt', () {
    const testVal = 5;
    const query = ExampleRecordQuery(weightLt: testVal);
    const record = ExampleRecord(id: 0, title: '', weight: testVal + 1);
    expect(query.fits(record), false);

    const record1 = ExampleRecord(id: 0, title: '', weight: testVal);
    expect(query.fits(record1), false);

    const record2 = ExampleRecord(id: 0, title: '', weight: testVal - 1);
    expect(query.fits(record2), true);
  });

  test('ExampleRecordQuery: fits, weightGte', () {
    const testVal = 5;
    const query = ExampleRecordQuery(weightGte: testVal);
    const record = ExampleRecord(id: 0, title: '', weight: testVal + 1);
    expect(query.fits(record), true);

    const record1 = ExampleRecord(id: 0, title: '', weight: testVal);
    expect(query.fits(record1), true);

    const record2 = ExampleRecord(id: 0, title: '', weight: testVal - 1);
    expect(query.fits(record2), false);
  });

  test('ExampleRecordQuery: fits, weightLte', () {
    const testVal = 5;
    const query = ExampleRecordQuery(weightLte: testVal);
    const record = ExampleRecord(id: 0, title: '', weight: testVal + 1);
    expect(query.fits(record), false);

    const record1 = ExampleRecord(id: 0, title: '', weight: testVal);
    expect(query.fits(record1), true);

    const record2 = ExampleRecord(id: 0, title: '', weight: testVal - 1);
    expect(query.fits(record2), true);
  });

  test('ExampleRecordQuery: fits, contains', () {
    const query = ExampleRecordQuery(contains: 'test');
    const record = ExampleRecord(id: 0, title: ' test ', weight: 0);
    expect(query.fits(record), true);

    const record1 = ExampleRecord(id: 0, title: ' qwer ', weight: 0);
    expect(query.fits(record1), false);
  });

  test('ExampleRecordQuery: compareRecords', () {
    const record1 = ExampleRecord(id: 0, title: '', weight: 1);
    const record2 = ExampleRecord(id: 0, title: '', weight: 4);
    const query = ExampleRecordQuery();
    expect(query.compareRecords(record1, record2), -1);

    final query2 = query.copyWith(revesed: true);
    expect(query2.compareRecords(record1, record2), 1);
  });
}
