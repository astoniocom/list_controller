import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'offset_pagination_mock.dart';

void main() {
  group('OffsetPagination', () {
    late MockOffsetPaginationController controller;
    setUp(() {
      controller = MockOffsetPaginationController();
    });

    tearDown(() {
      controller.closeList();
    });

    test(
        'calls [buildOffsetQuery] and [offsetToLoadingKey] when [loadPage] is '
        'called', () async {
      controller.loadPage(1);

      verify(controller.buildOffsetQuery(1)).called(1);
      verify(controller.offsetToLoadingKey(1)).called(1);
    });
  });
}
