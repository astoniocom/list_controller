import 'package:meta/meta.dart';

/// A base class for all the stages the list can be in.
abstract class ListStage {
  /// Abstract const constructor.
  const ListStage();

  /// List is idle.
  factory ListStage.idle() => const IdleListStage();

  /// List is loading.
  factory ListStage.loading() => const LoadingListStage();

  /// Loading the list records was unsuccessful.
  factory ListStage.error() => const ErrorListStage();

  /// List is complete and has not any pages to load.
  factory ListStage.complete() => const CompleteListStage();
}

/// Stage indicating that the list is idle.
@immutable
class IdleListStage extends ListStage {
  /// Creates a new `IdleListStage`.
  const IdleListStage();

  @override
  String toString() => 'IdleListStage';
}

/// Stage indicating that the list is loading.
@immutable
class LoadingListStage extends ListStage {
  /// Const constructor.
  const LoadingListStage();

  @override
  String toString() => 'LoadingListStage';
}

/// Stage indicating that loading of the list records was unsuccessful.
@immutable
class ErrorListStage extends ListStage {
  /// Const constructor.
  const ErrorListStage({this.error});

  /// If necessary, used to store the original exception/error object.
  final Object? error;

  @override
  String toString() => 'ErrorListStage(error: $error)';
}

/// Stage indicating that the list is complete and has not any pages to load
@immutable
class CompleteListStage extends ListStage {
  /// Const constructor.
  const CompleteListStage();

  @override
  String toString() => 'CompleteListStage';
}

/// Default value for a nullable `ListStage` property of a copyWith functions.
@immutable
class DefaultListStage extends ListStage {
  /// Const constructor.
  const DefaultListStage();

  @override
  String toString() => 'DefaultListStage';
}
