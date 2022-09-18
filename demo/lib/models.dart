import 'package:flutter/material.dart';

class SourceFile {
  const SourceFile({
    required this.title,
    required this.codeFile,
  });

  final String title;
  final String codeFile;

  String get slug => title.toLowerCase().replaceAll(' ', '-');
}

class Example {
  const Example({
    required this.builder,
    required this.description,
    required this.usedFeatures,
    required this.title,
    required this.slug,
    required this.sources,
  });

  final Widget Function(Example, BuildContext context) builder;
  final String description;
  final List<String> usedFeatures;
  final String title;
  final String slug;
  final List<SourceFile> sources;
}
