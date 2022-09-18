import 'package:list_controller/list_controller.dart';
import 'package:meta/meta.dart';

/// Implements the loading of list records based on offset.
///
/// [Offset], for example, can be `int` with page order number.
/// In the mixins list, it should go after `RecordsLoader`.
mixin OffsetPagination<Record, Query, LoadResult, Offset>
    on RecordsLoader<Record, Query, LoadResult> {
  /// Should generate a loading key based on the [offset].
  ///
  /// If multiple pages can be loaded simultaneously, each [offset] must have
  /// a unique loading key. Otherwise, it can have any value.
  @protected
  LoadingKey offsetToLoadingKey(Offset offset);

  /// Based on [offset], the function should build a [Query] object
  /// that will be used to load the list page by the
  /// `loadRecords()` function.
  @protected
  Query buildOffsetQuery(Offset offset);

  /// Initiates page loading by [offset].
  void loadPage(Offset offset) {
    loadRecords(
      buildOffsetQuery(offset),
      loadingKey: offsetToLoadingKey(offset),
    );
  }
}
