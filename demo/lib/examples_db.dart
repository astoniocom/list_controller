import 'package:demo/examples/actualizing/actualizing_view.dart';
import 'package:demo/examples/async_records_loading/async_records_loading_view.dart';
import 'package:demo/examples/basic/basic_view.dart';
import 'package:demo/examples/carousel_slider/carousel_slider_view.dart';
import 'package:demo/examples/complex_bidirectional_bloc_list/complex_bidirectional_bloc_list_view.dart';
import 'package:demo/examples/complex_bloc_list/complex_bloc_list_view.dart';
import 'package:demo/examples/complex_value_notifier_list/complex_value_notifier_list_view.dart';
import 'package:demo/examples/filtering_sorting/filtering_sorting_view.dart';
import 'package:demo/examples/hot_huge_list/hot_huge_list_view.dart';
import 'package:demo/examples/huge_list/huge_list_view.dart';
import 'package:demo/examples/isolate_loading/isolate_loading_view.dart';
import 'package:demo/examples/keyset_pagination_bloc_list/keyset_pagination_bloc_list_view.dart';
import 'package:demo/examples/keyset_pagination_mobx_list/keyset_pagination_mobx_list_view.dart';
import 'package:demo/examples/keyset_pagination_statefull_widget/keyset_pagination_statefull_widget.dart';
import 'package:demo/examples/keyset_pagination_value_notifier_list/keyset_pagination_value_notifier_list_view.dart';
import 'package:demo/examples/line_by_line_loading/line_by_line_loading_view.dart';
import 'package:demo/examples/offset_pagination_list/offset_pagination_list_view.dart';
import 'package:demo/examples/offset_pagination_splitted_list/offset_pagination_splitted_list_view.dart';
import 'package:demo/examples/record_tracking/record_tracking_view.dart';
import 'package:demo/examples/related_records_list/related_records_list_view.dart';
import 'package:demo/examples/repeating_queries/repeating_queries_view.dart';
import 'package:demo/models.dart';

