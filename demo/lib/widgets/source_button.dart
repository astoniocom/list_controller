import 'package:demo/models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SourceButton extends StatelessWidget {
  const SourceButton({required this.sources, super.key}) : super();

  final List<SourceFile> sources;

  @override
  Widget build(BuildContext context) {
    if (sources.length == 1) {
      final router = GoRouter.of(context);
      return IconButton(onPressed: () => context.go('${router.location}/code/${sources.first.slug}'), icon: const Icon(Icons.code));
    } else if (sources.isNotEmpty) {
      final router = GoRouter.of(context);
      const BoxConstraints unadjustedConstraints = BoxConstraints(
        minWidth: kMinInteractiveDimension,
        minHeight: kMinInteractiveDimension,
      );
      final ThemeData theme = Theme.of(context);
      final BoxConstraints adjustedConstraints = theme.visualDensity.effectiveConstraints(unadjustedConstraints);

      return ConstrainedBox(
        constraints: adjustedConstraints,
        child: PopupMenuButton<String>(
          onSelected: (slug) => context.go('${router.location}/code/$slug'),
          itemBuilder: (context) => sources
              .map((e) => PopupMenuItem<String>(
                    value: e.slug,
                    child: Text(e.title),
                  ))
              .toList(),
          child: const Icon(Icons.code),
        ),
      );
    }
    return Container();
  }
}
