import 'package:list_controller/helpers/list_state.dart';
import 'package:list_controller/helpers/utils.dart';
import 'package:list_controller/list_stages.dart';
import 'package:test/test.dart';

void main() {
  test('Wrapped', () {
    expect(Wrapped.withNull().value, isNull);
  });

  test('ListStateMeta constructor', () {
    expect(
        ListStateMeta(
            isEmpty: true, stage: ListStage.idle(), isInitialized: false),
        isA<ListStateMeta>());
  });

  test('ListState [records]', () {
    expect(const ListState(query: 1).records, []);
  });

  test('ListState [isInitialized] is false', () {
    expect(const ListState(query: 1).isInitialized, isFalse);
  });

  test('ListState with records has false [isInitialized]', () {
    expect(
        const ListState(query: 1, records: [1, 2, 3]).isInitialized, isFalse);
  });

  test('ListState copied with records has true [isInitialized]', () {
    expect(const ListState(query: 1).copyWith(records: [1, 2]).isInitialized,
        isTrue);
  });

  test('ListState [isLoading]', () {
    expect(ListState(query: 1, stage: ListStage.loading()).isLoading, isTrue);
  });

  test('ListState [toString]', () {
    expect(const ListState(query: 1).toString().contains('ListState('), isTrue);
  });

  test('ListState equality', () {
    expect(const ListState(query: 1), const ListState(query: 1));
  });

  test('ListState [hashCode]', () {
    expect(const ListState(query: 1).hashCode,
        isNot(const ListState(query: 2).hashCode));
  });

  test('ListState [copyWith]', () {
    expect(
        const ListState<int, int>(query: 1).copyWith(
            records: const [1, 2, 3], query: 2, stage: ListStage.error()),
        ListState(
            records: const [1, 2, 3], query: 2, stage: ListStage.error()));
  });

  test('ListState [isEmpty] is true', () {
    expect(const ListState<int, int>(query: 1, records: []).isEmpty, true);
  });

  test('ListState [isEmpty] is false', () {
    expect(
        const ListState<int, int>(query: 1, records: [1, 2, 3]).isEmpty, false);
  });

  test('ListState [copyWith] without arguments', () {
    expect(
        ListState(records: const [1, 2, 3], query: 2, stage: ListStage.error())
            .copyWith(),
        ListState(
            records: const [1, 2, 3], query: 2, stage: ListStage.error()));
  });
}
