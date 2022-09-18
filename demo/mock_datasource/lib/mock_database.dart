import 'package:mock_datasource/brand_color/repository.dart';
import 'package:mock_datasource/mock_datasource.dart';

class MockDatabase {
  MockDatabase({int recodsNum = 1000, int colorsNum = 10}) {
    controller = DatabaseController<ID>();
    brandColorRepository =
        BrandColorRepository(recodsNum: colorsNum, controller: controller);

    exampleRecordRepository = ExampleRecordRepository(
        recodsNum: recodsNum,
        controller: controller,
        brandColorRepository: brandColorRepository);
  }

  late DatabaseController<ID> controller;
  late ExampleRecordRepository exampleRecordRepository;
  late BrandColorRepository brandColorRepository;
}
