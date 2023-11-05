import 'dart:async';
import 'dart:math';
import 'package:demo/settings.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mock_datasource/mock_datasource.dart';

class RecordEditScreen extends StatefulWidget {
  const RecordEditScreen({
    required this.db,
    required this.settings,
    this.displayColor = false,
    this.record,
    super.key,
  });

  final MockDatabase db;
  final SettingsController settings;
  final ExampleRecord? record;
  final bool displayColor;

  static const formKey = GlobalObjectKey<FormState>('editRecordForm');
  static const autogenTitleBtnKey = Key('autogenTitleBtnKey');
  static const titleFieldKey = Key('titleField');
  static const weightFieldKey = Key('weightField');
  static const submitBtnKey = Key('editRecordSubmit');
  static const recordDeosNotExistSnackbarKey = Key('recordDeosNotExistSnackbar');
  static const weightNotUniqueSnackbarKey = Key('weightNotUniqueSnackbar');

  static Future<void> open({
    required BuildContext context,
    required MockDatabase db,
    required SettingsController settings,
    ExampleRecord? record,
    bool displayColor = false,
  }) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RecordEditScreen(record: record, db: db, settings: settings, displayColor: displayColor);
    }));
  }

  @override
  State<RecordEditScreen> createState() => _RecordEditScreenState();
}

class _RecordEditScreenState extends State<RecordEditScreen> {
  bool get isEdit => widget.record != null;
  final _titleController = TextEditingController();
  final _weightController = TextEditingController();
  int? _brandColor;

  @override
  void initState() {
    if (isEdit) {
      _titleController.text = widget.record!.title;
      _weightController.text = widget.record!.weight.toString();
      _brandColor = widget.record?.colorId;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    return null;
  }

  Future<void> _submit(NavigatorState navigator) async {
    try {
      if (!isEdit) {
        await widget.db.exampleRecordRepository.createRecord(
          title: _titleController.text,
          weight: int.parse(_weightController.text),
          raiseException: widget.settings.isRaiseException,
          colorId: _brandColor,
        );
      } else {
        try {
          await widget.db.exampleRecordRepository.updateRecord(
            widget.record!.id,
            title: _titleController.text,
            weight: int.parse(_weightController.text),
            raiseException: widget.settings.isRaiseException,
            colorId: () => _brandColor,
          );
        } on RecordDoesNotExist {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            key: RecordEditScreen.recordDeosNotExistSnackbarKey,
            content: Text('Record does not exist'),
          ));
        }
      }
      navigator.pop();
    } on WeightDuplicate {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        key: RecordEditScreen.weightNotUniqueSnackbarKey,
        content: Text('Weight must be unique'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isEdit ? Text('Edit Record ${widget.record!.id}') : const Text('Create Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: RecordEditScreen.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                key: RecordEditScreen.titleFieldKey,
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: 'Title',
                    suffixIcon: IconButton(
                      key: RecordEditScreen.autogenTitleBtnKey,
                      icon: const Icon(
                        Icons.auto_awesome,
                        semanticLabel: 'Autogenerate title',
                      ),
                      onPressed: () => _titleController.text = nouns[Random().nextInt(nouns.length)],
                    )),
                validator: _requiredValidator,
              ),
              TextFormField(
                key: RecordEditScreen.weightFieldKey,
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[\-0-9]'))],
                maxLength: 6,
                validator: _requiredValidator,
              ),
              if (widget.displayColor)
                DropdownButton<int?>(
                  value: _brandColor,
                  items: widget.db.brandColorRepository.store
                      .map((e) => DropdownMenuItem(
                            value: e.id,
                            child: Container(width: 160, height: 42, color: Color(e.color).withOpacity(1)),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    _brandColor = value;
                  }),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  key: RecordEditScreen.submitBtnKey,
                  onPressed: () async {
                    if (!RecordEditScreen.formKey.currentState!.validate()) return;
                    await _submit(Navigator.of(context));
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
