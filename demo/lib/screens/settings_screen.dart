import 'package:demo/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const responseSliderKey = Key('ResponseSlider');
  static const batchSizeSliderKey = Key('BatchSizeSlider');
  static const loadThresholdSliderKey = Key('LoadThresholdSlider');
  static const exceptionsToThrowSliderKey = Key('ExceptionsToThrowSlider');

  static Future<void> open({required BuildContext context, required SettingsController settings}) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ChangeNotifierProvider.value(value: settings, child: const SettingsScreen());
    }));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Response delay: ${settings.value.responseDelay.inMilliseconds}ms'),
              Slider(
                key: responseSliderKey,
                value: settings.value.responseDelay.inMilliseconds.toDouble(),
                max: 20000,
                onChanged: (value) => settings.setResponseDelay(value.round()),
              ),
              Text('Batch size: ${settings.value.batchSize}'),
              Slider(
                key: batchSizeSliderKey,
                value: settings.value.batchSize.toDouble(),
                max: 500,
                onChanged: (value) => settings.setBatchSize(value.round()),
              ),
              Text('Records load threshold: ${settings.value.recordsLoadThreshold}'),
              Slider(
                key: loadThresholdSliderKey,
                value: settings.value.recordsLoadThreshold.toDouble(),
                max: 20,
                onChanged: (value) => settings.setRecordsLoadThreshold(value.toInt()),
              ),
              Text('Exceptions to throw: ${settings.value.exceptionsToThrow}'),
              Slider(
                key: exceptionsToThrowSliderKey,
                value: settings.value.exceptionsToThrow.toDouble(),
                max: 10,
                onChanged: (value) => settings.setExceptionsToRaise(value.round()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
