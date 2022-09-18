import 'package:equatable/equatable.dart';
import 'package:mock_datasource/core/record.dart';

class RecordQuery<KEY, T extends RecordModel<KEY>> extends Equatable {
  const RecordQuery({this.idIn, this.idNotIn});

  final Iterable<KEY>? idIn;
  final Iterable<KEY>? idNotIn;

  bool fits(T obj) {
    return (idIn == null || idIn!.contains(obj.id)) &&
        (idNotIn == null || !idNotIn!.contains(obj.id));
  }

  Iterable<T> filter(Iterable<T> records) => records.where(fits);

  int compareRecords(T record1, T record2) => 0;

  @override
  List<dynamic> get props => [idIn, idNotIn];
}
