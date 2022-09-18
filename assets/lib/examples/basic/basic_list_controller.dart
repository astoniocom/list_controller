import 'package:flutter/foundation.dart';
import 'package:list_controller/list_controller.dart';

class BasicListController extends ValueNotifier<List<int>> with ListCore<int> {
  BasicListController() : super(List<int>.generate(100, (i) => i + 1));

  @override
  void dispose() {
    closeList();
    super.dispose();
  }
}
