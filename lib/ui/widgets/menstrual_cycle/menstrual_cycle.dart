import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sona/local_notifications.dart';
import 'package:sona/ui/utils/date_time.dart';
import 'package:timezone/timezone.dart' as tz;

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

class PeriodCalculatorResult {
  final DateTime? previousPeriodDay;
  final List<DateTime> pastPeriodDays;
  final List<DateTime> futurePeriodDays;
  final List<DateTime> futureOvulationDays;

  PeriodCalculatorResult({
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

  factory PeriodCalculatorResult.empty() {
    return PeriodCalculatorResult(
      previousPeriodDay: null,
      pastPeriodDays: [],
      futurePeriodDays: [],
      futureOvulationDays: [],
    );
  }
}

abstract class PeriodCalculatorController extends ChangeNotifier implements ValueListenable<PeriodCalculatorResult> {
  int _cycleLength;
  int _periodLength;
  int _futureMonthCount;
  List<DateTime> _pastPeriodDays;

  PeriodCalculatorResult _result = PeriodCalculatorResult.empty();

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
    _updateValueIfChanged(_cycleLength, value, () => _cycleLength = value);
  }

  set periodLength(int value) {
    _updateValueIfChanged(_periodLength, value, () => _periodLength = value);
  }

  set pastPeriodDays(List<DateTime> value) {
    _updateValueIfChanged(_pastPeriodDays, value, () => _pastPeriodDays = value);
  }

  set futureMonthCount(int value) {
    _updateValueIfChanged(_futureMonthCount, value, () => _futureMonthCount = value);
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

  void _updateValueIfChanged<T>(T oldValue, T newValue, void Function() action) {
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

  PeriodCalculatorResult internalCalculate();

  @override
  PeriodCalculatorResult get value => _result;
}

class BasicPeriodCalculatorController extends PeriodCalculatorController {
  //
  BasicPeriodCalculatorController({
    super.cycleLength,
    super.periodLength,
    super.pastPeriodDays,
    super.futureMonthCount,
  });

  @override
  PeriodCalculatorResult internalCalculate() {
    if (_pastPeriodDays.isEmpty) {
      return PeriodCalculatorResult.empty();
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

    return PeriodCalculatorResult(
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

DateTime? getNextClosestDate(List<DateTime> dates, DateTime currentDateTime) {
  // Filtramos las fechas que son posteriores a la fecha actual
  final futureDates = dates.where((date) => date.isAfter(currentDateTime)).toList();
  // Si no hay fechas futuras, retornamos null
  if (futureDates.isEmpty) return null;
  // Si hay fechas futuras, encontramos la más cercana
  futureDates.sort((a, b) => a.compareTo(b)); // Ordenamos las fechas de menor a mayor
  // Retornamos la primera fecha (la más cercana)
  return futureDates.first;
}

class NotificationScheduler {
  //
  static Future<void> clear() async {
    await LocalNotifications.cancelMultiple([1, 2, 3, 4]);
  }

  static Future<void> scheduleNotifications(PeriodCalculatorResult result) async {
    final currentDateTime = DateTime.now(); // Guardamos la fecha y hora actuales
    // Cancelar todas las notificaciones existentes antes de programar nuevas
    await clear();
    // Si no hay datos registrados, programa notificaciones periódicas
    if (result.pastPeriodDays.isEmpty) {
      await LocalNotifications.periodicallyShow(
        1,
        title: 'Registro del período pendiente',
        body: '¿Olvidaste registrar tu período? Te recordamos que tienes que registrarlo.',
        payload: 'register_period',
        repeatInterval: RepeatInterval.daily,
      );
      return;
    }
    // Si hay datos registrados, cancelar la notificación periódica
    await LocalNotifications.cancel(1);
    // Obtener el próximo día del período más cercano que sea futuro
    final nextPeriodDay = getNextClosestDate(result.futurePeriodDays, currentDateTime);
    // Obtener el próximo día de ovulación más cercano que sea futuro
    final nextOvulationDay = getNextClosestDate(result.futureOvulationDays, currentDateTime);
    // Programar notificación para el próximo período, si existe
    if (nextPeriodDay != null) {
      await LocalNotifications.zonedSchedule(
        2,
        title: 'Predicción: Inicio de tu período',
        body: 'Tu período está predicho para comenzar hoy. ¡Recuerda tomar las precauciones necesarias!',
        payload: 'period_start',
        scheduledDate: tz.TZDateTime.from(nextPeriodDay, tz.local),
      );
      // Programar notificación de recordatorio unos días antes del período
      final reminderDaysBefore = 3; // Puedes ajustar este número según lo necesario
      final reminderDate = nextPeriodDay.subtract(Duration(days: reminderDaysBefore));
      if (reminderDate.isAfter(currentDateTime)) {
        await LocalNotifications.zonedSchedule(
          3,
          title: 'Se acerca tu período',
          body: 'Según nuestro cálculo, tu período comenzará en $reminderDaysBefore días. Te notificaremos cuando inicie.',
          payload: 'period_coming_soon',
          scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
        );
      }
    }
    // Programar notificación de ovulación, si existe
    if (nextOvulationDay != null) {
      await LocalNotifications.zonedSchedule(
        4,
        title: 'Tu ovulación está cerca',
        body: 'Recuerda que estás en tus días fértiles. ¡La ovulación está prevista para el ${nextOvulationDay.day}/${nextOvulationDay.month}!',
        payload: 'ovulation',
        scheduledDate: tz.TZDateTime.from(nextOvulationDay, tz.local),
      );
    }
  }
}
