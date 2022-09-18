import 'package:mock_datasource/core/events.dart';
import 'package:mock_datasource/mock_database.dart';
import 'package:test/test.dart';

void main() {
  test('DatabaseController buffers events during transaction', () async {
    final db = MockDatabase(recodsNum: 100);
    db.controller.transaction(() async {
      await db.exampleRecordRepository
          .createRecord(title: 'title', weight: 999);
      await db.exampleRecordRepository.updateRecord(1, title: 'title');
      await db.exampleRecordRepository.deleteRecord(2);
    });

    expect(
      await db.controller.events.first,
      const TypeMatcher<List<RecordEvent<int>>>()
          .having((p0) => p0.length, '3 events', 3),
    );
  });
}
