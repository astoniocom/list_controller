import 'package:demo/examples/related_records_list/related_records_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/screens/record_edit_screen.dart';
import 'package:demo/settings.dart';
import 'package:demo/widgets/list_status_indicator.dart';
import 'package:demo/widgets/record_teaser.dart';
import 'package:demo/widgets/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:provider/provider.dart';

class RelatedRecordsListExample extends StatelessWidget {
  const RelatedRecordsListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  static const createRecordBtnKey = Key('relatedRecordsCreateRecordButton');

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => MockDatabase()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Builder(builder: (context) {
        final settingsController = context.watch<SettingsController>();
        return ChangeNotifierProvider(
          key: ValueKey(Object.hash(settingsController.value.batchSize, settingsController.value.recordsLoadThreshold)),
          create: (context) => RelatedRecordsListController(
            settings: context.read<SettingsController>(),
            initialState: ExListState(query: const ExampleRecordQuery()),
            repository: context.read<MockDatabase>().exampleRecordRepository,
          ),
          child: Builder(builder: (context) {
            final listState = context.watch<RelatedRecordsListController>().value;
            final controller = context.read<RelatedRecordsListController>();
            final itemCount = listState.records.length + (ListStatusIndicator.canRepresentState(listState) ? 1 : 0);
            return Scaffold(
              appBar: ComplexExampleAppBar(
                title: title,
                sources: sources,
                query: listState.query.contains ?? '',
                onChanged: (searchQuery) {
                  controller.reset(ExampleRecordQuery(contains: searchQuery));
                },
              ),
              body: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index == listState.records.length && ListStatusIndicator.canRepresentState(listState)) {
                    return ListStatusIndicator(listState: listState, onRepeat: controller.repeatQuery);
                  }

                  const recordsLoadThreshold = 1;
                  if (index >= listState.records.length - recordsLoadThreshold) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.loadNextPage();
                    });
                  }

                  return RecordTeaser(listState.records[index]);
                },
                itemCount: itemCount,
              ),
              floatingActionButton: FloatingActionButton(
                key: RelatedRecordsListExample.createRecordBtnKey,
                onPressed: () async =>
                    RecordEditScreen.open(context: context, displayColor: true, db: context.read<MockDatabase>(), settings: context.read<SettingsController>()),
                tooltip: 'Create record',
                child: const Icon(Icons.add),
              ),
            );
          }),
        );
      }),
    );
  }
}
