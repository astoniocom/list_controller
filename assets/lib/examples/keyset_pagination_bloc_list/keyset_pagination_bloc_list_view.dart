import 'package:demo/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_bloc.dart';
import 'package:demo/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_events.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KeysetPaginationBlocListExample extends StatelessWidget {
  const KeysetPaginationBlocListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: BlocProvider(
        create: (context) => KeysetPaginationListController(),
        child: Builder(builder: (context) {
          return BlocBuilder<KeysetPaginationListController, KeysetPaginationListState>(
            builder: (context, listState) {
              return Stack(
                children: [
                  ListView.builder(
                    itemCount: listState.records.length,
                    itemBuilder: (context, index) {
                      const recordsLoadThreshold = 1;
                      if (index >= listState.records.length - recordsLoadThreshold) {
                        context.read<KeysetPaginationListController>().add(const KeysetPaginationListLoadNextPageEvent());
                      }

                      return ListTile(title: Text('${listState.records[index]}'));
                    },
                  ),
                  if (listState.isLoading) const Center(child: CircularProgressIndicator()),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
