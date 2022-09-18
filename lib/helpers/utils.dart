import 'dart:collection';

import 'package:meta/meta.dart';

/// A wrapper for nullable properties of a copyWith functions.
class Wrapped<T> {
  /// Creates a wrapper for nullable [value].
  const Wrapped(this.value);

  /// Creates a wrapper for the null value.
  factory Wrapped.withNull() => const Wrapped(null);

  /// Stores the wrapped value.
  final T? value;
}

/// Default value for a nullable `List` property of a copyWith functions.
@immutable
class DefaultList<T> with ListMixin<T> {
  /// Creates the default value.
  const DefaultList();

  @override
  set length(int newLength) => throw UnimplementedError();

  @override
  int get length => 0;

  @override
  T operator [](int index) => throw UnimplementedError();

  @override
  void operator []=(int index, T value) => throw UnimplementedError();
}
