import 'dart:async';
import 'dart:math';

import 'package:demo/examples/actualizing/actualizing_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:provider/provider.dart';

class ActualizingExample extends StatelessWidget {
  ActualizingExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  final db = MockDatabase();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => ActualizingListController(db.exampleRecordRepository),
        child: Builder(builder: (context) {
          final listState = context.watch<ActualizingListController>().value;
          return ListView.builder(
            itemCount: listState.records.length,
            itemBuilder: (context, index) {
              final record = listState.records[index];
              return ListTile(
                title: Text(record.title),
                subtitle: Text('weight: ${record.weight}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: () => _createRecord(context, record), icon: const Icon(Icons.new_label)),
                    IconButton(onPressed: () => db.exampleRecordRepository.updateRecord(record.id, title: _randomNoun()), icon: const Icon(Icons.edit)),
                    IconButton(onPressed: () => db.exampleRecordRepository.deleteRecord(record.id), icon: const Icon(Icons.delete)),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
