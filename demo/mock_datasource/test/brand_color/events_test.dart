import 'package:mock_datasource/brand_color/events.dart';
import 'package:test/test.dart';

void main() {
  test('BrandColorCreatedEvent equality', () {
    expect(BrandColorCreatedEvent(1), BrandColorCreatedEvent(1));
  });

  test('BrandColorUpdatedEvent equality', () {
    expect(BrandColorUpdatedEvent(1), BrandColorUpdatedEvent(1));
  });

  test('BrandColorDeletedEvent equality', () {
    expect(BrandColorDeletedEvent(1), BrandColorDeletedEvent(1));
  });
}
