import 'package:demo/models.dart';
import 'package:demo/widgets/source_button.dart';
import 'package:flutter/material.dart';

class ExampleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExampleAppBar({
    required this.title,
    required this.sources,
    super.key,
  });

  final String title;
  final List<SourceFile> sources;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        SourceButton(sources: sources),
      ],
    );
  }
}
