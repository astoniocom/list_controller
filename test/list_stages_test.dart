import 'package:list_controller/list_stages.dart';
import 'package:test/test.dart';

void main() {
  test('LoadingListStage [toString]', () {
    expect(ListStage.loading().toString(), 'LoadingListStage');
  });

  test('ErrorListStage [toString]', () {
    expect(ListStage.error().toString(), 'ErrorListStage(error: null)');
  });

  test('CompleteListStage [toString]', () {
    expect(ListStage.complete().toString(), 'CompleteListStage');
  });

  test('DefaultListStage [toString]', () {
    expect(const DefaultListStage().toString(), 'DefaultListStage');
  });
}
