import 'package:demo/examples/complex_bloc_list/bloc/complex_list_bloc.dart';
import 'package:demo/models.dart';
import 'package:demo/screens/record_edit_screen.dart';
import 'package:demo/settings.dart';
import 'package:demo/widgets/list_status_indicator.dart';
import 'package:demo/widgets/record_teaser.dart';
import 'package:demo/widgets/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:provider/provider.dart';

class ComplexBlocListExample extends StatelessWidget {
  const ComplexBlocListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;
  static const createRecordBtnKey = Key('homeScreenCreateRecordButton');

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => MockDatabase()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Builder(builder: (context) {
        final settingsController = context.watch<SettingsController>();

        return BlocProvider<ComplexListBloc>(
          key: ValueKey(Object.hash(settingsController.value.batchSize, settingsController.value.recordsLoadThreshold)),
          create: (context) => ComplexListBloc(
            settings: context.read<SettingsController>(),
            initialState: const ExListState(query: ExampleRecordQuery()),
            repository: context.read<MockDatabase>().exampleRecordRepository,
          ),
          child: Builder(builder: (context) {
            final listBloc = context.read<ComplexListBloc>();
            return BlocBuilder<ComplexListBloc, ExListState>(builder: (context, listState) {
              final itemCount = listState.records.length + (ListStatusIndicator.canRepresentState(listState) ? 1 : 0);
              return Scaffold(
                appBar: ComplexExampleAppBar(
                  title: title,
                  sources: sources,
                  query: listState.query.contains ?? '',
                  onChanged: (searchQuery) {
                    listBloc.add(ResetEvent<ExampleRecordQuery>(query: ExampleRecordQuery(contains: searchQuery)));
                  },
                ),
                body: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == listState.records.length && ListStatusIndicator.canRepresentState(listState)) {
                      return ListStatusIndicator(listState: listState, onRepeat: () => listBloc.add(const RepeatQueryEvent()));
                    }

                    if (index >= listState.records.length - context.read<SettingsController>().value.recordsLoadThreshold) {
                      listBloc.add(const LoadNextPageEvent());
                    }

                    return RecordTeaser(listState.records[index]);
                  },
                  itemCount: itemCount,
                ),
                floatingActionButton: FloatingActionButton(
                  key: ComplexBlocListExample.createRecordBtnKey,
                  onPressed: () async =>
                      RecordEditScreen.open(context: context, db: context.read<MockDatabase>(), settings: context.read<SettingsController>()),
                  tooltip: 'Create record',
                  child: const Icon(Icons.add),
                ),
              );
            });
          }),
        );
      }),
    );
  }
}
