import 'package:flutter/material.dart';
import 'package:list_controller/list_controller.dart';

class ListStatusIndicator extends StatelessWidget {
  const ListStatusIndicator({this.listState, this.onRepeat, super.key}) : super();

  final ListStateMeta? listState;

  final VoidCallback? onRepeat;

  static bool canRepresentState(ListStateMeta listState) =>
      listState.stage is ErrorListStage || listState.stage is LoadingListStage || (listState.isInitialized && listState.isEmpty);

  @override
  Widget build(BuildContext context) {
    Widget? stateIndicator;
    if (listState?.stage is ErrorListStage) {
      stateIndicator = const Text('Loading Error', textAlign: TextAlign.center);
      if (onRepeat != null) {
        stateIndicator = Row(
          mainAxisSize: MainAxisSize.min,
          children: [stateIndicator, const SizedBox(width: 8), IconButton(onPressed: onRepeat, icon: const Icon(Icons.refresh))],
        );
      }
    } else if (listState?.stage is LoadingListStage) {
      stateIndicator = const CircularProgressIndicator();
    } else if (listState != null && listState!.isInitialized && listState!.isEmpty) {
      stateIndicator = const Text('No records to display', textAlign: TextAlign.center);
    }

    return Container(height: 72.0, alignment: Alignment.center, child: stateIndicator);
  }
}
