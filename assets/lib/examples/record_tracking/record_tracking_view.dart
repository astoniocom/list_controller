import 'package:demo/examples/record_tracking/record_tracking_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class RecordsTrackingExample extends StatelessWidget {
  const RecordsTrackingExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => RecordTrackingListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<RecordTrackingListController>().value;
          return ListView.builder(
            itemCount: listState.length,
            itemBuilder: (context, index) => BlocProvider.value(
              value: listState[index],
              child: BlocBuilder<RecordCubit, RecordData>(
                key: ObjectKey(listState[index]),
                builder: (context, state) {
                  return ListTile(
                    tileColor: state.color,
                    title: Text('Initial position: ${state.initPosition}'),
                    trailing: Text('${state.weight}'),
                    onTap: context.read<RecordCubit>().increase,
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
