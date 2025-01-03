import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sona/ui/utils/date_time.dart';

const defaultMenstruationColor = Color(0xFFf24187);
const defaultOvulationColor = Color(0xFFff922b);

const defaultFutureMonthCount = 12;
const defaultCycleLength = 28;
const defaultPeriodLength = 5;

enum CycleDayType {
  period,
  periodPrediction,
  ovulationPrediction,
}

List<DateTime> _computeFuturePeriodDays({
  required DateTime? previousPeriodDay,
  required int cycleLength,
  required int periodLength,
  int futureMonthCount = defaultFutureMonthCount,
}) {
  List<DateTime> futurePeriodDays = [];
  if (previousPeriodDay == null) {
    return futurePeriodDays;
  }

  var cycleLength0 = cycleLength - 1;
  var nextPeriodDate = previousPeriodDay.add(Duration(days: cycleLength0));
  for (int index = 0; index < futureMonthCount; index++) {
    for (int i = 1; i <= periodLength; i++) {
      var periodDay = nextPeriodDate.add(Duration(days: i));
      futurePeriodDays.add(periodDay);
    }
    var newDatetime = nextPeriodDate.add(Duration(days: cycleLength0));
    nextPeriodDate = newDatetime;
  }

  return futurePeriodDays;
}

List<DateTime> _computeFutureOvulationDay({
  required DateTime? previousPeriodDay,
  required int cycleLength,
  int futureMonthCount = defaultFutureMonthCount,
}) {
  List<DateTime> futureOvulationDays = [];
  if (previousPeriodDay == null) {
    return futureOvulationDays;
  }

  var nextPeriodDate = previousPeriodDay;
  for (var index = 0; index < futureMonthCount; index++) {
    var ovulationDate = nextPeriodDate.add(Duration(days: cycleLength)).add(const Duration(days: -14));
    futureOvulationDays.add(ovulationDate);
    var newDatetime = nextPeriodDate.add(Duration(days: cycleLength));
    nextPeriodDate = newDatetime;
  }

  return futureOvulationDays;
}

class PerdiodCalculatorResult {
  final DateTime? previousPeriodDay;
  final List<DateTime> pastPeriodDays;
  final List<DateTime> futurePeriodDays;
  final List<DateTime> futureOvulationDays;

  PerdiodCalculatorResult({
    this.previousPeriodDay,
    required this.pastPeriodDays,
    required this.futurePeriodDays,
    required this.futureOvulationDays,
  });

  CycleDayType? getCycleDayType(DateTime day) {
    if (previousPeriodDay == null) {
      return null;
    }

    if (_containsDay(pastPeriodDays, day)) {
      return CycleDayType.period;
    }

    if (_containsDay(futurePeriodDays, day)) {
      return CycleDayType.periodPrediction;
    }

    if (_containsDay(futureOvulationDays, day)) {
      return CycleDayType.ovulationPrediction;
    }

    return null;
  }

  factory PerdiodCalculatorResult.empty() {
    return PerdiodCalculatorResult(
      previousPeriodDay: null,
      pastPeriodDays: [],
      futurePeriodDays: [],
      futureOvulationDays: [],
    );
  }
}

abstract class PeriodCalculatorController extends ChangeNotifier implements ValueListenable<PerdiodCalculatorResult> {
  int _cycleLength;
  int _periodLength;
  int _futureMonthCount;
  List<DateTime> _pastPeriodDays;

  PerdiodCalculatorResult _result = PerdiodCalculatorResult.empty();

  PeriodCalculatorController({
    List<DateTime> pastPeriodDays = const [],
    int cycleLength = defaultCycleLength,
    int periodLength = defaultPeriodLength,
    int futureMonthCount = defaultFutureMonthCount,
  })  : _cycleLength = cycleLength,
        _periodLength = periodLength,
        _pastPeriodDays = pastPeriodDays,
        _futureMonthCount = futureMonthCount {
    calculate();
  }

  int get cycleLength => _cycleLength;

  int get periodLength => _periodLength;

  int get futureMonthCount => _futureMonthCount;

  List<DateTime> get pastPeriodDays => _result.pastPeriodDays;

  DateTime? get previousPeriodDay => _result.previousPeriodDay;

  List<DateTime> get futurePeriodDays => _result.futurePeriodDays;

