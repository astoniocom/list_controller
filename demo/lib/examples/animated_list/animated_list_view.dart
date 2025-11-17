import 'dart:async';
import 'dart:math';

import 'package:demo/examples/animated_list/animated_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:provider/provider.dart';

class AnimatedListExample extends StatelessWidget {
  AnimatedListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  final db = MockDatabase(recodsNum: 11);
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();

  String _randomNoun() => nouns[Random().nextInt(nouns.length)];

  Future<void> _createRecord(BuildContext context, ExampleRecord parentRecord) async {
    final weight = parentRecord.weight + 1;
    try {
      await db.exampleRecordRepository.createRecord(title: _randomNoun(), weight: weight);
    } on WeightDuplicate {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Weight duplicate: $weight')));
    } on RecordDoesNotExist {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RecordDoesNotExist exception')));
    }
  }

  Widget buildListItem({required BuildContext context, required ExampleRecord record, required Animation<double> animation, required bool isActionsAvailable}) {
    return SizeTransition(
      key: ValueKey(record.id),
      sizeFactor: animation,
      child: ListTile(
        title: Text(record.title),
        subtitle: Text('weight: ${record.weight}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: isActionsAvailable ? () => _createRecord(context, record) : null, icon: const Icon(Icons.new_label)),
            IconButton(
                onPressed: isActionsAvailable ? () => db.exampleRecordRepository.updateRecord(record.id, title: _randomNoun()) : null,
                icon: const Icon(Icons.edit)),
            IconButton(onPressed: isActionsAvailable ? () => db.exampleRecordRepository.deleteRecord(record.id) : null, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }

  void _onListChange({required Map<int, ExampleRecord> removedItems, required Set<int> insertedIndexes}) {
    final animatedListState = _animatedListKey.currentState;
    if (animatedListState == null) return;

    for (final removedEntry in removedItems.entries) {
      animatedListState.removeItem(
        removedEntry.key,
        (BuildContext context, Animation<double> animation) {
          return buildListItem(
            context: context,
            animation: animation,
            record: removedEntry.value,
            isActionsAvailable: false,
          );
        },
      );
    }

    insertedIndexes.forEach(animatedListState.insertItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => AnimatedListController(db.exampleRecordRepository, onListChange: _onListChange),
        child: Builder(builder: (context) {
          final listState = context.watch<AnimatedListController>().value;
          return AnimatedList(
            key: _animatedListKey,
            initialItemCount: listState.records.length,
            itemBuilder: (context, index, Animation<double> animation) {
              return buildListItem(
                context: context,
                animation: animation,
                record: listState.records[index],
                isActionsAvailable: true,
              );
            },
          );
        }),
      ),
    );
  }
}
