import 'package:list_controller/mixins/list_core.dart';
import 'package:mockito/mockito.dart';

class MockCoreController extends Mock with ListCore<int> {
  MockCoreController() {
    throwOnMissingStub(this);
  }

  void close() {
    closeList();
  }
}
