import 'package:mock_datasource/brand_color/models.dart';
import 'package:mock_datasource/core/record.dart';
import 'package:mock_datasource/core/types.dart';

class ExampleRecord extends RecordModel<ID> {
  const ExampleRecord({
    required super.id,
    required this.title,
    required this.weight,
    this.colorId,
  }) : super();

  final String title;
  final int weight;
  final ID? colorId;

  @override
  List<Object?> get props => [id, title, weight, colorId];
}

class ExpandedExampleRecord extends ExampleRecord {
  const ExpandedExampleRecord({
    required super.id,
    required super.title,
    required super.weight,
    super.colorId,
    this.color,
  }) : super();

  final BrandColor? color;

  @override
  List<Object?> get props => [id, title, weight, colorId, color];
}
