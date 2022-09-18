import 'package:list_controller/exceptions.dart';
import 'package:list_controller/helpers/list_state.dart';
import 'package:list_controller/helpers/utils.dart';
import 'package:list_controller/list_stages.dart';
import 'package:test/test.dart';

void main() {
  test('Wrapped', () {
    expect(Wrapped.withNull().value, isNull);
  });

  test('ListState [records]', () {
    expect(ListState(query: 1).records, []);
  });

  test('ListState [isInitialized] is false', () {
    expect(ListState(query: 1).isInitialized, isFalse);
  });

  test('ListState [isInitialized] is true', () {
    expect(ListState(query: 1, records: const [1, 2, 3]).isInitialized, isTrue);
  });

  test('ListState [isLoading]', () {
    expect(ListState(query: 1, stage: ListStage.loading()).isLoading, isTrue);
  });

  test('ListState [toString]', () {
    expect(ListState(query: 1).toString().contains('ListState('), isTrue);
  });

  test('ListState equality', () {
    expect(ListState(query: 1), ListState(query: 1));
  });

  test('ListState [hashCode]', () {
    expect(ListState(query: 1).hashCode, isNot(ListState(query: 2).hashCode));
  });

  test('ListState [copyWith]', () {
    expect(
        ListState<int, int>(query: 1).copyWith(
            records: const [1, 2, 3], query: 2, stage: ListStage.error()),
        ListState(
            records: const [1, 2, 3], query: 2, stage: ListStage.error()));
  });

  test('ListState [copyWith] without arguments', () {
    expect(
        ListState(records: const [1, 2, 3], query: 2, stage: ListStage.error())
            .copyWith(),
        ListState(
            records: const [1, 2, 3], query: 2, stage: ListStage.error()));
  });

  test('ListState constructor throws [WrongListStateException]', () {
    expect(() => ListState(query: 1, records: const []),
        throwsA(const TypeMatcher<WrongListStateException>()));
  });
}
