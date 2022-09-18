import 'package:mock_datasource/core/record.dart';
import 'package:mock_datasource/core/types.dart';

class BrandColor extends RecordModel<ID> {
  const BrandColor({required super.id, required this.color}) : super();

  final int color;

  @override
  List<Object?> get props => [id, color];

  @override
  String toString() =>
      'BrandColor($id, 0x${color.toRadixString(16).toUpperCase()})';
}
