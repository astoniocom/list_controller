import 'package:mock_datasource/brand_color/query.dart';
import 'package:test/test.dart';

void main() {
  test('BrandColorQuery: equality', () {
    expect(
        // ignore: prefer_const_constructors
        BrandColorQuery(
          idIn: const [1],
        ),
        // ignore: prefer_const_constructors
        BrandColorQuery(
          idIn: const [1],
        ));
  });
}