  List<DateTime> get futureOvulationDays => _result.futureOvulationDays;

  set cycleLength(int value) {
    ifDistingCalculate(_cycleLength, value, () => _cycleLength = value);
  }

  set periodLength(int value) {
    ifDistingCalculate(_periodLength, value, () => _periodLength = value);
  }

  set pastPeriodDays(List<DateTime> value) {
    ifDistingCalculate(_pastPeriodDays, value, () => _pastPeriodDays = value);
  }

  set futureMonthCount(int value) {
    ifDistingCalculate(_futureMonthCount, value, () => _futureMonthCount = value);
  }

  void changeData({
    List<DateTime>? pastPeriodDays,
    int? cycleLength,
    int? periodLength,
    int? futureMonthCount,
  }) {
    _pastPeriodDays = pastPeriodDays ?? _pastPeriodDays;
    _cycleLength = cycleLength ?? _cycleLength;
    _periodLength = periodLength ?? _periodLength;
    _futureMonthCount = futureMonthCount ?? _futureMonthCount;
    calculate();
  }

  void ifDistingCalculate<T>(T oldValue, T newValue, void Function() action) {
    if (oldValue != newValue) {
      action();
      calculate();
    } else {
      if (kDebugMode) {
        print('Not calculating, value did not change');
      }
    }
  }

  void calculate() {
    _result = internalCalculate();
    if (kDebugMode) {
      print('Notifying listeners, result: $_result');
    }
    notifyListeners();
  }

  PerdiodCalculatorResult internalCalculate();

  @override
  PerdiodCalculatorResult get value => _result;
}

class BasicPeriodCalculatorController extends PeriodCalculatorController {
  BasicPeriodCalculatorController({
    super.cycleLength,
    super.periodLength,
    super.pastPeriodDays,
    super.futureMonthCount,
  });

  @override
  PerdiodCalculatorResult internalCalculate() {
    if (_pastPeriodDays.isEmpty) {
      return PerdiodCalculatorResult.empty();
    }

    _pastPeriodDays.sort();

    final previousPeriodDay = _pastPeriodDays.last;

    final futurePeriodDays = _computeFuturePeriodDays(
      previousPeriodDay: previousPeriodDay,
      cycleLength: _cycleLength,
      periodLength: _periodLength,
      futureMonthCount: _futureMonthCount,
    );

    final futureOvulationDays = _computeFutureOvulationDay(
      previousPeriodDay: previousPeriodDay,
      cycleLength: _cycleLength,
      futureMonthCount: _futureMonthCount,
    );

    return PerdiodCalculatorResult(
      previousPeriodDay: previousPeriodDay,
      pastPeriodDays: _pastPeriodDays,
      futurePeriodDays: futurePeriodDays,
      futureOvulationDays: futureOvulationDays,
    );
  }
}

bool _containsDay(List<DateTime> days, DateTime day) {
  return days.any((element) => isSameDay(element, day));
}

class DayTypeWidgetConfiguration {
  final Color iconColor;
  final IconData icon;
  final Color onIconColor;
  final String text;

  const DayTypeWidgetConfiguration({
    required this.iconColor,
    required this.icon,
    required this.onIconColor,
    required this.text,
  });
}

typedef DayTypeWidgetConfigurer = DayTypeWidgetConfiguration Function(CycleDayType dayType);

DayTypeWidgetConfiguration defaultDayTypeWidgetConfigurer(CycleDayType dayType) {
  switch (dayType) {
    case CycleDayType.period:
      return const DayTypeWidgetConfiguration(
        icon: Icons.water_drop_sharp,
        iconColor: defaultMenstruationColor,
        onIconColor: defaultMenstruationColor,
        text: "Período",
      );
    case CycleDayType.periodPrediction:
      return const DayTypeWidgetConfiguration(
        icon: Icons.water_drop_outlined,
        iconColor: defaultMenstruationColor,
        onIconColor: defaultMenstruationColor,
        text: "Predicción de periodo",
      );
    case CycleDayType.ovulationPrediction:
      return const DayTypeWidgetConfiguration(
        icon: Icons.favorite_border,
        iconColor: defaultOvulationColor,
        onIconColor: defaultOvulationColor,
        text: "Predicción de ovulación",
      );
  }
}
