import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RecordEvent<Key> extends Equatable {
  const RecordEvent(this.id);

  final Key id;

  @override
  List<Object?> get props => [id];
}

mixin RecordCreatedEvent<Key> on RecordEvent<Key> {}

mixin RecordUpdatedEvent<Key> on RecordEvent<Key> {}

mixin RecordDeletedEvent<Key> on RecordEvent<Key> {}
