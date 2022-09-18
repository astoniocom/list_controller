import 'package:mock_datasource/core/database_controller.dart';
import 'package:mock_datasource/core/exceptions.dart';

abstract class BaseRepository<KEY, T, Query> {
  BaseRepository({required this.db});

  final DatabaseController<KEY> db;

  Future<List<T>> queryRecords(Query? query);
  Future<List<T>> getByIds(Iterable<KEY> ids);
  Future<T> getRecordByPk(KEY id) async {
    try {
      return await getByIds({id}).then((value) => value.first);
    } on StateError {
      throw RecordDoesNotExist();
    }
  }
}
