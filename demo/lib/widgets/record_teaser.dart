import 'dart:async';
import 'dart:math';

import 'package:demo/screens/record_edit_screen.dart';
import 'package:demo/settings.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_datasource/mock_datasource.dart';

class RecordTeaser extends StatelessWidget {
  const RecordTeaser(this.record, {this.height, super.key});

  final ExampleRecord record;
  final double? height;

  Future<void> _deleteRecord(BuildContext context, ID pk) async {
    try {
      await context.read<MockDatabase>().exampleRecordRepository.deleteRecord(
            pk,
            raiseException: context.read<SettingsController>().isRaiseException,
          );
    } on RecordDoesNotExist {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record does not exist')));
    }
  }

  String _randomNoun() => nouns[Random().nextInt(nouns.length)];

  @override
  Widget build(BuildContext context) {
    final db = context.read<MockDatabase>();
    Widget result = ListTile(
      onTap: () async => RecordEditScreen.open(
        context: context,
        record: record,
        displayColor: record is ExpandedExampleRecord,
        db: context.read<MockDatabase>(),
        settings: context.read<SettingsController>(),
      ),
      title: Text(
        record.title,
        style: record is ExpandedExampleRecord && (record as ExpandedExampleRecord).color != null
            ? TextStyle(color: Color((record as ExpandedExampleRecord).color!.color).withOpacity(1))
            : null,
      ),
      subtitle: Text('weight: ${record.weight}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () async => db.exampleRecordRepository.updateRecord(record.id, title: _randomNoun()), icon: const Icon(Icons.edit_outlined)),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async => _deleteRecord(context, record.id),
          ),
        ],
      ),
    );
    if (height != null) {
      result = SizedBox(height: height, child: result);
    }
    return result;
  }
}
