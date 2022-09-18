import 'package:mock_datasource/brand_color/models.dart';
import 'package:mock_datasource/core/query.dart';
import 'package:mock_datasource/core/types.dart';

class BrandColorQuery extends RecordQuery<ID, BrandColor> {
  const BrandColorQuery({
    super.idIn,
    super.idNotIn,
  }) : super();
}
