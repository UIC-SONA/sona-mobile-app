import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sona/application/common/http/http.dart';
import 'package:sona/application/common/security/storage.dart';
import 'package:sona/application/common/utils/extensions.dart';
import 'package:sona/application/common/utils/full_state_widget.dart';
import 'package:sona/application/common/utils/scaffold_messenger.dart';
import 'package:sona/application/widgets/sona_scaffold.dart';
import 'package:sona/features/menstrualcalendar/models/models.dart';
import 'package:sona/features/menstrualcalendar/services/menstrual_calendar_service.dart' as service;
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MenstrualCalendar extends StatefulWidget {
  const MenstrualCalendar({super.key});

  @override
  State<MenstrualCalendar> createState() => _MenstrualCalendarState();
}

class _MenstrualCalendarState extends FullState<MenstrualCalendar> {
  MenstrualCycle? _menstrualCycle;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cycle = await storage.read(key: 'cycle');
    if (cycle != null) {
      _menstrualCycle = MenstrualCycle.fromJson(jsonDecode(cycle));
      refresh();
    } else {
      await _showDialogsSetData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return SonaScaffold(
      actionButton: SonaActionButton.options(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const Text(
            'Mi Calendario Menstrual',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_menstrualCycle != null)
            Expanded(
              child: SfCalendar(
                headerStyle: CalendarHeaderStyle(
                  backgroundColor: primaryColor,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                view: CalendarView.month,
                dataSource: MeetingDataSource(_getDataSource()),
                monthViewSettings: const MonthViewSettings(showAgenda: true),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSettingsDialog,
        child: const Icon(Icons.settings),
      ),
    );
  }

  Future<void> _showDialogsSetData() async {
    final periodDuration = await _showIntInputDialog('¿Cuántos días dura tu periodo?', 'El periodo de sangrado en promedio dura de 3 a 7 días');
    if (periodDuration == null) {
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final cycleDuration = await _showIntInputDialog('¿Cuántos días dura tu ciclo?', 'El ciclo menstrual en promedio dura de 23 a 35 días');
    if (cycleDuration == null) {
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final lastPeriodDate = await _showDateInputDialog('¿Cuándo fue la fecha de inicio de tu último periodo?');
    if (lastPeriodDate == null) {
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    _menstrualCycle = MenstrualCycle(periodDuration: periodDuration, cycleDuration: cycleDuration, lastPeriodDate: lastPeriodDate);

    await storage.write(
      key: 'cycle',
      value: jsonEncode(_menstrualCycle!.toJson()),
    );

    refresh();
  }

  Future<int?> _showIntInputDialog(String title, String caption) async {
    int? value;
    bool isValid = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(caption, textAlign: TextAlign.center),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "Días"),
                      onChanged: (text) {
                        setState(() {
                          value = int.tryParse(text);
                          isValid = value != null && value! > 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: isValid ? () => Navigator.of(context).pop() : null,
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
    return value;
  }

  Future<DateTime?> _showDateInputDialog(String title) async {
    DateTime? selectedDate;

    await showDialog(
      context: context,
      barrierDismissible: false, // Hace el diálogo bloqueante
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(selectedDate != null ? 'Fecha seleccionada: ${selectedDate!.format(DateTimeFormat.date)}' : 'Selecciona una fecha'),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                      child: Text(selectedDate != null ? 'Cambiar fecha' : 'Seleccionar fecha'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: selectedDate != null ? () => Navigator.of(context).pop() : null,
                  child: const Text('Aceptar'), // Deshabilita el botón si no se ha seleccionado una fecha válida
                ),
              ],
            );
          },
        );
      },
    );

    return selectedDate;
  }

  Future<void> _showSettingsDialog() async {
    bool isLoading = false;
    String loadingAction = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> runAction(Future<void> Function() action, String actionName) async {
              setState(() {
                isLoading = true;
                loadingAction = actionName;
              });

              await action();

              setState(() {
                isLoading = false;
                loadingAction = '';
              });
            }

            return AlertDialog(
              title: const Text('Configuración'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: isLoading && loadingAction == 'save' ? const CircularProgressIndicator() : const Icon(Icons.cloud_upload),
                    title: const Text('Guardar datos'),
                    onTap: isLoading ? null : () => runAction(_saveCycle, 'save'),
                  ),
                  ListTile(
                    leading: isLoading && loadingAction == 'load' ? const CircularProgressIndicator() : const Icon(Icons.cloud_download),
                    title: const Text('Obtener datos guardados'),
                    onTap: isLoading ? null : () => runAction(_loadCycle, 'load'),
                  ),
                  ListTile(
                    leading: isLoading && loadingAction == 'reset' ? const CircularProgressIndicator() : const Icon(Icons.restart_alt),
                    title: const Text('Reiniciar calendario'),
                    onTap: isLoading ? null : () => runAction(_resetCycleLocal, 'reset'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveCycle() async {
    try {
      await service.saveCycle(_menstrualCycle!);
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnackBarSuccess(context, 'Datos guardados');
    } on HttpException catch (e) {
      if (mounted) showSnackBarErrorFromHttpException(context, e);
    }
  }

  Future<void> _loadCycle() async {
    try {
      final cycle = await service.getCycle();
      _menstrualCycle = cycle;
      await storage.write(
        key: 'cycle',
        value: jsonEncode(cycle.toJson()),
      );
      refresh();
      if (mounted) Navigator.of(context).pop();
    } on HttpException catch (e) {
      if (mounted) showSnackBarErrorFromHttpException(context, e);
    }
  }

  Future<void> _resetCycleLocal() async {
    await storage.delete(key: 'cycle');
    _menstrualCycle = null;
    refresh();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  List<Meeting> _getDataSource() {
    final primaryColor = Theme.of(context).primaryColor;
    final List<Meeting> meetings = <Meeting>[];

    final periodDuration = _menstrualCycle!.periodDuration;
    final cycleDuration = _menstrualCycle!.cycleDuration;
    final lastPeriodDate = _menstrualCycle!.lastPeriodDate;

    DateTime startTime = lastPeriodDate;
    for (int i = 0; i < 12; i++) {
      // Calcula el final del periodo actual
      DateTime endTime = startTime.add(Duration(days: periodDuration));
      meetings.add(Meeting('Periodo', startTime, endTime, primaryColor, false));

      // Calcula la fecha de inicio del siguiente ciclo
      DateTime nextCycleStart = startTime.add(Duration(days: cycleDuration));

      // Calcula la ovulación como 14 días antes del siguiente ciclo
      DateTime ovulationDate = nextCycleStart.subtract(const Duration(days: 14));
      meetings.add(Meeting('Ovulación', ovulationDate, ovulationDate.add(const Duration(hours: 24)), Colors.pink, false));

      // Actualiza el inicio del ciclo actual al inicio del siguiente ciclo
      startTime = nextCycleStart;
    }

    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => _getMeetingData(index).from;

  @override
  DateTime getEndTime(int index) => _getMeetingData(index).to;

  @override
  String getSubject(int index) => _getMeetingData(index).eventName;

  @override
  Color getColor(int index) => _getMeetingData(index).background;

  @override
  bool isAllDay(int index) => _getMeetingData(index).isAllDay;

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    return meeting is Meeting ? meeting : Meeting('', DateTime.now(), DateTime.now(), Colors.transparent, false);
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
