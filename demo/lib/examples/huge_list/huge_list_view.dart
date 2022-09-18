/// Idea taken from https://stackoverflow.com/questions/60074466/pagination-infinite-scrolling-in-flutter-with-caching-and-realtime-invalidatio

import 'package:demo/examples/huge_list/huge_list_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HugeListExample extends StatefulWidget {
  const HugeListExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  static const filteringCheckboxKey = Key('filteringCheckbox');
  static const sortingCheckboxKey = Key('sortingCheckbox');

  @override
  State<HugeListExample> createState() => _HugeListExampleState();
}

class _HugeListExampleState extends State<HugeListExample> {
  bool _frameCallbackInProgress = false;
  static const itemHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: widget.title, sources: widget.sources),
      body: ChangeNotifierProvider(
        create: (context) => HugeListController(),
        child: Builder(builder: (context) {
          final listState = context.watch<HugeListController>().value;
          final listController = context.read<HugeListController>();
          if (listState.recordsCount == 0) return const Center(child: CircularProgressIndicator());

          return Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    key: HugeListExample.filteringCheckboxKey,
                    value: listState.query.filtering,
                    onChanged: (value) {
                      listController.setNewQuery(listState.query.copyWith(filtering: value));
                    },
                  ),
                  const Text('Filtering'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    key: HugeListExample.sortingCheckboxKey,
                    value: listState.query.sorting,
                    onChanged: (value) {
                      listController.setNewQuery(listState.query.copyWith(sorting: value));
                    },
                  ),
                  const Text('Sorting'),
                ],
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  interactive: true,
                  child: ListView.builder(
                    itemCount: listState.recordsCount,
                    physics: const _MaxVelocityPhysics(velocityThreshold: 128),
                    itemBuilder: (context, index) {
                      final page = index ~/ pageSize;
                      final pageResult = listState.records[page];
                      final value = pageResult?.elementAt(index % pageSize);
                      if (value != null) {
                        return ListTile(title: Text('Item $value'));
                      }

                      if (!Scrollable.recommendDeferredLoadingForContext(context)) {
                        SchedulerBinding.instance.addPostFrameCallback((timeStamp) => listController.loadPage(page));
                      } else if (!_frameCallbackInProgress) {
                        _frameCallbackInProgress = true;
                        SchedulerBinding.instance.scheduleFrameCallback((d) => _deferredReload(context));
                      }
                      return SizedBox(
                        key: ValueKey('Shimmer $index'),
                        height: itemHeight,
                        child: Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.primary,
                          highlightColor: Colors.yellow,
                          child: const Text('Loading...'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
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
