import 'package:mock_datasource/brand_color/models.dart';
import 'package:mock_datasource/example_record/models.dart';
import 'package:test/test.dart';

void main() {
  test('ExampleRecord equality', () {
    expect(
        ExampleRecord(id: 1, title: 'test', weight: 1, colorId: 1), // ignore: prefer_const_constructors
        ExampleRecord(id: 1, title: 'test', weight: 1, colorId: 1)); // ignore: prefer_const_constructors
  });

  test('ExpandedExampleRecord equality', () {
    expect(
        ExpandedExampleRecord(id: 1, title: 'test', weight: 1, colorId: 1, color: BrandColor(id: 1, color: 0x000000)), // ignore: prefer_const_constructors
        ExpandedExampleRecord(id: 1, title: 'test', weight: 1, colorId: 1, color: BrandColor(id: 1, color: 0x000000))); // ignore: prefer_const_constructors
  });
}
