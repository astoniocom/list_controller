import 'package:mock_datasource/core/query.dart';
import 'package:mock_datasource/core/types.dart';
import 'package:mock_datasource/example_record/models.dart';

class ExampleRecordQuery extends RecordQuery<ID, ExampleRecord> {
  const ExampleRecordQuery({
    super.idIn,
    super.idNotIn,
    this.weightGt,
    this.weightLt,
    this.weightGte,
    this.weightLte,
    this.contains,
    this.revesed = false,
    this.page,
  }) : super();

  final String? contains;
  final int? weightGt;
  final int? weightLt;
  final int? weightGte;
  final int? weightLte;
  final bool revesed;
  final int? page;

  @override
  bool fits(ExampleRecord obj) {
    if (!super.fits(obj)) return false;
    if (weightGt != null && obj.weight <= weightGt!) return false;
    if (weightLt != null && obj.weight >= weightLt!) return false;
    if (weightGte != null && obj.weight < weightGte!) return false;
    if (weightLte != null && obj.weight > weightLte!) return false;
    if (contains != null &&
        contains!.isNotEmpty &&
        !obj.title.contains(contains!)) return false;
    return true;
  }

  ExampleRecordQuery copyWith({
    int? weightGt = defInt,
    int? weightLt = defInt,
    int? weightGte = defInt,
    int? weightLte = defInt,
    String? contains,
    bool? revesed,
    int? page,
  }) {
    return ExampleRecordQuery(
      weightGt: weightGt != defInt ? weightGt : this.weightGt,
      weightLt: weightLt != defInt ? weightLt : this.weightLt,
      weightGte: weightGte != defInt ? weightGte : this.weightGte,
      weightLte: weightLte != defInt ? weightLte : this.weightLte,
      contains: contains ?? this.contains,
      revesed: revesed ?? this.revesed,
      page: page ?? this.page,
    );
  }

  @override
  int compareRecords(ExampleRecord record1, ExampleRecord record2) {
    if (!revesed) return record1.weight.compareTo(record2.weight);
    return record2.weight.compareTo(record1.weight);
  }

  @override
  List<dynamic> get props => [
        ...super.props,
        weightGt,
        weightLt,
        weightGte,
        weightLte,
        contains,
        revesed,
        page
      ];
}
