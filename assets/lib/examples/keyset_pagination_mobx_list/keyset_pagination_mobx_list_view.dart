import 'package:demo/examples/keyset_pagination_mobx_list/keyset_pagination_mobx_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class KeysetPaginationMobxListExample extends StatefulWidget {
  const KeysetPaginationMobxListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  State<KeysetPaginationMobxListExample> createState() => _KeysetPaginationMobxListExampleState();
}

class _KeysetPaginationMobxListExampleState extends State<KeysetPaginationMobxListExample> {
  late final _listController = PaginationMobxListController();

  @override
  void dispose() {
    _listController.closeList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: widget.title, sources: widget.sources),
      body: Observer(
        builder: (_) {
          final listState = _listController.state;

          return Stack(
            children: [
              ListView.builder(
                itemCount: listState.records.length,
                itemBuilder: (context, index) {
                  const recordsLoadThreshold = 1;
                  if (index >= _listController.state.records.length - recordsLoadThreshold) {
                    _listController.loadNextPage();
                  }
                  return ListTile(title: Text('${listState.records[index]}'));
                },
              ),
              if (listState.isLoading) const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }
}
