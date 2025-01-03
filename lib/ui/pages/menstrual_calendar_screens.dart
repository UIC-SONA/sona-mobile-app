import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle_calender_view.dart';

import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class MenstrualCalendarScreen extends StatefulWidget {
  const MenstrualCalendarScreen({super.key});

  @override
  State<MenstrualCalendarScreen> createState() => _MenstrualCalendarScreenState();
}

class _MenstrualCalendarScreenState extends FullState<MenstrualCalendarScreen> {
  final _menstrualCycleService = injector.get<MenstrualCycleService>();

  final _calendarController = BasicPeriodCalculatorController();

  var cycleLength = 28;
  var periodLength = 5;

  var _selectedDate = DateTime.now();
  CycleDayType? _selectedDateDayType;

  updateMenstrualData() async {
    await _menstrualCycleService.saveCycleDetails(
      periodDuration: periodLength,
      cycleLength: cycleLength,
    );

    _calendarController.changeData(
      cycleLength: cycleLength,
      periodLength: periodLength,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cycleData = await _menstrualCycleService.getCycleData();
    setState(() {
      cycleLength = cycleData.cycleLength;
      periodLength = cycleData.periodDuration;
    });
    _calendarController.changeData(
      cycleLength: cycleLength,
      periodLength: periodLength,
      pastPeriodDays: cycleData.periodDates,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return SonaScaffold(
      actionButton: SonaActionButton.options(),
      floatingActionButton: FloatingActionButton(
        onPressed: _settingsPeriod,
        child: const Icon(Icons.settings),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: MenstrualCycleCalendarView(
                  controller: _calendarController,
                  themeColor: primaryColor,
                  editPeriodText: "EDITAR",
                  daySelectedColor: Colors.greenAccent,
                  hideInfoView: false,
                  onDataChanged: () {
                    _menstrualCycleService.savePeriodDates(_calendarController.pastPeriodDays);
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
          _buildDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    final formattedDate = DateFormat('MMMM d, y', Localizations.localeOf(context).languageCode).format(_selectedDate);
    final capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capitalizedDate,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            switch (_selectedDateDayType) {
              CycleDayType.ovulationPrediction => const Text('Alta probabilidad de quedarse embarazada'),
              CycleDayType.periodPrediction || CycleDayType.period => const Text('Probabilidad media de quedarse embarazada'),
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
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Actualizar configuración de periodo",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
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
                            // Border color
                            borderRadius: BorderRadius.circular(12),
                            // Rounded corners
                            color: Colors.white, // Background color
                          ),
                          child: DropdownButton<int>(
                            value: cycleLength,
                            items: List<int>.generate(31, (index) => (15 + index)).map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (newValue) async {
                              if (newValue == null) return;
                              setState(() {
                                cycleLength = newValue;
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
                  const SizedBox(
                    height: 10,
                  ),
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
                            value: periodLength,
                            items: List<int>.generate(8, (index) => (2 + index)).map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (newValue) async {
                              if (newValue == null) return;
                              setState(() {
                                periodLength = newValue;
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
