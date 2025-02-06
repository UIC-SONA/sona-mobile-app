import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle_calender_view.dart';

import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

import '../theme/icons.dart';

@RoutePage()
class MenstrualCalendarScreen extends StatefulWidget {
  const MenstrualCalendarScreen({super.key});

  @override
  State<MenstrualCalendarScreen> createState() => _MenstrualCalendarScreenState();
}

class _MenstrualCalendarScreenState extends FullState<MenstrualCalendarScreen> with UserServiceWidgetHelper {
  @override
  final userService = injector.get<UserService>();
  final menstrualCycleService = injector.get<MenstrualCycleService>();
  final calendarController = BasicPeriodCalculatorController();

  var _cycleLength = 28;
  var _periodLength = 5;
  var _selectedDate = DateTime.now();
  CycleDayType? _selectedDateDayType;

  updateMenstrualData() async {
    await menstrualCycleService.saveCycleDetails(
      periodDuration: _periodLength,
      cycleLength: _cycleLength,
    );

    calendarController.changeData(
      cycleLength: _cycleLength,
      periodLength: _periodLength,
    );

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Escucha los cambios en el calendario y programa las notificaciones correspondientes
    calendarController.addListener(() {
      if (kDebugMode) print("Programming schedule notifications");
      CalendarNotificationScheduler.scheduleNotifications(calendarController.value);
    });
    // Cargar los datos iniciales
    _loadData();
  }

  Future<void> _loadData() async {
    final cycleData = await menstrualCycleService.getCycleData();

    // Actualizar el estado
    setState(() {
      _cycleLength = cycleData.cycleLength;
      _periodLength = cycleData.periodDuration;
    });

    // Cambiar los datos del calendario
    calendarController.changeData(
      cycleLength: _cycleLength,
      periodLength: _periodLength,
      pastPeriodDays: cycleData.periodDates,
    );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final profile = userService.currentUser;
    final nextPeriod = calendarController.futurePeriodDays.firstOrNull;
    final locale = Localizations.localeOf(context).languageCode;

    return SonaScaffold(
      actionButton: IconButton(
        icon: Icon(SonaIcons.settings),
        onPressed: _settingsPeriod,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    buildProfilePicture(radius: 35),
                    const SizedBox(width: 10),
                    Text(
                      profile.firstName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildProfileCalendar(nextPeriod),
                      if (nextPeriod != null)
                        Text(
                          "Próximo periodo: ${DateFormat('d MMM', locale).format(nextPeriod)}",
                          style: const TextStyle(
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: MenstrualCycleCalendarView(
                  controller: calendarController,
                  themeColor: primaryColor,
                  editPeriodText: "EDITAR",
                  onDataChanged: () async {
                    await menstrualCycleService.savePeriodDates(calendarController.pastPeriodDays);
                    if (mounted) setState(() {});
                  },
                  onDateSelected: (date, dayType) {
                    setState(() {
                      _selectedDate = date;
                      _selectedDateDayType = dayType;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.height,
            child: _buildDetailsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCalendar(DateTime? nextPeriod) {
    if (calendarController.pastPeriodDays.isEmpty) {
      return Wrap(children: [
        const Text(
          "Sin datos registrados",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.end,
          //softWrap: true,
        ),
      ]);
    }

    final now = DateTime.now();
    int? currentPeriodDay;

    for (var date in calendarController.pastPeriodDays) {
      final difference = now.difference(date).inDays;
      if (difference >= 0 && difference < _periodLength) {
        currentPeriodDay = difference;
        break;
      }
    }

    if (currentPeriodDay != null) {
      return Text(
        "Día ${currentPeriodDay + 1} del periodo",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (nextPeriod == null) {
      return const Text(
        "Sin predicción disponible",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final difference = nextPeriod.difference(now).inDays;
    if (difference < 0) {
      final lastPeriod = calendarController.pastPeriodDays.reduce((a, b) => a.isAfter(b) ? a : b);
      final daysSinceLastPeriod = now.difference(lastPeriod).inDays;
      if (daysSinceLastPeriod > _cycleLength) {
        return Text(
          "${-difference} días de retraso",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
    }

    return Text(
      "Faltan $difference días",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDetailsSection() {
    //
    final formattedDate = DateFormat(
      'MMMM d, y',
      Localizations.localeOf(context).languageCode,
    ).format(_selectedDate);

    final capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capitalizedDate,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            switch (_selectedDateDayType) {
              CycleDayType.ovulationPrediction => const Text('Alta probabilidad de quedarse embarazada'),
              CycleDayType.periodPrediction || CycleDayType.period => const Text('Probabilidad baja de quedarse embarazada'),
              null => const Text('Baja probabilidad de quedarse embarazada'),
            }
          ],
        ),
      ),
    );
  }

  void _settingsPeriod() async {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 150.0,
              margin: const EdgeInsets.all(20),
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => AutoRouter.of(context).push(const MenuOptionsRoute()),
                        icon: Icon(
                          SonaIcons.drop,
                          color: defaultMenstruationColor,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "Actualizar configuración de periodo",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text("Duración del ciclo menstrual"),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 30,
                        width: 70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white, // Background color
                          ),
                          child: DropdownButton<int>(
                            value: _cycleLength,
                            menuMaxHeight: 250,
                            items: List<int>.generate(31, (index) => (15 + index)).map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (newValue) async {
                              if (newValue == null) return;
                              setState(() {
                                _cycleLength = newValue;
                              });
                              updateMenstrualData();
                            },
                            underline: const SizedBox(),
                            isExpanded: true,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Duración del periodo menstrual"),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 30,
                        width: 70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white, // Background color
                          ),
                          child: DropdownButton<int>(
                            value: _periodLength,
                            menuMaxHeight: 250,
                            items: List<int>.generate(8, (index) => (2 + index)).map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (newValue) async {
                              if (newValue == null) return;
                              setState(() {
                                _periodLength = newValue;
                              });
                              updateMenstrualData();
                            },
                            underline: const SizedBox(),
                            isExpanded: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