final List<Example> examples = [
  Example(
    title: 'Basic Example',
    description: 'Does nothing, but a good starting point for adding functionality.',
    usedFeatures: ['ValueNotifier', 'ListCore'],
    builder: (e, _) => BasicExample(title: e.title, sources: e.sources),
    slug: 'basic',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/basic/basic_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/basic/basic_view.dart'),
    ],
  ),
  Example(
    title: 'Asynchronous records loading',
    description: 'Emulates asynchronous data loading.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader'],
    builder: (e, _) => AsyncRecordsLoadingExample(title: e.title, sources: e.sources),
    slug: 'async_records_loading',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/async_records_loading/async_records_loading_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/async_records_loading/async_records_loading_view.dart'),
    ],
  ),
  Example(
    title: 'Filtering and sorting',
    description: 'Demonstrates how to filter and sort records. If conditions change during loading, the unfinished loading will be ignored.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader'],
    builder: (e, _) => FilteringSortingExample(title: e.title, sources: e.sources),
    slug: 'filtering_sorting',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/filtering_sorting/filtering_sorting_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/filtering_sorting/filtering_sorting_view.dart'),
    ],
  ),
  Example(
    title: 'Line by line records loading',
    description: 'Demonstrates how to show intermediate loading results.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader'],
    builder: (e, _) => LineByLineLoadingExample(title: e.title, sources: e.sources),
    slug: 'line_by_line_loading',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/line_by_line_loading/line_by_line_loading_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/line_by_line_loading/line_by_line_loading_view.dart'),
    ],
  ),
  Example(
    title: 'Keyset Pagination StatefulWidget list',
    description: 'Implementation of keyset pagination list controller based on StatefulWidget.',
    usedFeatures: ['RecordsLoader', 'KeysetPagination'],
    builder: (e, _) => KeysetPaginationStatefullWidgetExample(title: e.title, sources: e.sources),
    slug: 'keyset_pagination_statefull_widget',
    sources: const [
      SourceFile(title: 'View', codeFile: 'lib/examples/keyset_pagination_statefull_widget/keyset_pagination_statefull_widget.dart'),
    ],
  ),
  Example(
    title: 'Keyset Pagination ValueNotifier list',
    description: 'Implementation of keyset pagination list controller based on ValueNotifier.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'KeysetPagination'],
    builder: (e, _) => KeysetPaginationValueNotifierListExample(title: e.title, sources: e.sources),
    slug: 'keyset_pagination_value_notifier_list',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/keyset_pagination_value_notifier_list/keyset_pagination_value_notifier_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/keyset_pagination_value_notifier_list/keyset_pagination_value_notifier_list_view.dart'),
    ],
  ),
  Example(
    title: 'Keyset Pagination Bloc list',
    description: 'Implementation of keyset pagination list controller based on Bloc.',
    usedFeatures: ['Bloc', 'RecordsLoader', 'KeysetPagination'],
    builder: (e, _) => KeysetPaginationBlocListExample(title: e.title, sources: e.sources),
    slug: 'keyset_pagination_bloc_list',
    sources: const [
      SourceFile(title: 'Query', codeFile: 'lib/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_query.dart'),
      SourceFile(title: 'Events', codeFile: 'lib/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_events.dart'),
      SourceFile(title: 'Bloc', codeFile: 'lib/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_bloc.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/keyset_pagination_bloc_list/keyset_pagination_bloc_list_view.dart'),
    ],
  ),
  Example(
    title: 'Keyset Pagination Mobx list',
    description: 'Implementation of keyset pagination list controller based on Mobx.',
    usedFeatures: ['Mobx', 'RecordsLoader', 'KeysetPagination'],
    builder: (e, _) => KeysetPaginationMobxListExample(title: e.title, sources: e.sources),
    slug: 'keyset_pagination_mobx_list',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/keyset_pagination_mobx_list/keyset_pagination_mobx_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/keyset_pagination_mobx_list/keyset_pagination_mobx_list_view.dart'),
    ],
  ),
  Example(
    title: 'Offset Pagination ValueNotifier list',
    description: 'Implementation of offset pagination list controller based on ValueNotifier.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'OffsetPagination'],
    builder: (e, _) => OffsetPaginationListExample(title: e.title, sources: e.sources),
    slug: 'offset_pagination_list',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/offset_pagination_list/offset_pagination_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/offset_pagination_list/offset_pagination_list_view.dart'),
    ],
  ),
  Example(
    title: 'Offset Pagination splitted list',
    description: 'Implementation of offset pagination list controller based on ValueNotifier.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'OffsetPagination'],
    builder: (e, _) => OffsetPaginationSplittedListExample(title: e.title, sources: e.sources),
    slug: 'offset_pagination_splitted_list',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/offset_pagination_splitted_list/offset_pagination_splitted_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/offset_pagination_splitted_list/offset_pagination_splitted_list_view.dart'),
    ],
  ),
  Example(
    title: 'Repeating Queries',
    description: 'Based on paginated list, demonstrates the handling of loading errors and retrying a failed load.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'KeysetPagination'],
    builder: (e, _) => RepeatingQueriesExample(title: e.title, sources: e.sources),
    slug: 'repeating_queries',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/repeating_queries/repeating_queries_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/repeating_queries/repeating_queries_view.dart'),
    ],
  ),
  Example(
    title: 'Tracking records and handling changes',
    description: 'Sorts the list when a record weight changes after tapping on it.',
    usedFeatures: ['ValueNotifier', 'RecordsTracker'],
    builder: (e, _) => RecordsTrackingExample(title: e.title, sources: e.sources),
    slug: 'records_tracking',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/record_tracking/record_tracking_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/record_tracking/record_tracking_view.dart'),
    ],
  ),
  Example(
    title: 'Tracking changes in the database and actualizing the list',
    description: 'Provides buttons for changing records in the database. Subscribes to database changes, then updates the list to keep it up-to-date.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'HotList'],
    builder: (e, _) => ActualizingExample(title: e.title, sources: e.sources),
    slug: 'tracking_database',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/actualizing/actualizing_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/actualizing/actualizing_view.dart'),
    ],
  ),
  Example(
    title: 'Records loading in Isolate',
    description: 'Demonstrates how to load records in Isolate. If conditions change during loading, the appropriate Isolate will be killed.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader'],
    builder: (e, _) => IsolateLoadingExample(title: e.title, sources: e.sources),
    slug: 'isolate_loading',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/isolate_loading/isolate_loading_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/isolate_loading/isolate_loading_view.dart'),
    ],
  ),
  /*Example(
      title: 'List actualizing optimizations',
      description: 'Buffering, related loading',
      builder: (e, _) => Minimal(title: e.title),
      path: 'minimal',
    ),
    Example(
      title: 'Loading and actualizing synchronization',
      description: 'live-list table',
      builder: (e, _) => Minimal(title: e.title),
      path: 'minimal',
    ),
    Example(
      title: 'Extended list state',
      description: '',
      builder: (e, _) => Minimal(title: e.title),
      path: 'minimal',
    ),*/
  Example(
    title: 'Related Records List',
    description:
        'Demonstrates how to minimize database load when actualizing the list. Related records (Color) are queried from the database after checking whether they should be added to the list.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'KeysetPagination', 'HotList'],
    builder: (e, _) => RelatedRecordsListExample(title: e.title, sources: e.sources),
    slug: 'related_records_list',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/related_records_list/related_records_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/related_records_list/related_records_list_view.dart'),
    ],
  ),
  Example(
    title: 'Huge List',
    description:
        'Simplest example of a very long list allowing for instantly scrolling to any position in the list and asynchronously loading records. Only requested records are stored in memory.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'OffsetPagination'],
    builder: (e, _) => HugeListExample(title: e.title, sources: e.sources),
    slug: 'huge_list',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/huge_list/huge_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/huge_list/huge_list_view.dart'),
    ],
  ),
  Example(
    title: 'Hot Huge List',
    description:
        'Example of a very long list allowing for instantly scrolling to any position in the list, asynchronously loading records and updating the list when the database data changes. Only requested records are stored in memory.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'OffsetPagination', 'HotList'],
    builder: (e, _) => HotHugeListExample(title: e.title, sources: e.sources),
    slug: 'hot_huge_list',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/hot_huge_list/hot_huge_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/hot_huge_list/hot_huge_list_view.dart'),
    ],
  ),
  Example(
    title: 'Carousel Slider',
    description: "Demonstrates the list controller's work with not the ListView widget.",
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'KeysetPagination'],
    builder: (e, _) => CarouselSliderExample(title: e.title, sources: e.sources),
    slug: 'carousel_slider',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/carousel_slider/carousel_slider_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/carousel_slider/carousel_slider_view.dart'),
    ],
  ),
  Example(
    title: 'Complex Bloc list',
    description: 'Demonstrates all the main features implemented in a single list: Filtering, Paginating, Adding, Editing, Deleting records.',
    usedFeatures: ['Bloc', 'RecordsLoader', 'KeysetPagination', 'HotList'],
    builder: (e, _) => ComplexBlocListExample(title: e.title, sources: e.sources),
    slug: 'complex_bloc_list',
    sources: const [
      SourceFile(title: 'Bloc', codeFile: 'lib/examples/complex_bloc_list/bloc/complex_list_bloc.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/complex_bloc_list/complex_bloc_list_view.dart'),
    ],
  ),
  Example(
    title: 'Complex ValueNotifier list',
    description: 'Demonstrates all the main features implemented in a single list: Filtering, Paginating, Adding, Editing, Deleting records.',
    usedFeatures: ['ValueNotifier', 'RecordsLoader', 'KeysetPagination', 'HotList'],
    builder: (e, _) => ComplexValueNotifierListExample(title: e.title, sources: e.sources),
    slug: 'complex_value_notifier_list',
    sources: const [
      SourceFile(title: 'Controller', codeFile: 'lib/examples/complex_value_notifier_list/complex_value_notifier_list_controller.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/complex_value_notifier_list/complex_value_notifier_list_view.dart'),
    ],
  ),
  Example(
    title: 'Complex bidirectional Bloc list',
    description:
        'Implementation of a list that can be scrolled in both directions. Demonstrates all the main features: Filtering, Paginating, Adding, Editing, Deleting records.',
    usedFeatures: ['Bloc', 'RecordsLoader', 'KeysetPagination', 'HotList'],
    builder: (e, _) => ComplexBidirectionalBlocListExample(title: e.title, sources: e.sources),
    slug: 'complex_bidirectional_bloc_list',
    sources: const [
      SourceFile(title: 'State', codeFile: 'lib/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_state.dart'),
      SourceFile(title: 'Bloc', codeFile: 'lib/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_bloc.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/complex_bidirectional_bloc_list/complex_bidirectional_bloc_list_view.dart'),
    ],
  ),
  Example(
    title: 'Complex bidirectional Bloc list with limited store',
    description:
        'Implementation of a list that can be scrolled in both directions and has a limited number of records to store. Demonstrates all the main features: Filtering, Paginating, Adding, Editing, Deleting records.',
    usedFeatures: ['Bloc', 'RecordsLoader', 'KeysetPagination', 'HotList'],
    builder: (e, _) => ComplexBidirectionalBlocListExample(title: e.title, sources: e.sources, storeSize: 45),
    slug: 'complex_bidirectional_bloc_list_limited_store',
    sources: const [
      SourceFile(title: 'State', codeFile: 'lib/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_state.dart'),
      SourceFile(title: 'Bloc', codeFile: 'lib/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_bloc.dart'),
      SourceFile(title: 'View', codeFile: 'lib/examples/complex_bidirectional_bloc_list/complex_bidirectional_bloc_list_view.dart'),
    ],
  ),
];
