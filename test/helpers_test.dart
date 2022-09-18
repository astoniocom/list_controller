import 'package:list_controller/helpers/utils.dart';
import 'package:test/test.dart';

void main() {
  test('Wrapped', () {
    expect(Wrapped.withNull().value, isNull);
  });

  test('DefaultList exceptions', () {
    const list = DefaultList();
    expect(() => list.length = 2,
        throwsA(const TypeMatcher<UnimplementedError>()));
    expect(list.length, 0);
    expect(() => list[0], throwsA(const TypeMatcher<UnimplementedError>()));
    expect(() => list[0] = 1, throwsA(const TypeMatcher<UnimplementedError>()));
  });
}
