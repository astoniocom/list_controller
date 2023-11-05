// Idea taken from https://stackoverflow.com/questions/60074466/pagination-infinite-scrolling-in-flutter-with-caching-and-realtime-invalidatio
import 'dart:math';

import 'package:demo/examples/hot_huge_list/hot_huge_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HotHugeListExample extends StatefulWidget {
  const HotHugeListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  State<HotHugeListExample> createState() => _HotHugeListExampleState();
}

class _HotHugeListExampleState extends State<HotHugeListExample> {
  bool _frameCallbackInProgress = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => MockDatabase(recodsNum: totalRecords)),
        ChangeNotifierProvider(create: (context) => HotHugeListController(repository: context.read<MockDatabase>().exampleRecordRepository)),
      ],
      child: Scaffold(
        appBar: ExampleAppBar(title: widget.title, sources: widget.sources),
        body: Builder(builder: (context) {
          final listState = context.watch<HotHugeListController>().value;
          final listController = context.read<HotHugeListController>();
          if (listState.recordsCount == 0) return const Center(child: CircularProgressIndicator());

          return Scrollbar(
            thumbVisibility: true,
            interactive: true,
            child: ListView.builder(
              itemCount: listState.recordsCount,
              physics: const _MaxVelocityPhysics(velocityThreshold: 128),
              itemBuilder: (context, index) {
                final page = index ~/ pageSize;
                final pageResult = listState.pages[page];
                final record = pageResult?.elementAt(index % pageSize);
                if (record != null) {
                  return ListTile(
                    title: Text(record.title),
                    subtitle: Text('weight: ${record.weight}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final newTitle = nouns[Random().nextInt(nouns.length)];
                        await context.read<MockDatabase>().exampleRecordRepository.updateRecord(record.id, title: newTitle);
                      },
                    ),
                  );
                }

                if (!Scrollable.recommendDeferredLoadingForContext(context)) {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) => listController.loadPage(page));
                } else if (!_frameCallbackInProgress) {
                  _frameCallbackInProgress = true;
                  SchedulerBinding.instance.scheduleFrameCallback((d) => _deferredReload(context));
                }
                return SizedBox(
                  key: ValueKey('Shimmer $index'),
                  height: 64,
                  child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.primary,
                    highlightColor: Colors.yellow,
                    child: const Text('Loading...'),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  void _deferredReload(BuildContext context) {
    if (!Scrollable.recommendDeferredLoadingForContext(context)) {
      _frameCallbackInProgress = false;
      if (mounted) setState(() {});
    } else {
      SchedulerBinding.instance.scheduleFrameCallback((d) => _deferredReload(context), rescheduling: true);
    }
  }
}

class _MaxVelocityPhysics extends AlwaysScrollableScrollPhysics {
  const _MaxVelocityPhysics({required this.velocityThreshold, super.parent}) : super();

  final double velocityThreshold;

  @override
  bool recommendDeferredLoading(double velocity, ScrollMetrics metrics, BuildContext context) {
    return velocity.abs() > velocityThreshold;
  }

  @override
  _MaxVelocityPhysics applyTo(ScrollPhysics? ancestor) {
    return _MaxVelocityPhysics(velocityThreshold: velocityThreshold, parent: buildParent(ancestor));
  }
}
