import 'package:meta/meta.dart';
import 'package:mock_datasource/core/events.dart';
import 'package:mock_datasource/core/types.dart';

abstract class BrandColorEvent extends RecordEvent<ID> {
  const BrandColorEvent(super.pk) : super();
}

@immutable
class BrandColorCreatedEvent extends BrandColorEvent
    with RecordCreatedEvent<ID> {
  BrandColorCreatedEvent(super.pk) : super();
}

@immutable
class BrandColorUpdatedEvent extends BrandColorEvent
    with RecordUpdatedEvent<ID> {
  BrandColorUpdatedEvent(super.pk) : super();
}

@immutable
class BrandColorDeletedEvent extends BrandColorEvent
    with RecordDeletedEvent<ID> {
  BrandColorDeletedEvent(super.pk) : super();
}
