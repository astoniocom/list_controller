import 'package:flutter/material.dart';
import 'package:widget_with_codeview/widget_with_codeview.dart';

class CodeViewScreen extends StatelessWidget {
  const CodeViewScreen({required this.filePath, super.key});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code'),
      ),
      body: SourceCodeView(
        filePath: filePath,
        codeLinkPrefix: 'https://github.com/astoniocom/list_controller',
      ),
    );
  }
}
