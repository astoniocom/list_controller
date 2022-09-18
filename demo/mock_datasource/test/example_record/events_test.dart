import 'package:mock_datasource/example_record/events.dart';
import 'package:test/test.dart';

void main() {
  test('ExampleRecordCreatedEvent equality', () {
    expect(ExampleRecordCreatedEvent(1), ExampleRecordCreatedEvent(1));
  });

  test('ExampleRecordUpdatedEvent equality', () {
    expect(ExampleRecordUpdatedEvent(1), ExampleRecordUpdatedEvent(1));
  });

  test('ExampleRecordDeletedEvent equality', () {
    expect(ExampleRecordDeletedEvent(1), ExampleRecordDeletedEvent(1));
  });
}
