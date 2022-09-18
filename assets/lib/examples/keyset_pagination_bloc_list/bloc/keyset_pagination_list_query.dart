import 'package:equatable/equatable.dart';

class KeysetPaginationListQuery extends Equatable {
  const KeysetPaginationListQuery({this.weightGt = 0});

  final int weightGt;

  @override
  List<Object?> get props => [weightGt];
}
