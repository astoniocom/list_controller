import 'package:flutter/foundation.dart';

class Settings {
  const Settings({
    this.responseDelay = const Duration(milliseconds: 900),
    this.batchSize = 30,
    this.recordsLoadThreshold = 2,
    this.exceptionsToThrow = 0,
  });

  final Duration responseDelay;
  final int batchSize;
  final int recordsLoadThreshold;
  final int exceptionsToThrow;

  Settings copyWith({
    Duration? responseDelay,
    int? batchSize,
    int? recordsLoadThreshold,
    int? exceptionsToThrow,
  }) {
    return Settings(
      responseDelay: responseDelay ?? this.responseDelay,
      batchSize: batchSize ?? this.batchSize,
      recordsLoadThreshold: recordsLoadThreshold ?? this.recordsLoadThreshold,
      exceptionsToThrow: exceptionsToThrow ?? this.exceptionsToThrow,
    );
  }
}

class SettingsController extends ValueNotifier<Settings> with DiagnosticableTreeMixin {
  SettingsController({Settings settings = const Settings()}) : super(settings);

  void setResponseDelay(int responseDelay) => value = value.copyWith(responseDelay: Duration(milliseconds: responseDelay));

  void setBatchSize(int batchSize) => value = value.copyWith(batchSize: batchSize);

  void setRecordsLoadThreshold(int recordsLoadThreshold) => value = value.copyWith(recordsLoadThreshold: recordsLoadThreshold);

  void setExceptionsToRaise(int exceptionsToRaise) => value = value.copyWith(exceptionsToThrow: exceptionsToRaise);

  bool get isRaiseException {
    if (value.exceptionsToThrow > 0) {
      setExceptionsToRaise(value.exceptionsToThrow - 1);
      return true;
    }
    return false;
  }
}
