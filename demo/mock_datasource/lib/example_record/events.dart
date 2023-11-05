import 'package:meta/meta.dart';
import 'package:mock_datasource/core/events.dart';
import 'package:mock_datasource/core/types.dart';

abstract class ExampleRecordEvent extends RecordEvent<ID> {
  const ExampleRecordEvent(super.id) : super();
}

@immutable
class ExampleRecordCreatedEvent extends ExampleRecordEvent
    with RecordCreatedEvent<ID> {
  ExampleRecordCreatedEvent(super.id) : super();
}

@immutable
class ExampleRecordUpdatedEvent extends ExampleRecordEvent
    with RecordUpdatedEvent<ID> {
  ExampleRecordUpdatedEvent(super.id) : super();
}

@immutable
class ExampleRecordDeletedEvent extends ExampleRecordEvent
    with RecordDeletedEvent<ID> {
  ExampleRecordDeletedEvent(super.id) : super();
}
