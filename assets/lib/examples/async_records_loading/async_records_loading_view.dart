import 'package:demo/examples/async_records_loading/async_records_loading_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AsyncRecordsLoadingExample extends StatelessWidget {
  const AsyncRecordsLoadingExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => AsyncRecordsLoadingListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<AsyncRecordsLoadingListController>().value;
          if (listState.isLoading) return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            itemCount: listState.records.length,
            itemBuilder: (context, index) => ListTile(title: Text('${listState.records[index]}')),
          );
        }),
      ),
    );
  }
}
