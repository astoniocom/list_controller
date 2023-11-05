import 'package:list_controller/exceptions.dart';
import 'package:test/test.dart';

void main() {
  test('InterruptLoading exception represents itself with message', () {
    const message = 'test message';
    expect(const InterruptLoading(message).toString(),
        'InterruptLoading($message)');
  });

  test('InterruptLoading exception represents itself without message', () {
    expect(const InterruptLoading().toString(), 'InterruptLoading');
  });

  test('WrongListStateException represents itself with message', () {
    const message = 'test message';
    expect(const WrongListStateException(message).toString(),
        'WrongListStateException($message)');
  });

  test('WrongListStateException represents itself without message', () {
    expect(
        const WrongListStateException().toString(), 'WrongListStateException');
  });

  test('UnexpectedLoadingKeyException represents itself with message', () {
    const message = 'test message';
    expect(const UnexpectedLoadingKeyException(message).toString(),
        'UnexpectedLoadingKeyException($message)');
  });

  test('UnexpectedLoadingKeyException represents itself without message', () {
    expect(const UnexpectedLoadingKeyException().toString(),
        'UnexpectedLoadingKeyException');
  });
}
