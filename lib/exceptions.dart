/// Exception that should be thrown in `RecordsLoader.performLoadQuery`
/// when record loading fails.
class HandledLoadingException extends Error {}

/// Exception that should be thrown in `RecordsLoader.performLoadQuery`
/// to interrupt the loading process.
class InterruptLoading implements Exception {
  /// Creates a new `InterruptLoading` with an optional
  /// [message].
  const InterruptLoading([this.message]);

  /// A message describing the error.
  final String? message;

  @override
  String toString() {
    return message != null ? 'InterruptLoading: $message' : 'InterruptLoading';
  }
}

/// Exception to be thrown when the list state is impossible.
class WrongListStateException implements Exception {
  /// Creates a new `WrongListStateException` with an optional
  /// [message].
  const WrongListStateException([this.message]);

  /// A message describing the error.
  final String? message;

  @override
  String toString() {
    return message != null
        ? 'WrongListStateException: $message'
        : 'WrongListStateException';
  }
}

/// Exception to be thrown when a loading key provided to a function is
/// unexpected.
class UnexpectedLoadingKeyException implements Exception {
  /// Creates a new `UnexpectedLoadingKeyException` with an optional
  /// [message].
  const UnexpectedLoadingKeyException([this.message]);

  /// A message describing the error.
  final String? message;

  @override
  String toString() {
    return message != null
        ? 'UnexpectedLoadingKeyException: $message'
        : 'UnexpectedLoadingKeyException';
  }
}
