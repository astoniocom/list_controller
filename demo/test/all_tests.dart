import 'examples/actualizing_test.dart' as actualizing_test;
import 'examples/complex_bidirectional_bloc_list_test.dart' as complex_bidirectional_bloc_list_test;
import 'examples/complex_bloc_list_test.dart' as complex_bloc_list_test;
import 'examples/complex_value_notifier_list_test.dart' as complex_value_notifier_list_test;
import 'examples/filtering_sorting_test.dart' as filtering_sorting_test;
import 'examples/hot_huge_list_test.dart' as hot_huge_list_test;
import 'examples/huge_list_test.dart' as huge_list_test;
import 'examples/isolate_loading_test.dart' as isolate_loading_test;
import 'examples/keyset_pagination_bloc_list_test.dart' as keyset_pagination_bloc_list_test;
import 'examples/keyset_pagination_list_test.dart' as keyset_pagination_list_test;
import 'examples/keyset_pagination_mobx_list_test.dart' as keyset_pagination_mobx_list_test;
import 'examples/keyset_pagination_statefull_widget_list_test.dart' as keyset_pagination_statefull_widget_list_test;
import 'examples/line_by_line_loading_test.dart' as line_by_line_loading_test;
import 'examples/minimal_test.dart' as minimal_test;
import 'examples/offset_pagination_list_test.dart' as offset_pagination_list_test;
import 'examples/record_tracking_test.dart' as record_tracking_test;
import 'examples/records_loading_test.dart' as records_loading_test;
import 'examples/related_records_list_test.dart' as related_records_list_test;
import 'examples/repeating_queries_test.dart' as repeating_queries_test;
import 'screens/home_screen_test.dart' as home_screen_test;
import 'screens/record_edit_screen_test.dart' as record_edit_screen_test;
import 'screens/settings_screen_test.dart' as settings_screen_test;
import 'widgets/example_app_bar_test.dart' as example_app_bar_test;
import 'widgets/record_teaser_test.dart' as record_teaser_test;
import 'widgets/search_app_bar_test.dart' as search_app_bar_test;
import 'widgets/search_field_test.dart' as search_field_test;

void main() {
  actualizing_test.main();
  complex_bidirectional_bloc_list_test.main();
  complex_bloc_list_test.main();
  complex_value_notifier_list_test.main();
  filtering_sorting_test.main();
  hot_huge_list_test.main();
  huge_list_test.main();
  isolate_loading_test.main();
  keyset_pagination_bloc_list_test.main();
  keyset_pagination_list_test.main();
  keyset_pagination_mobx_list_test.main();
  keyset_pagination_statefull_widget_list_test.main();
  line_by_line_loading_test.main();
  minimal_test.main();
  offset_pagination_list_test.main();
  record_tracking_test.main();
  records_loading_test.main();
  related_records_list_test.main();
  repeating_queries_test.main();

  home_screen_test.main();
  record_edit_screen_test.main();
  settings_screen_test.main();

  example_app_bar_test.main();
  record_teaser_test.main();
  search_app_bar_test.main();
  search_field_test.main();
}
