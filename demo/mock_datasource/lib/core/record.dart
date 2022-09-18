import 'package:equatable/equatable.dart';
import 'package:mock_datasource/core/get_pk.dart';

abstract class RecordModel<KEY> extends Equatable implements GetPK<KEY> {
  const RecordModel({required this.id});

  @override
  List<Object?> get props => [id];

  @override
  final KEY id;
}
