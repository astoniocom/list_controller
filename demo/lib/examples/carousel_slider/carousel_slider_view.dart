import 'package:carousel_slider/carousel_slider.dart';
import 'package:demo/examples/carousel_slider/carousel_slider_controller.dart';
import 'package:demo/models.dart';
import 'package:demo/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:list_controller/list_controller.dart';
import 'package:provider/provider.dart';

class CarouselSliderExample extends StatelessWidget {
  const CarouselSliderExample({required this.title, required this.sources, super.key});

  final String title;
  final List<SourceFile> sources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(title: title, sources: sources),
      body: ChangeNotifierProvider(
        create: (context) => CarouselSliderController(),
        child: LayoutBuilder(builder: (context, constrains) {
          final listState = context.watch<CarouselSliderController>().value;

          return Center(
            child: CarouselSlider.builder(
              options: CarouselOptions(
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                height: constrains.maxHeight - 64,
                onPageChanged: (index, reason) {
                  if (index == listState.records.length - 1) {
                    context.read<CarouselSliderController>().loadNextPage();
                  }
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return CarouselCard(
                    child: (realIndex == listState.records.length && listState.stage == ListStage.loading())
                        ? const CircularProgressIndicator()
                        : Text(
                            listState.records[realIndex].toString(),
                            style: const TextStyle(fontSize: 128),
                          ));
              },
              itemCount: listState.records.length + (listState.stage == ListStage.loading() ? 1 : 0),
            ),
          );
        }),
      ),
    );
  }
}

class CarouselCard extends StatelessWidget {
  const CarouselCard({
    required this.child,
    super.key,
  }) : super();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(16)), alignment: Alignment.center, child: child);
  }
}
