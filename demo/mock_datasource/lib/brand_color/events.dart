import 'package:meta/meta.dart';
import 'package:mock_datasource/core/events.dart';
import 'package:mock_datasource/core/types.dart';

abstract class BrandColorEvent extends RecordEvent<ID> {
  const BrandColorEvent(super.id);
}

@immutable
class BrandColorCreatedEvent extends BrandColorEvent
    with RecordCreatedEvent<ID> {
  BrandColorCreatedEvent(super.id) : super();
}

@immutable
class BrandColorUpdatedEvent extends BrandColorEvent
    with RecordUpdatedEvent<ID> {
  BrandColorUpdatedEvent(super.id) : super();
}

@immutable
class BrandColorDeletedEvent extends BrandColorEvent
    with RecordDeletedEvent<ID> {
  BrandColorDeletedEvent(super.id) : super();
}
