import 'package:mock_datasource/core/record.dart';
import 'package:mock_datasource/core/types.dart';
import 'package:test/test.dart';

class MockRecord extends RecordModel<ID> {
  const MockRecord({required super.id}) : super();
}

void main() {
  test('RecordModel equality', () {
    expect(MockRecord(id: 1), MockRecord(id: 1)); // ignore: prefer_const_constructors
  });
}
