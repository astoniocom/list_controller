import 'dart:math';

import 'package:bidirectional_listview/bidirectional_listview.dart';
import 'package:demo/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_bloc.dart';
import 'package:demo/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_state.dart';
import 'package:demo/models.dart';
import 'package:demo/screens/record_edit_screen.dart';
import 'package:demo/settings.dart';
import 'package:demo/widgets/list_status_indicator.dart';
import 'package:demo/widgets/record_teaser.dart';
import 'package:demo/widgets/search_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_controller/list_controller.dart';
import 'package:mock_datasource/mock_datasource.dart';
import 'package:provider/provider.dart';

const kRecordTeaserHeight = 72.0;

class ComplexBidirectionalBlocListExample extends StatelessWidget {
  const ComplexBidirectionalBlocListExample({
    required this.title,
    required this.sources,
    this.storeSize,
    super.key,
  });

  final String title;
  final List<SourceFile> sources;
  final int? storeSize;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => MockDatabase()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => BidirectionalScrollController()),
      ],
      child: LayoutBuilder(builder: (context, constraints) {
        final settingsController = context.watch<SettingsController>();
        final scrollController = context.read<BidirectionalScrollController>();

        return BlocProvider<BidirectionalListBloc>(
            key: ValueKey(Object.hash(settingsController.value.batchSize, settingsController.value.recordsLoadThreshold)),
            create: (context) => BidirectionalListBloc(
                  storeSize: storeSize != null
                      ? [
                          settingsController.value.batchSize * 2, // cache can not be less that 2x of batch size
                          ((constraints.maxHeight ~/ kRecordTeaserHeight) + 5 + settingsController.value.recordsLoadThreshold) *
                              2, // cache can not be less that number of items on screen
                          storeSize!,
                        ].reduce(max)
                      : null,
                  settings: settingsController,
                  firstForwardWeight: 501,
                  query: const ExampleRecordQuery(),
                  repository: context.read<MockDatabase>().exampleRecordRepository,
                ),
            child: Builder(
              builder: (context) {
                final listBloc = context.read<BidirectionalListBloc>();
                return BlocConsumer<BidirectionalListBloc, BidirectionalListState<ExampleRecord, ExampleRecordQuery>>(listener: (context, state) {
                  _updateScrollExtent(controller: scrollController, listState: state, listTileHeight: kRecordTeaserHeight);
                }, builder: (context, listState) {
                  final backwardItemCount = -listState.recordsOffset + (ListStatusIndicator.canRepresentState(listState.backwardMeta) ? 1 : 0);
                  final forwardItemCount =
                      listState.recordsOffset + listState.listLength + (ListStatusIndicator.canRepresentState(listState.forwardMeta) ? 1 : 0);
                  return Scaffold(
                    appBar: ComplexExampleAppBar(
                      title: title,
                      sources: sources,
                      query: listState.query.contains ?? '',
                      onChanged: (searchQuery) {
                        listBloc.add(ResetEvent<ExampleRecordQuery>(query: ExampleRecordQuery(contains: searchQuery)));
                      },
                    ),
                    body: CupertinoScrollbar(
                      controller: scrollController,
                      child: BidirectionalListView.builder(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        // physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final realIndex = index - listState.recordsOffset;

                          if (realIndex == -1 && ListStatusIndicator.canRepresentState(listState.backwardMeta)) {
                            return ListStatusIndicator(
                              listState: listState.backwardMeta,
                              onRepeat: () => listBloc.add(const RepeatQueryEvent(loadingKey: BidirectionalListBloc.backwardLoadingKey)),
                            );
                          } else if (index == listState.recordsOffset + listState.listLength && ListStatusIndicator.canRepresentState(listState.forwardMeta)) {
                            return ListStatusIndicator(
                              listState: listState.forwardMeta,
                              onRepeat: () => listBloc.add(const RepeatQueryEvent(loadingKey: BidirectionalListBloc.forwardLoadingKey)),
                            );
                          }

                          _requestRecord(
                            index: index,
                            bloc: listBloc,
                            listState: listState,
                            recordsLoadThreshold: settingsController.value.recordsLoadThreshold,
                            scrollController: scrollController,
                          );

                          if (realIndex < listState.records.length && realIndex >= 0) {
                            return RecordTeaser(
                              listState.records[realIndex],
                              height: kRecordTeaserHeight,
                            );
                          } else {
                            // We need it because
                            // - negativeItemCount and itemCount cannot have a negative values
                            // and BidirectionalListView build the items despite they are out of visible extents;
                            // - items may disappear from the screen when the cache becomes invalid.
                            return SizedBox(
                                height: kRecordTeaserHeight,
                                child: ListTile(title: const Text('Wait...'), subtitle: Text('Index $index; Real index $realIndex;')));
                          }
                        },
                        negativeItemCount: backwardItemCount,
                        itemCount: forwardItemCount,
                      ),
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () async => RecordEditScreen.open(
                        context: context,
                        db: context.read<MockDatabase>(),
                        settings: context.read<SettingsController>(),
                      ),
                      tooltip: 'Create record',
                      child: const Icon(Icons.add),
                    ),
                  );
                });
              },
            ));
      }),
    );
  }
}

void _requestRecord({
  required int index,
  required BidirectionalListBloc bloc,
  required BidirectionalListState<ExampleRecord, ExampleRecordQuery> listState,
  required int recordsLoadThreshold,
  required BidirectionalScrollController scrollController,
}) {
  if (index == -1) {
    // For some reason BidirectionalListView is requesting building of this element unpredictably
    return;
  }
  if (index < listState.recordsOffset + recordsLoadThreshold) {
    bloc.add(const LoadNextPageDirectedEvent(loadingKey: BidirectionalListBloc.backwardLoadingKey));
  } else if (index >= listState.recordsOffset + listState.listLength - recordsLoadThreshold) {
    bloc.add(const LoadNextPageDirectedEvent(loadingKey: BidirectionalListBloc.forwardLoadingKey));
  }
}

void _updateScrollExtent({
  required BidirectionalScrollController controller,
  required BidirectionalListStateEx listState,
  required double listTileHeight,
}) {
  if (!controller.position.hasContentDimensions) return;

  final viewport = controller.position.viewportDimension;

  final minExtent = (listState.recordsOffset - (ListStatusIndicator.canRepresentState(listState.backwardMeta) ? 1 : 0)) * listTileHeight;
  final needMaxExtent =
      (listState.recordsOffset + listState.listLength + (ListStatusIndicator.canRepresentState(listState.forwardMeta) ? 1 : 0)) * listTileHeight;
  final maxExtent = needMaxExtent - viewport > minExtent ? needMaxExtent - viewport : minExtent;

  (controller.position as BidirectionalScrollPosition).setMinMaxExtent(minExtent, maxExtent);
}
