import 'package:mock_datasource/brand_color/models.dart';
import 'package:test/test.dart';

// ignore_for_file: prefer_const_constructors

void main() {
  test('BrandColor equality', () {
    expect(
        BrandColor(id: 1, color: 0xFFFFFF), BrandColor(id: 1, color: 0xFFFFFF));
  });

  test('BrandColor toString', () {
    expect(const BrandColor(id: 1, color: 0xFFFFFF).toString(),
        'BrandColor(1, 0xFFFFFF)');
  });
}
